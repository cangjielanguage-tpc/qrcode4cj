/*
 * Copyright 2021 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package zxing.code.datamatrix.encoder

import zxing.code.common.MinimalECIInput
import zxing.code.common.MyCharset
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion

/**
 * Encoder that encodes minimally
 *
 * Algorithm:
 *
 * Uses Dijkstra to produce mathematically minimal encodings that are in some cases smaller than the results produced
 * by the algorithm described in annex S in the specification ISO/IEC 16022:200(E). The biggest improvment of this
 * algorithm over that one is the case when the algorithm enters the most inefficient mode, the B256 mode. The
 * algorithm start the specification algorithm will exit this mode only if it encounters digits so that arbitrarily
 * inefficient results can be produced if the postfix contains no digits.
 *
 * Multi ECI support and ECI switching:
 *
 * For multi language content the algorithm selects the most compact representation using ECI modes. Note that unlike
 * the compaction algorithm used for QR-Codes, this implementation operates in two stages and therfore is not
 * mathematically optimal. In the first stage, the input string is encoded minimally as a stream of ECI character set
 * selectors and bytes encoded in the selected encoding. In this stage the algorithm might for example decide to
 * encode ocurrences of the characters "\u0150\u015C" (O-double-acute, S-circumflex) in UTF-8 by a single ECI or
 * alternatively by multiple ECIs that switch between IS0-8859-2 and ISO-8859-3 (e.g. in the case that the input
 * contains many * characters start ISO-8859-2 (Latin 2) and few start ISO-8859-3 (Latin 3)).
 * In a second stage this stream of ECIs and bytes is minimally encoded using the various Data Matrix encoding modes.
 * While both stages encode mathematically minimally it is not ensured that the result is mathematically minimal since
 * the size growth for inserting an ECI in the first stage can only be approximated as the first stage does not know
 * in which mode the ECI will occur in the second stage (may, or may not require an extra latch to ASCII depending on
 * the current mode). The reason for this shortcoming are difficulties in implementing it in a straightforward and
 * readable manner.
 *
 * GS1 support
 *
 * FNC1 delimiters can be encoded in the input string by using the FNC1 character specified in the encoding function.
 * When a FNC1 character is specified then a leading FNC1 will be encoded and all ocurrences of delimiter characters
 * while result in FNC1 codewords in the symbol.
 *
 * @author Alex Geller
 */
public enum Mode <: Equatable<Mode> {
    | ASCII
    | C40
    | TEXT
    | X12
    | EDF
    | B256

    public func GetModeNum(): Int64 {
        match (this) {
            case ASCII => return 0;
            case C40 => return 1;
            case TEXT => return 2;
            case X12 => return 3;
            case EDF => return 4;
            case B256 => return 5;
        }
    }

    public operator func ==(right: Mode): Bool {
        if (right.GetModeNum() == this.GetModeNum()) {
            true;
        } else {
            false;
        }
    }

    public operator func !=(right: Mode): Bool {
        if (right.GetModeNum() != this.GetModeNum()) {
            true;
        } else {
            false;
        }
    }
}

public class Input <: MinimalECIInput {
    private let shape: SymbolShapeHint
    private let macroId: Int64

    init(stringToEncode: UTF32String, priorityCharset: MyCharset, fnc1: Int64, shape: SymbolShapeHint, macroId: Int64) {
        super(stringToEncode, priorityCharset, fnc1);
        this.shape = shape
        this.macroId = macroId
    }

    public func getMacroId(): Int64 {
        return macroId
    }

    public func getShapeHint(): SymbolShapeHint {
        return shape
    }
}

public class Edge {
    private static var allCodewordCapacities: Array<Int64> = [
        3,
        5,
        8,
        10,
        12,
        16,
        18,
        22,
        30,
        32,
        36,
        44,
        49,
        62,
        86,
        114,
        144,
        174,
        204,
        280,
        368,
        456,
        576,
        696,
        816,
        1050,
        1304,
        1558
    ]
    private static var squareCodewordCapacities: Array<Int64> = [
        3,
        5,
        8,
        12,
        18,
        22,
        30,
        36,
        44,
        62,
        86,
        114,
        144,
        174,
        204,
        280,
        368,
        456,
        576,
        696,
        816,
        1050,
        1304,
        1558
    ]
    private static var rectangularCodewordCapacities: Array<Int64> = [5, 10, 16, 33, 32, 49]
    public let input: Input
    public let mode: Mode //the mode at the start of this edge.
    public let fromPosition: Int64
    public let characterLength: Int64
    public let previous: ?Edge
    public var cachedTotalSize: Int64 = 0

    init(input: Input, mode: Mode, fromPosition: Int64, characterLength: Int64, previous: ?Edge) {
        this.input = input
        this.mode = mode
        this.fromPosition = fromPosition
        this.characterLength = characterLength
        this.previous = previous
        @Assert(fromPosition + characterLength <= input.length())

        var size: Int64 = if (let Some(p) <- previous) {
            p.cachedTotalSize
        } else {
            0
        }

        var previousMode: Mode = if (let Some(p) <- previous) {
            p.getEndMode()
        } else {
            Mode.ASCII
        }

        /*
         * Switching modes
         * ASCII -> C40: latch 230
         * ASCII -> TEXT: latch 239
         * ASCII -> X12: latch 238
         * ASCII -> EDF: latch 240
         * ASCII -> B256: latch 231
         * C40 -> ASCII: word(c1,c2,c3), 254
         * TEXT -> ASCII: word(c1,c2,c3), 254
         * X12 -> ASCII: word(c1,c2,c3), 254
         * EDIFACT -> ASCII: Unlatch character,0,0,0 or c1,Unlatch character,0,0 or c1,c2,Unlatch character,0 or
         * c1,c2,c3,Unlatch character
         * B256 -> ASCII: without latch after n bytes
         */
        match (mode) {
            case ASCII =>
                size++
                if (input.isECI(fromPosition) || MinimalEncoder.isExtendedASCII(
                    input.charAt(fromPosition),
                    input.getFNC1Character()
                )) {
                    size++
                }
                if (previousMode == Mode.C40 || previousMode == Mode.TEXT || previousMode == Mode.X12) {
                    size++
                    // unlatch 254 to ASCII
                }
            case B256 =>
                size++
                if (previousMode != Mode.B256) {
                    size++
                //byte count
                } else {
                    var cnt: Int64 = 0;
                    var current: ?Edge = this
                    var flag: Bool = false;

                    while ((cnt == 0 && this.mode == Mode.B256 && cnt <= 250) ||
                            current.getOrThrow().mode == Mode.B256 && cnt <= 250) {
                        cnt++
                        current = current.getOrThrow().previous
                        if (let Some(c) <- current) {}
                        else {
                            break
                        }
                    }

                    if (cnt == 250) {
                        size++
                        //extra byte count
                    }
                }
                if (previousMode == Mode.ASCII) {
                    size++
                //latch to B256
                } else if (previousMode == Mode.C40 || previousMode == Mode.TEXT || previousMode == Mode.X12) {
                    size += 2
                    //unlatch to ASCII, latch to B256
                }
            case C40 | TEXT | X12 =>
                if (mode == Mode.X12) {
                    size += 2
                } else {
                    var charLen: Array<Int64> = Array<Int64>(1, item: 0)
                    size += MinimalEncoder.getNumberOfC40Words(input, fromPosition, mode == Mode.C40, charLen) * 2
                }

                if (previousMode == Mode.ASCII || previousMode == Mode.B256) {
                    size++
                //additional byte for latch start ASCII to this mode
                } else if (previousMode != mode && (previousMode == Mode.C40 || previousMode == Mode.TEXT ||
                    previousMode == Mode.X12)) {
                    size += 2
                    //unlatch 254 to ASCII followed by latch to this mode
                }
            case EDF =>
                size += 3
                if (previousMode == Mode.ASCII || previousMode == Mode.B256) {
                    size++
                //additional byte for latch start ASCII to this mode
                } else if (previousMode == Mode.C40 || previousMode == Mode.TEXT || previousMode == Mode.X12) {
                    size += 2
                    //unlatch 254 to ASCII followed by latch to this mode
                }
        }
        cachedTotalSize = size
    }

