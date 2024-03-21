/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.datamatrix.encoder

from std import math.*
from std import format.*
from charset import charset.tools.UTF32String

/**
 * DataMatrix ECC 200 data encoder following the algorithm described in ISO/IEC 16022:200(E) in
 * annex S.
 */
public class HighLevelEncoder {
    /**
     * Padding character
     */
    private static let PAD: Char = Char(129)

    /**
     * mode latch to C40 encodation mode
     */
    public static let LATCH_TO_C40: Char = Char(230)

    /**
     * mode latch to Base 256 encodation mode
     */
    static let LATCH_TO_BASE256: Char = Char(231)

    /**
     * FNC1 Codeword
     */
    //private static final char FNC1 = 232;
    /**
     * Structured Append Codeword
     */
    //private static final char STRUCTURED_APPEND = 233;
    /**
     * Reader Programming
     */
    //private static final char READER_PROGRAMMING = 234;
    /**
     * Upper Shift
     */
    static let UPPER_SHIFT: Char = Char(235)

    /**
     * 05 Macro
     */
    private static let MACRO_05: Char = Char(236)

    /**
     * 06 Macro
     */
    private static let MACRO_06: Char = Char(237)

    /**
     * mode latch to ANSI X.12 encodation mode
     */
    static let LATCH_TO_ANSIX12: Char = Char(238)

    /**
     * mode latch to Text encodation mode
     */
    static let LATCH_TO_TEXT: Char = Char(239)

    /**
     * mode latch to EDIFACT encodation mode
     */
    static let LATCH_TO_EDIFACT: Char = Char(240)

    /**
     * ECI character (Extended Channel Interpretation)
     */
    //private static final char ECI = 241;

    /**
     * Unlatch from C40 encodation
     */
    static let C40_UNLATCH: Char = Char(254)

    /**
     * Unlatch from X12 encodation
     */
    static let X12_UNLATCH: Char = Char(254)

    /**
     * 05 Macro header
     */
    static let MACRO_05_HEADER: UTF32String = UTF32String("[)>\u{001E}05\u{001D}");

    /**
     * 06 Macro header
     */
    static let MACRO_06_HEADER: UTF32String = UTF32String("[)>\u{001E}06\u{001D}");

    /**
     * Macro trailer
     */
    static let MACRO_TRAILER: UTF32String = UTF32String("\u{001E}\u{0004}");

    public static let ASCII_ENCODATION: Int64 = 0;
    public static let C40_ENCODATION: Int64 = 1;
    public static let TEXT_ENCODATION: Int64 = 2;
    public static let X12_ENCODATION: Int64 = 3;
    public static let EDIFACT_ENCODATION: Int64 = 4;
    public static let BASE256_ENCODATION: Int64 = 5;

    init() {}

    private static func randomize253State(codewordPosition: Int64): Char {
        let pseudoRandom = ((149 * codewordPosition) % 253) + 1
        let tempVariable = PAD.hashCode() + pseudoRandom
        if (tempVariable <= 254) {
            let t = UInt8(tempVariable)
            return Char(t)
        } else {
            let t = UInt8(tempVariable - 254)
            return Char(t)
        }
    }

    /**
     * Performs message encoding of a DataMatrix message using the algorithm described in annex P
     * of ISO/IEC 16022:2000(E).
     *
     * @param msg the message
     * @return the encoded message (the char values range from 0 to 255)
     */
    public static func encodeHighLevel(msg: UTF32String): UTF32String {
        return encodeHighLevel(msg, SymbolShapeHint.FORCE_NONE, None, None, false);
    }

    /**
     * Performs message encoding of a DataMatrix message using the algorithm described in annex P
     * of ISO/IEC 16022:2000(E).
     *
     * @param msg     the message
     * @param shape   requested shape. May be {@code SymbolShapeHint.FORCE_NONE},
     * {@code SymbolShapeHint.FORCE_SQUARE} or {@code SymbolShapeHint.FORCE_RECTANGLE}.
     * @param minSize the minimum symbol size constraint or null for no constraint
     * @param maxSize the maximum symbol size constraint or null for no constraint
     * @return the encoded message (the char values range from 0 to 255)
     */
    public static func encodeHighLevel(
        msg: UTF32String,
        shape: SymbolShapeHint,
        minSize: ?Dimension,
        maxSize: ?Dimension
    ): UTF32String {
        return encodeHighLevel(msg, shape, minSize, maxSize, false);
    }

