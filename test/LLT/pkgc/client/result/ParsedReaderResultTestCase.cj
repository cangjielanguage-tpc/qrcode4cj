/* com.google.
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
from std import unicode.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from QRCode4cj import common.BarcodeFormat
from QRCode4cj import common.Result
from QRCode4cj import common.ResultPoint
from QRCode4cj import client.result.*

main(): Int64 {
    let tester = ParsedReaderResultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link ParsedResult}.
 *
 * @author Sean Owen
 * @author dswitkin@google.com (Daniel Switkin)
 */
@Test
public class ParsedReaderResultTestCase {
    @TestCase
    public func testTextType(): Unit {
        doTestResult("", "", ParsedResultType.TEXT);
        doTestResult("foo", "foo", ParsedResultType.TEXT);
        doTestResult("Hi.", "Hi.", ParsedResultType.TEXT);
        doTestResult("This is a test", "This is a test", ParsedResultType.TEXT);
        doTestResult(
            "This is a test\nwith newlines",
            "This is a test\nwith newlines",
            ParsedResultType.TEXT
        );
        doTestResult(
            "This: a test with lots of @ nearly-random punctuation! No? OK then.",
            "This: a test with lots of @ nearly-random punctuation! No? OK then.",
            ParsedResultType.TEXT
        );
    }

    @TestCase
    public func testBookmarkType(): Unit {
        doTestResult("MEBKM:URL:google.com;;", "http://google.com", ParsedResultType.URI);
        doTestResult(
            "MEBKM:URL:google.com;TITLE:Google;;",
            "Google\nhttp://google.com",
            ParsedResultType.URI
        );
        doTestResult(
            "MEBKM:TITLE:Google;URL:google.com;;",
            "Google\nhttp://google.com",
            ParsedResultType.URI
        );
        doTestResult("MEBKM:URL:http://google.com;;", "http://google.com", ParsedResultType.URI);
        doTestResult("MEBKM:URL:HTTPS://google.com;;", "HTTPS://google.com", ParsedResultType.URI);
    }

    @TestCase
    public func testURLTOType(): Unit {
        doTestResult("urlto:foo:bar.com", "foo\nhttp://bar.com", ParsedResultType.URI);
        doTestResult("URLTO:foo:bar.com", "foo\nhttp://bar.com", ParsedResultType.URI);
        doTestResult("URLTO::bar.com", "http://bar.com", ParsedResultType.URI);
        doTestResult("URLTO::http://bar.com", "http://bar.com", ParsedResultType.URI);
    }

    @TestCase
    public func testEmailType(): Unit {
        doTestResult(
            "MATMSG:TO:srowen@example.org;;",
            "srowen@example.org",
            ParsedResultType.EMAIL_ADDRESS
        );
        doTestResult(
            "MATMSG:TO:srowen@example.org;SUB:Stuff;;",
            "srowen@example.org\nStuff",
            ParsedResultType.EMAIL_ADDRESS
        );
        doTestResult(
            "MATMSG:TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;",
            "srowen@example.org\nStuff\nThis is some text",
            ParsedResultType.EMAIL_ADDRESS
        );
        doTestResult(
            "MATMSG:SUB:Stuff;BODY:This is some text;TO:srowen@example.org;;",
            "srowen@example.org\nStuff\nThis is some text",
            ParsedResultType.EMAIL_ADDRESS
        );
        doTestResult(
            "TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;",
            "TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;",
            ParsedResultType.TEXT
        );
    }

    @TestCase
    public func testEmailAddressType(): Unit {
        doTestResult("srowen@example.org", "srowen@example.org", ParsedResultType.EMAIL_ADDRESS);
        doTestResult("mailto:srowen@example.org", "srowen@example.org", ParsedResultType.EMAIL_ADDRESS);
        doTestResult("MAILTO:srowen@example.org", "srowen@example.org", ParsedResultType.EMAIL_ADDRESS);
        doTestResult("srowen@example", "srowen@example", ParsedResultType.EMAIL_ADDRESS);
        doTestResult("srowen", "srowen", ParsedResultType.TEXT);
        doTestResult("Let's meet @ 2", "Let's meet @ 2", ParsedResultType.TEXT);
    }