    // does not count beyond 250
    func getB256Size(): Int64 {
        var cnt: Int64 = 0;
        var current: ?Edge = this
        var flag: Bool = false;
        while (current.getOrThrow().mode == Mode.B256 && cnt <= 250) {
            cnt++
            current = current.getOrThrow().previous
            if (let Some(c) <- current) {}
            else {
                break
            }
        }
        return cnt
    }

    func getPreviousStartMode(): Mode {
        return if (let Some(p) <- previous) {
            p.mode
        } else {
            Mode.ASCII
        }
    }

    func getPreviousMode(): Mode {
        return if (let Some(p) <- previous) {
            p.getEndMode()
        } else {
            Mode.ASCII
        }
    }

    /** Returns Mode.ASCII in case that=>
     * - Mode is EDIFACT and characterLength is less than 4 or the remaining characters can be encoded in at most 2
     * ASCII bytes.
     * - Mode is C40, TEXT or X12 and the remaining characters can be encoded in at most 1 ASCII byte.
     * Returns mode in all other cases.
     * */
    func getEndMode(): Mode {
        if (mode == Mode.EDF) {
            if (characterLength < 4) {
                return Mode.ASCII;
            }
            var lastASCII: Int64 = getLastASCII();

            // see 5.2.8.2 EDIFACT encodation Rules
            if (lastASCII > 0 && getCodewordsRemaining(cachedTotalSize + lastASCII) <= 2 - lastASCII) {
                return Mode.ASCII;
            }
        }
        if (mode == Mode.C40 || mode == Mode.TEXT || mode == Mode.X12) {
            // see 5.2.5.2 C40 encodation rules and 5.2.7.2 ANSI X12 encodation rules
            if (fromPosition + characterLength >= input.length() && getCodewordsRemaining(cachedTotalSize) == 0) {
                return Mode.ASCII;
            }
            var lastASCII: Int64 = getLastASCII();
            if (lastASCII == 1 && getCodewordsRemaining(cachedTotalSize + 1) == 0) {
                return Mode.ASCII;
            }
        }
        return mode
    }

    func getMode(): Mode {
        return mode
    }

    /** Peeks ahead and returns 1 if the postfix consists of exactly two digits, 2 if the postfix consists of exactly
     * two consecutive digits and a non extended character or of 4 digits.
     * Returns 0 in any other case
     * */
    func getLastASCII(): Int64 {
        var length: Int64 = input.length();
        var start: Int64 = fromPosition + characterLength
        if (length - start > 4 || start >= length) {
            return 0;
        }
        if (length - start == 1) {
            if (MinimalEncoder.isExtendedASCII(input.charAt(start), input.getFNC1Character())) {
                return 0;
            }
            return 1;
        }
        if (length - start == 2) {
            if (MinimalEncoder.isExtendedASCII(input.charAt(start), input.getFNC1Character()) ||
                MinimalEncoder.isExtendedASCII(
                input.charAt(start + 1),
                input.getFNC1Character()
            )) {
                return 0;
            }
            if (HighLevelEncoder.isDigit(input.charAt(start)) && HighLevelEncoder.isDigit(input.charAt(start + 1))) {
                return 1;
            }
            return 2;
        }
        if (length - start == 3) {
            if (HighLevelEncoder.isDigit(input.charAt(start)) && HighLevelEncoder.isDigit(input.charAt(start + 1)) &&
                !MinimalEncoder.isExtendedASCII(input.charAt(start + 2), input.getFNC1Character())) {
                return 2;
            }
            if (HighLevelEncoder.isDigit(input.charAt(start + 1)) && HighLevelEncoder.isDigit(input.charAt(start + 2)) &&
                !MinimalEncoder.isExtendedASCII(input.charAt(start), input.getFNC1Character())) {
                return 2;
            }
            return 0;
        }
        if (HighLevelEncoder.isDigit(input.charAt(start)) && HighLevelEncoder.isDigit(input.charAt(start + 1)) &&
            HighLevelEncoder.isDigit(input.charAt(start + 2)) && HighLevelEncoder.isDigit(input.charAt(start + 3))) {
            return 2;
        }
        return 0;
    }

    /** Returns the capacity in codewords of the smallest symbol that has enough capacity to fit the given minimal
     * number of codewords.
     * */
    func getMinSymbolSize(minimum: Int64): Int64 {
        match (input.getShapeHint()) {
            case FORCE_SQUARE => for (i in 0..squareCodewordCapacities.size) {
                if (squareCodewordCapacities[i] >= minimum) {
                    return squareCodewordCapacities[i]
                }
            }
            case FORCE_RECTANGLE => for (i in 0..rectangularCodewordCapacities.size) {
                if (rectangularCodewordCapacities[i] >= minimum) {
                    return rectangularCodewordCapacities[i]
                }
            }
            case FORCE_NONE => ();
        }

        for (i in 0..allCodewordCapacities.size) {
            if (allCodewordCapacities[i] >= minimum) {
                return allCodewordCapacities[i]
            }
        }
        return allCodewordCapacities[allCodewordCapacities.size - 1]
    }

