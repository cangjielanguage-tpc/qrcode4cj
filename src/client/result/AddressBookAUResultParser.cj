/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package client.result

import tools.UTF32String

public open class AddressBookAUResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);

        // MEMORY is mandatory; seems like a decent indicator, as does end-of-record separator CR/LF
        if (!rawText.contains("MEMORY") || !rawText.contains("\r\n")) {
            return None
        }

        // NAME1 and NAME2 have specific uses, namely written name and pronunciation, respectively.
        // Therefore we treat them specially instead of as an array of names.
        var name: String = matchSinglePrefixedField("NAME1:", rawText, '\r', true);
        var pronunciation: String = matchSinglePrefixedField("NAME2:", rawText, '\r', true);

        var phoneNumbers: Array<String> = matchMultipleValuePrefix("TEL", rawText);
        var emails: Array<String> = matchMultipleValuePrefix("MAIL", rawText);
        var note: String = matchSinglePrefixedField("MEMORY:", rawText, '\r', false);
        var address: String = matchSinglePrefixedField("ADD:", rawText, '\r', true);
        var addresses: Array<String> = Array<String>()
        if (address.isEmpty()) {
            addresses.isEmpty;
        } else {
            addresses = [address]
        }
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
            "",
            "",
            "",
            Array<String>(),
            Array<String>()
        );
    }

    private static func matchMultipleValuePrefix(prefix: String, rawText: UTF32String): Array<String> {
        var values: ArrayList<String> = ArrayList<String>(0)

        // For now, always 3, and always trim
        for (i in 1..4) {
            var value: String = matchSinglePrefixedField(prefix + i.toString() + ":", rawText, '\r', true);
            if (value.isEmpty()) {
                break
            }
            if (values.isEmpty()) {
                values = ArrayList<String>(3)
                // lazy init
            }
            values.append(value);
        }
        if (values.isEmpty()) {
            return []
        }

        return values.toArray();
    }

    static func isBasicallyValidURI(uri: String): Bool {
        if (uri.isEmpty() || uri.indexOf(' '.toString()).getOrThrow() >= 0 ||
            uri.indexOf('\n'.toString()).getOrThrow() >= 0) {
            return false;
        }

        // Look for period in a domain but followed by at least a two-char TLD
        // Forget strings that don't have a valid-looking protocol
        let period: Int64 = uri.indexOf('.'.toString()).getOrThrow();
        var charArray = uri.toRuneArray()
        if (period >= charArray.size - 2) {
            return false;
        }
        let colon: Int64 = uri.indexOf(':'.toString()).getOrThrow();
        if (period < 0 && colon < 0) {
            return false;
        }
        if (colon >= 0) {
            if (period < 0 || period > colon) {
                // colon ends the protocol
                for (i in 0..colon) {
                    let c: Char = charArray[i]
                    if ((c < 'a' || c > 'z') && (c < 'A' || c > 'Z')) {
                        return false;
                    }
                }
            } else {
                // colon starts the port; crudely look for at least two numbers
                if (colon >= charArray.size - 2) {
                    return false;
                }
                for (i in colon + 1..colon + 3) {
                    let c: Char = charArray[i]
                    if (c < '0' || c > '9') {
                        return false;
                    }
                }
            }
        }
        return true;
    }
}
