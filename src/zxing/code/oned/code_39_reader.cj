/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * <Decodes Code 39 barcodes. Supports "Full ASCII Code 39" if USE_CODE_39_EXTENDED_MODE is set.
 *
 * @see Code93Reader
 */
public open class Code39Reader <: OneDReader {
    static let ALPHABET_STRING: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%"

    /**
     * These represent the encodings of characters, as patterns of wide and narrow bars.
     * The 9 least-significant bits of each int correspond to the pattern of wide and narrow, with
     * 1s representing "wide" and 0s representing narrow.
     */
    static let CHARACTER_ENCODINGS: Array<Int64> = [
        0x034,
        0x121,
        0x061,
        0x160,
        0x031,
        0x130,
        0x070,
        0x025,
        0x124,
        0x064, // 0-9
        0x109,
        0x049,
        0x148,
        0x019,
        0x118,
        0x058,
        0x00D,
        0x10C,
        0x04C,
        0x01C, // A-J
        0x103,
        0x043,
        0x142,
        0x013,
        0x112,
        0x052,
        0x007,
        0x106,
        0x046,
        0x016, // K-T
        0x181,
        0x0C1,
        0x1C0,
        0x091,
        0x190,
        0x0D0,
        0x085,
        0x184,
        0x0C4,
        0x0A8, // U-$
        0x0A2,
        0x08A,
        0x02A // /-%
    ]

    static let ASTERISK_ENCODING: Int64 = 0x094

    private var usingCheckDigit: Bool = false
    private var extendedMode: Bool = false
    private var decodeRowResult: ArrayList<Char> = ArrayList<Char>()
    private var counters: Array<Int64> = Array<Int64>()

    /**
     * Creates a reader that assumes all encoded data is data, and does not treat the final character
     * as a check digit. It will not decoded "extended Code 39" sequences.
     */
    public init() {
        this(false)
    }

    /**
     * Creates a reader that can be configured to check the last character as a check digit.
     * It will not decoded "extended Code 39" sequences.
     *
     * @param usingCheckDigit if true, treat the last data character as a check digit, not data,
     * and verify that the checksum passes.
     */
    public init(usingCheckDigit: Bool) {
        this(usingCheckDigit, false)
    }

    /**
     * Creates a reader that can be configured to check the last character as a check digit,
     * or optionally attempt to decode "extended Code 39" sequences that are used to encode
     * the full ASCII character set.
     *
     * @param usingCheckDigit if true, treat the last data character as a check digit, not data, 
     * and verify that the checksum passes.
     * @param extendedMode if true, will attempt to decode extended Code 39 sequences in the
     * text.
     */
    public init(usingCheckDigit: Bool, extendedMode: Bool) {
        this.usingCheckDigit = usingCheckDigit
        this.extendedMode = extendedMode
        decodeRowResult = ArrayList<Char>()
        counters = Array<Int64>(9, item: 0)
    }

