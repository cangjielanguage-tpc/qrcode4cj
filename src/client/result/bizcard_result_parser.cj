/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.client.result

import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*

public open class BizcardResultParser <: AbstractDoCoMoResultParser {
    // Yes, we extend AbstractDoCoMoResultParser since the format is very much
    // like the DoCoMo MECARD format, but this is not technically one of
    // DoCoMo's proposed formats
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!rawText.startsWith(UTF32String("BIZCARD:"))) {
            return None
        }
        var firstName: String = matchSingleDoCoMoPrefixedField("N:", rawText, true);
        var lastName: String = matchSingleDoCoMoPrefixedField("X:", rawText, true);
        var fullName: String = buildName(firstName, lastName);
        var title: String = matchSingleDoCoMoPrefixedField("T:", rawText, true);
        var org: String = matchSingleDoCoMoPrefixedField("C:", rawText, true);
        var addresses: Array<String> = matchDoCoMoPrefixedField("A:", rawText);
        var phoneNumber1: String = matchSingleDoCoMoPrefixedField("B:", rawText, true);
        var phoneNumber2: String = matchSingleDoCoMoPrefixedField("M:", rawText, true);
        var phoneNumber3: String = matchSingleDoCoMoPrefixedField("F:", rawText, true);
        var email: String = matchSingleDoCoMoPrefixedField("E:", rawText, true);

        return AddressBookParsedResult(
            maybeWrap(fullName),
            Array<String>(),
            "",
            buildPhoneNumbers(phoneNumber1, phoneNumber2, phoneNumber3),
            Array<String>(),
            maybeWrap(email),
            Array<String>(),
            "",
            "",
            addresses,
            Array<String>(),
            org,
            "",
            title,
            Array<String>(),
            Array<String>()
        );
    }

    private static func buildPhoneNumbers(number1: String, number2: String, number3: String): Array<String> {
        var numbers: ArrayList<String> = ArrayList<String>(3);
        if (number1 != "") {
            numbers.add(number1);
        }
        if (number2 != "") {
            numbers.add(number2);
        }
        if (number3 != "") {
            numbers.add(number3);
        }
        var size: Int64 = numbers.size;
        if (size == 0) {
            return []
        }
        return numbers.toArray();
    }

    private static func buildName(firstName: String, lastName: String): String {
        if (firstName == "") {
            return lastName
        } else {
            if (lastName == "") {
                return firstName
            } else {
                return firstName + " " + lastName
            }
        }
    }
}
