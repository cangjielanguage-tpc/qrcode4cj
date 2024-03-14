/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * @see UPCEANExtension2Support
 */
open class UPCEANExtension5Support {
    private static let CHECK_DIGIT_ENCODINGS: Array<Int64> = [0x18, 0x14, 0x12, 0x11, 0x0C, 0x06, 0x03, 0x0A, 0x09, 0x05]

    private let decodeMiddleCounters: Array<Int64> = Array<Int64>(4, item: 0)

    func decodeRow(rowNumber: Int64, row: BitArray, extensionStartRange: Array<Int64>): Result {
        var result: ArrayList<Char> = ArrayList<Char>()

        var end: Int64 = decodeMiddle(row, extensionStartRange, result);

        var resultString: UTF32String = UTF32String(result);
        var extensionData: HashMap<ResultMetadataType, Any> = parseExtensionString(resultString);

        var extensionResult: Result = Result(
            resultString.toString(),
            Array<UInt8>(),
            Array<ResultPoint>(
                [
                    ResultPoint(Float32(extensionStartRange[0] + extensionStartRange[1]) / 2.0, Float32(rowNumber)),
                    ResultPoint(Float32(end), Float32(rowNumber))
                ]
            ),
            BarcodeFormat.UPC_EAN_EXTENSION
        );
        if (extensionData.size > 0) {
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

        var lgPatternFound: Int64 = 0;

        var x = 0;
        while (x < 5 && rowOffset < end) {
            var bestMatch: Int64 = UPCEANReader.decodeDigit(row, counters, rowOffset, UPCEANReader.L_AND_G_PATTERNS);
            resultString.append(Char('0'.hashCode() + bestMatch % 10));

            for (i in 0..counters.size) {
                rowOffset += counters[i]
            }
            if (bestMatch >= 10) {
                lgPatternFound |= 1 << (4 - x)
            }
            if (x != 4) {
                // Read off separator if not last
                rowOffset = row.getNextSet(rowOffset)
                rowOffset = row.getNextUnset(rowOffset)
            }
            x++;
        }

        if (resultString.size != 5) {
            throw NotFoundException.getNotFoundInstance();
        }

        var checkDigit: Int64 = determineCheckDigit(lgPatternFound);
        if (extensionChecksum(UTF32String(resultString)) != checkDigit) {
            throw NotFoundException.getNotFoundInstance();
        }

        return rowOffset
    }

    private static func extensionChecksum(s: UTF32String): Int64 {
        var length: Int64 = s.charSize;
        var sum: Int64 = 0;
        var i: Int64 = length - 2
        while (i >= 0) {
            sum += s.get(i).hashCode() - '0'.hashCode()
            i -= 2
        }
        sum *= 3
        i = length - 1
        while (i >= 0) {
            sum += s.get(i).hashCode() - '0'.hashCode()
            i -= 2
        }
        sum *= 3
        return sum % 10
    }

    private static func determineCheckDigit(lgPatternFound: Int64): Int64 {
        for (d in 0..10) {
            if (lgPatternFound == CHECK_DIGIT_ENCODINGS[d]) {
                return d
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }

    /**
     * @param raw raw content of extension
     * @return formatted interpretation of raw content as a {@link HashMap} mapping
     * one {@link ResultMetadataType} to appropriate value, or {@code null} if not known
     */
    private static func parseExtensionString(raw: UTF32String): HashMap<ResultMetadataType, Any> {
        if (raw.charSize != 5) {
            return HashMap<ResultMetadataType, Any>();
        }
        var value: String = parseExtension5String(raw);
        if (value.isEmpty()) {
            return HashMap<ResultMetadataType, Any>();
        }
        var result: HashMap<ResultMetadataType, Any> = HashMap<ResultMetadataType, Any>();
        result.put(ResultMetadataType.SUGGESTED_PRICE, value);
        return result
    }

    private static func parseExtension5String(raw: UTF32String): String {
        var currency: String
        match (raw[0]) {
            case '0' => currency = "£"

            case '5' => currency = "$"

            case '9' =>
                // Reference: http://www.jollytech.com
                if (raw == "90000") {
                    // No suggested retail price
                    return "";
                } else if (raw == "99991") { // Complementary
                    return "0.00";
                } else if (raw == "99990") {
                    return "Used";
                }
                // Otherwise... unknown currency?
                currency = ""

            case _ => currency = ""
        }
        var rawAmount: Int64 = Int64.parse(raw.substring(0, 1).toString());
        var unitsString: String = (rawAmount / 100).toString();
        var hundredths: Int64 = rawAmount % 100
        var hundredthsString: String = ""
        if (hundredths < 10) {
            hundredthsString = "0" + hundredths.toString()
        } else {
            hundredthsString = hundredths.toString()
        }

        return currency + unitsString + "." + hundredthsString
    }
}
