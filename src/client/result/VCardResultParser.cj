/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.client.result

import std.io.*
import encoding.url.*
import QRCode4cj.common.StandardCharsets
import QRCode4cj.common.MyCharset
import std.regex.*
import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*

/**
 * Parses contact information formatted according to the VCard (2.1) format. This is not a complete
 * implementation but should parse information as commonly encoded in 2D barcodes.
 */
public open class VCardResultParser <: ResultParser {
    private static let BEGIN_VCARD: Regex = Regex("(?i)BEGIN:VCARD");
    private static let VCARD_LIKE_DATE: Regex = Regex("\\d{4}-?\\d{2}-?\\d{2}");
    private static let CR_LF_SPACE_TAB: Regex = Regex("\r\n[ \t]");
    private static let NEWLINE_ESCAPE: Regex = Regex("\\\\[nN]");
    private static let VCARD_ESCAPES: Regex = Regex("\\\\([,;\\\\])");
    private static let EQUALS: String = ("=")
    private static let SEMICOLON: String = (";")
    private static let UNESCAPED_SEMICOLONS: Regex = Regex("(?<!\\\\);+");
    private static let COMMA: String = (",")
    private static let SEMICOLON_OR_COMMA: String = ("[;,]")
    public override func parse(result: Result): ?ParsedResult {
        // Although we should insist on the raw text ending with "END:VCARD", there's no reason to
        // throw out everything else we parsed just because this was omitted. In fact, Eclair
        // is doing just that, and we can't parse its contacts without this leniency.
        var rawText: UTF32String = getMassagedText(result);
        var m = BEGIN_VCARD.matcher(rawText.toString())
        var n = m.find()
        if (let None <- n) {
            return None
        } else {
            if (rawText.indexOf(n.getOrThrow().matchStr()) != 0) {
                return None
            }
        }
        var names: ArrayList<ArrayList<String>> = matchVCardPrefixedField("FN", rawText, true, false);
        var namess: ArrayList<ArrayList<String>> = ArrayList<ArrayList<String>>()
        if (names.isEmpty()) {
            // If no display names found, look for regular name fields and format them
            names = matchVCardPrefixedField("N", rawText, true, false)
            formatNames(names);
            exparse(names, namess)
        }
        var nicknameString: ArrayList<String> = matchSingleVCardPrefixedField("NICKNAME", rawText, true, false);

        var nicknames: Array<String> = Array<String>()
        var phoneTypes: Array<String> = Array<String>()
        if (nicknameString.size != 0) {
            nicknames = COMMA.split(",")
        }

        var phoneNumbers: ArrayList<ArrayList<String>> = matchVCardPrefixedField("TEL", rawText, true, false);
        var emails: ArrayList<ArrayList<String>> = matchVCardPrefixedField("EMAIL", rawText, true, false);
        var note: ArrayList<String> = matchSingleVCardPrefixedField("NOTE", rawText, false, false);
        var addresses: ArrayList<ArrayList<String>> = matchVCardPrefixedField("ADR", rawText, true, true);
        var org: ArrayList<String> = matchSingleVCardPrefixedField("ORG", rawText, true, true);
        var birthday: ArrayList<String> = matchSingleVCardPrefixedField("BDAY", rawText, true, false);
        if (birthday.size != 0 && !isLikeVCardDate(birthday[0])) {
            birthday = ArrayList<String>()
        }
        var title: ArrayList<String> = matchSingleVCardPrefixedField("TITLE", rawText, true, false);
        var urls = matchVCardPrefixedField("URL", rawText, true, false);
        var instantMessenger: ArrayList<String> = matchSingleVCardPrefixedField("IMPP", rawText, true, false);
        var geoString: ArrayList<String> = matchSingleVCardPrefixedField("GEO", rawText, true, false);
        var geo: Array<String> = Array<String>()
        if (geoString.size != 0) {
            geo = SEMICOLON_OR_COMMA.split(geoString[0])
        }
        if (geo.size != 2) {
            geo = Array<String>()
        }
        return AddressBookParsedResult(toPrimaryValues(namess), nicknames, "", toPrimaryValues(phoneNumbers), phoneTypes,
            toPrimaryValues(emails), toTypes(emails), toPrimaryValue(instantMessenger), toPrimaryValue(note),
            toPrimaryValues(addresses), toTypes(addresses), toPrimaryValue(org), toPrimaryValue(birthday),
            toPrimaryValue(title), toPrimaryValues(urls), geo);
    }