    /** Returns the remaining capacity in codewords of the smallest symbol that has enough capacity to fit the given
     * minimal number of codewords.
     * */
    func getCodewordsRemaining(minimum: Int64): Int64 {
        return getMinSymbolSize(minimum) - minimum
    }

    @OverflowWrapping
    static func getBytes(c: Int64): Array<UInt8> {
        var result: Array<UInt8> = Array<UInt8>(1, item: 0)
        result[0] = UInt8(c)
        return result
    }

    static func getBytes(c1: Int64, c2: Int64): Array<UInt8> {
        var result: Array<UInt8> = Array<UInt8>(2, item: 0)
        result[0] = UInt8(c1)
        result[1] = UInt8(c2)
        return result
    }

    @OverflowWrapping
    static func setC40Word(bytes: Array<UInt8>, offset: Int64, c1: Int64, c2: Int64, c3: Int64) {
        var val16: Int64 = Int64(1600 * (Int32(c1) & 0xff)) + Int64(40 * (Int32(c2) & 0xff)) + Int64(Int32(c3) & 0xff) +
            1
        bytes[offset] = UInt8(val16 / 256)
        bytes[offset + 1] = UInt8(val16 % 256)
    }

    private static func getX12Value(c: Char): Int64 {
        if (c.hashCode() == 13) {
            return 0;
        } else if (c.hashCode() == 42) {
            return 1;
        } else if (c.hashCode() == 62) {
            return 2;
        } else if (c.hashCode() == 32) {
            return 3;
        } else if (c.hashCode() >= 48 && c.hashCode() <= 57) {
            return c.hashCode() - 44
        } else if (c.hashCode() >= 65 && c.hashCode() <= 90) {
            return c.hashCode() - 51
        } else {
            return c.hashCode()
        }
    }

    func getX12Words(): Array<UInt8> {
        @Assert(characterLength % 3 == 0)
        var result: Array<UInt8> = Array<UInt8>(characterLength / 3 * 2, item: 0);

        for (i in 0..result.size : 2) {
            setC40Word(
                result,
                i,
                getX12Value(input.charAt(fromPosition + i / 2 * 3)),
                getX12Value(input.charAt(fromPosition + i / 2 * 3 + 1)),
                getX12Value(input.charAt(fromPosition + i / 2 * 3 + 2))
            );
        }
        return result
    }

    static func getShiftValue(c: Char, c40: Bool, fnc1: Int64): Int64 {
        return if (c40 && MinimalEncoder.isInC40Shift1Set(c) || !c40 && MinimalEncoder.isInTextShift1Set(c)) {
            0
        } else {
            if (c40 && MinimalEncoder.isInC40Shift2Set(c, fnc1) || !c40 && MinimalEncoder.isInTextShift2Set(c, fnc1)) {
                1
            } else {
                2
            }
        }
    }

    private static func getC40Value(c40: Bool, setIndex: Int64, c: Char, fnc1: Int64): Int64 {
        if (c.hashCode() == fnc1) {
            @Assert(setIndex ==  2)
            return 27;
        }
        if (c40) {
            if (c.hashCode() <= 31) {
                return c.hashCode();
            } else if (c.hashCode() == 32) {
                return 3;
            } else if (c.hashCode() <= 47) {
                return c.hashCode() - 33
            } else if (c.hashCode() <= 57) {
                return c.hashCode() - 44
            } else if (c.hashCode() <= 64) {
                return c.hashCode() - 43
            } else if (c.hashCode() <= 90) {
                return c.hashCode() - 51
            } else if (c.hashCode() <= 95) {
                return c.hashCode() - 69
            } else if (c.hashCode() <= 127) {
                return c.hashCode() - 96
            } else {
                return c.hashCode();
            }
        } else {
            returnhashCode(c, setIndex)
        }
    }

    private static func returnhashCode(c: Char, setIndex: Int64): Int64 {
        if (c.hashCode() == 0) {
            return 0;
        } else if (setIndex == 0 && c.hashCode() <= 3) {
            return c.hashCode() - 1
        } else if (setIndex == 1 && c.hashCode() <= 31) {
            return c.hashCode();
        } else if (c.hashCode() == 32) {
            return 3;
        } else if (c.hashCode() >= 33 && c.hashCode() <= 47) {
            return c.hashCode() - 33
        } else if (c.hashCode() >= 48 && c.hashCode() <= 57) {
            return c.hashCode() - 44
        } else if (c.hashCode() >= 58 && c.hashCode() <= 64) {
            return c.hashCode() - 43
        } else if (c.hashCode() >= 65 && c.hashCode() <= 90) {
            return c.hashCode() - 64
        } else if (c.hashCode() >= 91 && c.hashCode() <= 95) {
            return c.hashCode() - 69
        } else if (c.hashCode() == 96) {
            return 0;
        } else if (c.hashCode() >= 97 && c.hashCode() <= 122) {
            return c.hashCode() - 83
        } else if (c.hashCode() >= 123 && c.hashCode() <= 127) {
            return c.hashCode() - 96
        } else {
            return c.hashCode()
        }
    }

