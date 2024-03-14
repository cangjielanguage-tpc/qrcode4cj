/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.client.result

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