    private func exparse(names: ArrayList<ArrayList<String>>, namess: ArrayList<ArrayList<String>>) {
        for (name in names) {
            var nam: ArrayList<String> = ArrayList<String>()
            for (na in name) {
                nam.append(na)
            }
            namess.append(nam)
        }
    }

    static func matchVCardPrefixedField(prefix: String, rawText: UTF32String, trim: Bool, parseFieldDivider: Bool): ArrayList<ArrayList<String>> {
        var matches: ArrayList<ArrayList<String>> = ArrayList<ArrayList<String>>();
        var i: Int64 = 0;
        var max: Int64 = rawText.charSize;

        while (i < max) {
            // At start or after newline, match prefix, followed by optional metadata 
            // (led by ;) ultimately ending in colon
            var matcher: Matcher = Regex("(?i)(?:^|\n)" + prefix + "(?i)(?:;([^:]*))?:").matcher(rawText.toString());

            if (i > 0) {
                i--
                // Find from i-1 not i since looking at the preceding character
            }
            var matchData = matcher.find(i)
            if (let None <- matchData) {
                break
            }
            i = matchData.getOrThrow().matchPosition(0).end
            var metadataString = ""

            // group 0 = whole pattern; end(0) is past final colon
            if (let Some(result) <- matcher.find(1)) {
                if (result.groupNumber() > 0) {
                    metadataString = result.matchStr(1)
                }
            }

            // group 1 = metadata substring
            var metadata: ArrayList<String> = ArrayList<String>();
            var quotedPrintable: Bool = false;
            var quotedPrintableCharset: String = "";
            var valueType: String = "";
            if (metadataString != "") {
                for (metadatum in metadataString.split(SEMICOLON)) {
                    if (metadata.isEmpty()) {
                        metadata = ArrayList<String>(1)
                    }
                    metadata.append(metadatum);
                    var metadatumTokens: Array<String> = metadatum.split(EQUALS);
                    if (metadatumTokens.size > 1) {
                        var key: String = metadatumTokens[0]
                        var value: String = metadatumTokens[1]
                        if ("ENCODING" == (key) && "QUOTED-PRINTABLE" == (value)) {
                            quotedPrintable = true
                        } else if ("CHARSET" == (key)) {
                            quotedPrintableCharset = value
                        } else if ("VALUE" == (key)) {
                            valueType = value
                        }
                    }
                }
            }
            var matchStart: Int64 = i

            /* Found the start of a match here */
            while (let Some(v) <- rawText.indexOf(r'\n'.toString(), start: i)) { /* Really, end in \r\n */
                i = v
                if (i < rawText.charSize - 1 && /* But if followed by tab or space, */
                    (rawText.get(i + 1) == r' ' || /* this is only a continuation */
                    rawText.get(i + 1) == r'\t')) {
                    i = i + 2
                /* Skip \n and continutation whitespace */
                } else if (quotedPrintable && /* If preceded by = in quoted printable */
                    ((i >= 1 && rawText.get(i - 1) == r'=') || /* this is a continuation */
                    (i >= 2 && rawText.get(i - 2) ==
                    r'='))) {
                    i++
                /* Skip \n */
                } else {
                    break
                }
            }

            if (i < 0) {
                /* No terminating end character? uh, done. Set i such that loop terminates and break */
                i = max
            } else if (i > matchStart) {
                /* found a match */
                if (matches.isEmpty()) {
                    matches = ArrayList()
                    /* lazy init */
                }
                if (i >= 1 && rawText.get(i - 1) == r'\r') {
                    i--
                    /* Back up over \r, which really should be there */
                }
                var element_: String = rawText.substring(matchStart, i - matchStart).toString();
                if (trim) {
                    element_ = element_.trimAscii()
                }
                if (quotedPrintable) {
                    element_ = decodeQuotedPrintable(UTF32String(element_), quotedPrintableCharset)

                    if (parseFieldDivider == true) {
                        element_ = UNESCAPED_SEMICOLONS.matcher(element_).replaceAll("\n").trimAscii()
                    }
                } else {
                    if (parseFieldDivider) {
                        element_ = UNESCAPED_SEMICOLONS.matcher(element_).replaceAll("\n").trimAscii()
                    }
                    element_ = CR_LF_SPACE_TAB.matcher(element_).replaceAll("")
                    element_ = NEWLINE_ESCAPE.matcher(element_).replaceAll("\n")
                    while (true) {
                        if (let Some(r) <- VCARD_ESCAPES.matcher(element_).find()) {
                            element_ = VCARD_ESCAPES.matcher(element_).replace(r.matchStr(1))
                        } else {
                            break
                        }
                    }
                }

                /* Only handle VALUE=uri specially */
                if ("uri" == (valueType)) {
                    // Don't actually support dereferencing URIs, but use scheme-specific part not URI
                    // as value, to support tel: and mailto:
                    try {
                        element_ = URL.parse(element_).opaque
                    } catch (iae: IllegalArgumentException) {
                        /* ignore */
                    }
                }
                if (metadata.isEmpty()) {
                    var matchData: ArrayList<String> = ArrayList<String>(1);
                    matchData.append(element_);
                    matches.append(matchData);
                } else {
                    metadata.insert(0, element_);
                    matches.append(metadata);
                }
                i++
            } else {
                i++
            }
        }
        return matches
    }