    func getC40Words(c40: Bool, fnc1: Int64): Array<UInt8> {
        var c40Values: ArrayList<UInt8> = ArrayList<UInt8>();

        for (i in 0..characterLength) {
            var ci: Char = input.charAt(fromPosition + i);
            if (c40 && HighLevelEncoder.isNativeC40(ci) || !c40 && HighLevelEncoder.isNativeText(ci)) {
                c40Values.append(UInt8(getC40Value(c40, 0, ci, fnc1)));
            } else if (!MinimalEncoder.isExtendedASCII(ci, fnc1)) {
                var shiftValue: Int64 = getShiftValue(ci, c40, fnc1);
                c40Values.append(UInt8(shiftValue));

                //Shift[123]
                c40Values.append(UInt8(getC40Value(c40, shiftValue, ci, fnc1)));
            } else {
                var asciiValue: Char = Char(ci.hashCode() & 0xff - 128)
                if (c40 && HighLevelEncoder.isNativeC40(asciiValue) || !c40 && HighLevelEncoder.isNativeText(asciiValue)) {
                    c40Values.append(UInt8(1));

                    //Shift 2
                    c40Values.append(UInt8(30));

                    //Upper Shift
                    c40Values.append(UInt8(getC40Value(c40, 0, asciiValue, fnc1)));
                } else {
                    c40Values.append(UInt8(1));

                    //Shift 2
                    c40Values.append(UInt8(30));

                    //Upper Shift
                    var shiftValue: Int64 = getShiftValue(asciiValue, c40, fnc1);
                    c40Values.append(UInt8(shiftValue));

                    // Shift[123]
                    c40Values.append(UInt8(getC40Value(c40, shiftValue, asciiValue, fnc1)));
                }
            }
        }

        if ((c40Values.size % 3) != 0) {
            @Assert((c40Values.size - 2) % 3 == 0 && fromPosition + characterLength == input.length())
            c40Values.append(0);
        }

        var result: Array<UInt8> = Array<UInt8>(c40Values.size / 3 * 2, item: 0);
        var byteIndex: Int64 = 0;
        for (i in 0..c40Values.size : 3) {
            setC40Word(
                result,
                byteIndex,
                Int64(c40Values[i] & 0xff),
                Int64(c40Values[i + 1]) & 0xff,
                Int64(c40Values[i + 2]) & 0xff
            );
            byteIndex += 2
        }
        return result
    }

    func getEDFBytes(): Array<UInt8> {
        var numberOfThirds: Int64 = Int64(ceil(Float64(characterLength) / 4.0))
        var result: Array<UInt8> = Array<UInt8>(numberOfThirds * 3, item: 0)
        var pos: Int64 = fromPosition
        var endPos: Int64 = min(fromPosition + characterLength - 1, input.length() - 1);

        for (i in 0..numberOfThirds) {
            var edfValues: Array<Int64> = Array<Int64>(4, item: 0)

            for (j in 0..4) {
                if (pos <= endPos) {
                    edfValues[j] = input.charAt(pos).hashCode() & 0x3f
                    pos++
                } else {
                    edfValues[j] = if (pos == endPos + 1) {
                        0x1f
                    } else {
                        0
                    }
                }
            }
            var val24: Int64 = edfValues[0] << 18
            val24 |= edfValues[1] << 12
            val24 |= edfValues[2] << 6
            val24 |= edfValues[3]
            result[i] = UInt8((val24 >> 16 & 0xff))
            result[i + 1] = UInt8((val24 >> 8 & 0xff))
            result[i + 2] = UInt8(val24 & 0xff)
        }
        return result
    }

    func getLatchBytes(): Array<UInt8> {
        match (getPreviousMode()) {
            case ASCII | B256 =>
                //after B256 ends (via length) we are back to ASCII
                match (mode) {
                case B256 => return getBytes(231);
                case C40 => return getBytes(230);
                case TEXT => return getBytes(239);
                case X12 => return getBytes(238);
                case EDF => return getBytes(240);
                case _ => ();
            }
            case C40 | TEXT | X12 => if (mode != getPreviousMode()) {
                match (mode) {
                    case ASCII => return getBytes(254);
                    case B256 => return getBytes(254, 231);
                    case C40 => return getBytes(254, 230);
                    case TEXT => return getBytes(254, 239);
                    case X12 => return getBytes(254, 238);
                    case EDF => return getBytes(254, 240);
                }
            }
            case EDF => @Assert(mode == Mode.EDF) //The rightmost EDIFACT edge always contains an unlatch character
        }
        return Array<Byte>();
    }

    // Important: The function does not return the length bytes (one or two) in case of B256 encoding
    func getDataBytes(): Array<UInt8> {
        match (mode) {
            case ASCII => if (input.isECI(fromPosition)) {
                return getBytes(241, input.getECIValue(fromPosition) + 1);
            } else if (MinimalEncoder.isExtendedASCII(input.charAt(fromPosition), input.getFNC1Character())) {
                return getBytes(235, input.charAt(fromPosition).hashCode() - 127);
            } else if (characterLength == 2) {
                return getBytes(
                    (input.charAt(fromPosition).hashCode() - '0'.hashCode()) * 10 +
                    input.charAt(fromPosition + 1).hashCode() - '0'.hashCode() + 130);
            } else if (input.isFNC1(fromPosition)) {
                return getBytes(232);
            } else {
                return getBytes(input.charAt(fromPosition).hashCode() + 1);
            }
            case B256 => return getBytes(input.charAt(fromPosition).hashCode());
            case C40 => return getC40Words(true, input.getFNC1Character());
            case TEXT => return getC40Words(false, input.getFNC1Character());
            case X12 => return getX12Words();
            case EDF => return getEDFBytes();
        }
        @Assert(false)
        return Array<UInt8>();
    }
}

public class Result {
    private let bytes: Array<UInt8>

    init(solution: Edge) {
        var input: Input = solution.input;
        var size: Int64 = 0;
        var bytesAL: ArrayList<UInt8> = ArrayList<UInt8>();
        var randomizePostfixLength: ArrayList<Int64> = ArrayList<Int64>();
        var randomizeLengths: ArrayList<Int64> = ArrayList<Int64>();
        if ((solution.mode == Mode.C40 || solution.mode == Mode.TEXT || solution.mode == Mode.X12) &&
            solution.getEndMode() != Mode.ASCII) {
            size += Result.prepend(Edge.getBytes(254), bytesAL)
        }
        var current: ?Edge = solution
        var currentFlag = false;
        if (let Some(c) <- current) {
            currentFlag = true
        }
        while (currentFlag) {
            size += Result.prepend(current.getOrThrow().getDataBytes(), bytesAL)

            if (let Some(p) <- current.getOrThrow().previous) {
                if (current.getOrThrow().getPreviousStartMode() != current.getOrThrow().getMode()) {
                    if (current.getOrThrow().getMode() == Mode.B256) {
                        if (size <= 249) {
                            bytesAL.insert(0, UInt8(size))
                            size++
                        } else {
                            bytesAL.insert(0, UInt8(size % 250));
                            bytesAL.insert(0, UInt8(size / 250 + 249));
                            size += 2
                        }
                        randomizePostfixLength.append(bytesAL.size);
                        randomizeLengths.append(size);
                    }
                    prepend(current.getOrThrow().getLatchBytes(), bytesAL);
                    size = 0
                }
            } else {
                if (current.getOrThrow().getMode() == Mode.B256) {
                    if (size <= 249) {
                        bytesAL.insert(0, UInt8(size))
                        size++
                    } else {
                        bytesAL.insert(0, UInt8(size % 250));
                        bytesAL.insert(0, UInt8(size / 250 + 249));
                        size += 2
                    }
                    randomizePostfixLength.append(bytesAL.size);
                    randomizeLengths.append(size);
                }
                prepend(current.getOrThrow().getLatchBytes(), bytesAL);
                size = 0
            }

            current = current.getOrThrow().previous

            if (let Some(c) <- current) {
                currentFlag = true
            } else {
                currentFlag = false
            }
        }
        if (input.getMacroId() == 5) {
            size += Result.prepend(Edge.getBytes(236), bytesAL)
        } else if (input.getMacroId() == 6) {
            size += Result.prepend(Edge.getBytes(237), bytesAL)
        }
        if (input.getFNC1Character() > 0) {
            size += prepend(Edge.getBytes(232), bytesAL)
        }
        for (i in 0..randomizePostfixLength.size) {
            applyRandomPattern(bytesAL, bytesAL.size - randomizePostfixLength[i], randomizeLengths[i]);
        }

        //add padding
        var capacity: Int64 = solution.getMinSymbolSize(bytesAL.size);
        if (bytesAL.size < capacity) {
            bytesAL.append(129);
        }
        while (bytesAL.size < capacity) {
            bytesAL.append(UInt8(randomize253State(bytesAL.size + 1)));
        }

        this.bytes = Array<UInt8>(bytesAL.size, item: 0)

        for (i in 0..bytes.size) {
            bytes[i] = bytesAL[i]
        }
    }

