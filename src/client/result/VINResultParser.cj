/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package client.result

from std import regex.*

/**
 * Detects a result that is likely a vehicle identification number.
 *
 * @author Sean Owen
 */
public open class VINResultParser <: ResultParser {
    private static let IOQ: Regex = Regex("[IOQ]");
    private static let AZ09: Regex = Regex("[A-Z0-9]{17}");

    // private var returndata: VINParsedResult = VINParsedResult()
    public override func parse(result: Result): ?ParsedResult {
        if (result.getBarcodeFormat() != BarcodeFormat.CODE_39) {
            return None
        }
        var rawText: String = result.getText();
        rawText = IOQ.matcher(rawText).replaceAll("").trim()
        if (let None <- AZ09.matcher(rawText).fullMatch()) {
            return None
        }
        try {
            if (checkChecksum(UTF32String(rawText)) == false) {
                return None
            }
            var wmi: String = rawText[Range<Int64>(0, 3, 1, true, true, false)]
            return VINParsedResult(
                rawText,
                wmi,
                rawText[Range<Int64>(3, 9, 1, true, true, false)],
                rawText[Range<Int64>(9, 17, 1, true, true, false)],
                countryCode(UTF32String(wmi)),
                rawText[Range<Int64>(3, 8, 1, true, true, false)],
                Int64(modelYear(Char(rawText[9]))),
                Char(rawText[10]),
                rawText[Range<Int64>(11, rawText.size, 1, true, true, false)]
            );
        } catch (iae: IllegalArgumentException) {
            return None
        }
    }

    private static func checkChar(remainder: Int64): Char {
        if (remainder < 10) {
            return Char(UInt32('0') + UInt32(remainder))
        }
        if (remainder == 10) {
            return 'X';
        }
        throw IllegalArgumentException();
    }

    private static func checkChecksum(vin: UTF32String): Bool {
        var sum: Int64 = 0
        for (i in 0..vin.charSize) {
            sum += vinPositionWeight(i + 1) * Int64(vinCharValue(vin.get(i)))
        }
        var checkChar1: Char = vin.get(8)
        var expectedCheckChar: Char = checkChar(sum % 11);
        return checkChar1 == expectedCheckChar
    }

    private static func vinCharValue(c: Char): UInt32 {
        if (c >= 'A' && c <= 'I') {
            return (UInt32(c) - UInt32('A')) + 1
        }
        if (c >= 'J' && c <= 'R') {
            return (UInt32(c) - UInt32('J')) + 1
        }
        if (c >= 'S' && c <= 'Z') {
            return (UInt32(c) - UInt32('S')) + 2
        }
        if (c >= '0' && c <= '9') {
            return UInt32(c) - UInt32('0')
        }
        throw IllegalArgumentException();
    }

    private static func vinPositionWeight(position_: Int64): Int64 {
        if (position_ >= 1 && position_ <= 7) {
            return 9 - position_
        }
        if (position_ == 8) {
            return 10;
        }
        if (position_ == 9) {
            return 0;
        }
        if (position_ >= 10 && position_ <= 17) {
            return 19 - position_
        }
        throw IllegalArgumentException();
    }

    private static func modelYear(c: Char): UInt32 {
        if (c >= 'E' && c <= 'H') {
            return (UInt32(c) - UInt32('E')) + 1984
        }
        if (c >= 'J' && c <= 'N') {
            return (UInt32(c) - UInt32('J')) + 1988
        }
        if (c == 'P') {
            return 1993;
        }
        if (c >= 'R' && c <= 'T') {
            return (UInt32(c) - UInt32('R')) + 1994
        }
        if (c >= 'V' && c <= 'Y') {
            return (UInt32(c) - UInt32('V')) + 1997
        }
        if (c >= '1' && c <= '9') {
            return (UInt32(c) - UInt32('1')) + 2001
        }
        if (c >= 'A' && c <= 'D') {
            return (UInt32(c) - UInt32('A')) + 2010
        }
        throw IllegalArgumentException();
    }

    private static func countryCode(wmi: UTF32String): String {
        var c1: Char = wmi.get(0);
        var c2: Char = wmi.get(1);
        match (c1) {
            case '1' | '4' | '5' => return "US";
            case '2' => return "CA";
            case '3' => if (c2 >= 'A' && c2 <= 'W') {
                return "MX";
            }
            case '9' => if ((c2 >= 'A' && c2 <= 'E') || (c2 >= '3' && c2 <= '9')) {
                return "BR";
            }
            case 'J' => if (c2 >= 'A' && c2 <= 'T') {
                return "JP";
            }
            case 'K' => if (c2 >= 'L' && c2 <= 'R') {
                return "KO";
            }
            case 'L' => return "CN";
            case 'M' => if (c2 >= 'A' && c2 <= 'E') {
                return "IN";
            }
            case 'S' => return excountryCode(c2)

            case 'V' => return excountryCode2(c2)

            case 'W' => return "DE";
            case 'X' => if (c2 == '0' || (c2 >= '3' && c2 <= '9')) {
                return "RU";
            }
            case 'Z' => if (c2 >= 'A' && c2 <= 'R') {
                return "IT";
            }
            case _ => return "UNKNOWN"
        }
        return "";
    }

    private static func excountryCode2(c2: Char): String {
        if (c2 >= 'F' && c2 <= 'R') {
            return "FR";
        }
        if (c2 >= 'S' && c2 <= 'W') {
            return "ES";
        }
        return ""
    }

    private static func excountryCode(c2: Char): String {
        if (c2 >= 'A' && c2 <= 'M') {
            return "UK";
        }
        if (c2 >= 'N' && c2 <= 'T') {
            return "DE";
        }
        return ""
    }
}
