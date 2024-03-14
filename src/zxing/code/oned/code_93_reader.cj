/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * <p>Decodes Code 93 barcodes.</p>
 *
 * @author Sean Owen
 * @see Code39Reader
 */
public open class Code93Reader <: OneDReader {
    // Note that 'abcd' are dummy characters in place of control characters.
    static let ALPHABET_STRING: UTF32String = UTF32String("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%abcd*");

    /**
     * These represent the encodings of characters, as patterns of wide and narrow bars.
     * The 9 least-significant bits of each int correspond to the pattern of wide and narrow.
     */
    static let CHARACTER_ENCODINGS: Array<Int64> = [
        0x114,
        0x148,
        0x144,
        0x142,
        0x128,
        0x124,
        0x122,
        0x150,
        0x112,
        0x10A, // 0-9
        0x1A8,
        0x1A4,
        0x1A2,
        0x194,
        0x192,
        0x18A,
        0x168,
        0x164,
        0x162,
        0x134, // A-J
        0x11A,
        0x158,
        0x14C,
        0x146,
        0x12C,
        0x116,
        0x1B4,
        0x1B2,
        0x1AC,
        0x1A6, // K-T
        0x196,
        0x19A,
        0x16C,
        0x166,
        0x136,
        0x13A, // U-Z
        0x12E,
        0x1D4,
        0x1D2,
        0x1CA,
        0x16E,
        0x176,
        0x1AE, // - - %
        0x126,
        0x1DA,
        0x1D6,
        0x132,
        0x15E // Control chars? $-*
    ]
    static let ASTERISK_ENCODING: Int64 = CHARACTER_ENCODINGS[47]

    private var decodeRowResult: ArrayList<Char> = ArrayList<Char>( /*Array<Char>(20,item:' ') */ )
    private var counters: Array<Int64> = Array<Int64>(6, item: 0)

    public init() {
    }

    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        var start: Array<Int64> = findAsteriskPattern(row);

        // Read off white space
        var nextStart: Int64 = row.getNextSet(start[1]);
        var end: Int64 = row.getSize();
        counters = Array<Int64>(6, item: 0)
        var theCounters: Array<Int64> = counters
        var result: ArrayList<Char> = decodeRowResult
        var decodedChar: Char
        var lastStart: Int64
        do {
            recordPattern(row, nextStart, theCounters);
            var pattern: Int64 = toPattern(theCounters);
            if (pattern < 0) {
                throw NotFoundException.getNotFoundInstance();
            }
            decodedChar = patternToChar(pattern)
            result.append(decodedChar);
            lastStart = nextStart

            for (i in 0..theCounters.size) {
                nextStart += theCounters[i]
            }

            // Read off white space
            nextStart = row.getNextSet(nextStart)
        } while (decodedChar != '*')
        result.remove(result.size - 1);

        // remove asterisk
        var lastPatternSize: Int64 = 0;

        for (i in 0..theCounters.size) {
            lastPatternSize += theCounters[i]
        }

        // Should be at least one more black module
        if (nextStart == end || !row.get(nextStart)) {
            throw NotFoundException.getNotFoundInstance();
        }

        if (result.size < 2) {
            // false positive -- need at least 2 checksum digits
            throw NotFoundException.getNotFoundInstance();
        }

        checkChecksums(UTF32String(result));

        // Remove checksum digits
        result = result[Range<Int64>(0, result.size - 2, 1, true, true, false)]

        var resultString: String = decodeExtended(UTF32String(result));

