/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * <p>Decodes Codabar barcodes.</p>
 *
 * @author Bas Vijfwinkel
 * @author David Walker
 */
public open class CodaBarReader <: OneDReader {
    // These values are critical for determining how permissive the decoding
    // will be. All stripe sizes must be within the window these define, as
    // compared to the average stripe size.
    private static let MAX_ACCEPTABLE: Float32 = 2.0;
    private static let PADDING: Float32 = 1.5;

    public static let ALPHABET_STRING: UTF32String = UTF32String("0123456789-$:/.+ABCD");

    /**
     * These represent the encodings of characters, as patterns of wide and narrow bars. The 7 least-significant bits of
     * each int correspond to the pattern of wide and narrow, with 1s representing "wide" and 0s representing narrow.
     */
    static let CHARACTER_ENCODINGS: Array<Int64> = [
        0x003,
        0x006,
        0x009,
        0x060,
        0x012,
        0x042,
        0x021,
        0x024,
        0x030,
        0x048, // 0-9
        0x00c,
        0x018,
        0x045,
        0x051,
        0x054,
        0x015,
        0x01A,
        0x029,
        0x00B,
        0x00E // -$:/.+ABCD
    ]

    // minimal number of characters that should be present (including start and stop characters)
    // under normal circumstances this should be set to 3, but can be set higher
    // as a last-ditch attempt to reduce false positives.
    private static let MIN_CHARACTER_LENGTH: Int64 = 3;

    // official start and end patterns
    private static let STARTEND_ENCODING: Array<Char> = ['A', 'B', 'C', 'D']

    // some Codabar generator allow the Codabar string to be closed by every
    // character. This will cause lots of false positives!

    // some industries use a checksum standard but this is not part of the original Codabar standard

    // Keep some instance variables to avoid reallocations
    private var decodeRowResult: ArrayList<Char> = ArrayList<Char>()
    private var counters: Array<Int64> = Array<Int64>()
    private var counterLength: Int64 = 0

    public init() {
        decodeRowResult = ArrayList<Char>()
        counters = Array<Int64>(80, item: 0)
        counterLength = 0
    }

    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        setCounters(row);
        var startOffset: Int64 = findStartPattern();
        var nextStart: Int64 = startOffset
        decodeRowResult = ArrayList<Char>()

        do {
            var charOffset: Int64 = toNarrowWidePattern(nextStart);
            if (charOffset == -1) {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance();
            }

            // Hack: We store the position in the alphabet table into a
            // StringBuilder, so that we can access the decoded patterns in
            // validatePattern. We'll translate to the actual characters later.
            decodeRowResult.append(Char(charOffset))
            nextStart += 8

            // Stop as soon as we see the end character.
            if (decodeRowResult.size > 1 && arrayContains(STARTEND_ENCODING, ALPHABET_STRING[charOffset])) {
                break
            }
        } while (nextStart < counterLength)

        // no fixed end pattern so keep on reading while data is available

        // Look for whitespace after pattern:
        var trailingWhitespace: Int64 = counters[nextStart - 1]
        var lastPatternSize: Int64 = 0;

        for (i in -8..-1) {
            lastPatternSize += counters[nextStart + i]
        }

