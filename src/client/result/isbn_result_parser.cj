/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.client.result

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.*
import QRCode4cj.tools.*

/**
 * Parses strings of digits that represent a ISBN.
 */
public open class ISBNResultParser <: ResultParser {
    /**
     * See ISBN-13 For Dummies
     */
    public func parse(result: Result): ?ParsedResult {
        var format: BarcodeFormat = result.getBarcodeFormat();
        if (format != BarcodeFormat.EAN_13) {
            return None
        }
        var rawText: UTF32String = getMassagedText(result);
        var length: Int64 = rawText.charSize;
        if (length != 13) {
            return None
        }
        if (!rawText.startsWith(UTF32String("978")) && !rawText.startsWith(UTF32String("979"))) {
            return None
        }

        return ISBNParsedResult(rawText.toString());
    }
}
