/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 *
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */
// 泛型value为ResultPointCallback
public abstract class UPCEANReader <: OneDReader {
    // These two values are critical for determining how permissive the decoding will be.
    // We've arrived at these values through a lot of trial and error. Setting them any higher
    // lets false positives creep in quickly.
    private static let MAX_AVG_VARIANCE: Float32 = 0.48;
    private static let MAX_INDIVIDUAL_VARIANCE: Float32 = 0.7;

    /**
     * Start/end guard pattern.
     */
    static let START_END_PATTERN: Array<Int64> = [1, 1, 1]

    /**
     * Pattern marking the middle of a UPC/EAN pattern, separating the two halves.
     */
    static let MIDDLE_PATTERN: Array<Int64> = [1, 1, 1, 1, 1]

    /**
     * end guard pattern.
     */
    static let END_PATTERN: Array<Int64> = [1, 1, 1, 1, 1, 1]

    /**
     * "Odd", or "L" patterns used to encode UPC/EAN digits.
     */
    static let L_PATTERNS: Array<Array<Int64>> = [
        [3, 2, 1, 1], // 0
        [2, 2, 2, 1], // 1
        [2, 1, 2, 2], // 2
        [1, 4, 1, 1], // 3
        [1, 1, 3, 2], // 4
        [1, 2, 3, 1], // 5
        [1, 1, 1, 4], // 6
        [1, 3, 1, 2], // 7
        [1, 2, 1, 3], // 8
        [3, 1, 1, 2] // 9
    ]

    /**
     * As above but also including the "even", or "G" patterns used to encode UPC/EAN digits.
     */
    static var L_AND_G_PATTERNS: Array<Array<Int64>> = [
        [3, 2, 1, 1],
        [2, 2, 2, 1],
        [2, 1, 2, 2],
        [1, 4, 1, 1],
        [1, 1, 3, 2],
        [1, 2, 3, 1],
        [1, 1, 1, 4],
        [1, 3, 1, 2],
        [1, 2, 1, 3],
        [3, 1, 1, 2],
        [1, 1, 2, 3],
        [1, 2, 2, 2],
        [2, 2, 1, 2],
        [1, 1, 4, 1],
        [2, 3, 1, 1],
        [1, 3, 2, 1],
        [4, 1, 1, 1],
        [2, 1, 3, 1],
        [3, 1, 2, 1],
        [2, 1, 1, 3]
    ]

    private let decodeRowStringBuffer: ArrayList<Char>
    private let extensionReader: UPCEANExtensionSupport
    private let eanManSupport: EANManufacturerOrgSupport

    protected init() {
        decodeRowStringBuffer = ArrayList<Char>()
        extensionReader = UPCEANExtensionSupport()
        eanManSupport = EANManufacturerOrgSupport()
    }

    static func findStartGuardPattern(row: BitArray): Array<Int64> {
        var foundStart: Bool = false;
        var startRange: Array<Int64> = Array<Int64>()
        var nextStart: Int64 = 0;
        while (!foundStart) {
            var counters: Array<Int64> = Array<Int64>(START_END_PATTERN.size, item: 0)
            startRange = findGuardPattern(row, nextStart, false, START_END_PATTERN, counters)
            var start: Int64 = startRange[0]
            nextStart = startRange[1]

            // Make sure there is a quiet zone at least as big as the start pattern before the barcode.
            // If this check would run off the left edge of the image, do not accept this barcode,
            // as it is very likely to be a false positive.
            var quietStart: Int64 = start - (nextStart - start)
            if (quietStart >= 0) {
                foundStart = row.isRange(quietStart, start, false)
            }
        }
        return startRange
    }

