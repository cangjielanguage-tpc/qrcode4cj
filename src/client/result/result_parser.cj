/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.client.result

import std.regex.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.collection.*
import encoding.url.*

/**
 * <p>Abstract class representing the result of decoding a barcode, as more than
 * a String -- as some type of structured data. This might be a subclass which represents
 * a URL, or an e-mail address. {@link #parseResult(Result)} will turn a raw
 * decoded string into the most appropriate type of structured representation.</p>
 *
 * Thanks to Jeff Griffin for proposing rewrite of these classes that relies less
 * on exception-based mechanisms during parsing.
 */
public abstract class ResultParser {
    private static let PARSERS: Array<ResultParser> = [
        WifiResultParser(),
        GeoResultParser(),
        BookmarkDoCoMoResultParser(),
        URLTOResultParser(),
        VINResultParser(),
        TelResultParser(),
        AddressBookDoCoMoResultParser(),
        EmailDoCoMoResultParser(),
        AddressBookAUResultParser(),
        VCardResultParser(),
        BizcardResultParser(),
        VEventResultParser(),
        EmailAddressResultParser(),
        SMTPResultParser(),
        SMSMMSResultParser(),
        SMSTOMMSTOResultParser(),
        ISBNResultParser(),
        ProductResultParser(),
        URIResultParser(),
        ExpandedProductResultParser()
    ]

    private static let DIGITS: Regex = Regex("\\d+");
    private static let AMPERSAND: Regex = Regex("&");
    private static let EQUALS: Regex = Regex("=");
    private static let BYTE_ORDER_MARK: UTF32String = UTF32String("\\ufeff");

    static let EMPTY_STR_ARRAY: Array<String> = Array<String>(0, repeat: "")

    /**
     * Attempts to parse the raw {@link Result}'s contents as a particular type
     * of information (email, URL, etc.) and return a {@link ParsedResult} encapsulating
     * the result of parsing.
     *
     * @param theResult the raw {@link Result} to parse
     * @return {@link ParsedResult} encapsulating the parsing result
     */
    public func parse(theResult: Result): ?ParsedResult

    protected static func getMassagedText(result: Result): UTF32String {
        var text: UTF32String = UTF32String(result.getText());
        if (text.startsWith(BYTE_ORDER_MARK)) {
            text = text.substring(1)
        }
        return text
    }
    public static func parseResult(theResult: Result): ParsedResult {
        for (parser in PARSERS) {
            var result = parser.parse(theResult);
            if (let Some(v) <- result) {
                return v
            }
        }
        return TextParsedResult(theResult.getText(), "");
    }

    protected static func maybeAppend(value: String, result: ArrayList<Rune>) {
        if (!value.isEmpty()) {
            result.add(r'\n');
            result.add(all:value.toRuneArray());
        }
    }

    protected static func maybeAppend(value: Array<String>, result: ArrayList<Rune>) {
        if (value.size != 0) {
            for (s in value) {
                result.add(r'\n');
                result.add(all:s.toRuneArray());
            }
        }
    }

    protected static func maybeWrap(value: String): Array<String> {
        if (value.size != 0) {
            return [value]
        } else {
            return Array<String>()
        }
    }

    protected static func unescapeBackslash(escaped: UTF32String): UTF32String {
        var backslash: Int64
        if (escaped.indexOf("\\") == None) {
            return escaped
        } else {
            backslash = escaped.indexOf("\\").getOrThrow()
        }
        var max: Int64 = escaped.size;
        var unescaped: ArrayList<Rune> = ArrayList<Rune>();
        unescaped.add(all:escaped.substring(0, backslash).toRuneArray());
        var nextIsEscaped: Bool = false;

        for (i in backslash..max) {
            var c: Rune = escaped.get(i);
            if (nextIsEscaped || c != r'\\') {
                unescaped.add(c);
                nextIsEscaped = false
            } else {
                nextIsEscaped = true
            }
        }
        return UTF32String(unescaped);
    }

    protected static func parseHexDigit(c: Rune): UInt32 {
        if (c >= r'0' && c <= r'9') {
            return UInt32(c) - UInt32(b'0')
        }
        if (c >= r'a' && c <= r'f') {
            return 10 + (UInt32(c) - UInt32(b'a'))
        }
        if (c >= r'A' && c <= r'F') {
            return 10 + (UInt32(c) - UInt32(b'A'))
        }
        return throw IllegalArgumentException();
    }

