/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.client.result

public open class SMSTOMMSTOResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!(rawText.startsWith(UTF32String("smsto:")) || rawText.startsWith(UTF32String("SMSTO:")) ||
            rawText.startsWith(UTF32String("mmsto:")) || rawText.startsWith(UTF32String("MMSTO:")))) {
            return None
        }

        // Thanks to dominik.wild for suggesting this enhancement to support
        // smsto:number:body URIs
        var number: UTF32String = rawText.substring(6);
        var body: UTF32String = UTF32String("");
        var bodyStart = number.indexOf(':'.toString());
        if (bodyStart != None) {
            body = number.substring(bodyStart.getOrThrow() + 1)
            number = number.substring(0, bodyStart.getOrThrow())
        }
        return SMSParsedResult(number.toString(), "", "", body.toString());
    }
}