    public static func prepend(bytes: Array<UInt8>, into: ArrayList<UInt8>): Int64 {
        for (i in bytes.size - 1..=0 : -1) {
            into.insert(0, bytes[i]);
        }
        return bytes.size;
    }

    private static func randomize253State(codewordPosition: Int64): Int64 {
        var pseudoRandom: Int64 = ((149 * codewordPosition) % 253) + 1
        var tempVariable: Int64 = 129 + pseudoRandom
        return if (tempVariable <= 254) {
            tempVariable
        } else {
            tempVariable - 254
        }
    }

    static func applyRandomPattern(bytesAL: ArrayList<UInt8>, startPosition: Int64, length: Int64) {
        for (i in 0..length) {
            //See "B.1 253-state algorithm
            var Pad_codeword_position: Int64 = startPosition + i
            var Pad_codeword_value: Int64 = Int64(bytesAL[Pad_codeword_position]) & 0xff
            var pseudo_random_number: Int64 = ((149 * (Pad_codeword_position + 1)) % 255) + 1
            var temp_variable: Int64 = Pad_codeword_value + pseudo_random_number
            bytesAL.set(Pad_codeword_position, UInt8(if (temp_variable <= 255) {
                    temp_variable
                } else {
                    temp_variable - 256
                }));
        }
    }

    public func getBytes(): Array<UInt8> {
        return bytes
    }
}

public class MinimalEncoder {
    static let C40_SHIFT2_CHARS = [
        '!',
        '"',
        '#',
        '$',
        '%',
        '&',
        '\'',
        '(',
        ')',
        '*',
        '+',
        ',',
        '-',
        '.',
        '/',
        ':',
        ';',
        '<',
        '=',
        '>',
        '?',
        '@',
        '[',
        '\\',
        ']',
        '^',
        '_'
    ]

    init() {}

    public static func isExtendedASCII(ch: Char, fnc1: Int64): Bool {
        return ch.hashCode() != fnc1 && ch.hashCode() >= 128 && ch <= Char(255)
    }

    public static func isInC40Shift1Set(ch: Char): Bool {
        return ch <= Char(31)
    }

    public static func isInC40Shift2Set(ch: Char, fnc1: Int64): Bool {
        for (i in 0..C40_SHIFT2_CHARS.size) {
            if (C40_SHIFT2_CHARS[i] == ch) {
                return true;
            }
        }
        return ch.hashCode() == fnc1
    }

    public static func isInTextShift1Set(ch: Char): Bool {
        return isInC40Shift1Set(ch);
    }

    public static func isInTextShift2Set(ch: Char, fnc1: Int64): Bool {
        return isInC40Shift2Set(ch, fnc1);
    }

    /**
     * Performs message encoding of a DataMatrix message
     *
     * @param msg the message
     * @return the encoded message (the char values range start 0 to 255)
     */
    public static func encodeHighLevel(msg: UTF32String): UTF32String {
        return encodeHighLevel(msg, MyCharset(), -1, SymbolShapeHint.FORCE_NONE);
    }

    /**
     * Performs message encoding of a DataMatrix message
     *
     * @param msg the message
     * @param priorityCharset The preferred {@link MyCharset}. When the value of the argument is null, the algorithm
     * chooses charsets that leads to a minimal representation. Otherwise the algorithm will use the priority
     * charset to encode any character in the input that can be encoded by it if the charset is among the
     * supported charsets.
     * @param fnc1 denotes the character in the input that represents the FNC1 character or -1 if this is not a GS1
     * bar code. If the value is not -1 then a FNC1 is also prepended.
     * @param shape requested shape.
     * @return the encoded message (the char values range start 0 to 255)
     */
    public static func encodeHighLevel(
        msg0: UTF32String,
        priorityCharset: MyCharset,
        fnc1: Int64,
        shape: SymbolShapeHint
    ): UTF32String {
        var macroId: Int64 = 0;
        var msg = msg0
        if (msg.startsWith(HighLevelEncoder.MACRO_05_HEADER) && msg.endsWith(HighLevelEncoder.MACRO_TRAILER)) {
            macroId = 5
            msg = msg.substring(
                HighLevelEncoder.MACRO_05_HEADER.charSize,
                msg.charSize - 2 - HighLevelEncoder.MACRO_05_HEADER.charSize
            )
        } else if (msg.startsWith(HighLevelEncoder.MACRO_06_HEADER) && msg.endsWith(HighLevelEncoder.MACRO_TRAILER)) {
            macroId = 6
            msg = msg.substring(
                HighLevelEncoder.MACRO_06_HEADER.charSize,
                msg.charSize - 2 - HighLevelEncoder.MACRO_06_HEADER.charSize
            )
        }
        return UTF32String(
            StandardCharsets.ISO_8859_1.newDecoder().decode(encode(msg, priorityCharset, fnc1, shape, macroId)))
    }