    /**
     * Performs message encoding of a DataMatrix message using the algorithm described in annex P
     * of ISO/IEC 16022:2000(E).
     *
     * @param msg     the message
     * @param shape   requested shape. May be {@code SymbolShapeHint.FORCE_NONE},
     * {@code SymbolShapeHint.FORCE_SQUARE} or {@code SymbolShapeHint.FORCE_RECTANGLE}.
     * @param minSize the minimum symbol size constraint or null for no constraint
     * @param maxSize the maximum symbol size constraint or null for no constraint
     * @param forceC40 enforce C40 encoding
     * @return the encoded message (the char values range from 0 to 255)
     */
    public static func encodeHighLevel(
        msg: UTF32String,
        shape: SymbolShapeHint,
        minSize: ?Dimension,
        maxSize: ?Dimension,
        forceC40: Bool
    ): UTF32String {
        //the codewords 0..255 are encoded as Unicode characters
        var c40Encoder: C40Encoder = C40Encoder();
        let encoders: Array<Encoder> = [
            ASCIIEncoder(),
            c40Encoder,
            TextEncoder(),
            X12Encoder(),
            EdifactEncoder(),
            Base256Encoder()
        ]

        var context: EncoderContext = EncoderContext(msg);
        context.setSymbolShape(shape);
        context.setSizeConstraints(minSize, maxSize);

        if (msg.startsWith(MACRO_05_HEADER) && msg.endsWith(MACRO_TRAILER)) {
            context.writeCodeword(MACRO_05)
            context.setSkipAtEnd(2);
            context.pos += MACRO_05_HEADER.charSize
        } else if (msg.startsWith(MACRO_06_HEADER) && msg.endsWith(MACRO_TRAILER)) {
            context.writeCodeword(MACRO_06)
            context.setSkipAtEnd(2);
            context.pos += MACRO_06_HEADER.charSize
        }
        var encodingMode: Int64 = ASCII_ENCODATION

        //Default mode
        if (forceC40) {
            c40Encoder.encodeMaximal(context);
            encodingMode = context.getNewEncoding()
            context.resetEncoderSignal();
        }

        while (context.hasMoreCharacters()) {
            encoders[encodingMode].encode(context);
            if (context.getNewEncoding() >= 0) {
                encodingMode = context.getNewEncoding()
                context.resetEncoderSignal();
            }
        }

        var len: Int64 = context.getCodewordCount();
        context.updateSymbolInfo();
        var capacity: Int64 = context.getSymbolInfo().getOrThrow().getDataCapacity();
        if (len < capacity && encodingMode != ASCII_ENCODATION && encodingMode != BASE256_ENCODATION && encodingMode !=
            EDIFACT_ENCODATION) {
            context.writeCodeword('\u{00fe}');
        }

        //Padding
        var codewords: ArrayList<Char> = context.getCodewords();
        if (codewords.size < capacity) {
            codewords.append(PAD);
        }
        while (codewords.size < capacity) {
            codewords.append(randomize253State(codewords.size + 1));
        }

        return UTF32String(context.getCodewords());
    }

    static func visualize(codewords: UTF32String): UTF32String {
        var sb: ArrayList<Char> = ArrayList<Char>();
        for (i in 0..codewords.charSize) {
            if (i > 0) {
                sb.append(' ');
            }
            sb.appendAll(codewords.get(i).hashCode().toString().toRuneArray())
        }
        return UTF32String(sb);
    }

    static func lookAheadTest(msg: UTF32String, startpos: Int64, currentMode: Int64): Int64 {
        var newMode: Int64 = lookAheadTestIntern(msg, startpos, currentMode);
        if (currentMode == X12_ENCODATION && newMode == X12_ENCODATION) {
            var endpos: Int64 = min(startpos + 3, msg.charSize);
            for (i in startpos..endpos) {
                if (!isNativeX12(msg.get(i))) {
                    return ASCII_ENCODATION
                }
            }
        } else if (currentMode == EDIFACT_ENCODATION && newMode == EDIFACT_ENCODATION) {
            var endpos: Int64 = min(startpos + 4, msg.charSize);
            for (i in startpos..endpos) {
                if (!isNativeEDIFACT(msg.get(i))) {
                    return ASCII_ENCODATION
                }
            }
        }
        return newMode
    }

