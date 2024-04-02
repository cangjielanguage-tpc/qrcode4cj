/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

from std import convert.*

/**
 * @see UPCEANExtension5Support
 */
open class UPCEANExtension2Support {
    private let decodeMiddleCounters: Array<Int64> = Array<Int64>(4, item: 0)

    func decodeRow(rowNumber: Int64, row: BitArray, extensionStartRange: Array<Int64>): Result {
        var result: ArrayList<Char> = ArrayList<Char>()

        var end: Int64 = decodeMiddle(row, extensionStartRange, result);

        var resultString: String = String(result);
        var extensionData: HashMap<ResultMetadataType, Any> = parseExtensionString(resultString);

        var extensionResult: Result = Result(
            resultString,
            Array<UInt8>(),
            Array<ResultPoint>(
                [
                    ResultPoint(Float32(extensionStartRange[0] + extensionStartRange[1]) / 2.0, Float32(rowNumber)),
                    ResultPoint(Float32(end), Float32(rowNumber))
                ]
            ),
            BarcodeFormat.UPC_EAN_EXTENSION
        );
        if (extensionData.size != 0) {
            extensionResult.putAllMetadata(extensionData);
        }

        return extensionResult
    }

    private func decodeMiddle(row: BitArray, startRange: Array<Int64>, resultString: ArrayList<Char>): Int64 {
        var counters: Array<Int64> = decodeMiddleCounters
        counters[0] = 0
        counters[1] = 0
        counters[2] = 0
        counters[3] = 0
        var end: Int64 = row.getSize();
        var rowOffset: Int64 = startRange[1]

        var checkParity: Int64 = 0;

        var x = 0;
        while (x < 2 && rowOffset < end) {
            var bestMatch: Int64 = UPCEANReader.decodeDigit(row, counters, rowOffset, UPCEANReader.L_AND_G_PATTERNS);
            resultString.append(Char('0'.hashCode() + bestMatch % 10));

            for (i in 0..counters.size) {
                rowOffset += counters[i]
            }
            if (bestMatch >= 10) {
                checkParity |= 1 << (1 - x)
            }
            if (x != 1) {
                // Read off separator if not last
                rowOffset = row.getNextSet(rowOffset)
                rowOffset = row.getNextUnset(rowOffset)
            }
            x++;
        }

        if (resultString.size != 2) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        if (Int64.parse(String(resultString)) % 4 != checkParity) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        return rowOffset
    }

    /**
     * @param raw raw content of extension
     * @return formatted interpretation of raw content as a {@link Map} mapping
     * one ResultMetadataType to appropriate value, or None if not known
     */
    private static func parseExtensionString(raw: String): HashMap<ResultMetadataType, Any> {
        if (raw.toRuneArray().size != 2) {
            return HashMap<ResultMetadataType, Any>()
        }
        var result: HashMap<ResultMetadataType, Any> = HashMap<ResultMetadataType, Any>();
        result.put(ResultMetadataType.ISSUE_NUMBER, Int64.parse(raw));
        return result
    }
}