    /**
     * Encodes input minimally and returns an array of the codewords
     *
     * @param input The string to encode
     * @param priorityCharset The preferred {@link MyCharset}. When the value of the argument is null, the algorithm
     * chooses charsets that leads to a minimal representation. Otherwise the algorithm will use the priority
     * charset to encode any character in the input that can be encoded by it if the charset is among the
     * supported charsets.
     * @param fnc1 denotes the character in the input that represents the FNC1 character or -1 if this is not a GS1
     * bar code. If the value is not -1 then a FNC1 is also prepended.
     * @param shape requested shape.
     * @param macroId Prepends the specified macro function in case that a value of 5 or 6 is specified.
     * @return An array of bytes representing the codewords of a minimal encoding.
     */
    static func encode(
        input: UTF32String,
        priorityCharset: MyCharset,
        fnc1: Int64,
        shape: SymbolShapeHint,
        macroId: Int64
    ): Array<UInt8> {
        return encodeMinimally(Input(input, priorityCharset, fnc1, shape, macroId)).getBytes();
    }

    static func addEdge(edges: Array<Array<?Edge>>, edge: Edge) {
        let vertexIndex = edge.fromPosition + edge.characterLength
        if (let Some(e) <- edges[vertexIndex][edge.getEndMode().GetModeNum()]) {
            if (e.cachedTotalSize > edge.cachedTotalSize) {
                edges[vertexIndex][edge.getEndMode().GetModeNum()] = edge
            }
        } else {
            edges[vertexIndex][edge.getEndMode().GetModeNum()] = edge
        }
    }

    /** @return the number of words in which the string starting at start can be encoded in c40 or text mode.
     * The number of characters encoded is returned in characterLength.
     * The number of characters encoded is also minimal in the sense that the algorithm stops as soon
     * as a character encoding fills a C40 word competely (three C40 values). An exception is at the
     * end of the string where two C40 values are allowed (according to the spec the third c40 value
     * is filled  with 0 (Shift 1) in this case).
     */
    public static func getNumberOfC40Words(input: Input, start: Int64, c40: Bool, characterLength: Array<Int64>): Int64 {
        var thirdsCount: Int64 = 0;
        for (i in start..input.length()) {
            if (input.isECI(i)) {
                characterLength[0] = 0
                return 0;
            }
            var ci: Char = input.charAt(i);
            if (c40 && HighLevelEncoder.isNativeC40(ci) || !c40 && HighLevelEncoder.isNativeText(ci)) {
                thirdsCount++
            //native
            } else if (!isExtendedASCII(ci, input.getFNC1Character())) {
                thirdsCount += 2
            //shift
            } else {
                var asciiValue: Int64 = ci.hashCode() & 0xff
                if (asciiValue >= 128 && (c40 && HighLevelEncoder.isNativeC40(Char(asciiValue - 128)) || !c40 &&
                    HighLevelEncoder.isNativeText(Char(asciiValue - 128)))) {
                    thirdsCount += 3
                // shift, Upper shift
                } else {
                    thirdsCount += 4
                    // shift, Upper shift, shift
                }
            }

            if (thirdsCount % 3 == 0 || ((thirdsCount - 2) % 3 == 0 && i + 1 == input.length())) {
                characterLength[0] = i - start + 1
                return Int64(ceil((Float64(thirdsCount) / 3.0)))
            }
        }
        characterLength[0] = 0
        return 0;
    }