        var left: Float32 = Float32(start[1] + start[0]) / 2.0
        var right: Float32 = Float32(lastStart) + Float32(lastPatternSize) / 2.0
        var resultObject: Result = Result(resultString, Array<UInt8>(),
            Array<ResultPoint>([ResultPoint(left, Float32(rowNumber)), ResultPoint(right, Float32(rowNumber))]),
            BarcodeFormat.CODE_93);
        resultObject.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]G0");

        return resultObject
    }

    private func findAsteriskPattern(row: BitArray): Array<Int64> {
        var width: Int64 = row.getSize();
        var rowOffset: Int64 = row.getNextSet(0);
        counters = Array<Int64>(6, item: 0)
        var theCounters: Array<Int64> = counters
        var patternStart: Int64 = rowOffset
        var isWhite: Bool = false;
        var patternLength: Int64 = theCounters.size;

        var counterPosition: Int64 = 0;

        for (i in rowOffset..width) {
            if (row.get(i) != isWhite) {
                theCounters[counterPosition] = theCounters[counterPosition] + 1
            } else {
                if (counterPosition == patternLength - 1) {
                    if (toPattern(theCounters) == ASTERISK_ENCODING) {
                        let returnData: Array<Int64> = [patternStart, i]
                        return returnData
                    }
                    patternStart += theCounters[0] + theCounters[1]
                    System.arraycopy(theCounters, 2, theCounters, 0, counterPosition - 1);
                    theCounters[counterPosition - 1] = 0
                    theCounters[counterPosition] = 0
                    counterPosition--
                } else {
                    counterPosition++
                }
                theCounters[counterPosition] = 1
                isWhite = !isWhite
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }

    private static func toPattern(counters: Array<Int64>): Int64 {
        var sum: Int64 = 0;
        for (i in 0..counters.size) {
            sum += counters[i]
        }
        var pattern: Int64 = 0;
        var max: Int64 = counters.size;

        for (i in 0..max) {
            //Compute the center of the rectangle
            var scaled_s = Float32(counters[i]) * 9.0 / Float32(sum)
            var scaled_o = round(scaled_s)

            var scaled_d = Int64(scaled_s) % 2
            var scaled_f = scaled_s - Float32(Int64(scaled_s))
            if (scaled_d == 0 && scaled_f == 0.5) {
                scaled_o = scaled_o + 1.0
            }

            var scaled: Int64 = Int64(scaled_o)

            if (scaled < 1 || scaled > 4) {
                return -1;
            }
            if ((i & 0x01) == 0) {
                for (j in 0..scaled) {
                    pattern = (pattern << 1) | 0x01
                }
            } else {
                pattern <<= scaled
            }
        }
        return pattern
    }

    private static func patternToChar(pattern: Int64): Char {
        for (i in 0..CHARACTER_ENCODINGS.size) {
            if (CHARACTER_ENCODINGS[i] == pattern) {
                return ALPHABET_STRING[i]
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }

    private static func decodeExtended(encoded: UTF32String): String {
        var length: Int64 = encoded.size;
        var decoded: ArrayList<Char> = ArrayList<Char>();

        var i: Int64 = 0
        while (i < length) {
            var c: Char = encoded.get(i);

            if (c >= 'a' && c <= 'd') {
                if (i >= length - 1) {
                    throw FormatException.getFormatInstance();
                }
                var next: Char = encoded.get(i + 1);
                var decodedChar: Char = '\0';
                if (c == 'd') {
                    // +A to +Z map to a to z
                    if (next >= 'A' && next <= 'Z') {
                        decodedChar = Char(next.hashCode() + 32)
                    } else {
                        throw FormatException.getFormatInstance();
                    }
                } else if (c == 'a') {
                    // $A to $Z map to control codes SH to SB
                    if (next >= 'A' && next <= 'Z') {
                        decodedChar = Char(next.hashCode() - 64)
                    } else {
                        throw FormatException.getFormatInstance();
                    }
                } else if (c == 'b') {
                    decodedChar = getDecoded93Char(next)
                } else if (c == 'c') {
                    // /A to /O map to ! to , and /Z maps to :
                    if (next >= 'A' && next <= 'O') {
                        decodedChar = Char(next.hashCode() - 32)
                    } else if (next == 'Z') {
                        decodedChar = ':'
                    } else {
                        throw FormatException.getFormatInstance();
                    }
                }
                decoded.append(decodedChar);

                // bump up i again since we read two characters
                i++
            } else {
                decoded.append(c);
            }
            i++
        }
        return String(decoded);
    }

    private static func getDecoded93Char(next: Char) {
        var decodedChar = ' '
        if (next >= 'A' && next <= 'E') {
            // %A to %E map to control codes ESC to USep
            decodedChar = Char(next.hashCode() - 38)
        } else if (next >= 'F' && next <= 'J') {
            // %F to %J map to ; < = > ?
            decodedChar = Char(next.hashCode() - 11)
        } else if (next >= 'K' && next <= 'O') {
            // %K to %O map to [ \ ] ^ _
            decodedChar = Char(next.hashCode() + 16)
        } else if (next >= 'P' && next <= 'T') {
            // %P to %T map to { | } ~ DEL
            decodedChar = Char(next.hashCode() + 43)
        } else if (next == 'U') {
            // %U map to NUL
            decodedChar = '\0'
        } else if (next == 'V') {
            // %V map to @
            decodedChar = '@'
        } else if (next == 'W') {
            // %W map to `
            decodedChar = '`'
        } else if (next >= 'X' && next <= 'Z') {
            // %X to %Z all map to DEL (127)
            decodedChar = Char(127)
        } else {
            throw FormatException.getFormatInstance();
        }
        return decodedChar
    }

    private static func checkChecksums(result: UTF32String) {
        var length: Int64 = result.size;
        checkOneChecksum(result, length - 2, 20);
        checkOneChecksum(result, length - 1, 15);
    }

    private static func checkOneChecksum(result: UTF32String, checkPosition: Int64, weightMax: Int64) {
        var weight: Int64 = 1
        var total: Int64 = 0
        var i: Int64 = checkPosition - 1
        while (i >= 0) {
            total += weight * ALPHABET_STRING.indexOf(result.get(i).toString()).getOrThrow()
            weight++

            if (weight > weightMax) {
                weight = 1
            }
            i--
        }
        if (result.get(checkPosition) != ALPHABET_STRING[total % 47]) {
            throw ChecksumException.getChecksumInstance();
        }
    }
}
