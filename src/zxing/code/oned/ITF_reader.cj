/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

public open class ITFReader <: OneDReader {
    private static let MAX_AVG_VARIANCE: Float32 = 0.38
    private static let MAX_INDIVIDUAL_VARIANCE: Float32 = 0.5

    private static let W: Int64 = 3 // Pixel width of a 3x wide line
    private static let w: Int64 = 2 // Pixel width of a 2x wide line
    private static let N: Int64 = 1 // Pixed width of a narrow line

    /** Valid ITF lengths. Anything longer than the largest value is also allowed. */
    private static let DEFAULT_ALLOWED_LENGTHS: Array<Int64> = [6, 8, 10, 12, 14]

    // Stores the actual narrow line width of the image being decoded.
    private var narrowLineWidth: Int64 = -1

    /**
     * Start/end guard pattern.
     *
     * Note: The end pattern is reversed because the row is reversed before
     * searching for the END_PATTERN
     */
    private static let START_PATTERN: Array<Int64> = [N, N, N, N]
    private static let END_PATTERN_REVERSED: Array<Array<Int64>> = [
        [N, N, w], // 2x
        [N, N, W] // 3x
    ]

    // See ITFWriter.PATTERNS

    /**
     * Patterns of Wide / Narrow lines to indicate each digit
     */
    private static let PATTERNS: Array<Array<Int64>> = [
        [N, N, w, w, N], // 0
        [w, N, N, N, w], // 1
        [N, w, N, N, w], // 2
        [w, w, N, N, N], // 3
        [N, N, w, N, w], // 4
        [w, N, w, N, N], // 5
        [N, w, w, N, N], // 6
        [N, N, N, w, w], // 7
        [w, N, N, w, N], // 8
        [N, w, N, w, N], // 9
        [N, N, W, W, N], // 0
        [W, N, N, N, W], // 1
        [N, W, N, N, W], // 2
        [W, W, N, N, N], // 3
        [N, N, W, N, W], // 4
        [W, N, W, N, N], // 5
        [N, W, W, N, N], // 6
        [N, N, N, W, W], // 7
        [W, N, N, W, N], // 8
        [N, W, N, W, N] // 9
    ]

    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {

        // Find out where the Middle section (payload) starts & ends
        var startRange: Array<Int64> = decodeStart(row)
        var endRange: Array<Int64> = decodeEnd(row)

        var result: ArrayList<Char> = ArrayList<Char>()
        decodeMiddle(row, startRange[1], endRange[0], result)
        var resultString: UTF32String = UTF32String(result)

        var allowedLengths: Array<Int64> = Array<Int64>()
        if (hints.size > 0) {
            let num = hints.get(DecodeHintType.ALLOWED_LENGTHS) as Array<Int64>
            if (let Some(one) <- num) {
                allowedLengths = one
            }
        }
        if (allowedLengths.size == 0) {
            allowedLengths = DEFAULT_ALLOWED_LENGTHS
        }

        // To avoid false positives with 2D barcodes (and other patterns), make
        // an assumption that the decoded string must be a 'standard' length if it's short
        var length: Int64 = resultString.charSize
        var lengthOK: Bool = false
        var maxAllowedLength: Int64 = 0

        for (i in 0..allowedLengths.size) {
            if (length == allowedLengths[i]) {
                lengthOK = true
                break
            }
            if (allowedLengths[i] > maxAllowedLength) {
                maxAllowedLength = allowedLengths[i]
            }
        }
        if (!lengthOK && length > maxAllowedLength) {
            lengthOK = true
        }
        if (!lengthOK) {
            throw FormatException.getFormatInstance()
        }

        var resultObject: Result = Result(
            resultString.toString(),
            Array<UInt8>(),
            Array<ResultPoint>(
                [
                    ResultPoint(Float32(startRange[1]), Float32(rowNumber)),
                    ResultPoint(Float32(endRange[0]), Float32(rowNumber))
                ]
            ),
            BarcodeFormat.ITF
        )
        resultObject.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]I0")

