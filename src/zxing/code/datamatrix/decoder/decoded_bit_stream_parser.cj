/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.datamatrix.decoder

import zxing.code.common.BitSource
import zxing.code.common.DecoderResult
import zxing.code.common.ECIStringBuilder
import zxing.code.common.ReaderException
import zxing.code.common.MyCharset
import zxing.code.common.StandardCharsets

/**
 * <p>Data Matrix Codes can encode text as bits in one of several modes, and can use multiple modes
 * in one Data Matrix Code. This class decodes the bits back into text.</p>
 *
 * <p>See ISO 16022:2006, 5.2.1 - 5.2.9.2</p>
 *
 * @author bbrown@google.com (Brian Brown)
 * @author Sean Owen
 */
enum Mode <: Equatable<Mode> {
    | PAD_ENCODE // Not really a mode
    | ASCII_ENCODE
    | C40_ENCODE
    | TEXT_ENCODE
    | ANSIX12_ENCODE
    | EDIFACT_ENCODE
    | BASE256_ENCODE
    | ECI_ENCODE

    public func GetModeNum(): Int64 {
        match (this) {
            case PAD_ENCODE => return 0;
            case ASCII_ENCODE => return 1;
            case C40_ENCODE => return 2;
            case TEXT_ENCODE => return 3;
            case ANSIX12_ENCODE => return 4;
            case EDIFACT_ENCODE => return 5;
            case BASE256_ENCODE => return 6;
            case ECI_ENCODE => return 7;
        }
    }

    public operator func !=(right: Mode): Bool {
        if (right.GetModeNum() != this.GetModeNum()) {
            true;
        } else {
            false;
        }
    }

    public operator func ==(right: Mode): Bool {
        if (right.GetModeNum() == this.GetModeNum()) {
            true;
        } else {
            false;
        }
    }
}

public class DecodedBitStreamParser {
    /**
     * See ISO 16022:2006, Annex C Table C.1
     * The C40 Basic Character Set (*'s used for placeholders for the shift values)
     */
    private static let C40_BASIC_SET_CHARS = [
        '*',
        '*',
        '*',
        ' ',
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z'
    ]