    private static func decodeQuotedPrintable(value: UTF32String, charset: String): String {
        var length: Int64 = value.charSize;
        var result: ArrayList<Rune> = ArrayList<Rune>();
        var fragmentBuffer: ByteArrayStream = ByteArrayStream();
        var i = 0
        while (i < length) {
            var c: Rune = value.get(i);
            if (c == r'\r' || c == r'\n') {}
            else if (c == r'=') {
                if (i < length - 2) {
                    var nextChar = value.get(i + 1);
                    if (nextChar != r'\r' && nextChar != r'\n') {
                        var nextNextChar = value.get(i + 2);

                        var firstDigit = parseHexDigit(nextChar);
                        var secondDigit = parseHexDigit(nextNextChar);

                        if (firstDigit >= 0 && secondDigit >= 0) {
                            fragmentBuffer.write(UInt8(firstDigit << 4) + UInt8(secondDigit));
                        }

                        i += 2
                    }
                }
            } else {
                maybeAppendFragment(fragmentBuffer, charset, result);
                result.append(c);
            }
            i++
        }
        maybeAppendFragment(fragmentBuffer, charset, result);
        return String(result);
    }
    private static func maybeAppendFragment(
        fragmentBuffer: ByteArrayStream,
        charset: String,
        result: ArrayList<Rune>
    ) {
        if (fragmentBuffer.length > 0) {
            var fragmentBytes: Array<Byte> = fragmentBuffer.bytes()
            var fragment: String = String()
            if (charset.isEmpty()) {
                fragment = StandardCharsets.UTF_8.newDecoder().decode(fragmentBytes)
            } else {
                try {
                    fragment = MyCharset.forName(charset).newDecoder().decode(fragmentBytes)
                } catch (e: Error) {
                    fragment = StandardCharsets.UTF_8.newDecoder().decode(fragmentBytes)
                }
            }
            fragmentBuffer.clear()
            result.appendAll(fragment.toRuneArray())
        }
    }

