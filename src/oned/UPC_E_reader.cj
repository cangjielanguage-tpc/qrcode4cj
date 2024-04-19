/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned

/**
 * Implements decoding of the UPC-E format.
 */
public open class UPCEReader <: UPCEANReader {
    /**
     * The pattern that marks the middle, and end, of a UPC-E pattern.
     * There is no "second half" to a UPC-E barcode.
     */
    private static let MIDDLE_END_PATTERN: Array<Int64> = [1, 1, 1, 1, 1, 1]

    /**
     * See {@link #L_AND_G_PATTERNS}; these values similarly represent patterns of
     * even-odd parity encodings of digits that imply both the number system (0 or 1)
     * used, and the check digit.
     */
    static let NUMSYS_AND_CHECK_DIGIT_PATTERNS: Array<Array<Int64>> = [
        [0x38, 0x34, 0x32, 0x31, 0x2C, 0x26, 0x23, 0x2A, 0x29, 0x25],
        [0x07, 0x0B, 0x0D, 0x0E, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A]
    ]

    private var decodeMiddleCounters: Array<Int64>

    public init() {
        decodeMiddleCounters = Array<Int64>(4, item: 0)
    }

    protected override func decodeMiddle(row: BitArray, startRange: Array<Int64>, result: ArrayList<Char>): Int64 {
        var counters: Array<Int64> = decodeMiddleCounters
        counters[0] = 0
        counters[1] = 0
        counters[2] = 0
        counters[3] = 0
        var end: Int64 = row.getSize();
        var rowOffset: Int64 = startRange[1]

        var lgPatternFound: Int64 = 0;

        var x = 0;
        while (x < 6 && rowOffset < end) {
            var bestMatch: Int64 = decodeDigit(row, counters, rowOffset, L_AND_G_PATTERNS);
            result.append(Char('0'.hashCode() + bestMatch % 10));

            for (i in 0..counters.size) {
                rowOffset += counters[i]
            }
            if (bestMatch >= 10) {
                lgPatternFound |= 1 << (5 - x)
            }
            x++;
        }

        determineNumSysAndCheckDigit(result, lgPatternFound);

        return rowOffset
    }

    protected func decodeEnd(row: BitArray, endStart: Int64): Array<Int64> {
        return findGuardPattern(row, endStart, true, MIDDLE_END_PATTERN);
    }

    protected func checkChecksum(s: UTF32String): Bool {
        return super.checkChecksum(convertUPCEtoUPCA(s));
    }

    private static func determineNumSysAndCheckDigit(resultString: ArrayList<Char>, lgPatternFound: Int64) {
        for (numSys in 0..2) {
            for (d in 0..10) {
                if (lgPatternFound == NUMSYS_AND_CHECK_DIGIT_PATTERNS[numSys][d]) {
                    resultString.insert(0, Char('0'.hashCode() + numSys));
                    resultString.append(Char('0'.hashCode() + d));
                    return;
                }
            }
        }
        throw Qrcoder4cjNotFoundException.getNotFoundInstance();
    }

    public func getBarcodeFormat(): BarcodeFormat {
        return BarcodeFormat.UPC_E;
    }

    /**
     * Expands a UPC-E value back into its full, equivalent UPC-A code value.
     *
     * @param upce UPC-E code as string of digits
     * @return equivalent UPC-A code as string of digits
     */
    public static func convertUPCEtoUPCA(upce: UTF32String): UTF32String {
        var upceChars: Array<Char> = upce.substring(1, 6).toRuneArray()
        var result: ArrayList<Char> = ArrayList<Char>();
        result.append(upce.get(0))
        var lastChar: Char = upceChars[5]
        match (lastChar) {
            case '0' | '1' | '2' =>
                result.append(upceChars[0])
                result.append(upceChars[1])
                result.append(lastChar);
                result.appendAll("0000".toRuneArray());
                result.append(upceChars[2])
                result.append(upceChars[3])
                result.append(upceChars[4])

            case '3' =>
                result.append(upceChars[0])
                result.append(upceChars[1])
                result.append(upceChars[2])

                result.appendAll("00000".toRuneArray());

                result.append(upceChars[3])
                result.append(upceChars[4])

            case '4' =>
                result.append(upceChars[0])
                result.append(upceChars[1])
                result.append(upceChars[2])
                result.append(upceChars[3])
                result.appendAll("00000".toRuneArray());
                result.append(upceChars[4]);

            case _ =>
                result.append(upceChars[0])
                result.append(upceChars[1])
                result.append(upceChars[2])
                result.append(upceChars[3])
                result.append(upceChars[4])
                result.appendAll("0000".toRuneArray());
                result.append(lastChar);
        }

        // Only append check digit in conversion if supplied
        if (upce.charSize >= 8) {
            result.append(upce.get(7))
        }

        return UTF32String(result);
    }
}