    @TestCase
    public func testAddressBookType(): Unit {
        doTestResult("MECARD:N:Sean Owen;;", "Sean Owen", ParsedResultType.ADDRESSBOOK);
        doTestResult(
            "MECARD:TEL:+12125551212;N:Sean Owen;;",
            "Sean Owen\n+12125551212",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "MECARD:TEL:+12125551212;N:Sean Owen;URL:google.com;;",
            "Sean Owen\n+12125551212\ngoogle.com",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "MECARD:TEL:+12125551212;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;",
            "Sean Owen\n+12125551212\nsrowen@example.org\ngoogle.com",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "MECARD:ADR:76 9th Ave;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;",
            "Sean Owen\n76 9th Ave\nsrowen@example.org\ngoogle.com",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "MECARD:BDAY:19760520;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;",
            "Sean Owen\nsrowen@example.org\ngoogle.com\n19760520",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "MECARD:ORG:Google;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;",
            "Sean Owen\nGoogle\nsrowen@example.org\ngoogle.com",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "MECARD:NOTE:ZXing Team;N:Sean Owen;URL:google.com;EMAIL:srowen@example.org;",
            "Sean Owen\nsrowen@example.org\ngoogle.com\nZXing Team",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "N:Sean Owen;TEL:+12125551212;;",
            "N:Sean Owen;TEL:+12125551212;;",
            ParsedResultType.TEXT
        );
    }

    @TestCase
    public func testAddressBookAUType(): Unit {
        doTestResult("MEMORY:\r\n", "", ParsedResultType.ADDRESSBOOK);
        doTestResult("MEMORY:foo\r\nNAME1:Sean\r\n", "Sean\nfoo", ParsedResultType.ADDRESSBOOK);
        doTestResult("TEL1:+12125551212\r\nMEMORY:\r\n", "+12125551212", ParsedResultType.ADDRESSBOOK);
    }

    @TestCase
    public func testBizcard(): Unit {
        doTestResult(
            "BIZCARD:N:Sean;X:Owen;C:Google;A:123  St;M:+12225551212;E:srowen@example.org;",
            "Sean Owen\nGoogle\n123  St\n+12225551212\nsrowen@example.org",
            ParsedResultType.ADDRESSBOOK
        );
    }

    @TestCase
    public func testUPCA(): Unit {
        doTestResult("123456789012", "123456789012", ParsedResultType.PRODUCT, BarcodeFormat.UPC_A);
        doTestResult("1234567890123", "1234567890123", ParsedResultType.PRODUCT, BarcodeFormat.UPC_A);
        doTestResult("12345678901", "12345678901", ParsedResultType.TEXT);
    }

    @TestCase
    public func testUPCE(): Unit {
        doTestResult("01234565", "01234565", ParsedResultType.PRODUCT, BarcodeFormat.UPC_E);
    }

    @TestCase
    public func testEAN(): Unit {
        doTestResult("00393157", "00393157", ParsedResultType.PRODUCT, BarcodeFormat.EAN_8);
        doTestResult("00393158", "00393158", ParsedResultType.TEXT);
        doTestResult("5051140178499", "5051140178499", ParsedResultType.PRODUCT, BarcodeFormat.EAN_13);
        doTestResult("5051140178490", "5051140178490", ParsedResultType.TEXT);
    }

    @TestCase
    public func testISBN(): Unit {
        doTestResult("9784567890123", "9784567890123", ParsedResultType.ISBN, BarcodeFormat.EAN_13);
        doTestResult("9794567890123", "9794567890123", ParsedResultType.ISBN, BarcodeFormat.EAN_13);
        doTestResult("97845678901", "97845678901", ParsedResultType.TEXT);
        doTestResult("97945678901", "97945678901", ParsedResultType.TEXT);
    }

    @TestCase
    public func testURI(): Unit {
        doTestResult("http://google.com", "http://google.com", ParsedResultType.URI);
        doTestResult("google.com", "http://google.com", ParsedResultType.URI);
        doTestResult("https://google.com", "https://google.com", ParsedResultType.URI);
        doTestResult("HTTP://google.com", "HTTP://google.com", ParsedResultType.URI);
        doTestResult("http://google.com/foobar", "http://google.com/foobar", ParsedResultType.URI);
        doTestResult("https://google.com:443/foobar", "https://google.com:443/foobar", ParsedResultType.URI);
        doTestResult("google.com:443", "http://google.com:443", ParsedResultType.URI);
        doTestResult("google.com:443/", "http://google.com:443/", ParsedResultType.URI);
        doTestResult("google.com:443/foobar", "http://google.com:443/foobar", ParsedResultType.URI);
        doTestResult("http://google.com:443/foobar", "http://google.com:443/foobar", ParsedResultType.URI);
        doTestResult("https://google.com:443/foobar", "https://google.com:443/foobar", ParsedResultType.URI);
        doTestResult("ftp://google.com/fake", "ftp://google.com/fake", ParsedResultType.URI);
        doTestResult("gopher://google.com/obsolete", "gopher://google.com/obsolete", ParsedResultType.URI);
    }

