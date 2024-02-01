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
 * Implements the "BIZCARD" address book entry format, though this has been
 * largely reverse-engineered from examples observed in the wild -- still
 * looking for a definitive reference.
 *
 * @author Sean Owen
 */
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
            numbers.append(number1);
        }
        if (number2 != "") {
            numbers.append(number2);
        }
        if (number3 != "") {
            numbers.append(number3);
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