    static func lookAheadTestIntern(msg: UTF32String, startpos: Int64, currentMode: Int64): Int64 {
        if (startpos >= msg.charSize) {
            return currentMode
        }
        var charCounts: Array<Float32>

        //step J
        if (currentMode == ASCII_ENCODATION) {
            charCounts = [0.0, 1.0, 1.0, 1.0, 1.0, 1.25]
        } else {
            charCounts = [1.0, 2.0, 2.0, 2.0, 2.0, 2.25]
            charCounts[currentMode] = 0.0
        }

        var charsProcessed = 0;
        var mins = Array<Byte>(6, item: 0)
        var intCharCounts = Array<Int64>(6, item: 0)
        while (true) {
            //step K
            if ((startpos + charsProcessed) == msg.charSize) {
                mins = Array<Byte>(6, item: 0)
                intCharCounts = Array<Int64>(6, item: 0)
                var min: Int64 = findMinimums(charCounts, intCharCounts, Int64(Int32.Max), mins);
                var minCount: Int64 = getMinimumCount(mins);

                if (intCharCounts[ASCII_ENCODATION] == min) {
                    return ASCII_ENCODATION
                }
                if (minCount == 1) {
                    if (mins[BASE256_ENCODATION] > 0) {
                        return BASE256_ENCODATION
                    }
                    if (mins[EDIFACT_ENCODATION] > 0) {
                        return EDIFACT_ENCODATION
                    }
                    if (mins[TEXT_ENCODATION] > 0) {
                        return TEXT_ENCODATION
                    }
                    if (mins[X12_ENCODATION] > 0) {
                        return X12_ENCODATION
                    }
                }
                return C40_ENCODATION
            }

            var c: Char = msg.get(startpos + charsProcessed);
            charsProcessed++

            //step L
            if (isDigit(c)) {
                charCounts[ASCII_ENCODATION] += 0.5f32
            } else if (isExtendedASCII(c)) {
                charCounts[ASCII_ENCODATION] = ceil(charCounts[ASCII_ENCODATION])
                charCounts[ASCII_ENCODATION] += 2.0f32
            } else {
                charCounts[ASCII_ENCODATION] = ceil(charCounts[ASCII_ENCODATION])
                charCounts[ASCII_ENCODATION] = charCounts[ASCII_ENCODATION] + 1.0
            }

            //step M
            if (isNativeC40(c)) {
                charCounts[C40_ENCODATION] += 2.0f32 / 3.0f32
            } else if (isExtendedASCII(c)) {
                charCounts[C40_ENCODATION] += 8.0f32 / 3.0f32
            } else {
                charCounts[C40_ENCODATION] += 4.0f32 / 3.0f32
            }

            //step N
            if (isNativeText(c)) {
                charCounts[TEXT_ENCODATION] += 2.0f32 / 3.0f32
            } else if (isExtendedASCII(c)) {
                charCounts[TEXT_ENCODATION] += 8.0f32 / 3.0f32
            } else {
                charCounts[TEXT_ENCODATION] += 4.0f32 / 3.0f32
            }

            //step O
            if (isNativeX12(c)) {
                charCounts[X12_ENCODATION] += 2.0f32 / 3.0f32
            } else if (isExtendedASCII(c)) {
                charCounts[X12_ENCODATION] += 13.0f32 / 3.0f32
            } else {
                charCounts[X12_ENCODATION] += 10.0f32 / 3.0f32
            }

            //step P
            if (isNativeEDIFACT(c)) {
                charCounts[EDIFACT_ENCODATION] += 3.0f32 / 4.0f32
            } else if (isExtendedASCII(c)) {
                charCounts[EDIFACT_ENCODATION] += 17.0f32 / 4.0f32
            } else {
                charCounts[EDIFACT_ENCODATION] += 13.0f32 / 4.0f32
            }

            // step Q
            if (isSpecialB256(c)) {
                charCounts[BASE256_ENCODATION] += 4.0f32
            } else {
                charCounts[BASE256_ENCODATION] = charCounts[BASE256_ENCODATION] + 1.0
            }

            //step R
            if (charsProcessed >= 4) {
                mins = Array<Byte>(6, item: 0)
                intCharCounts = Array<Int64>(6, item: 0)
                findMinimums(charCounts, intCharCounts, Int64(Int32.Max), mins);

                if (intCharCounts[ASCII_ENCODATION] < min(
                    intCharCounts[BASE256_ENCODATION],
                    intCharCounts[C40_ENCODATION],
                    intCharCounts[TEXT_ENCODATION],
                    intCharCounts[X12_ENCODATION],
                    intCharCounts[EDIFACT_ENCODATION]
                )) {
                    return ASCII_ENCODATION
                }
                if (intCharCounts[BASE256_ENCODATION] < intCharCounts[ASCII_ENCODATION] ||
                    intCharCounts[BASE256_ENCODATION] + 1 < min(
                    intCharCounts[C40_ENCODATION],
                    intCharCounts[TEXT_ENCODATION],
                    intCharCounts[X12_ENCODATION],
                    intCharCounts[EDIFACT_ENCODATION]
                )) {
                    return BASE256_ENCODATION
                }
                if (intCharCounts[EDIFACT_ENCODATION] + 1 < min(
                    intCharCounts[BASE256_ENCODATION],
                    intCharCounts[C40_ENCODATION],
                    intCharCounts[TEXT_ENCODATION],
                    intCharCounts[X12_ENCODATION],
                    intCharCounts[ASCII_ENCODATION]
                )) {
                    return EDIFACT_ENCODATION
                }
                if (intCharCounts[TEXT_ENCODATION] + 1 < min(
                    intCharCounts[BASE256_ENCODATION],
                    intCharCounts[C40_ENCODATION],
                    intCharCounts[EDIFACT_ENCODATION],
                    intCharCounts[X12_ENCODATION],
                    intCharCounts[ASCII_ENCODATION]
                )) {
                    return TEXT_ENCODATION
                }
                if (intCharCounts[X12_ENCODATION] + 1 < min(
                    intCharCounts[BASE256_ENCODATION],
                    intCharCounts[C40_ENCODATION],
                    intCharCounts[EDIFACT_ENCODATION],
                    intCharCounts[TEXT_ENCODATION],
                    intCharCounts[ASCII_ENCODATION]
                )) {
                    return X12_ENCODATION
                }
                if (intCharCounts[C40_ENCODATION] + 1 < min(
                    intCharCounts[ASCII_ENCODATION],
                    intCharCounts[BASE256_ENCODATION],
                    intCharCounts[EDIFACT_ENCODATION],
                    intCharCounts[TEXT_ENCODATION]
                )) {
                    if (intCharCounts[C40_ENCODATION] < intCharCounts[X12_ENCODATION]) {
                        return C40_ENCODATION
                    }
                    if (intCharCounts[C40_ENCODATION] == intCharCounts[X12_ENCODATION]) {
                        var p: Int64 = startpos + charsProcessed + 1
                        while (p < msg.charSize) {
                            var tc: Char = msg.get(p);
                            if (isX12TermSep(tc)) {
                                return X12_ENCODATION
                            }
                            if (!isNativeX12(tc)) {
                                break
                            }
                            p++
                        }
                        return C40_ENCODATION
                    }
                }
            }
        }
        return 0;
    }

