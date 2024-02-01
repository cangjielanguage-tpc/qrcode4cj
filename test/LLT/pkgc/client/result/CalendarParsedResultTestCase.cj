/*
 * Copyright 2007 ZXing authors
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

// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import math.*
from std import time.*
from std import unittest.*
from std import unittest.testmacro.*
from QRCode4cj import zxing.code.common.BarcodeFormat
from QRCode4cj import zxing.code.common.Result
from QRCode4cj import zxing.code.common.ResultPoint
from QRCode4cj import zxing.code.client.result.*

main(): Int64 {
    let tester = CalendarParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link CalendarParsedResult}.
 *
 * @author Sean Owen
 */
@Test
public open class CalendarParsedResultTestCase {
    private static let EPSILON: Float64 = 1.0E-10;

    @TestCase
    public func testStartEnd(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" + "DTEND:20080505T234555Z\r\n" +
                "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            String(),
            String(),
            "20080504T123456Z",
            "20080505T234555Z"
        );
    }

    @TestCase
    public func testNoVCalendar(): Unit {
        doTest(
            "BEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" + "DTEND:20080505T234555Z\r\n" + "END:VEVENT",
            String(),
            String(),
            String(),
            "20080504T123456Z",
            "20080505T234555Z"
        );
    }

    @TestCase
    public func testStart(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" + "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            String(),
            String(),
            "20080504T123456Z",
            String()
        );
    }

    @TestCase
    public func testDuration(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" + "DURATION:P1D\r\n" +
                "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            String(),
            String(),
            "20080504T123456Z",
            "20080505T123456Z"
        );
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" + "DURATION:P1DT2H3M4S\r\n" +
                "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            String(),
            String(),
            "20080504T123456Z",
            "20080505T143800Z"
        );
    }

    @TestCase
    public func testSummary(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "SUMMARY:foo\r\n" + "DTSTART:20080504T123456Z\r\n" +
                "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            "foo",
            String(),
            "20080504T123456Z",
            String()
        );
    }

    @TestCase
    public func testLocation(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "LOCATION:Miami\r\n" + "DTSTART:20080504T123456Z\r\n" +
                "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            String(),
            "Miami",
            "20080504T123456Z",
            String()
        );
    }

    @TestCase
    public func testDescription(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" + "DESCRIPTION:This is a test\r\n" +
                "END:VEVENT\r\nEND:VCALENDAR",
            "This is a test",
            String(),
            String(),
            "20080504T123456Z",
            String()
        );
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" +
                "DESCRIPTION:This is a test\r\n\t with a continuation\r\n" + "END:VEVENT\r\nEND:VCALENDAR",
            "This is a test with a continuation",
            String(),
            String(),
            "20080504T123456Z",
            String()
        );
    }

    @TestCase
    public func testGeo(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" + "GEO:-12.345;-45.678\r\n" +
                "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            String(),
            String(),
            "20080504T123456Z",
            String(),
            String(),
            Array<String>(),
            -12.345,
            -45.678
        );
    }

    @TestCase
    public func testBadGeo(): Unit {
        // Not parsed as VEVENT
        var fakeResult: Result = Result(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "GEO:-12.345\r\n" + "END:VEVENT\r\nEND:VCALENDAR",
            [],
            [],
            BarcodeFormat.QR_CODE
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.TEXT.toString(), result.getType().toString())
    }

    @TestCase
    public func testOrganizer(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" +
                "ORGANIZER:mailto:bob@example.org\r\n" + "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            String(),
            String(),
            "20080504T123456Z",
            String(),
            "bob@example.org",
            Array<String>(),
            Float64.NaN,
            Float64.NaN
        );
    }

    @TestCase
    public func testAttendees(): Unit {
        doTest(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\n" + "DTSTART:20080504T123456Z\r\n" +
                "ATTENDEE:mailto:bob@example.org\r\n" + "ATTENDEE:mailto:alice@example.org\r\n" +
                "END:VEVENT\r\nEND:VCALENDAR",
            String(),
            String(),
            String(),
            "20080504T123456Z",
            String(),
            String(),
            Array<String>(["bob@example.org", "alice@example.org"]),
            Float64.NaN,
            Float64.NaN
        );
    }

    @TestCase
    public func testVEventEscapes(): Unit {
        doTest(
            "BEGIN:VEVENT\n" + "CREATED:20111109T110351Z\n" + "LAST-MODIFIED:20111109T170034Z\n" +
                "DTSTAMP:20111109T170034Z\n" + "UID:0f6d14ef-6cb7-4484-9080-61447ccdf9c2\n" + "SUMMARY:Summary line\n" +
                "CATEGORIES:Private\n" + "DTSTART;TZID=Europe/Vienna:20111110T110000\n" +
                "DTEND;TZID=Europe/Vienna:20111110T120000\n" + "LOCATION:Location\\, with\\, escaped\\, commas\n" +
                "DESCRIPTION:Meeting with a friend\\nlook at homepage first\\n\\n\n" + "  \\n\n" + "SEQUENCE:1\n" +
                "X-MOZ-GENERATION:1\n" + "END:VEVENT",
            "Meeting with a friend\nlook at homepage first\n\n\n  \n",
            "Summary line",
            "Location, with, escaped, commas",
            "20111110T110000Z",
            "20111110T120000Z"
        );
    }

    @TestCase
    public func testAllDayValueDate(): Unit {
        doTest(
            "BEGIN:VEVENT\n" + "DTSTART;VALUE=DATE:20111110\n" + "DTEND;VALUE=DATE:20111110\n" + "END:VEVENT",
            String(),
            String(),
            String(),
            "20111110T000000Z",
            "20111110T000000Z"
        );
    }

    private func doTest(
        contents: String,
        description: String,
        summary: String,
        location: String,
        startString: String,
        endString: String
    ) {
        doTest(contents, description, summary, location, startString, endString, String(), [], Float64.NaN, Float64.NaN);
    }

    private func doTest(
        contents: String,
        description: String,
        summary: String,
        location: String,
        startString: String,
        endString: String,
        organizer: String,
        attendees: Array<String>,
        latitude: Float64,
        longitude: Float64
    ) {
        var fakeResult: Result = Result(contents, Array<UInt8>(), Array<ResultPoint>(), BarcodeFormat.QR_CODE);
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.CALENDAR.toString(), result.getType().toString())

        if (result is CalendarParsedResult) {
            var calResult: CalendarParsedResult = (result as CalendarParsedResult).getOrThrow()
            @Assert(description, calResult.getDescription())
            @Assert(summary, calResult.getSummary())
            @Assert(location, calResult.getLocation())

            @Assert(startString, DateTime.ofEpoch(second:calResult.getStartTimestamp() / 1000, nanosecond:0).inUTC().toString("yyyyMMddTHHmmss") + "Z")
            var endStringTest: String = String()
            if (calResult.getEndTimestamp() >= 0) {
                endStringTest = DateTime.ofEpoch(second: calResult.getEndTimestamp() / 1000, nanosecond: 0).inUTC().
                    toString("yyyyMMddTHHmmss") + "Z"
            }

            @Assert(endString, endStringTest)
            @Assert(organizer, calResult.getOrganizer())
            @Assert(attendees, calResult.getAttendees())
            if (latitude.isNaN()) {
                @Assert(calResult.getLatitude().isNaN())
            } else {
                @Assert(latitude,calResult.getLatitude())
            }

            if (longitude.isNaN()) {
                @Assert(calResult.getLongitude().isNaN())
            } else {
                @Assert(longitude,calResult.getLongitude())
            }
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }

    private static func assertEqualOrNaN(Asserted: Float64, actual: Float64) {
        if (Asserted.isNaN()) {
            @Assert(actual.isNaN(),true)
        } else {
            if (abs(Asserted - actual) < EPSILON) {
                @Assert(true)
            } else {
                @Assert(false)
            }
        }
    }
}
