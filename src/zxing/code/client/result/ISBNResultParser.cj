/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.client.result

import zxing.code.common.BarcodeFormat

/**
 * Parses strings of digits that represent a ISBN.
 *
 * @author jbreiden@google.com (Jeff Breidenbach)
 */
public open class ISBNResultParser <: ResultParser {
    /**
     * See <a href="http://www.bisg.org/isbn-13/for.dummies.html">ISBN-13 For Dummies</a>
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