        return resultObject
    }

    /**
     * @param row          row of black/white values to search
     * @param payloadStart offset of start pattern
     * @param resultString {@link StringBuilder} to append decoded chars to
     * @throws NotFoundException if decoding could not complete successfully
     */
    private static func decodeMiddle(
        row: BitArray,
        payloadStartin: Int64,
        payloadEnd: Int64,
        resultString: ArrayList<Char>
    ) {
        // Digits are interleaved in pairs - 5 black lines for one digit, and the 5
        // interleaved white lines for the second digit.
        // Therefore, need to scan 10 lines and then
        // split these into two arrays
        var counterDigitPair: Array<Int64> = Array<Int64>(10, item: 0)
        var counterBlack: Array<Int64> = Array<Int64>(5, item: 0)
        var counterWhite: Array<Int64> = Array<Int64>(5, item: 0)

        var payloadStart: Int64 = payloadStartin

        while (payloadStart < payloadEnd) {
            // Get 10 runs of black/white.
            recordPattern(row, payloadStart, counterDigitPair)

            // Split them into each array
            for (k in 0..5) {
                var twoK: Int64 = 2 * k
                counterBlack[k] = counterDigitPair[twoK]
                counterWhite[k] = counterDigitPair[twoK + 1]
            }

            var bestMatch: Int64 = decodeDigit(counterBlack)
            resultString.append(Char('0'.hashCode() + bestMatch))
            bestMatch = decodeDigit(counterWhite)
            resultString.append(Char('0'.hashCode() + bestMatch))

            for (i in 0..counterDigitPair.size) {
                payloadStart += counterDigitPair[i]
            }
        }
    }

    /**
     * Identify where the start of the middle / payload section starts.
     *
     * @param row row of black/white values to search
     *
     * @return Array, containing index of start of 'start block' and end of
     * 'start block'
     */
    private func decodeStart(row: BitArray): Array<Int64> {
        var endStart: Int64 = skipWhiteSpace(row)
        var startPattern: Array<Int64> = findGuardPattern(row, endStart, START_PATTERN)

        // Determine the width of a narrow line in pixels. We can do this by getting
        // the width of the start pattern and dividing by 4 because its
        // made up of 4 narrow lines.
        this.narrowLineWidth = (startPattern[1] - startPattern[0]) / 4

        validateQuietZone(row, startPattern[0])

        return startPattern
    }

    /**
     * The start & end patterns must be pre/post fixed by a quiet zone. This
     * zone must be at least 10 times the width of a narrow line.  Scan back until we
     * either get to the start of the barcode or match the necessary number of
     * quiet zone pixels.
     *
     * Note: Its assumed the row is reversed when using this method to find quiet
     * zone after the end pattern.
     *
     * ref: http://www.barcode-1.net/i25code.html
     *
     * @param row bit array representing the scanned barcode.
     * @param startPattern index into row of the start or end pattern.
     *
     * @throws NotFoundException if the quiet zone cannot be found
     */
    private func validateQuietZone(row: BitArray, startPattern: Int64) {
        var quietCount: Int64 = this.narrowLineWidth * 10

        // expect to find this many pixels of quiet zone

        // if there are not so many pixel at all let's try as many as possible
        quietCount = min(quietCount, startPattern)
        var i: Int64 = startPattern - 1
        while (i >= 0 && quietCount > 0) {
            if (row.get(i)) {
                break
            }
            i--
            quietCount--
        }
        if (quietCount != 0) {
            // Unable to find the necessary number of quiet zone pixels.
            throw NotFoundException.getNotFoundInstance()
        }
    }

    /**
     * Skip all whitespace until we get to the first black line.
     *
     * @param row row of black/white values to search
     * @return index of the first black line.
     * @throws NotFoundException Throws exception if no black lines are found in the row
     */
    private static func skipWhiteSpace(row: BitArray): Int64 {
        var width: Int64 = row.getSize()
        var endStart: Int64 = row.getNextSet(0)
        if (endStart == width) {
            throw NotFoundException.getNotFoundInstance()
        }

        return endStart
    }

    /**
     * Identify where the end of the middle / payload section ends.
     *
     * @param row row of black/white values to search
     * @return Array, containing index of start of 'end block' and end of 'end
     * block'
     */
    private func decodeEnd(row: BitArray): Array<Int64> {
        // For convenience, reverse the row and then
        // search from 'the start' for the end block
        row.reverse()
        try {
            var endStart: Int64 = skipWhiteSpace(row)
            var endPattern: Array<Int64>
            try {
                endPattern = findGuardPattern(row, endStart, END_PATTERN_REVERSED[0])
            } catch (nfe: NotFoundException) {
                endPattern = findGuardPattern(row, endStart, END_PATTERN_REVERSED[1])
            }

            // The start & end patterns must be pre/post fixed by a quiet zone. This zone
            // must be at least 10 times the width of a narrow line.
            // ref: http://www.barcode-1.net/i25code.html
            validateQuietZone(row, endPattern[0])

            // Now recalculate the indices of where the 'endblock' starts & stops to accommodate
            // the reversed nature of the search
            var temp: Int64 = endPattern[0]
            endPattern[0] = row.getSize() - endPattern[1]
            endPattern[1] = row.getSize() - temp

            return endPattern
        } finally {
            // Put the row back the right way.
            row.reverse()
        }
    }

    /**
     * @param row       row of black/white values to search
     * @param rowOffset position to start search
     * @param pattern   pattern of counts of number of black and white pixels that are being
     * searched for as a pattern
     *
     * @return start/end horizontal offset of guard pattern, as an array of two ints
     * @throws NotFoundException if pattern is not found
     */
    private static func findGuardPattern(row: BitArray, rowOffset: Int64, pattern: Array<Int64>): Array<Int64> {
        var patternLength: Int64 = pattern.size
        var counters: Array<Int64> = Array<Int64>(patternLength, item: 0)
        var width: Int64 = row.getSize()
        var isWhite: Bool = false

        var counterPosition: Int64 = 0
        var patternStart: Int64 = rowOffset

        for (x in rowOffset..width) {
            if (row.get(x) != isWhite) {
                counters[counterPosition] = counters[counterPosition] + 1
            } else {
                if (counterPosition == patternLength - 1) {
                    if (patternMatchVariance(counters, pattern, MAX_INDIVIDUAL_VARIANCE) < MAX_AVG_VARIANCE) {
                        return [patternStart, x]
                    }
                    patternStart += counters[0] + counters[1]
                    System.arraycopy(counters, 2, counters, 0, counterPosition - 1)
                    counters[counterPosition - 1] = 0
                    counters[counterPosition] = 0
                    counterPosition--
                } else {
                    counterPosition++
                }
                counters[counterPosition] = 1
                isWhite = !isWhite
            }
        }
        throw NotFoundException.getNotFoundInstance()
    }

    /**
     * Attempts to decode a sequence of ITF black/white lines into single digit.
     *
     * @param counters the counts of runs of observed black/white/black/... values
     * @return The decoded digit
     * @throws NotFoundException if digit cannot be decoded
     */
    private static func decodeDigit(counters: Array<Int64>): Int64 {
        var bestVariance: Float32 = MAX_AVG_VARIANCE

        // worst variance we'll accept
        var bestMatch: Int64 = -1
        var max: Int64 = PATTERNS.size

        for (i in 0..max) {
            var pattern: Array<Int64> = PATTERNS[i]
            var variance: Float32 = patternMatchVariance(counters, pattern, MAX_INDIVIDUAL_VARIANCE)
            if (variance < bestVariance) {
                bestVariance = variance
                bestMatch = i
            } else if (variance == bestVariance) {
                // if we find a second 'best match' with the same variance, we can not reliably report to have a suitable match
                bestMatch = -1
            }
        }
        if (bestMatch >= 0) {
            return bestMatch % 10
        } else {
            throw NotFoundException.getNotFoundInstance()
        }
    }
}
