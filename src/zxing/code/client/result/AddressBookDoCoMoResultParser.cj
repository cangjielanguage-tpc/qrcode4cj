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
 * Implements the "MECARD" address book entry format.
 *
 * Supported keys: N, SOUND, TEL, EMAIL, NOTE, ADR, BDAY, URL, plus ORG
 * Unsupported keys: TEL-AV, NICKNAME
 *
 * Except for TEL, multiple values for keys are also not supported;
 * the first one found takes precedence.
 *
 * Our understanding of the MECARD format is based on this document:
 *
 * http://www.mobicode.org.tw/files/OMIA%20Mobile%20Bar%20Code%20Standard%20v3.2.1.doc
 *
 * @author Sean Owen
 */
public open class AddressBookDoCoMoResultParser <: AbstractDoCoMoResultParser {
    public func parse(result: Result): ?ParsedResult {
        // var returndata: AddressBookParsedResult = AddressBookParsedResult()
        var rawText: UTF32String = getMassagedText(result);
        if (!rawText.startsWith(UTF32String("MECARD:"))) {
            return None
        }
        var rawName: Array<String> = matchDoCoMoPrefixedField("N:", rawText);
        if (rawName.isEmpty()) {
            return None
        }
        var name: String = parseName(rawName[0]);
        var pronunciation: String = matchSingleDoCoMoPrefixedField("SOUND:", rawText, true);
        var phoneNumbers: Array<String> = matchDoCoMoPrefixedField("TEL:", rawText);
        var emails: Array<String> = matchDoCoMoPrefixedField("EMAIL:", rawText);
        var note: String = matchSingleDoCoMoPrefixedField("NOTE:", rawText, false);
        var addresses: Array<String> = matchDoCoMoPrefixedField("ADR:", rawText);
        var birthday: String = matchSingleDoCoMoPrefixedField("BDAY:", rawText, true);
        if (!isStringOfDigits(birthday, 8)) {
            // No reason to throw out the whole card because the birthday is formatted wrong.
            birthday = ""
        }
        var urls: Array<String> = matchDoCoMoPrefixedField("URL:", rawText);

        // Although ORG may not be strictly legal in MECARD, it does exist in VCARD and we might as well
        // honor it when found in the wild.
        var org: String = matchSingleDoCoMoPrefixedField("ORG:", rawText, true);

        return AddressBookParsedResult(
            maybeWrap(name),
            Array<String>(),
            pronunciation,
            phoneNumbers,
            Array<String>(),
            emails,
            Array<String>(),
            "",
            note,
            addresses,
            Array<String>(),
            org,
            birthday,
            "",
            urls,
            Array<String>()
        );
    }

    private static func parseName(name: String): String {
        let comma: Int64 = name.indexOf(",") ?? -1
        if (comma >= 0) {
            // Format may be last,first; switch it around
            let firstName = UTF32String(name).substring(comma + 1)
            let lastName = UTF32String(name).substring(comma)
            return "${firstName.toString()} ${lastName.toString()}"
        }
        return name
    }
}