    public open override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        return decodeRow(rowNumber, row, findStartGuardPattern(row), hints);
    }

    /**
     * <p>Like {@link #decodeRow(int, BitArray, Map)}, but
     * allows caller to inform method about where the UPC/EAN start pattern is
     * found. This allows this to be computed once and reused across many implementations.</p>
     *
     * @param rowNumber row index into the image
     * @param row encoding of the row of the barcode image
     * @param startGuardRange start/end column where the opening start pattern was found
     * @param hints optional hints that influence decoding
     * @return {@link Result} encapsulating the result of decoding a barcode in the row
     * @throws NotFoundException if no potential barcode is found
     * @throws ChecksumException if a potential barcode is found but does not pass its checksum
     * @throws FormatException if a potential barcode is found but format is invalid
     */
    public open func decodeRow(
        rowNumber: Int64,
        row: BitArray,
        startGuardRange: Array<Int64>,
        hints: HashMap<DecodeHintType, Any>
    ): Result {
        var resultPointCallback: ?ResultPointCallback = if (let Some(r) <- hints.get(
            DecodeHintType.NEED_RESULT_POINT_CALLBACK)) {
            r as ResultPointCallback
        } else {
            None
        }

        if (hints.size == 0) {
            resultPointCallback = None
        }
        var symbologyIdentifier: Int64 = 0;

        if (let Some(r) <- resultPointCallback) {
            /* != null*/
            r.foundPossibleResultPoint(
                ResultPoint(Float32(startGuardRange[0] + startGuardRange[1]) / 2.0, Float32(rowNumber)));
        }

        var result: ArrayList<Char> = ArrayList<Char>()

        var endStart: Int64 = decodeMiddle(row, startGuardRange, result);

        if (let Some(r) <- resultPointCallback) {
            /* != null*/
            r.foundPossibleResultPoint(ResultPoint(Float32(endStart), Float32(rowNumber)));
        }

        var endRange: Array<Int64> = decodeEnd(row, endStart);

        if (let Some(r) <- resultPointCallback) {
            /* != null*/
            r.foundPossibleResultPoint(ResultPoint(Float32(endRange[0] + endRange[1]) / 2.0, Float32(rowNumber)));
        }

        // Make sure there is a quiet zone at least as big as the end pattern after the barcode. The
        // spec might want more whitespace, but in practice this is the maximum we can count on.
        var end: Int64 = endRange[1]
        var quietEnd: Int64 = end + (end - endRange[0])
        if (quietEnd >= row.getSize() || !row.isRange(end, quietEnd, false)) {
            throw NotFoundException.getNotFoundInstance();
        }

        var resultString: UTF32String = UTF32String(result);

        // UPC/EAN should never be less than 8 chars anyway
        if (resultString.charSize < 8) {
            throw FormatException.getFormatInstance();
        }
        if (!checkChecksum(resultString)) {
            throw ChecksumException.getChecksumInstance();
        }

        var left: Float32 = Float32(startGuardRange[1] + startGuardRange[0]) / 2.0
        var right: Float32 = Float32(endRange[1] + endRange[0]) / 2.0
        var format: BarcodeFormat = getBarcodeFormat();
        var decodeResult: Result = Result(
            resultString.toString(),
            Array<UInt8>(), // no natural byte representation for these barcodes
            Array<ResultPoint>(
                [
                    ResultPoint(left, Float32(rowNumber)),
                    ResultPoint(right, Float32(rowNumber))
                ]
            ),
            format
        );

        var extensionLength: Int64 = 0;
        var extensionResult_none: ?Result = extensionReader.decodeRow(rowNumber, row, endRange[1])

        try {
            if (let Some(extensionResult) <- extensionResult_none) {
                decodeResult.putMetadata(ResultMetadataType.UPC_EAN_EXTENSION, extensionResult.getText());
                decodeResult.putAllMetadata(extensionResult.getResultMetadata());
                decodeResult.addResultPoints(extensionResult.getResultPoints());
                extensionLength = extensionResult.getText().toRuneArray().size
            }
        } catch (re: ReaderException) {
            // continue
        }

        var allowedExtensions: Array<Int64>
        if (hints.size == 0) {
            allowedExtensions = Array<Int64>()
        } else {
            if (let Some(hints_one) <- hints.get(DecodeHintType.ALLOWED_EAN_EXTENSIONS)) {
                allowedExtensions = Array<Int64>(
                    (hints_one as Int64).getOrThrow(),
                    item: 0
                )
            } else {
                allowedExtensions = Array<Int64>()
            }
        }
        if (!allowedExtensions.isEmpty()) {
            var valid: Bool = false;

            for (i in 0..allowedExtensions.size) {
                if (extensionLength == allowedExtensions[i]) {
                    valid = true
                    break
                }
            }
            if (!valid) {
                throw NotFoundException.getNotFoundInstance();
            }
        }

        if (format == BarcodeFormat.EAN_13 || format == BarcodeFormat.UPC_A) {
            var countryID: String = eanManSupport.lookupCountryIdentifier(resultString);
            if (countryID != "") {
                decodeResult.putMetadata(ResultMetadataType.POSSIBLE_COUNTRY, countryID);
            }
        }
        if (format == BarcodeFormat.EAN_8) {
            symbologyIdentifier = 4
        }

        decodeResult.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]E" + symbologyIdentifier.toString());

        return decodeResult
    }

    /**
     * @param s string of digits to check
     * @return {@link #checkStandardUPCEANChecksum(String)}
     * @throws FormatException if the string does not contain only digits
     */
    protected open func checkChecksum(s: UTF32String): Bool {
        return checkStandardUPCEANChecksum(s);
    }

    /**
     * Computes the UPC/EAN checksum on a string of digits, and reports
     * whether the checksum is correct or not.
     *
     * @param s string of digits to check
     * @return true iff string of digits passes the UPC/EAN checksum algorithm
     * @throws FormatException if the string does not contain only digits
     */
    static func checkStandardUPCEANChecksum(s: UTF32String): Bool {
        var length: Int64 = s.charSize;
        if (length == 0) {
            return false;
        }
        var check: Int64 = -1
        if (s[length - 1].isAsciiNumber()) {
            check = s.get(length - 1).hashCode() - 48
        }
        return getStandardUPCEANChecksum(s.substring(0, length - 1)) == check
    }

    static func getStandardUPCEANChecksum(s: UTF32String): Int64 {
        var length: Int64 = s.charSize;
        var sum: Int64 = 0;
        var i: Int64 = length - 1
        while (i >= 0) {
            var digit: Int64 = s.get(i).hashCode() - '0'.hashCode()
            if (digit < 0 || digit > 9) {
                throw FormatException.getFormatInstance();
            }
            sum += digit
            i -= 2
        }
        sum *= 3
        i = length - 2
        while (i >= 0) {
            var digit: Int64 = s.get(i).hashCode() - '0'.hashCode()
            if (digit < 0 || digit > 9) {
                throw FormatException.getFormatInstance();
            }
            sum += digit
            i -= 2
        }
        return (1000 - sum) % 10
    }

    protected open func decodeEnd(row: BitArray, endStart: Int64): Array<Int64> {
        return findGuardPattern(row, endStart, false, START_END_PATTERN);
    }

    static func findGuardPattern(row: BitArray, rowOffset: Int64, whiteFirst: Bool, pattern: Array<Int64>): Array<Int64> {
        return findGuardPattern(row, rowOffset, whiteFirst, pattern, Array<Int64>(pattern.size, item: 0));
    }

    /**
     * @param row row of black/white values to search
     * @param rowOffset position to start search
     * @param whiteFirst if true, indicates that the pattern specifies white/black/white/...
     * pixel counts, otherwise, it is interpreted as black/white/black/...
     * @param pattern pattern of counts of number of black and white pixels that are being
     * searched for as a pattern
     * @param counters array of counters, as long as pattern, to re-use
     * @return start/end horizontal offset of guard pattern, as an array of two ints
     * @throws NotFoundException if pattern is not found
     */
    private static func findGuardPattern(
        row: BitArray,
        rowOffsetin: Int64,
        whiteFirst: Bool,
        pattern: Array<Int64>,
        counters: Array<Int64>
    ): Array<Int64> {
        var width: Int64 = row.getSize();
        var rowOffset: Int64 = rowOffsetin

        if (whiteFirst) {
            rowOffset = row.getNextUnset(rowOffset)
        } else {
            rowOffset = row.getNextSet(rowOffset)
        }

        var counterPosition: Int64 = 0
        var patternStart: Int64 = rowOffset
        var patternLength: Int64 = pattern.size
        var isWhite: Bool = whiteFirst
        for (x in rowOffset..width) {
            if (row.get(x) != isWhite) {
                counters[counterPosition] = counters[counterPosition] + 1
            } else {
                if (counterPosition == patternLength - 1) {
                    if (patternMatchVariance(counters, pattern, MAX_INDIVIDUAL_VARIANCE) < MAX_AVG_VARIANCE) {
                        return [patternStart, x]
                    }
                    patternStart += counters[0] + counters[1]
                    System.arraycopy(counters, 2, counters, 0, counterPosition - 1);
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
        throw NotFoundException.getNotFoundInstance();
    }

    /**
     * Attempts to decode a single UPC/EAN-encoded digit.
     *
     * @param row row of black/white values to decode
     * @param counters the counts of runs of observed black/white/black/... values
     * @param rowOffset horizontal offset to start decoding from
     * @param patterns the set of patterns to use to decode -- sometimes different encodings
     * for the digits 0-9 are used, and this indicates the encodings for 0 to 9 that should
     * be used
     * @return horizontal offset of first pixel beyond the decoded digit
     * @throws NotFoundException if digit cannot be decoded
     */
    static func decodeDigit(row: BitArray, counters: Array<Int64>, rowOffset: Int64, patterns: Array<Array<Int64>>): Int64 {
        recordPattern(row, rowOffset, counters);
        var bestVariance: Float32 = MAX_AVG_VARIANCE

        // worst variance we'll accept
        var bestMatch: Int64 = -1;
        var max: Int64 = patterns.size;

        for (i in 0..max) {
            var pattern: Array<Int64> = patterns[i]
            var variance: Float32 = patternMatchVariance(counters, pattern, MAX_INDIVIDUAL_VARIANCE);
            if (variance < bestVariance) {
                bestVariance = variance
                bestMatch = i
            }
        }
        if (bestMatch >= 0) {
            return bestMatch
        } else {
            throw NotFoundException.getNotFoundInstance();
        }
    }

    /**
     * Get the format of this decoder.
     *
     * @return The 1D format.
     */
    public func getBarcodeFormat(): BarcodeFormat

    /**
     * Subclasses override this to decode the portion of a barcode between the start
     * and end guard patterns.
     *
     * @param row row of black/white values to search
     * @param startRange start/end offset of start guard pattern
     * @param resultString {@link StringBuilder} to append decoded chars to
     * @return horizontal offset of first pixel after the "middle" that was decoded
     * @throws NotFoundException if decoding could not complete successfully
     */
    protected func decodeMiddle(
        row: BitArray,
        startRange: Array<Int64>,
        resultString: ArrayList<Char>
    ): Int64
}
