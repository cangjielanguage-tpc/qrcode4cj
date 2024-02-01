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

package zxing.code.client.result

/**
 * Parses a "tel:" URI result, which specifies a phone number.
 *
 * @author Sean Owen
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
