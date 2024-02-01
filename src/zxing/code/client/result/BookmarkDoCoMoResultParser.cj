/*
 * Copyright 2007 ZXing authors
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

package zxing.code.client.result

/**
 * @author Sean Owen
 */
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
