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

from std import unicode.*

/**
 * Tries to parse results that are a URI of some kind.
 *
 * @author Sean Owen
 */
public open class URIResultParser <: ResultParser {
    private static let ALLOWED_URI_CHARS_PATTERN: Regex = Regex("[-._~:/?#\\[\\]@!$&'()*+,;=%A-Za-z0-9]+");
    private static let USER_IN_HOST: Regex = Regex(":/*([^/@]+)@[^/]+");

    // See http://www.ietf.org/rfc/rfc2396.txt
    private static let URL_WITH_PROTOCOL_PATTERN: Regex = Regex("[a-zA-Z][a-zA-Z0-9+-.]+:");
    private static let URL_WITHOUT_PROTOCOL_PATTERN: Regex = Regex(
        "([a-zA-Z0-9\\-]+\\.){1,6}[a-zA-Z]{2,}" + // host name elements; allow up to say 6 domain elements
        "(:\\d{1,5})?" + // maybe port
        "(/|\\?|$)"
    );

    static func isPossiblyMaliciousURI(uri: String): Bool {
        var u = ALLOWED_URI_CHARS_PATTERN.matcher(uri).fullMatch()
        var n = USER_IN_HOST.matcher(uri).find()
        if (let None <- u) {
            true
        } else if (let None <- n) {
            false
        } else {
            true
        }
    }

    static func isBasicallyValidURI(uri: String): Bool {
        if (uri.contains(" ")) {
            // Quick hack check for a common case
            return false;
        }
        var m: Matcher = URL_WITH_PROTOCOL_PATTERN.matcher(uri);
        var n = m.find()
        if (let None <- n) {
            m = URL_WITHOUT_PROTOCOL_PATTERN.matcher(uri)
            n = m.find()
            if (let Some(v) <- n) {
                if ((uri.indexOf(n.getOrThrow().matchStr()) == 0)) {
                    return true
                }
            }
        } else {
            if ((uri.indexOf(n.getOrThrow().matchStr()) == 0)) {
                return true
            }
        }
        return false
    }

    // query, path or nothing
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);

        // We specifically handle the odd "URL" scheme here for simplicity and add "URI" for fun
        // Assume anything starting this way really means to be a URI
        if (rawText.startsWith(UTF32String("URL:")) || rawText.startsWith(UTF32String("URI:"))) {
            return URIParsedResult(rawText.substring(4).trim().toString(), "");
        }
        rawText = rawText.trim()
        if (isBasicallyValidURI(rawText.toString()) == false || isPossiblyMaliciousURI(rawText.toString()) == true) {
            return None
        }
        return URIParsedResult(rawText.toString(), "");
    }
}
