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
 * Implements the "MATMSG" email message entry format.
 *
 * Supported keys: TO, SUB, BODY
 *
 * @author Sean Owen
 */
public open class EmailDoCoMoResultParser <: AbstractDoCoMoResultParser {
    private static let ATEXT_ALPHANUMERIC: Regex = Regex("[a-zA-Z0-9@.!#$%&'*+\\-/=?^_`{|}~]+");
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!rawText.startsWith(UTF32String("MATMSG:"))) {
            return None
        }
        var tos: Array<String> = matchDoCoMoPrefixedField("TO:", rawText);
        if (tos.size == 0) {
            return None
        }
        for (to in tos) {
            if (!isBasicallyValidEmailAddress(to)) {
                return None
            }
        }
        var subject: String = matchSingleDoCoMoPrefixedField("SUB:", rawText, false);
        var body: String = matchSingleDoCoMoPrefixedField("BODY:", rawText, false);

        return EmailAddressParsedResult(tos, Array<String>(), Array<String>(), subject, body);
    }

    /**
     * This implements only the most basic checking for an email address's validity -- that it contains
     * an '@' and contains no characters disallowed by RFC 2822. This is an overly lenient definition of
     * validity. We want to generally be lenient here since this class is only intended to encapsulate what's
     * in a barcode, not "judge" it.
     */
    static func isBasicallyValidEmailAddress(email: String): Bool {
        if (email == "") {
            return false;
        }

        var matcher = ATEXT_ALPHANUMERIC.matcher(email);
        if (let None <- matcher.fullMatch()) {
            return false;
        }

        var index = email.indexOf('@'.toString());
        if (index == None) {
            return false;
        }

        return true;
    }
}
