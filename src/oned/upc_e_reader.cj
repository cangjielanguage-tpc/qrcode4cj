/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned

import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.math.*

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
        decodeMiddleCounters = Array<Int64>(4, repeat: 0)
    }

    protected override func decodeMiddle(row: BitArray, startRange: Array<Int64>, result: ArrayList<Rune>): Int64 {
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
            result.add(Rune(r'0'.hashCode() + bestMatch % 10));

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

    private static func determineNumSysAndCheckDigit(resultString: ArrayList<Rune>, lgPatternFound: Int64) {
        for (numSys in 0..2) {
            for (d in 0..10) {
                if (lgPatternFound == NUMSYS_AND_CHECK_DIGIT_PATTERNS[numSys][d]) {
                    resultString.add(Rune(r'0'.hashCode() + numSys), at: 0);
                    resultString.add(Rune(r'0'.hashCode() + d));
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
        var upceChars: Array<Rune> = upce.substring(1, 6).toRuneArray()
        var result: ArrayList<Rune> = ArrayList<Rune>();
        result.add(upce.get(0))
        var lastChar: Rune = upceChars[5]
        match (lastChar) {
            case r'0' | r'1' | r'2' =>
                result.add(upceChars[0])
                result.add(upceChars[1])
                result.add(lastChar);
                result.add(all:"0000".toRuneArray());
                result.add(upceChars[2])
                result.add(upceChars[3])
                result.add(upceChars[4])

            case r'3' =>
                result.add(upceChars[0])
                result.add(upceChars[1])
                result.add(upceChars[2])

                result.add(all:"00000".toRuneArray());

                result.add(upceChars[3])
                result.add(upceChars[4])

            case r'4' =>
                result.add(upceChars[0])
                result.add(upceChars[1])
                result.add(upceChars[2])
                result.add(upceChars[3])
                result.add(all:"00000".toRuneArray());
                result.add(upceChars[4]);

            case _ =>
                result.add(upceChars[0])
                result.add(upceChars[1])
                result.add(upceChars[2])
                result.add(upceChars[3])
                result.add(upceChars[4])
                result.add(all:"0000".toRuneArray());
                result.add(lastChar);
        }

        // Only add check digit in conversion if supplied
        if (upce.charSize >= 8) {
            result.add(upce.get(7))
        }

        return UTF32String(result);
    }
}