    private static let C40_SHIFT2_SET_CHARS = [
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

    /**
     * See ISO 16022:2006, Annex C Table C.2
     * The Text Basic Character Set (*'s used for placeholders for the shift values)
     */
    private static let TEXT_BASIC_SET_CHARS = [
        '*',
        '*',
        '*',
        ' ',
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z'
    ]

    // Shift 2 for Text is the same encoding as C40
    private static let TEXT_SHIFT2_SET_CHARS: Array<Char> = C40_SHIFT2_SET_CHARS

    private static let TEXT_SHIFT3_SET_CHARS = [
        '`',
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z',
        '{',
        '|',
        '}',
        '~',
        Char(127)
    ]

    init() {}

    public static func decode(bytes: Array<UInt8>): DecoderResult {
        var bits: BitSource = BitSource(bytes);
        var result: ECIStringBuilder = ECIStringBuilder(100);
        var resultTrailer: ArrayList<Char> = ArrayList<Char>();
        var byteSegments = ArrayList<Array<UInt8>>(1)
        var mode: Mode = Mode.ASCII_ENCODE;

        // Could look directly at 'bytes', if we're sure of not having to account for multi byte values
        var fnc1Positions: Set<Int64> = HashSet<Int64>();
        var symbologyModifier: Int64
        var isECIencoded: Bool = false;
        do {
            if (mode == Mode.ASCII_ENCODE) {
                mode = decodeAsciiSegment(bits, result, resultTrailer, fnc1Positions)
            } else {
                match (mode) {
                    case C40_ENCODE => decodeC40Segment(bits, result, fnc1Positions);
                    case TEXT_ENCODE => decodeTextSegment(bits, result, fnc1Positions);
                    case ANSIX12_ENCODE => decodeAnsiX12Segment(bits, result);
                    case EDIFACT_ENCODE => decodeEdifactSegment(bits, result);
                    case BASE256_ENCODE => decodeBase256Segment(bits, result, byteSegments);
                    case ECI_ENCODE =>
                        decodeECISegment(bits, result);
                        isECIencoded = true

                    // ECI detection only, atm continue decoding as ASCII
                    case _ => throw FormatException.getFormatInstance();
                }
                mode = Mode.ASCII_ENCODE
            }
        } while (mode != Mode.PAD_ENCODE && bits.available() > 0)
        if (resultTrailer.size > 0) {
            result.appendCharacters(resultTrailer);
        }
        if (isECIencoded) {
            // Examples for this numbers can be found in this documentation of a hardware barcode scanner:
            if (fnc1Positions.contains(0) || fnc1Positions.contains(4)) {
                symbologyModifier = 5
            } else if (fnc1Positions.contains(1) || fnc1Positions.contains(5)) {
                symbologyModifier = 6
            } else {
                symbologyModifier = 4
            }
        } else {
            if (fnc1Positions.contains(0) || fnc1Positions.contains(4)) {
                symbologyModifier = 2
            } else if (fnc1Positions.contains(1) || fnc1Positions.contains(5)) {
                symbologyModifier = 3
            } else {
                symbologyModifier = 1
            }
        }

        return returndecode(bytes, result, byteSegments, symbologyModifier)
    }

    private static func returndecode(bytes: Array<UInt8>, result: ECIStringBuilder,
        byteSegments: ArrayList<Array<UInt8>>, symbologyModifier: Int64): DecoderResult {
        return DecoderResult(bytes, result.toString(),
            if (byteSegments.isEmpty()) {
            ArrayList<Array<UInt8>>()
        } else {
            byteSegments
        }, String(), symbologyModifier);
    }

    /**
     * See ISO 16022:2006, 5.2.3 and Annex C, Table C.2
     */
    private static func decodeAsciiSegment(bits: BitSource, result: ECIStringBuilder, resultTrailer: ArrayList<Char>,
        fnc1positions: Set<Int64>): Mode {
        var upperShift: Bool = false;
        do {
            var oneByte: Int64 = bits.readBits(8);
            if (oneByte == 0) {
                throw FormatException.getFormatInstance();
            } else if (oneByte <= 128) { // ASCII data (ASCII value + 1)
                if (upperShift) {
                    oneByte += 128
                }
                result.append(Char(oneByte - 1));

                return Mode.ASCII_ENCODE;
            } else if (oneByte == 129) { // Pad

                return Mode.PAD_ENCODE;
            } else if (oneByte <= 229) { // 2-digit data 00-99 (Numeric Value + 130)
                var value: Int64 = oneByte - 130
                if (value < 10) { // pad with '0' for single digit values
                    result.append('0');
                }
                result.append(value);
            } else {
                match (oneByte) {
                    case 230 => return Mode.C40_ENCODE;
                    case 231 => return Mode.BASE256_ENCODE;
                    case 232 =>
                        // FNC1
                        fnc1positions.put(result.length());
                        result.append(Char(29)) // translate as ASCII 29
                        break
                    case 233 => break // Structured Append
                    case 234 => break // Reader Programming 
                    case 235 =>
                        // Upper Shift (shift to Extended ASCII)
                        upperShift = true
                        break
                    case 236 =>
                        // 05 Macro
                        result.append("[)>\u{001E05}\u{001D}");
                        resultTrailer.insertAll(0, "\u{001E}\u{0004}".toRuneArray());
                        break
                    case 237 =>
                        // 06 Macro
                        result.append("[)>\u{001E06}\u{001D}");
                        resultTrailer.insertAll(0, "\u{001E}\u{0004}".toRuneArray());
                        break
                    case 238 => return Mode.ANSIX12_ENCODE; // Latch to ANSI X12 encodation
                    case 239 => return Mode.TEXT_ENCODE; // Latch to Text encodation
                    case 240 => return Mode.EDIFACT_ENCODE; // Latch to EDIFACT encodation
                    case 241 => return Mode.ECI_ENCODE; // ECI Character
                    case _ =>
                        // Not to be used in ASCII encodation
                        // but work around encoders that end with 254, latch back to ASCII
                        if (oneByte != 254 || bits.available() != 0) {
                            throw FormatException.getFormatInstance();
                        }
                        break
                }
            }
        } while (bits.available() > 0)

        return Mode.ASCII_ENCODE;
    }

    /**
     * See ISO 16022:2006, 5.2.5 and Annex C, Table C.1
     */
    private static func decodeC40Segment(bits: BitSource, result: ECIStringBuilder, fnc1positions: Set<Int64>) {
        // Three C40 values are encoded in a 16-bit value as
        // (1600 * C1) + (40 * C2) + C3 + 1
        // TODO(bbrown): The Upper Shift with C40 doesn't work in the 4 value scenario all the time
        var upperShift: Bool = false;

        var cValues: Array<Int64> = Array<Int64>(3, item: 0)
        var shift: Int64 = 0;

        do {
            // If there is only one byte left then it will be encoded as ASCII
            if (bits.available() == 8) {
                return;
            }
            var firstByte: Int64 = bits.readBits(8);
            if (firstByte == 254) { // Unlatch codeword
                return;
            }

            parseTwoBytes(firstByte, bits.readBits(8), cValues);

            for (i in 0..3) {
                var cValue: Int64 = cValues[i]
                match (shift) {
                    case 0 => if (cValue < 3) {
                        shift = cValue + 1
                    } else if (cValue < C40_BASIC_SET_CHARS.size) {
                        var c40char: Char = C40_BASIC_SET_CHARS[cValue]
                        if (upperShift) {
                            result.append(Char(c40char.hashCode() + 128));
                            upperShift = false
                        } else {
                            result.append(c40char);
                        }
                    } else {
                        throw FormatException.getFormatInstance();
                    }
                    case 1 =>
                        if (upperShift) {
                            result.append(Char(cValue + 128));
                            upperShift = false
                        } else {
                            result.append(Char(cValue))
                        }
                        shift = 0
                    case 2 => (upperShift, shift) = exdecodeC40Segment2(upperShift, result, cValue, fnc1positions)
                    case 3 => (upperShift, shift) = exdecodeC40Segment3(upperShift, result, cValue)
                    case _ => throw FormatException.getFormatInstance();
                }
            }
        } while (bits.available() > 0)
    }

    private static func exdecodeC40Segment2(upperShift: Bool, result: ECIStringBuilder, cValue: Int64,
        fnc1positions: Set<Int64>): (Bool, Int64) {
        var upperShift_p = upperShift
        if (cValue < C40_SHIFT2_SET_CHARS.size) {
            var c40char: Char = C40_SHIFT2_SET_CHARS[cValue]
            if (upperShift_p) {
                result.append(Char(c40char.hashCode() + 128));
                upperShift_p = false
            } else {
                result.append(c40char);
            }
        } else {
            match (cValue) {
                case 27 =>
                    // FNC1
                    fnc1positions.put(result.length());
                    result.append(Char(29)) // translate as ASCII 29
                case 30 => // Upper Shift
                    upperShift_p = true
                case _ => throw FormatException.getFormatInstance();
            }
        }
        return (upperShift_p, 0)
    }

    private static func exdecodeC40Segment3(upperShift: Bool, result: ECIStringBuilder, cValue: Int64): (Bool, Int64) {
        var upperShift_p = upperShift
        if (upperShift_p) {
            result.append(Char(cValue + 224));
            upperShift_p = false
        } else {
            result.append(Char(cValue + 96));
        }
        return (upperShift_p, 0)
    }

    /**
     * See ISO 16022:2006, 5.2.6 and Annex C, Table C.2
     */
    private static func decodeTextSegment(bits: BitSource, result: ECIStringBuilder, fnc1positions: Set<Int64>) {
        // Three Text values are encoded in a 16-bit value as
        // (1600 * C1) + (40 * C2) + C3 + 1
        // TODO(bbrown): The Upper Shift with Text doesn't work in the 4 value scenario all the time

        var upperShift: Bool = false;

        var cValues: Array<Int64> = Array<Int64>(3, item: 0)
        var shift: Int64 = 0;
        do {
            // If there is only one byte left then it will be encoded as ASCII
            if (bits.available() == 8) {
                return;
            }
            var firstByte: Int64 = bits.readBits(8);
            if (firstByte == 254) { // Unlatch codeword

                return;
            }

            parseTwoBytes(firstByte, bits.readBits(8), cValues);

            for (i in 0..3) {
                var cValue: Int64 = cValues[i]
                match (shift) {
                    case 0 => if (cValue < 3) {
                        shift = cValue + 1
                    } else if (cValue < TEXT_BASIC_SET_CHARS.size) {
                        var textChar: Char = TEXT_BASIC_SET_CHARS[cValue]
                        if (upperShift) {
                            result.append(Char(textChar.hashCode() + 128));
                            upperShift = false
                        } else {
                            result.append(textChar);
                        }
                    } else {
                        throw FormatException.getFormatInstance();
                    }
                    case 1 =>
                        if (upperShift) {
                            result.append(Char(cValue + 128));
                            upperShift = false
                        } else {
                            result.append(Char(cValue))
                        }
                        shift = 0
                    case 2 => (upperShift, shift) = exdecodeTextSegment2(upperShift, result, cValue, fnc1positions)
                    case 3 => (upperShift, shift) = exdecodeTextSegment3(upperShift, result, cValue)
                    case _ => throw FormatException.getFormatInstance();
                }
            }
        } while (bits.available() > 0)
    }

    private static func exdecodeTextSegment2(upperShift: Bool, result: ECIStringBuilder, cValue: Int64,
        fnc1positions: Set<Int64>): (Bool, Int64) {
        var upperShift_p = upperShift
        // Shift 2 for Text is the same encoding as C40
        if (cValue < TEXT_SHIFT2_SET_CHARS.size) {
            var textChar: Char = TEXT_SHIFT2_SET_CHARS[cValue]
            if (upperShift_p) {
                result.append(Char(textChar.hashCode() + 128));
                upperShift_p = false
            } else {
                result.append(textChar);
            }
        } else {
            match (cValue) {
                case 27 =>
                    // FNC1
                    fnc1positions.put(result.length());
                    result.append(Char(29)) // translate as ASCII 29
                case 30 => // Upper Shift
                    upperShift_p = true
                case _ => throw FormatException.getFormatInstance();
            }
        }
        return (upperShift_p, 0)
    }

    private static func exdecodeTextSegment3(upperShift: Bool, result: ECIStringBuilder, cValue: Int64): (Bool, Int64) {
        var upperShift_p = upperShift
        if (cValue < TEXT_SHIFT3_SET_CHARS.size) {
            var textChar: Char = TEXT_SHIFT3_SET_CHARS[cValue]
            if (upperShift_p) {
                result.append(Char(textChar.hashCode() + 128));
                upperShift_p = false
            } else {
                result.append(textChar);
            }
            return (upperShift_p, 0)
        } else {
            throw FormatException.getFormatInstance();
        }
    }

    /**
     * See ISO 16022:2006, 5.2.7
     */
    private static func decodeAnsiX12Segment(bits: BitSource, result: ECIStringBuilder) {
        // Three ANSI X12 values are encoded in a 16-bit value as
        // (1600 * C1) + (40 * C2) + C3 + 1
        var cValues: Array<Int64> = Array<Int64>(3, item: 0)
        do {
            // If there is only one byte left then it will be encoded as ASCII
            if (bits.available() == 8) {
                return;
            }
            var firstByte: Int64 = bits.readBits(8);
            if (firstByte == 254) { // Unlatch codeword
                return;
            }

            parseTwoBytes(firstByte, bits.readBits(8), cValues);

            for (i in 0..3) {
                var cValue: Int64 = cValues[i]
                match (cValue) {
                    case 0 => // X12 segment terminator <CR>
                        result.append('\r');
                    case 1 => // X12 segment separator *
                        result.append('*');
                    case 2 => // X12 sub-element separator >
                        result.append('>');
                    case 3 => // space
                        result.append(' ');
                    case _ => if (cValue < 14) { // 0 - 9
                        result.append(Char(cValue + 44));
                    } else if (cValue < 40) { // A - Z
                        result.append(Char(cValue + 51));
                    } else {
                        throw FormatException.getFormatInstance();
                    }
                }
            }
        } while (bits.available() > 0)
    }

    private static func parseTwoBytes(firstByte: Int64, secondByte: Int64, result: Array<Int64>) {
        var fullBitValue = (firstByte << 8) + secondByte - 1
        var temp = fullBitValue / 1600
        result[0] = temp
        fullBitValue -= temp * 1600
        temp = fullBitValue / 40
        result[1] = temp
        result[2] = fullBitValue - temp * 40
    }

    /**
     * See ISO 16022:2006, 5.2.8 and Annex C Table C.3
     */
    private static func decodeEdifactSegment(bits: BitSource, result: ECIStringBuilder) {
        do {
            // If there is only two or less bytes left then it will be encoded as ASCII
            if (bits.available() <= 16) {
                return;
            }

            for (i in 0..4) {
                var edifactValue: Int64 = bits.readBits(6);

                // Check for the unlatch character
                if (edifactValue == 0x1F) { // 011111
                    // Read rest of byte, which should be 0, and stop
                    var bitsLeft: Int64 = 8 - bits.getBitOffset()
                    if (bitsLeft != 8) {
                        bits.readBits(bitsLeft);
                    }
                    return;
                }

                if ((edifactValue & 0x20) == 0) { // no 1 in the leading (6th) bit
                    edifactValue |= 0x40
                    // Add a leading 01 to the 6 bit binary value
                }
                result.append(Char(edifactValue))
            }
        } while (bits.available() > 0)
    }

    /**
     * See ISO 16022:2006, 5.2.9 and Annex B, B.2
     */
    private static func decodeBase256Segment(
        bits: BitSource,
        result: ECIStringBuilder,
        byteSegments: ArrayList<Array<Byte>>
    ) {

        // Figure out how long the Base 256 Segment is.
        var codewordPosition = 1 + bits.getByteOffset()

        // position is 1-indexed
        var d1 = unrandomize255State(bits.readBits(8), codewordPosition);
        codewordPosition++
        var count: Int64
        if (d1 == 0) { // Read the remainder of the symbol
            count = bits.available() / 8
        } else if (d1 < 250) {
            count = d1
        } else {
            count = 250 * (d1 - 249) + unrandomize255State(bits.readBits(8), codewordPosition)
            codewordPosition++
        }

        // We're seeing NegativeArraySizeException errors from users.
        if (count < 0) {
            throw FormatException.getFormatInstance();
        }

        var bytes: Array<UInt8> = Array<UInt8>(count, item: 0)

        for (i in 0..count) {
            // Have seen this particular error in the wild, such as at
            // http://www.bcgen.com/demo/IDAutomationStreamingDataMatrix.aspx?MODE=3&D=Fred&PFMT=3&PT=F&X=0.3&O=0&LM=0.2
            if (bits.available() < 8) {
                throw FormatException.getFormatInstance();
            }
            bytes[i] = UInt8(unrandomize255State(bits.readBits(8), codewordPosition))
            codewordPosition++
        }
        byteSegments.append(bytes);
        result.append(StandardCharsets.ISO_8859_1.newDecoder().decode(bytes));
    }

    /**
     * See ISO 16022:2007, 5.4.1
     */
    private static func decodeECISegment(bits: BitSource, result: ECIStringBuilder) {
        if (bits.available() < 8) {
            throw FormatException.getFormatInstance();
        }
        var c1: Int64 = bits.readBits(8);
        if (c1 <= 127) {
            result.appendECI(c1 - 1);
        }
    }

    /**
     * See ISO 16022:2006, Annex B, B.2
     */
    private static func unrandomize255State(randomizedBase256Codeword: Int64, base256CodewordPosition: Int64): Int64 {
        var pseudoRandomNumber = ((149 * base256CodewordPosition) % 255) + 1
        var tempVariable: Int64 = randomizedBase256Codeword - pseudoRandomNumber
        if (tempVariable >= 0) {
            return tempVariable
        } else {
            return tempVariable + 256
        }
    }
}