    protected static func isStringOfDigits(value: String, length: Int64): Bool {
        if (value == "null") {
            return false;
        }

        if (length <= 0) {
            return false;
        }

        if (length != value.size) {
            return false;
        }

        if (let None <- DIGITS.matcher(value).fullMatch()) {
            return false;
        }

        return true;
    }

    protected static func isSubstringOfDigits(value: UTF32String, offset: Int64, length: Int64): Bool {
        if (value == "" || length <= 0) {
            return false;
        }
        var max: Int64 = offset + length
        var v = DIGITS.matcher(value.substring(offset, max - offset).toString()).fullMatch()
        if (value.size >= max) {
            if (let Some(MatchData) <- v) {
                return true;
            }
        }
        return false;
    }

    static func parseNameValuePairs(uri: UTF32String): HashMap<String, String> {
        var paramStart: Int64 = 0
        var obj = uri.indexOf(r'?'.toString())
        if (let None <- obj) {
            paramStart = -1
        } else {
            paramStart = obj.getOrThrow()
        }
        if (paramStart < 0) {
            return HashMap<String, String>()
        }
        var result: HashMap<String, String> = HashMap<String, String>(3);
        for (keyValue in AMPERSAND.matcher(uri.substring(paramStart + 1).toString()).split()) {
            appendKeyValue(UTF32String(keyValue), result)
        }
        return result
    }

    private static func appendKeyValue(keyValue: UTF32String, result: Map<String, String>) {
        var keyValueTokens: Array<UTF32String> = [UTF32String(""), UTF32String("")]
        var equalsIndex = keyValue.indexOf(r'='.toString())
        if (equalsIndex.getOrThrow() >= 0) {
            keyValueTokens[0] = keyValue.substring(0, equalsIndex.getOrThrow())
            keyValueTokens[1] = keyValue.substring(equalsIndex.getOrThrow() + 1)
        } else {
            keyValueTokens[0] = keyValue
        }
        if (keyValueTokens.size == 2) {
            var key: String = keyValueTokens[0].toString()
            var value: String = keyValueTokens[1].toString()
            try {
                value = urlDecode(value)
                result.add(key, value);
            } catch (iae: IllegalArgumentException) {
                // continue; invalid data such as an escape like %0t
            }
        }
    }

    static func urlDecode(encoded: String): String {
        try {
            return URL.parse(encoded).toString();
        } catch (uee: IllegalArgumentException) {
            throw IllegalArgumentException();
            // can't happen
        }
    }

    static func matchPrefixedField(prefix: String, rawText: UTF32String, endChar: Rune, trim: Bool): Array<String> {
        var matches: ArrayList<String> = ArrayList<String>();
        var i: Int64 = 0;
        var max: Int64 = rawText.size;
        while (i < max) {
            var index = rawText.indexOf(UTF32String(prefix), start: i)
            if (index == None) {
                break
            } else {
                i = index.getOrThrow()
            }
            i += prefix.size

            // Skip past this prefix we found to start
            var start: Int64 = i

            // Found the start of a match here
            var more: Bool = true;
            while (more) {
                i = rawText.indexOf(UTF32String(endChar), start: i).getOrThrow()
                if (i < 0) {
                    // No terminating end character? uh, done. Set i such that loop terminates and break
                    i = rawText.size
                    more = false
                } else if (countPrecedingBackslashes(rawText, i) % 2 != 0) {
                    // semicolon was escaped (odd count of preceding backslashes) so continue
                    i++
                } else {
                    // found a match
                    if (matches == ArrayList<String>()) {
                        matches = ArrayList<String>(3)
                        // lazy init
                    }
                    var element = unescapeBackslash(rawText.substring(start, i - start))
                    if (trim) {
                        element = element.trim()
                    }
                    if (!element.isEmpty()) {
                        matches.add(element.toString());
                    }
                    i++
                    more = false
                }
            }
        }
        if (matches == ArrayList<String>() || matches.isEmpty()) {
            return []
        }
        return matches.toArray();
    }

    private static func countPrecedingBackslashes(s: UTF32String, pos: Int64): Int64 {
        var i = pos - 1
        var count: Int64 = 0;
        while (i >= 0 && s.get(i) == r'\\') {
            count++
            i--
        }
        return count
    }

    static func matchSinglePrefixedField(prefix: String, rawText: UTF32String, endChar: Rune, trim: Bool): String {
        var matches: Array<String> = matchPrefixedField(prefix, rawText, endChar, trim);
        if (matches.isEmpty()) {
            return ""
        } else {
            return matches[0].toString()
        }
    }
}