    static func matchSingleVCardPrefixedField(
        prefix: String,
        rawText: UTF32String,
        trim: Bool,
        parseFieldDivider: Bool
    ): ArrayList<String> {
        var values: ArrayList<ArrayList<String>> = matchVCardPrefixedField(prefix, rawText, trim, parseFieldDivider);
        if (values.size == 0 || values.isEmpty()) {
            return ArrayList<String>();
        } else {
            return values[0]
        }
    }

    private static func toPrimaryValue(list: ArrayList<String>): String {
        if (list.size == 0 || list.isEmpty()) {
            return String()
        } else {
            return list[0]
        }
    }

    private static func toPrimaryValues(lists: Collection<ArrayList<String>>): Array<String> {
        if (lists.size == 0 || lists.isEmpty()) {
            return Array<String>()
        }
        var result: ArrayList<String> = ArrayList<String>(lists.size);
        for (list in lists) {
            var value: String = list[0]
            if (!value.isEmpty()) {
                result.append(value);
            }
        }
        return result.toArray();
    }

    private static func toTypes(lists: Collection<ArrayList<String>>): Array<String> {
        if (lists.isEmpty() || lists.size == 0) {
            return Array<String>();
        }
        var result: ArrayList<String> = ArrayList<String>(lists.size);

        for (list in lists) {
            var value: String = list[0]
            if (!value.isEmpty() && value != String()) {
                var typeData: UTF32String = UTF32String("");
                for (i in 1..list.size) {
                    var metadatum: UTF32String = UTF32String(list[i])
                    var equals = metadatum.indexOf(r'='.toString())
                    if (equals == None) {
                        // take the whole thing as a usable label
                        typeData = metadatum
                        break
                    }
                    if (UTF32String("TYPE") == (metadatum.substring(0, equals.getOrThrow()))) {
                        typeData = metadatum.substring(equals.getOrThrow() + 1)
                        break
                    }
                    result.append(typeData.toString());
                }
            }
        }
        return result.toArray();
    }

    private static func isLikeVCardDate(value: String): Bool {
        let y = VCARD_LIKE_DATE.matcher(value).fullMatch()
        match (value) {
            case y => return true;
        }
        return value == ""
    }

    /**
     * Formats name fields of the form "Public;John;Q.;Reverend;III" into a form like
     * "Reverend John Q. Public III".
     *
     * @param names name values to format, in place
     */
    private static func formatNames(names: ArrayList<ArrayList<String>>) {
        if (names.size != 0) {
            for (list in names) {
                var name: UTF32String = UTF32String(list.get(0).getOrThrow())
                var start: Int64 = 0;
                var components: Array<UTF32String> = Array<UTF32String>(5, repeat: UTF32String())
                var end: Int64
                var componentIndex: Int64 = 0;
                if (let Some(v) <- name.indexOf(r';'.toString(), start: start)) {
                    while (componentIndex < components.size - 1 && (name.indexOf(r';'.toString(), start: start)) != None) {
                        end = name.indexOf(r';'.toString(), start: start).getOrThrow()
                        components[componentIndex] = name.substring(start, end - start)
                        componentIndex++
                        start = end + 1
                    }
                }

                components[componentIndex] = name.substring(start)
                var newName: ArrayList<Rune> = ArrayList<Rune>();
                maybeAppendComponent(components, 3, newName);
                maybeAppendComponent(components, 1, newName);
                maybeAppendComponent(components, 2, newName);
                maybeAppendComponent(components, 0, newName);
                maybeAppendComponent(components, 4, newName);
                list.set(0, String(newName).trimAscii());
            }
        }
    }

    private static func maybeAppendComponent(components: Array<UTF32String>, i: Int64, newName: ArrayList<Rune>) {
        if (components[i].size != 0 && !components[i].isEmpty()) {
            if (newName.size > 0) {
                newName.append(r' ');
            }
            newName.appendAll(components[i].toRuneArray());
        }
    }
}
