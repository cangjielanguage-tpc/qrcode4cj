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
 * Represents a result that encodes an e-mail address, either as a plain address
 * like "joe@example.org" or a mailto: URL like "mailto:joe@example.org".
 *
 * @author Sean Owen
 */
public open class EmailAddressResultParser <: ResultParser {
    private static let COMMA: Regex = Regex(",");

    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (rawText.startsWith(UTF32String("mailto:")) || rawText.startsWith(UTF32String("MAILTO:"))) {
            // If it starts with mailto:, assume it is definitely trying to be an email address
            var hostEmail: String = rawText.substring(7).toString();
            var queryStart: Int64
            if (let None <- hostEmail.indexOf('?'.toString())) {
                queryStart = -1
            } else {
                queryStart = hostEmail.indexOf('?'.toString()).getOrThrow()
            }
            if (queryStart >= 0) {
                hostEmail = UTF32String(hostEmail).substring(0, queryStart).toString()
            }
            try {
                hostEmail = urlDecode(hostEmail)
            } catch (iae: IllegalArgumentException) {
                return None
            }
            var tos: Array<String> = Array<String>()
            if (!hostEmail.isEmpty()) {
                tos = hostEmail.split(COMMA.string())
            }
            var nameValues: HashMap<String, String> = parseNameValuePairs(rawText);
            var ccs: Array<String> = Array<String>()
            var bccs: Array<String> = Array<String>()
            var subject: String = ""
            var body: String = ""
            if (nameValues != HashMap<String, String>()) {
                if (tos == Array<String>()) {
                    if (let Some(v) <- nameValues.get("to")) {
                        var tosString = v
                        if (!tosString.isEmpty()) {
                            tos = tosString.split(COMMA.string())
                        }
                    }
                }
                if (let Some(v) <- nameValues.get("cc")) {
                    var ccString: String = v
                    if (!ccString.isEmpty()) {
                        ccs = ccString.split(COMMA.string())
                    }
                }
                if (let Some(v) <- nameValues.get("bcc")) {
                    var bccString: String = v
                    if (!bccString.isEmpty()) {
                        bccs = bccString.split(COMMA.string())
                    }
                }
                if (let Some(v) <- nameValues.get("subject")) {
                    subject = v
                }
                if (let Some(v) <- nameValues.get("body")) {
                    body = v
                }
            }
            return EmailAddressParsedResult(tos, ccs, bccs, subject, body);
        } else {
            if (!EmailDoCoMoResultParser.isBasicallyValidEmailAddress(rawText.toString())) {
                return None
            }

            return EmailAddressParsedResult(rawText.toString());
        }
    }
}