        /*
         * We need to see whitespace equal to 50% of the last pattern size, otherwise
         * this is probably a false positive. The exception is if we are
         * at the end of the row. (I.e. the barcode barely fits.)
         */ 
        if (nextStart < counterLength && trailingWhitespace < lastPatternSize / 2) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }
        validatePattern(startOffset);

        // Translate character table offsets to actual characters.
        var ldecodeRowResult: ArrayList<Char> = ArrayList<Char>()
        for (i in 0..decodeRowResult.size) {
            ldecodeRowResult.append(ALPHABET_STRING[decodeRowResult.get(i).getOrThrow().hashCode()])
        }
        decodeRowResult = ldecodeRowResult

        // Ensure a valid start and end character
        extdecodeRow(decodeRowResult, hints)

        var runningCount: Int64 = 0;

        for (i in 0..startOffset) {
            runningCount += counters[i]
        }
        var left: Float32 = Float32(runningCount)
        for (i in startOffset..nextStart - 1) {
            runningCount += counters[i]
        }
        var right: Float32 = Float32(runningCount)

        var result: Result = Result(String(decodeRowResult), Array<UInt8>(),
            Array<ResultPoint>([ResultPoint(left, Float32(rowNumber)), ResultPoint(right, Float32(rowNumber))]),
            BarcodeFormat.CODABAR)

        result.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]F0")

        return result
    }

    private func extdecodeRow(decodeRowResult: ArrayList<Char>, hints: HashMap<DecodeHintType, Any>) {
        var startchar: Char = decodeRowResult.get(0).getOrThrow()
        if (!arrayContains(STARTEND_ENCODING, startchar)) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }

        var endchar: Char = decodeRowResult.get(decodeRowResult.size - 1).getOrThrow()
        if (!arrayContains(STARTEND_ENCODING, endchar)) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }

        // remove stop/start characters character and check if a long enough string is contained
        if (decodeRowResult.size <= MIN_CHARACTER_LENGTH) {
            // Almost surely a false positive ( start + stop + at least 1 character)
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }

        if (hints.size == 0 || !hints.contains(DecodeHintType.RETURN_CODABAR_START_END)) {
            decodeRowResult.remove(decodeRowResult.size - 1)
            decodeRowResult.remove(0)
        }
    }

    private func validatePattern(start: Int64) {
        // First, sum up the total size of our four categories of stripe sizes;
        var sizes: Array<Int64> = Array<Int64>(4, item: 0);
        var counts: Array<Int64> = Array<Int64>(4, item: 0);
        var end: Int64 = decodeRowResult.size - 1

        // We break out of this loop in the middle, in order to handle
        // inter-character spaces properly.
        var pos: Int64 = start

        for (i in 0..=end) {
            var pattern: Int64 = CHARACTER_ENCODINGS[decodeRowResult.get(i).getOrThrow().hashCode()]

            for (j in 6..=0 : -1) {
                // Even j = bars, while odd j = spaces. Categories 2 and 3 are for
                // long stripes, while 0 and 1 are for short stripes.
                var category: Int64 = (j & 1) + (pattern & 1) * 2
                sizes[category] += counters[pos + j]
                counts[category] = counts[category] + 1
                pattern >>= 1
            }

            // We ignore the inter-character space - it could be of any size.
            pos += 8
        }

        // Calculate our allowable size thresholds using fixed-point math.
        var maxes: Array<Float32> = Array<Float32>(4, item: 0.0)
        var mins: Array<Float32> = Array<Float32>(4, item: 0.0)

        // Define the threshold of acceptability to be the midpoint between the
        // average small stripe and the average large stripe. No stripe lengths
        // should be on the "wrong" side of that line.
        for (i in 0..2) {
            mins[i] = 0.0

            // Accept arbitrarily small "short" stripes.
            mins[i + 2] = (Float32(sizes[i]) / Float32(counts[i]) + Float32(sizes[i + 2]) / Float32(counts[i + 2])) / 2.0
            maxes[i] = mins[i + 2]
            maxes[i + 2] = (Float32(sizes[i + 2]) * MAX_ACCEPTABLE + PADDING) / Float32(counts[i + 2])
        }

        // Now verify that all of the stripes are within the thresholds.
        pos = start

        for (i in 0..end + 1) {
            var pattern: Int64 = CHARACTER_ENCODINGS[decodeRowResult.get(i).getOrThrow().hashCode()]

            var j_: Int64 = 6
            while (j_ >= 0) {
                // Even j_ = bars, while odd j_ = spaces. Categories 2 and 3 are for
                // long stripes, while 0 and 1 are for short stripes.
                var category: Int64 = (j_ & 1) + (pattern & 1) * 2
                var size: Float32 = Float32(counters[pos + j_])
                if (size < mins[category] || size > maxes[category]) {
                    throw Qrcoder4cjNotFoundException.getNotFoundInstance();
                }
                pattern >>= 1
                j_--
            }
            pos += 8
        }
    }

    /**
     * Records the size of all runs of white and black pixels, starting with white. This is
     * just like recordPattern, except it records all the counters, and
     * uses our builtin "counters" member for storage.
     *
     * @param row row to count from
     */
    private func setCounters(row: BitArray) {
        counterLength = 0

        // Start from the first white bit.
        var i: Int64 = row.getNextUnset(0);
        var end_: Int64 = row.getSize();
        if (i >= end_) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }
        var isWhite_: Bool = true;
        var count: Int64 = 0;
        while (i < end_) {
            if (row.get(i) != isWhite_) {
                count++
            } else {
                counterAppend(count);
                count = 1
                isWhite_ = !isWhite_
            }
            i++
        }
        counterAppend(count);
    }

    private func counterAppend(e: Int64) {
        counters[counterLength] = e
        counterLength++
        if (counterLength >= counters.size) {
            var temp: Array<Int64> = Array<Int64>(counterLength * 2, item: 0)
            System.arraycopy(counters, 0, temp, 0, counterLength);
            counters = temp
        }
    }

    private func findStartPattern(): Int64 {
        var i: Int64 = 1
        while (i < counterLength) {
            var charOffset: Int64 = toNarrowWidePattern(i);
            if (charOffset != -1 && arrayContains(STARTEND_ENCODING, ALPHABET_STRING[charOffset])) {
                // Look for whitespace before start pattern, >= 50% of width of start pattern
                // We make an exception if the whitespace is the first element.
                var patternSize: Int64 = 0;
                for (j in i..i + 7) {
                    patternSize += counters[j]
                }
                if (i == 1 || counters[i - 1] >= patternSize / 2) {
                    return i
                }
            }
            i = i + 2
        }
        throw Qrcoder4cjNotFoundException.getNotFoundInstance();
    }

    static func arrayContains(array: Array<Char>, key: Char): Bool {
        if (array.size > 0) {
            for (c in 0..array.size) {
                if (array[c] == key) {
                    return true;
                }
            }
        }
        return false;
    }

    // Assumes that counters[position] is a bar.
    private func toNarrowWidePattern(position: Int64): Int64 {
        var end: Int64 = position + 7
        if (end >= counterLength) {
            return -1;
        }

        var theCounters: Array<Int64> = counters

        var maxBar: Int64 = 0;
        var minBar: Int64 = 0x7fffffff;
        for (j in position..end : 2) {
            var currentCounter: Int64 = theCounters[j]
            if (currentCounter < minBar) {
                minBar = currentCounter
            }
            if (currentCounter > maxBar) {
                maxBar = currentCounter
            }
        }
        var thresholdBar: Int64 = (minBar + maxBar) / 2

        var maxSpace: Int64 = 0;
        var minSpace: Int64 = 0x7fffffff;
        for (j in position + 1..end : 2) {
            var currentCounter: Int64 = theCounters[j]
            if (currentCounter < minSpace) {
                minSpace = currentCounter
            }
            if (currentCounter > maxSpace) {
                maxSpace = currentCounter
            }
        }
        var thresholdSpace: Int64 = (minSpace + maxSpace) / 2

        var bitmask: Int64 = 1 << 7
        var pattern: Int64 = 0;

        for (i in 0..7) {
            var threshold: Int64 = 0
            if ((i & 1) == 0) {
                threshold = thresholdBar
            } else {
                threshold = thresholdSpace
            }
            bitmask >>= 1
            if (theCounters[position + i] > threshold) {
                pattern |= bitmask
            }
        }

        for (i in 0..CHARACTER_ENCODINGS.size) {
            if (CHARACTER_ENCODINGS[i] == pattern) {
                return i
            }
        }
        return -1;
    }
}