    public static func addEdges(input: Input, edges: Array<Array<?Edge>>, start: Int64, previous: ?Edge) {
        if (input.isECI(start)) {
            addEdge(edges, Edge(input, Mode.ASCII, start, 1, previous));
            return;
        }

        var ch: Char = input.charAt(start);
        var flag: Bool = false;
        if (let Some(p) <- previous) {
            flag = true
        }

        if (flag == false || previous.getOrThrow().getEndMode() != Mode.EDF) { //not possible to unlatch a full EDF edge to something
            //else
            if (HighLevelEncoder.isDigit(ch) && input.haveNCharacters(start, 2) && HighLevelEncoder.isDigit(
                input.charAt(start + 1))) {
                // two digits ASCII encoded
                addEdge(edges, Edge(input, Mode.ASCII, start, 2, previous));
            } else {
                // one ASCII encoded character or an extended character via Upper Shift
                addEdge(edges, Edge(input, Mode.ASCII, start, 1, previous));
            }

            var modes: Array<Mode> = [Mode.C40, Mode.TEXT]

            for (i in 0..modes.size) {
                var characterLength: Array<Int64> = Array<Int64>(1, item: 0)
                if (getNumberOfC40Words(input, start, modes[i] == Mode.C40, characterLength) > 0) {
                    addEdge(edges, Edge(input, modes[i], start, characterLength[0], previous));
                }
            }

            if (input.haveNCharacters(start, 3) && HighLevelEncoder.isNativeX12(input.charAt(start)) &&
                HighLevelEncoder.isNativeX12(input.charAt(start + 1)) && HighLevelEncoder.isNativeX12(
                input.charAt(start + 2))) {
                addEdge(edges, Edge(input, Mode.X12, start, 3, previous));
            }

            addEdge(edges, Edge(input, Mode.B256, start, 1, previous));
        }

        //We create 4 EDF edges,  with 1, 2 3 or 4 characters length. The fourth normally doesn't have a latch to ASCII
        //unless it is 2 characters away start the end of the input.
        var i: Int64 = 0;
        while (i >= 0 && i < 3) {
            var pos: Int64 = start + i
            if (input.haveNCharacters(pos, 1) && HighLevelEncoder.isNativeEDIFACT(input.charAt(pos))) {
                addEdge(edges, Edge(input, Mode.EDF, start, i + 1, previous));
            } else {
                break
            }
            i++
        }
        if (i == 3 && input.haveNCharacters(start, 4) && HighLevelEncoder.isNativeEDIFACT(input.charAt(start + 3))) {
            addEdge(edges, Edge(input, Mode.EDF, start, 4, previous));
        }
    }
    public static func encodeMinimally(input: Input): Result {
        /* The minimal encoding is computed by Dijkstra. The acyclic graph is modeled as follows:
         * A vertex represents a combination of a position in the input and an encoding mode where position 0
         * denotes the position left of the first character, 1 the position left of the second character and so on.
         * Likewise the end vertices are located after the last character at position input.size.
         * For any position there might be up to six vertices, one for each of the encoding types ASCII, C40, TEXT, X12,
         * EDF and B256.
         *
         * As an example consider the input string "ABC123" then at position 0 there is only one vertex with the default
         * ASCII encodation. At position 3 there might be vertices for the types ASCII, C40, X12, EDF and B256.
         *
         * An edge leading to such a vertex encodes one or more of the characters left of the position that the vertex
         * represents. It encodes the characters in the encoding mode of the vertex that it ends on. In other words,
         * all edges leading to a particular vertex encode the same characters (the length of the suffix can vary) using the same
         * encoding mode.
         * As an example consider the input string "ABC123" and the vertex (4,EDF). Possible edges leading to this vertex
         * are:
         * (0,ASCII)  --EDF(ABC1)--> (4,EDF)
         * (1,ASCII)  --EDF(BC1)-->  (4,EDF)
         * (1,B256)   --EDF(BC1)-->  (4,EDF)
         * (1,EDF)    --EDF(BC1)-->  (4,EDF)
         * (2,ASCII)  --EDF(C1)-->   (4,EDF)
         * (2,B256)   --EDF(C1)-->   (4,EDF)
         * (2,EDF)    --EDF(C1)-->   (4,EDF)
         * (3,ASCII)  --EDF(1)-->    (4,EDF)
         * (3,B256)   --EDF(1)-->    (4,EDF)
         * (3,EDF)    --EDF(1)-->    (4,EDF)
         * (3,C40)    --EDF(1)-->    (4,EDF)
         * (3,X12)    --EDF(1)-->    (4,EDF)
         *
         * The edges leading to a vertex are stored in such a way that there is a fast way to enumerate the edges ending
         * on a particular vertex.
         *
         * The algorithm processes the vertices in order of their position thereby performing the following:
         *
         * For every vertex at position i the algorithm enumerates the edges ending on the vertex and removes all but the
         * shortest start that list.
         * Then it processes the vertices for the position i+1. If i+1 == input.size then the algorithm ends
         * and chooses the the edge with the smallest size start any of the edges leading to vertices at this position.
         * Otherwise the algorithm computes all possible outgoing edges for the vertices at the position i+1
         *
         * Examples:
         * The process is illustrated by showing the graph (edges) after each iteration start left to right over the input:
         * An edge is drawn as follows "(" + fromVertex + ") -- " + encodingMode + "(" + encodedInput + ") (" +
         * accumulatedSize + ") --> (" + toVertex + ")"
         *
         * Example 1 encoding the string "ABCDEFG":
         *
         *
         * Situation after adding edges to the start vertex (0,ASCII)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII)
         * (0,ASCII) B256(A) (3) --> (1,B256)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF)
         * (0,ASCII) C40(ABC) (3) --> (3,C40)
         * (0,ASCII) TEXT(ABC) (5) --> (3,TEXT)
         * (0,ASCII) X12(ABC) (3) --> (3,X12)
         * (0,ASCII) EDF(ABC) (4) --> (3,EDF)
         * (0,ASCII) EDF(ABCD) (4) --> (4,EDF)
         *
         * Situation after adding edges to vertices at position 1
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII)
         * (0,ASCII) B256(A) (3) --> (1,B256)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF)
         * (0,ASCII) C40(ABC) (3) --> (3,C40)
         * (0,ASCII) TEXT(ABC) (5) --> (3,TEXT)
         * (0,ASCII) X12(ABC) (3) --> (3,X12)
         * (0,ASCII) EDF(ABC) (4) --> (3,EDF)
         * (0,ASCII) EDF(ABCD) (4) --> (4,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) B256(B) (4) --> (2,B256)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) EDF(BC) (5) --> (3,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) C40(BCD) (4) --> (4,C40)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) TEXT(BCD) (6) --> (4,TEXT)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) X12(BCD) (4) --> (4,X12)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) EDF(BCD) (5) --> (4,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) EDF(BCDE) (5) --> (5,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) ASCII(B) (4) --> (2,ASCII)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256)
         * (0,ASCII) B256(A) (3) --> (1,B256) EDF(BC) (6) --> (3,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) C40(BCD) (5) --> (4,C40)
         * (0,ASCII) B256(A) (3) --> (1,B256) TEXT(BCD) (7) --> (4,TEXT)
         * (0,ASCII) B256(A) (3) --> (1,B256) X12(BCD) (5) --> (4,X12)
         * (0,ASCII) B256(A) (3) --> (1,B256) EDF(BCD) (6) --> (4,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) EDF(BCDE) (6) --> (5,EDF)
         *
         * Edge "(1,ASCII) ASCII(B) (2) --> (2,ASCII)" is minimal for the vertex (2,ASCII) so that edge "(1,B256) ASCII(B) (4) --> (2,ASCII)" is removed.
         * Edge "(1,B256) B256(B) (3) --> (2,B256)" is minimal for the vertext (2,B256) so that the edge "(1,ASCII) B256(B) (4) --> (2,B256)" is removed.
         *
         * Situation after adding edges to vertices at position 2
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII)
         * (0,ASCII) B256(A) (3) --> (1,B256)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF)
         * (0,ASCII) C40(ABC) (3) --> (3,C40)
         * (0,ASCII) TEXT(ABC) (5) --> (3,TEXT)
         * (0,ASCII) X12(ABC) (3) --> (3,X12)
         * (0,ASCII) EDF(ABC) (4) --> (3,EDF)
         * (0,ASCII) EDF(ABCD) (4) --> (4,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) EDF(BC) (5) --> (3,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) C40(BCD) (4) --> (4,C40)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) TEXT(BCD) (6) --> (4,TEXT)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) X12(BCD) (4) --> (4,X12)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) EDF(BCD) (5) --> (4,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) EDF(BCDE) (5) --> (5,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256)
         * (0,ASCII) B256(A) (3) --> (1,B256) EDF(BC) (6) --> (3,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) C40(BCD) (5) --> (4,C40)
         * (0,ASCII) B256(A) (3) --> (1,B256) TEXT(BCD) (7) --> (4,TEXT)
         * (0,ASCII) B256(A) (3) --> (1,B256) X12(BCD) (5) --> (4,X12)
         * (0,ASCII) B256(A) (3) --> (1,B256) EDF(BCD) (6) --> (4,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) EDF(BCDE) (6) --> (5,EDF)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF) ASCII(C) (5) --> (3,ASCII)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF) B256(C) (6) --> (3,B256)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF) EDF(CD) (7) --> (4,EDF)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF) C40(CDE) (6) --> (5,C40)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF) TEXT(CDE) (8) --> (5,TEXT)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF) X12(CDE) (6) --> (5,X12)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF) EDF(CDE) (7) --> (5,EDF)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF) EDF(CDEF) (7) --> (6,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) B256(C) (5) --> (3,B256)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) EDF(CD) (6) --> (4,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) C40(CDE) (5) --> (5,C40)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) TEXT(CDE) (7) --> (5,TEXT)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) X12(CDE) (5) --> (5,X12)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) EDF(CDE) (6) --> (5,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) EDF(CDEF) (6) --> (6,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) ASCII(C) (4) --> (3,ASCII)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) B256(C) (4) --> (3,B256)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) EDF(CD) (6) --> (4,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) C40(CDE) (5) --> (5,C40)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) TEXT(CDE) (7) --> (5,TEXT)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) X12(CDE) (5) --> (5,X12)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) EDF(CDE) (6) --> (5,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) EDF(CDEF) (6) --> (6,EDF)
         *
         * Edge "(2,ASCII) ASCII(C) (3) --> (3,ASCII)" is minimal for the vertex (3,ASCII) so that edges "(2,EDF) ASCII(C) (5) --> (3,ASCII)"
         * and "(2,B256) ASCII(C) (4) --> (3,ASCII)" can be removed.
         * Edge "(0,ASCII) EDF(ABC) (4) --> (3,EDF)" is minimal for the vertex (3,EDF) so that edges "(1,ASCII) EDF(BC) (5) --> (3,EDF)"
         * and "(1,B256) EDF(BC) (6) --> (3,EDF)" can be removed.
         * Edge "(2,B256) B256(C) (4) --> (3,B256)" is minimal for the vertex (3,B256) so that edges "(2,ASCII) B256(C) (5) --> (3,B256)"
         * and "(2,EDF) B256(C) (6) --> (3,B256)" can be removed.
         *
         * This continues for vertices 3 thru 7
         *
         * Situation after adding edges to vertices at position 7
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII)
         * (0,ASCII) B256(A) (3) --> (1,B256)
         * (0,ASCII) EDF(AB) (4) --> (2,EDF)
         * (0,ASCII) C40(ABC) (3) --> (3,C40)
         * (0,ASCII) TEXT(ABC) (5) --> (3,TEXT)
         * (0,ASCII) X12(ABC) (3) --> (3,X12)
         * (0,ASCII) EDF(ABC) (4) --> (3,EDF)
         * (0,ASCII) EDF(ABCD) (4) --> (4,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) C40(BCD) (4) --> (4,C40)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) TEXT(BCD) (6) --> (4,TEXT)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) X12(BCD) (4) --> (4,X12)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) EDF(BCDE) (5) --> (5,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256)
         * (0,ASCII) C40(ABC) (3) --> (3,C40) C40(DEF) (5) --> (6,C40)
         * (0,ASCII) X12(ABC) (3) --> (3,X12) X12(DEF) (5) --> (6,X12)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) C40(CDE) (5) --> (5,C40)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) TEXT(CDE) (7) --> (5,TEXT)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) X12(CDE) (5) --> (5,X12)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) EDF(CDEF) (6) --> (6,EDF)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) C40(BCD) (4) --> (4,C40) C40(EFG) (6) --> (7,C40)    //Solution 1
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) X12(BCD) (4) --> (4,X12) X12(EFG) (6) --> (7,X12)    //Solution 2
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) B256(C) (4) --> (3,B256)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII) ASCII(D) (4) --> (4,ASCII)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII) TEXT(DEF) (8) --> (6,TEXT)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII) EDF(DEFG) (7) --> (7,EDF)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) B256(C) (4) --> (3,B256) B256(D) (5) --> (4,B256)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII) ASCII(D) (4) --> (4,ASCII) ASCII(E) (5) --> (5,ASCII)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII) ASCII(D) (4) --> (4,ASCII) TEXT(EFG) (9) --> (7,TEXT)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) B256(C) (4) --> (3,B256) B256(D) (5) --> (4,B256) B256(E) (6) --> (5,B256)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII) ASCII(D) (4) --> (4,ASCII) ASCII(E) (5) --> (5,ASCII) ASCII(F) (6) --> (6,ASCII)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) B256(C) (4) --> (3,B256) B256(D) (5) --> (4,B256) B256(E) (6) --> (5,B256) B256(F) (7) --> (6,B256)
         * (0,ASCII) ASCII(A) (1) --> (1,ASCII) ASCII(B) (2) --> (2,ASCII) ASCII(C) (3) --> (3,ASCII) ASCII(D) (4) --> (4,ASCII) ASCII(E) (5) --> (5,ASCII) ASCII(F) (6) --> (6,ASCII) ASCII(G) (7) --> (7,ASCII)
         * (0,ASCII) B256(A) (3) --> (1,B256) B256(B) (3) --> (2,B256) B256(C) (4) --> (3,B256) B256(D) (5) --> (4,B256) B256(E) (6) --> (5,B256) B256(F) (7) --> (6,B256) B256(G) (8) --> (7,B256)
         *
         * Hence a minimal encoding of "ABCDEFG" is either ASCII(A),C40(BCDEFG) or ASCII(A), X12(BCDEFG) with a size of 5 bytes.
         */
        var inputLength: Int64 = input.length();

        // Array that represents vertices. There is a vertex for every character and mode.
        // The last dimension in the array below encodes the 6 modes ASCII, C40, TEXT, X12, EDF and B256
        var edges: Array<Array<?Edge>> = Array<Array<?Edge>>(inputLength + 1, {int: Int64 => Array<?Edge>(6, item: None)}
        );

        addEdges(input, edges, 0, None);

        for (i in 1..=inputLength) {
            for (j in 0..6) {
                if (let Some(e) <- edges[i][j]) {
                    if (i < inputLength) {
                        addEdges(input, edges, i, edges[i][j]);
                    }
                }
            }

            //optimize memory by removing edges that have been passed.
            for (j in 0..6) {
                edges[i - 1][j] = None
            }
        }

        var minimalJ: Int64 = -1;
        var minimalSize: Int64 = 0x7fffffff;

        for (j in 0..6) {
            if (let Some(e) <- edges[inputLength][j]) {
                var edge: Edge = e
                var size: Int64 = if (j >= 1 && j <= 3) {
                    edge.cachedTotalSize + 1
                } else {
                    edge.cachedTotalSize
                }

                //C40, TEXT and X12 need an
                // extra unlatch at the end
                if (size < minimalSize) {
                    minimalSize = size
                    minimalJ = j
                }
            }
        }

        if (minimalJ < 0) {
            throw IllegalArgumentException("Failed to encode \"" + input.toString() + "\"");
        }
        return Result(edges[inputLength][minimalJ].getOrThrow());
    }
}