    public override func decodeRow(rowNumber: Int64, row: BitArray, _: HashMap<DecodeHintType, Any>): Result {
        counters = Array<Int64>(9, item: 0)
        decodeRowResult = ArrayList<Char>()
        var theCounters: Array<Int64> = counters
        var result: ArrayList<Char> = decodeRowResult

        var start: Array<Int64> = findAsteriskPattern(row, theCounters)

        // Read off white space
        var nextStart: Int64 = row.getNextSet(start[1])
        var end: Int64 = row.getSize()

        var decodedChar: Char
        var lastStart: Int64
        do {
            (decodedChar, lastStart, nextStart) = exdecodeRow(row, nextStart, theCounters, result)
        } while (decodedChar != '*')

        result = result[Range<Int64>(0, result.size - 1, 1, true, true, false)]

        // remove asterisk

        // Look for whitespace after pattern:
        var lastPatternSize: Int64 = 0

        for (i in 0..theCounters.size) {
            lastPatternSize += theCounters[i]
        }
        var whiteSpaceAfterEnd: Int64 = nextStart - lastStart - lastPatternSize

        // If 50% of last pattern size, following last pattern, is not whitespace, fail
        // (but if it's whitespace to the very end of the image, that's OK)
        if (nextStart != end && (whiteSpaceAfterEnd * 2) < lastPatternSize) {
            throw NotFoundException.getNotFoundInstance()
        }

        if (usingCheckDigit) {
            var max: Int64 = result.size - 1
            var total: Int64 = 0

            for (i in 0..max) {
                total += ALPHABET_STRING.indexOf(UInt8(decodeRowResult.get(i).getOrThrow().hashCode())).getOrThrow()
            }
            if (result.get(max).getOrThrow() != Char(ALPHABET_STRING[total % 43])) {
                throw ChecksumException.getChecksumInstance()
            }
        }

        if (result.size == 0) {
            // false positive
            throw NotFoundException.getNotFoundInstance()
        }

        var resultString: String
        if (extendedMode) {
            resultString = decodeExtended(UTF32String(result))
        } else {
            resultString = String(result)
        }

        var left: Float32 = Float32(start[1] + start[0]) / 2.0
        var right: Float32 = Float32(lastStart + lastPatternSize) / 2.0

        var resultObject: Result = Result(resultString, Array<UInt8>(),
            Array<ResultPoint>([ResultPoint(left, Float32(rowNumber)), ResultPoint(right, Float32(rowNumber))]),
            BarcodeFormat.CODE_39)
        resultObject.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]A0")

