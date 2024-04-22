/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package client.result

import common.Qrcoder4cjFormatException
from std import convert.*

public open class VEventResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        var vEventStart: Int64 = 0
        if (rawText.indexOf("BEGIN:VEVENT") != None) {
            vEventStart = rawText.indexOf("BEGIN:VEVENT").getOrThrow()
        }
        if (vEventStart < 0) {
            return None
        }

        var summary: String = matchSingleVCardPrefixedField("SUMMARY", rawText);
        var start: String = matchSingleVCardPrefixedField("DTSTART", rawText);
        if (start == "") {
            return None
        }
        var (end, duration, location, organizer) = getmatchSingleVCardPrefixedField(rawText)

        var attendees: Array<String> = matchVCardPrefixedField("ATTENDEE", rawText);
        if (attendees.size != 0) {
            for (i in 0..attendees.size) {
                attendees[i] = stripMailto(attendees[i])
            }
        }
        var description: String = matchSingleVCardPrefixedField("DESCRIPTION", rawText);

        var geoString: UTF32String = UTF32String(matchSingleVCardPrefixedField("GEO", rawText));
        var latitude: Float64
        var longitude: Float64
        if (geoString == "") {
            latitude = Float64.NaN
            longitude = Float64.NaN
        } else {
            var semicolon: Int64
            if (geoString.indexOf(';'.toString()) == None) {
                return None
            } else {
                semicolon = geoString.indexOf(';'.toString()).getOrThrow()
            }
            try {
                latitude = Float64.parse(geoString.substring(0, semicolon).toString())
                longitude = Float64.parse(geoString.substring(semicolon + 1).toString())
            } catch (ignored: Qrcoder4cjFormatException) {
                return None
            }
        }

        try {
            return CalendarParsedResult(summary, start, end, duration, location, organizer, attendees, description,
                latitude, longitude);
        } catch (ignored: IllegalArgumentException) {
            return None
        }
    }

    private func getmatchSingleVCardPrefixedField(rawText: UTF32String): (String, String, String, String) {
        return (matchSingleVCardPrefixedField("DTEND", rawText), matchSingleVCardPrefixedField("DURATION", rawText),
            matchSingleVCardPrefixedField("LOCATION", rawText), stripMailto(
                matchSingleVCardPrefixedField("ORGANIZER", rawText)))
    }

    private static func matchSingleVCardPrefixedField(prefix: String, rawText: UTF32String): String {
        let values: ArrayList<String> = VCardResultParser.matchSingleVCardPrefixedField(prefix, rawText, true, false);
        if (values.isEmpty()) {
            return ""
        } else {
            return values[0].toString()
        }
    }

    private static func matchVCardPrefixedField(prefix: String, rawText: UTF32String): Array<String> {
        var values: ArrayList<ArrayList<String>> = VCardResultParser.matchVCardPrefixedField(
            prefix,
            rawText,
            true,
            false
        );
        if (values.isEmpty()) {
            return Array<String>();
        }
        var size: Int64 = values.size;
        var result: Array<String> = Array<String>(size, item: "")

        for (i in 0..size) {
            var a = values[i]
            result[i] = a[0]
        }
        return result
    }

    private static func stripMailto(s: String): String {
        if (!s.isEmpty() && (s.startsWith("mailto:") || s.startsWith("MAILTO:"))) {
            return s[Range<Int64>(7, s.size, 1, true, true, false)]
        }
        return s
    }
}