    @TestCase
    public func testGeo(): Unit {
        doTestResult("geo:1,2", "1.000000, 2.000000", ParsedResultType.GEO);
        doTestResult("GEO:1,2", "1.000000, 2.000000", ParsedResultType.GEO);
        doTestResult("geo:1,2,3", "1.000000, 2.000000, 3.000000m", ParsedResultType.GEO);
        doTestResult("geo:80.33,-32.3344,3.35", "80.330000, -32.334400, 3.350000m", ParsedResultType.GEO);
        doTestResult("geo", "geo", ParsedResultType.TEXT);
        doTestResult("geography", "geography", ParsedResultType.TEXT);
    }

    @TestCase
    public func testTel(): Unit {
        doTestResult("tel:+15551212", "+15551212", ParsedResultType.TEL);
        doTestResult("TEL:+15551212", "+15551212", ParsedResultType.TEL);
        doTestResult("tel:212 555 1212", "212 555 1212", ParsedResultType.TEL);
        doTestResult("tel:2125551212", "2125551212", ParsedResultType.TEL);
        doTestResult("tel:212-555-1212", "212-555-1212", ParsedResultType.TEL);
        doTestResult("tel", "tel", ParsedResultType.TEXT);
        doTestResult("telephone", "telephone", ParsedResultType.TEXT);
    }

