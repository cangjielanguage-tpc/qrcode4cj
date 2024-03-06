/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package zxing.code.oned

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
