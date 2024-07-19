/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.client.result

import std.regex.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.collection.*

/**
 * Detects a result that is likely a vehicle identification number.
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
        rawText = IOQ.matcher(rawText).replaceAll("").trimAscii()
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
                Int64(modelYear(Rune(rawText[9]))),
                Rune(rawText[10]),
                rawText[Range<Int64>(11, rawText.size, 1, true, true, false)]
            );
        } catch (iae: IllegalArgumentException) {
            return None
        }
    }

    private static func checkChar(remainder: Int64): Rune {
        if (remainder < 10) {
            return Rune(UInt32(r'0') + UInt32(remainder))
        }
        if (remainder == 10) {
            return r'X';
        }
        throw IllegalArgumentException();
    }

    private static func checkChecksum(vin: UTF32String): Bool {
        var sum: Int64 = 0
        for (i in 0..vin.charSize) {
            sum += vinPositionWeight(i + 1) * Int64(vinCharValue(vin.get(i)))
        }
        var checkChar1: Rune = vin.get(8)
        var expectedCheckChar: Rune = checkChar(sum % 11);
        return checkChar1 == expectedCheckChar
    }

    private static func vinCharValue(c: Rune): UInt32 {
        if (c >= r'A' && c <= r'I') {
            return (UInt32(c) - UInt32(r'A')) + 1
        }
        if (c >= r'J' && c <= r'R') {
            return (UInt32(c) - UInt32(r'J')) + 1
        }
        if (c >= r'S' && c <= r'Z') {
            return (UInt32(c) - UInt32(r'S')) + 2
        }
        if (c >= r'0' && c <= r'9') {
            return UInt32(c) - UInt32(r'0')
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

    private static func modelYear(c: Rune): UInt32 {
        if (c >= r'E' && c <= r'H') {
            return (UInt32(c) - UInt32(r'E')) + 1984
        }
        if (c >= r'J' && c <= r'N') {
            return (UInt32(c) - UInt32(r'J')) + 1988
        }
        if (c == r'P') {
            return 1993;
        }
        if (c >= r'R' && c <= r'T') {
            return (UInt32(c) - UInt32(r'R')) + 1994
        }
        if (c >= r'V' && c <= r'Y') {
            return (UInt32(c) - UInt32(r'V')) + 1997
        }
        if (c >= r'1' && c <= r'9') {
            return (UInt32(c) - UInt32(r'1')) + 2001
        }
        if (c >= r'A' && c <= r'D') {
            return (UInt32(c) - UInt32(r'A')) + 2010
        }
        throw IllegalArgumentException();
    }

    private static func countryCode(wmi: UTF32String): String {
        var c1: Rune = wmi.get(0);
        var c2: Rune = wmi.get(1);
        match (c1) {
            case r'1' | r'4' | r'5' => return "US";
            case r'2' => return "CA";
            case r'3' => if (c2 >= r'A' && c2 <= r'W') {
                return "MX";
            }
            case r'9' => if ((c2 >= r'A' && c2 <= r'E') || (c2 >= r'3' && c2 <= r'9')) {
                return "BR";
            }
            case r'J' => if (c2 >= r'A' && c2 <= r'T') {
                return "JP";
            }
            case r'K' => if (c2 >= r'L' && c2 <= r'R') {
                return "KO";
            }
            case r'L' => return "CN";
            case r'M' => if (c2 >= r'A' && c2 <= r'E') {
                return "IN";
            }
            case r'S' => return excountryCode(c2)

            case r'V' => return excountryCode2(c2)

            case r'W' => return "DE";
            case r'X' => if (c2 == r'0' || (c2 >= r'3' && c2 <= r'9')) {
                return "RU";
            }
            case r'Z' => if (c2 >= r'A' && c2 <= r'R') {
                return "IT";
            }
            case _ => return "UNKNOWN"
        }
        return "";
    }

    private static func excountryCode2(c2: Rune): String {
        if (c2 >= r'F' && c2 <= r'R') {
            return "FR";
        }
        if (c2 >= r'S' && c2 <= r'W') {
            return "ES";
        }
        return ""
    }

    private static func excountryCode(c2: Rune): String {
        if (c2 >= r'A' && c2 <= r'M') {
            return "UK";
        }
        if (c2 >= r'N' && c2 <= r'T') {
            return "DE";
        }
        return ""
    }
}
