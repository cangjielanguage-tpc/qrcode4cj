/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.client.result

public open class BookmarkDoCoMoResultParser <: AbstractDoCoMoResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = UTF32String(result.getText())
        if (!rawText.startsWith(UTF32String("MEBKM:"))) {
            return None
        }
        var title: String = matchSingleDoCoMoPrefixedField("TITLE:", rawText, true);
        var rawUri: Array<String> = matchDoCoMoPrefixedField("URL:", rawText);
        if (rawUri.size == 0) {
            return None
        }
        var uri: String = rawUri[0]
        if (URIResultParser.isBasicallyValidURI(uri)) {
            return URIParsedResult(uri, title)
        } else {
            return None
        }
    }
}