    private static func min(f1: Int64, f2: Int64, f3: Int64, f4: Int64, f5: Int64): Int64 {
        return math.min(min(f1, f2, f3, f4), f5);
    }

    private static func min(f1: Int64, f2: Int64, f3: Int64, f4: Int64): Int64 {
        return math.min(f1, math.min(f2, min(f3, f4)));
    }

    private static func findMinimums(
        charCounts: Array<Float32>,
        intCharCounts: Array<Int64>,
        min: Int64,
        mins: Array<UInt8>
    ): Int64 {
        var min_ = min
        var mins_ = mins
        for (i in 0..6) {
            intCharCounts[i] = Int64(ceil(charCounts[i]))
            var current: Int64 = Int64(ceil(charCounts[i]))
            if (min_ > current) {
                min_ = current
                for (j in 0..mins.size) {
                    mins[j] = 0
                }
            }
            if (min_ == current) {
                mins[i] = mins[i] + 1
            }
        }
        return min_
    }

    private static func getMinimumCount(mins: Array<UInt8>): Int64 {
        var minCount: Int64 = 0;

        for (i in 0..6) {
            minCount += Int64(mins[i])
        }
        return minCount
    }

    static func isDigit(ch: Char): Bool {
        return ch >= '0' && ch <= '9'
    }

    static func isExtendedASCII(ch: Char): Bool {
        return ch.hashCode() >= 128 && ch.hashCode() <= 255
    }

    static func isNativeC40(ch: Char): Bool {
        return (ch == ' ') || (ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'Z')
    }

    static func isNativeText(ch: Char): Bool {
        return (ch == ' ') || (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'z')
    }

    static func isNativeX12(ch: Char): Bool {
        return isX12TermSep(ch) || (ch == ' ') || (ch >= '0' && ch <= '9') || (ch >= 'A' && ch <= 'Z')
    }

    private static func isX12TermSep(ch: Char): Bool {
        return (ch == '\r') || (ch == '*') || (ch == '>')
    }

    static func isNativeEDIFACT(ch: Char): Bool {
        return ch >= ' ' && ch <= '^'
    }

    private static func isSpecialB256(_: Char): Bool {
        return false; //TODO NOT IMPLEMENTED YET!!!
    }

    /**
     * Determines the number of consecutive characters that are encodable using numeric compaction.
     *
     * @param msg      the message
     * @param startpos the start position within the message
     * @return the requested character count
     */
    public static func determineConsecutiveDigitCount(msg: UTF32String, startpos: Int64): Int64 {
        var len: Int64 = msg.charSize;
        var idx: Int64 = startpos
        while (idx < len && isDigit(msg.get(idx))) {
            idx++
        }
        return idx - startpos
    }

    static func illegalCharacter(c: Char) {
        var hex: String = c.hashCode().format("x");

        hex = "0000"[Range<Int64>(0, 4 - hex.size, 1, true, true, false)] + hex
        throw IllegalArgumentException("Illegal character: " + c.toString() + " (0x" + hex + ")");
    }
}