        return resultObject
    }

    private func exdecodeRow(row: BitArray, nextStart: Int64, theCounters: Array<Int64>, result: ArrayList<Char>) {
        var nextStart_p = nextStart
        recordPattern(row, nextStart_p, theCounters)
        var pattern: Int64 = toNarrowWidePattern(theCounters)

        if (pattern < 0) {
            throw NotFoundException.getNotFoundInstance()
        }
        var decodedChar = patternToChar(pattern)
        result.append(decodedChar)
        var lastStart = nextStart_p
        for (i in 0..theCounters.size) {
            nextStart_p += theCounters[i]
        }

        // Read off white space
        nextStart_p = row.getNextSet(nextStart_p)
        return (decodedChar, lastStart, nextStart_p)
    }

    private static func findAsteriskPattern(row: BitArray, counters_: Array<Int64>): Array<Int64> {
        var width: Int64 = row.getSize()
        var rowOffset: Int64 = row.getNextSet(0)

        var counterPosition: Int64 = 0
        var patternStart: Int64 = rowOffset
        var isWhite: Bool = false
        var patternLength: Int64 = counters_.size

        for (i in rowOffset..width) {
            if (row.get(i) != isWhite) {
                counters_[counterPosition] = counters_[counterPosition] + 1
            } else {
                if (counterPosition == patternLength - 1) {
                    // Look for whitespace before start pattern, >= 50% of width of start pattern
                    if (toNarrowWidePattern(counters_) == ASTERISK_ENCODING && row.isRange(
                        max(0, patternStart - ((i - patternStart) / 2)), patternStart, false)) {
                        let returnData: Array<Int64> = [patternStart, i]
                        return returnData
                    }
                    patternStart += counters_[0] + counters_[1]
                    System.arraycopy(counters_, 2, counters_, 0, counterPosition - 1)
                    counters_[counterPosition - 1] = 0
                    counters_[counterPosition] = 0
                    counterPosition--
                } else {
                    counterPosition++
                }
                counters_[counterPosition] = 1
                isWhite = !isWhite
            }
        }
        throw NotFoundException.getNotFoundInstance()
    }

    // For efficiency, returns -1 on failure. Not throwing here saved as many as 700 exceptions per
    // image when using some of our blackbox images.
    private static func toNarrowWidePattern(counters: Array<Int64>): Int64 {
        var numCounters: Int64 = counters.size
        var maxNarrowCounter: Int64 = 0
        var wideCounters_: Int64
        do {
            var minCounter: Int64 = 0x7fffffff

            for (counternum in 0..numCounters) {
                if (counters[counternum] < minCounter && counters[counternum] > maxNarrowCounter) {
                    minCounter = counters[counternum]
                }
            }
            maxNarrowCounter = minCounter
            wideCounters_ = 0
            var totalWideCountersWidth: Int64 = 0
            var pattern: Int64 = 0

            for (i in 0..numCounters) {
                var counter: Int64 = counters[i]
                if (counter > maxNarrowCounter) {
                    pattern |= 1 << (numCounters - 1 - i)
                    wideCounters_++
                    totalWideCountersWidth += counter
                }
            }
            if (wideCounters_ == 3) {
                // Found 3 wide counters, but are they close enough in width?
                // We can perform a cheap, conservative check to see if any individual counter
                // is more than 1.5 times the average:
                var i = 0
                while (wideCounters_ > 0 && i < numCounters) {
                    var counter: Int64 = counters[i]
                    if (counter > maxNarrowCounter) {
                        wideCounters_--

                        // totalWideCountersWidth = 3 * average, so this checks if counter >= 3/2 * average
                        if ((counter * 2) >= totalWideCountersWidth) {
                            return -1
                        }
                    }
                    i++
                }
                return pattern
            }
        } while (wideCounters_ > 3)
        return -1
    }

    private static func patternToChar(pattern: Int64): Char {
        for (i in 0..CHARACTER_ENCODINGS.size) {
            if (CHARACTER_ENCODINGS[i] == pattern) {
                return Char(ALPHABET_STRING[i])
            }
        }
        if (pattern == ASTERISK_ENCODING) {
            return '*'
        }
        throw NotFoundException.getNotFoundInstance()
    }

    private static func decodeExtended(encoded: UTF32String): String {
        var length: Int64 = encoded.size
        var decoded: ArrayList<Char> = ArrayList<Char>()

        var i: Int64 = 0
        while (i < length) {
            var c: Char = encoded.get(i)
            if (c == '+' || c == '$' || c == '%' || c == '/') {
                var next: Char = encoded.get(i + 1)
                var decodedChar: Char = '\0'
                match (c) {
                    case '+' =>
                        /* +A to +Z map to a to z */
                        if (next >= 'A' && next <= 'Z') {
                        decodedChar = Char(next.hashCode() + 32)
                    } else {
                        throw FormatException.getFormatInstance()
                    }
                    case '$' =>
                        /* $A to $Z map to control codes SH to SB */
                        if (next >= 'A' && next <= 'Z') {
                        decodedChar = Char(next.hashCode() - 64)
                    } else {
                        throw FormatException.getFormatInstance()
                    }
                    case '%' => decodedChar = getDecodedChar(next)
                    case '/' =>
                        /* /A to /O map to ! to , and /Z maps to : */
                        if (next >= 'A' && next <= 'O') {
                        decodedChar = Char(next.hashCode() - 32)
                    } else if (next == 'Z') {
                        decodedChar = ':'
                    } else {
                        throw FormatException.getFormatInstance()
                    }
                    case _ => ""
                }
                decoded.append(decodedChar)

                /* bump up i again since we read two characters */
                i++
            } else {
                decoded.append(c)
            }
            i++
        }
        return String(decoded)
    }

    private static func getDecodedChar(next: Char) {
        var decodedChar = ' '
        if (next >= 'A' && next <= 'E') {
            decodedChar = Char(next.hashCode() - 38)
        } else if (next >= 'F' && next <= 'J') {
            decodedChar = Char(next.hashCode() - 11)
        } else if (next >= 'K' && next <= 'O') {
            decodedChar = Char(next.hashCode() + 16)
        } else if (next >= 'P' && next <= 'T') {
            decodedChar = Char(next.hashCode() + 43)
        } else if (next == 'U') {
            decodedChar = Char(0)
        } else if (next == 'V') {
            decodedChar = '@'
        } else if (next == 'W') {
            decodedChar = '`'
        } else if (next == 'X' || next == 'Y' || next == 'Z') {
            decodedChar = Char(127)
        } else {
            throw FormatException.getFormatInstance()
        }
        return decodedChar
    }
}