    @TestCase
    public func testVCard(): Unit {
        doTestResult("BEGIN:VCARD\r\nEND:VCARD", "", ParsedResultType.ADDRESSBOOK);
        doTestResult(
            "BEGIN:VCARD\r\nN:Owen;Sean\r\nEND:VCARD",
            "Sean Owen",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "BEGIN:VCARD\r\nVERSION:2.1\r\nN:Owen;Sean\r\nEND:VCARD",
            "Sean Owen",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult(
            "BEGIN:VCARD\r\nADR;HOME:123  St\r\nVERSION:2.1\r\nN:Owen;Sean\r\nEND:VCARD",
            "Sean Owen\n123  St",
            ParsedResultType.ADDRESSBOOK
        );
        doTestResult("BEGIN:VCARD", "", ParsedResultType.ADDRESSBOOK);
    }

    @TestCase
    public func testVEvent(): Unit {
        // UTC times
        doTestResult(
            "BEGIN:VCALENDAR\r\nBEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456Z\r\n" +
                "DTEND:20080505T234555Z\r\nEND:VEVENT\r\nEND:VCALENDAR",
            "foo\n" + formatTime(2008, 5, 4, 12, 34, 56) + "\n" + formatTime(2008, 5, 5, 23, 45, 55),
            ParsedResultType.CALENDAR
        );
        doTestResult(
            "BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456Z\r\n" + "DTEND:20080505T234555Z\r\nEND:VEVENT",
            "foo\n" + formatTime(2008, 5, 4, 12, 34, 56) + "\n" + formatTime(2008, 5, 5, 23, 45, 55),
            ParsedResultType.CALENDAR
        );

        // Local times
        doTestResult(
            "BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456\r\n" + "DTEND:20080505T234555\r\nEND:VEVENT",
            "foo\n" + formatTime(2008, 5, 4, 12, 34, 56) + "\n" + formatTime(2008, 5, 5, 23, 45, 55),
            ParsedResultType.CALENDAR
        );

        // Date only (all day event)
        doTestResult(
            "BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504\r\n" + "DTEND:20080505\r\nEND:VEVENT",
            "foo\n" + formatDate(2008, 5, 4) + "\n" + formatDate(2008, 5, 5),
            ParsedResultType.CALENDAR
        );

        // Start time only
        doTestResult(
            "BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456Z\r\nEND:VEVENT",
            "foo\n" + formatTime(2008, 5, 4, 12, 34, 56),
            ParsedResultType.CALENDAR
        );
        doTestResult(
            "BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504T123456\r\nEND:VEVENT",
            "foo\n" + formatTime(2008, 5, 4, 12, 34, 56),
            ParsedResultType.CALENDAR
        );
        doTestResult(
            "BEGIN:VEVENT\r\nSUMMARY:foo\r\nDTSTART:20080504\r\nEND:VEVENT",
            "foo\n" + formatDate(2008, 5, 4),
            ParsedResultType.CALENDAR
        );
        doTestResult(
            "BEGIN:VEVENT\r\nDTEND:20080505T\r\nEND:VEVENT",
            "BEGIN:VEVENT\r\nDTEND:20080505T\r\nEND:VEVENT",
            ParsedResultType.TEXT
        );

        // Yeah, it's OK that this is thought of as maybe a URI as long as it's not CALENDAR
        // Make sure illegal entries without newlines don't crash
        doTestResult(
            "BEGIN:VEVENTSUMMARY:EventDTSTART:20081030T122030ZDTEND:20081030T132030ZEND:VEVENT",
            "BEGIN:VEVENTSUMMARY:EventDTSTART:20081030T122030ZDTEND:20081030T132030ZEND:VEVENT",
            ParsedResultType.URI
        );
    }

    private static func formatDate(year: Int64, month: Int64, day: Int64): String {
        var cal: DateTime = DateTime.of(year: year, month: Month.of(month), dayOfMonth: day);
        return cal.toString("yyyy-MM-dd")
    }

    private static func formatTime(year: Int64, month: Int64, day: Int64, hour: Int64, min: Int64, sec: Int64): String {
        var cal: DateTime = DateTime.of(
            year: year,
            month: Month.of(month),
            dayOfMonth: day,
            hour: hour,
            minute: min,
            second: sec
        );
        return cal.toString("yyyy-MM-dd HH:mm:ss")
    }

    @TestCase
    public func testSMS(): Unit {
        doTestResult("sms:+15551212", "+15551212", ParsedResultType.SMS);
        doTestResult("SMS:+15551212", "+15551212", ParsedResultType.SMS);
        doTestResult("sms:+15551212;via=999333", "+15551212", ParsedResultType.SMS);
        doTestResult("sms:+15551212?subject=foo&body=bar", "+15551212\nfoo\nbar", ParsedResultType.SMS);
        doTestResult("sms:+15551212,+12124440101", "+15551212\n+12124440101", ParsedResultType.SMS);
    }

    @TestCase
    public func testSMSTO(): Unit {
        doTestResult("SMSTO:+15551212", "+15551212", ParsedResultType.SMS);
        doTestResult("smsto:+15551212", "+15551212", ParsedResultType.SMS);
        doTestResult("smsto:+15551212:subject", "+15551212\nsubject", ParsedResultType.SMS);
        doTestResult("smsto:+15551212:My message", "+15551212\nMy message", ParsedResultType.SMS);

        // Need to handle question mark in the subject
        doTestResult("smsto:+15551212:What's up?", "+15551212\nWhat's up?", ParsedResultType.SMS);

        // Need to handle colon in the subject
        doTestResult(
            "smsto:+15551212:Directions: Do this",
            "+15551212\nDirections: Do this",
            ParsedResultType.SMS
        );
        doTestResult(
            "smsto:212-555-1212:Here's a longer message. Should be fine.",
            "212-555-1212\nHere's a longer message. Should be fine.",
            ParsedResultType.SMS
        );
    }

    @TestCase
    public func testMMS(): Unit {
        doTestResult("mms:+15551212", "+15551212", ParsedResultType.SMS);
        doTestResult("MMS:+15551212", "+15551212", ParsedResultType.SMS);
        doTestResult("mms:+15551212;via=999333", "+15551212", ParsedResultType.SMS);
        doTestResult("mms:+15551212?subject=foo&body=bar", "+15551212\nfoo\nbar", ParsedResultType.SMS);
        doTestResult("mms:+15551212,+12124440101", "+15551212\n+12124440101", ParsedResultType.SMS);
    }

    @TestCase
    public func testMMSTO(): Unit {
        doTestResult("MMSTO:+15551212", "+15551212", ParsedResultType.SMS);
        doTestResult("mmsto:+15551212", "+15551212", ParsedResultType.SMS);
        doTestResult("mmsto:+15551212:subject", "+15551212\nsubject", ParsedResultType.SMS);
        doTestResult("mmsto:+15551212:My message", "+15551212\nMy message", ParsedResultType.SMS);
        doTestResult("mmsto:+15551212:What's up?", "+15551212\nWhat's up?", ParsedResultType.SMS);
        doTestResult(
            "mmsto:+15551212:Directions: Do this",
            "+15551212\nDirections: Do this",
            ParsedResultType.SMS
        );
        doTestResult(
            "mmsto:212-555-1212:Here's a longer message. Should be fine.",
            "212-555-1212\nHere's a longer message. Should be fine.",
            ParsedResultType.SMS
        );
    }

    private static func doTestResult(contents: String, goldenResult: String, ptype: ParsedResultType) {
        doTestResult(contents, goldenResult, ptype, BarcodeFormat.QR_CODE);
        // QR code is arbitrary
    }

    private static func doTestResult(
        contents: String,
        goldenResult: String,
        ptype: ParsedResultType,
        format: BarcodeFormat
    ) {
        var fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            format
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);

        @Assert(ptype.toString(), result.getType().toString())

        var displayResult: String = result.getDisplayResult();
        @Assert(goldenResult, displayResult)
    }
}
