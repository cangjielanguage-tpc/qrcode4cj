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

from std import math.*
from std import ast.*
from std import time.*

/**
 * Represents a parsed result that encodes a calendar event at a certain time, optionally
 * with attendees and a location.
 *
 * @author Sean Owen
 */
public open class CalendarParsedResult <: ParsedResult {
    private static let RFC2445_DURATION: Regex = Regex(
        "P(?:(\\d+)W)?(?:(\\d+)D)?(?:T(?:(\\d+)H)?(?:(\\d+)M)?(?:(\\d+)S)?)?");
    private static let RFC2445_DURATION_FIELD_UNITS: Array<Int64> = [
        7 * 24 * 60 * 60 * 1000, // 1 week
        24 * 60 * 60 * 1000, // 1 day
        60 * 60 * 1000, // 1 hour
        60 * 1000, // 1 minute
        1000 // 1 second
    ]

    private static let DATE_TIME: Regex = Regex("[0-9]{8}(T[0-9]{6}Z?)?");

    private var summary: String = String()
    private var start: Int64 = 0
    private var startAllDay: Bool = false
    private var end: Int64 = 0
    private var endAllDay: Bool = false
    private var location: String = String()
    private var organizer: String = String()
    private var attendees: Array<String> = Array<String>()
    private var description: String = String()
    private var latitude: Float64 = Float64.NaN
    private var longitude: Float64 = Float64.NaN
    private var flag: Bool = false
    public init() {
        super(ParsedResultType.CALENDAR)
    }
    public init(
        summary: String,
        startString: String,
        endString: String,
        durationString: String,
        location: String,
        organizer: String,
        attendees: Array<String>,
        description: String,
        latitude: Float64,
        longitude: Float64
    ) {
        super(ParsedResultType.CALENDAR);
        this.summary = summary

        try {
            this.start = parseDate(startString)
        } catch (pe: TimeParseException) {
            throw IllegalArgumentException(pe.toString());
        }
        if (endString == "") {
            var durationMS: Int64 = parseDurationMS(durationString);

            if (durationMS < 0) {
                end = -1
            } else {
                end = start + durationMS
            }
        } else {
            try {
                this.end = parseDate(endString)
            } catch (pe: TimeParseException) {
                throw IllegalArgumentException(pe.toString());
            }
        }

        this.startAllDay = startString.toRuneArray().size == 8
        this.endAllDay = endString != "" && endString.toRuneArray().size == 8

        this.location = location
        this.organizer = organizer
        this.attendees = attendees
        this.description = description
        this.latitude = latitude
        this.longitude = longitude
        this.flag = true
    }

    public func getSummary(): String {
        return summary
    }

    /**
     * @return start time
     * @deprecated use {@link #getStartTimestamp()}
     */
    // @Deprecated
    public func getStart(start: Int64): DateTime {
        var time = DateTime.of(year: 1970, month: 1, dayOfMonth: 1)
        time.addSeconds(start * 1000)
        return time
    }

    /**
     * @return start time
     * @see #getEndTimestamp()
     */
    public func getStartTimestamp(): Int64 {
        return start
    }

    /**
     * @return true if start time was specified as a whole day
     */
    public func isStartAllDay(): Bool {
        return startAllDay
    }

    /**
     * @return event end {@link Time}, or {@code null} if event has no duration
     * @deprecated use {@link #getEndTimestamp()}
     */
    // @Deprecated
    public func getEnd(): DateTime {
        if (end < 0) {
            return getEnd()
        } else {
            var time = DateTime.of(year: 1970, month: 1, dayOfMonth: 1)
            time.addSeconds(start * 1000)

            // return Time(start*1000, 0)
            return time
        }
    }

    /**
     * @return event end {@link Time}, or -1 if event has no duration
     * @see #getStartTimestamp()
     */
    public func getEndTimestamp(): Int64 {
        return end
    }

    /**
     * @return true if end time was specified as a whole day
     */
    public func isEndAllDay(): Bool {
        return endAllDay
    }

    public func getLocation(): String {
        return location
    }

    public func getOrganizer(): String {
        return organizer
    }

    public func getAttendees(): Array<String> {
        return attendees
    }

    public func getDescription(): String {
        return description
    }

    public func getLatitude(): Float64 {
        return latitude
    }

    public func getLongitude(): Float64 {
        return longitude
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        maybeAppend(summary, result);
        maybeAppend(format(startAllDay, start), result);
        maybeAppend(format(endAllDay, end), result);
        maybeAppend(location, result);
        maybeAppend(organizer, result);
        maybeAppend(attendees, result);
        maybeAppend(description, result);
        return String(result);
    }

    /**
     * Parses a string as a date. RFC 2445 allows the start and end fields to be of type DATE (e.g. 20081021)
     * or DATE-TIME (e.g. 20081021T123000 for local time, or 20081021T123000Z for UTC).
     *
     * @param when The string to parse
     * @throws ParseException if not able to parse as a date
     */
    private static func parseDate(when: String): Int64 {
        let y = DATE_TIME.matcher(when).fullMatch()
        if (let None <- y) {
            throw TimeParseException("Error parsing input at position 0: " + when);
        }

        var charArray = when.toRuneArray()

        if (charArray.size == 8) {
            // Show only year/month/day
            var format = DateTime.parse(when, "yyyyMMdd");
            var test = DateTime.of(year: 1970, month: 1, dayOfMonth: 1)

            // For dates without a time, for purposes of interacting with Android, the resulting timestamp
            // needs to be midnight of that day in GMT. See:
            // http://code.google.com/p/android/issues/detail?id=8330
            return (format - test).toMilliseconds()
        }

        // The when string can be local time, or UTC if it ends with a Z
        if (charArray.size == 16 && charArray[15] == 'Z') {
            var milliseconds: Int64 = parseDateTimeString(String(charArray[Range<Int64>(0, 15, 1, true, true, false)]));

            return milliseconds
        }
        return parseDateTimeString(when);
    }

    private static func format(allDay: Bool, date: Int64): String {
        if (date < 0) {
            return ""
        }

        var format = DateTime.of(year: 1970, month: 1, dayOfMonth: 1)

        format = format.addSeconds(date / 1000)

        var datareturn: String
        if (allDay) {
            datareturn = format.toString("yyyy-MM-dd")
        } else {
            datareturn = format.toString("yyyy-MM-dd HH:mm:ss")
        }

        return datareturn
    }

    private static func parseDurationMS(durationString: String): Int64 {
        if (durationString.isEmpty()) {
            return -1
        }
        var m: Matcher = RFC2445_DURATION.matcher(durationString);
        var result = m.find()
        if (let None <- result) {
            return -1
        }
        var durationMS: Int64 = 0

        for (i in 0..RFC2445_DURATION_FIELD_UNITS.size) {
            if (result.getOrThrow().groupNumber() >= i + 1 && result.getOrThrow().matchStr(i + 1) != "") {
                durationMS += RFC2445_DURATION_FIELD_UNITS[i] * Int64.parse(result.getOrThrow().matchStr(i + 1))
            }
        }
        return durationMS
    }

    private static func parseDateTimeString(dateTimeString: String): Int64 {
        var format: DateTime = DateTime.parse(dateTimeString, "yyyyMMddTHHmmss")
        var test = DateTime.of(year: 1970, month: 1, dayOfMonth: 1)
        return (format - test).toMilliseconds()
    }
}
