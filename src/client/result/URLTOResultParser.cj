/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package client.result

/**
 * Parses the "URLTO" result format, which is of the form "URLTO:[title]:[url]".
 * This seems to be used sometimes, but I am not able to find documentation
 * on its origin or official format?
 *
 * @author Sean Owen
 */
public open class URLTOResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!rawText.startsWith(UTF32String("urlto:")) && !rawText.startsWith(UTF32String("URLTO:"))) {
            return None
        }
        var titleEnd: Int64 = rawText.indexOf(':'.toString(), start: 6).getOrThrow();
        if (titleEnd < 0) {
            return None
        }
        var title: String = ""
        if (titleEnd > 6) {
            title = rawText.substring(6, titleEnd - 6).toString()
        }

        var uri: String = rawText.substring(titleEnd + 1).toString();
        return URIParsedResult(uri, title);
    }
}
