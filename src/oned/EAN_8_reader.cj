/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned

/**
 * <p>Implements decoding of the EAN-8 format.</p>
 *
 * @author Sean Owen
 */
public open class EAN8Reader <: UPCEANReader {
    private var decodeMiddleCounters: Array<Int64> = Array<Int64>(4, item: 0)

    public init() {}

    protected func decodeMiddle(row: BitArray, startRange: Array<Int64>, result: ArrayList<Char>): Int64 {
        var counters: Array<Int64> = decodeMiddleCounters
        counters[0] = 0
        counters[1] = 0
        counters[2] = 0
        counters[3] = 0
        var end: Int64 = row.getSize();
        var rowOffset: Int64 = startRange[1]

        var x = 0;
        while (x < 4 && rowOffset < end) {
            var bestMatch: Int64 = decodeDigit(row, counters, rowOffset, L_PATTERNS);
            result.append(Char('0'.hashCode() + bestMatch));

            for (i in 0..counters.size) {
                rowOffset += counters[i]
            }
            x++;
        }

        var middleRange: Array<Int64> = findGuardPattern(row, rowOffset, true, MIDDLE_PATTERN);
        rowOffset = middleRange[1]

        x = 0
        while (x < 4 && rowOffset < end) {
            var bestMatch: Int64 = decodeDigit(row, counters, rowOffset, L_PATTERNS);
            result.append(Char('0'.hashCode() + bestMatch));

            for (i in 0..counters.size) {
                rowOffset += counters[i]
            }
            x++;
        }

        return rowOffset
    }

    public func getBarcodeFormat(): BarcodeFormat {
        return BarcodeFormat.EAN_8;
    }
}
