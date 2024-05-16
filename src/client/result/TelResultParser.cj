/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package client.result

/**
 * Parses a "tel:" URI result, which specifies a phone number.
 */
public open class TelResultParser <: ResultParser {
    var returndata: TelParsedResult = TelParsedResult()
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!rawText.startsWith(UTF32String("tel:")) && !rawText.startsWith(UTF32String("TEL:"))) {
            return None
        }

        // Normalize "TEL:" to "tel:"
        var telURI: UTF32String = UTF32String("")
        if (rawText.startsWith(UTF32String("TEL:"))) {
            telURI = UTF32String("tel:") + rawText.substring(4)
        } else {
            telURI = rawText
        }

        // Drop tel, query portion
        var obj = rawText.indexOf('?'.toString(), start: 4)
        var queryStart = 0
        if (let Some(v) <- obj) {
            queryStart = v
        } else {
            queryStart = -1
        }
        var number: String = ""
        if (queryStart < 0) {
            number = rawText.substring(4).toString()
        } else {
            number = rawText.substring(4, queryStart - 4).toString()
        }
        return TelParsedResult(number, telURI.toString(), "");
    }
}
