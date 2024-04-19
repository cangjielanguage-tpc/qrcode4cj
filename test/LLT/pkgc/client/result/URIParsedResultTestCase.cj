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
from std import unicode.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from QRCode4cj import common.BarcodeFormat
from QRCode4cj import common.Result
from QRCode4cj import common.ResultPoint
from QRCode4cj import client.result.*

main(): Int64 {
    let tester = URIParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link URIParsedResult}.
 *
 * @author Sean Owen
 */
@Test
public class URIParsedResultTestCase {
    @TestCase
    public func testBookmarkDocomo(): Unit {
        doTest("MEBKM:URL:google.com;;", "http://google.com", "");
        doTest("MEBKM:URL:http://google.com;;", "http://google.com", "");
        doTest("MEBKM:URL:google.com;TITLE:Google;", "http://google.com", "Google");
    }

    @TestCase
    public func testURI(): Unit {
        doTest("google.com", "http://google.com", "");
        doTest("123.com", "http://123.com", "");
        doTest("http://google.com", "http://google.com", "");
        doTest("https://google.com", "https://google.com", "");
        doTest("google.com:443", "http://google.com:443", "");
        doTest(
            "https://www.google.com/calendar/hosted/google.com/embed?mode=AGENDA&force_login=true&src=google.com_726f6f6d5f6265707075@resource.calendar.google.com",
            "https://www.google.com/calendar/hosted/google.com/embed?mode=AGENDA&force_login=true&src=google.com_726f6f6d5f6265707075@resource.calendar.google.com",
            ""
        );
        doTest(
            "otpauth://remoteaccess?devaddr=00%a1b2%c3d4&devname=foo&key=bar",
            "otpauth://remoteaccess?devaddr=00%a1b2%c3d4&devname=foo&key=bar",
            ""
        );
        doTest("s3://amazon.com:8123", "s3://amazon.com:8123", "");
        doTest("HTTP://R.BEETAGG.COM/?12345", "HTTP://R.BEETAGG.COM/?12345", "");
    }

    @TestCase
    public func testNotURI(): Unit {
        doTestNotUri("google.c");
        doTestNotUri(".com");
        doTestNotUri(":80/");
        doTestNotUri("ABC,20.3,AB,AD");
        doTestNotUri("http://google.com?q=foo bar");
        doTestNotUri("12756.501");
        doTestNotUri("google.50");
        doTestNotUri("foo.bar.bing.baz.foo.bar.bing.baz");
    }

    @TestCase
    public func testURLTO(): Unit {
        doTest("urlto::bar.com", "http://bar.com", "");
        doTest("urlto::http://bar.com", "http://bar.com", "");
        doTest("urlto:foo:bar.com", "http://bar.com", "foo");
    }

    @TestCase
    public func testIsPossiblyMalicious(): Unit {
        doTestIsPossiblyMalicious("http://google.com", false);
        doTestIsPossiblyMalicious("http://google.com@evil.com", true);
        doTestIsPossiblyMalicious("http://google.com:@evil.com", true);
        doTestIsPossiblyMalicious("google.com:@evil.com", false);
        doTestIsPossiblyMalicious("https://google.com:443", false);
        doTestIsPossiblyMalicious("https://google.com:443/", false);
        doTestIsPossiblyMalicious("https://evil@google.com:443", true);
        doTestIsPossiblyMalicious("http://google.com/foo@bar", false);
        doTestIsPossiblyMalicious("http://google.com/@@", false);
    }

    @TestCase
    public func testMaliciousUnicode(): Unit {
        doTestIsPossiblyMalicious("https://google.com∕.evil.com/stuff", true);
    }

    @TestCase
    public func testExotic(): Unit {
        doTest("bitcoin:mySD89iqpmptrK3PhHFW9fa7BXiP7ANy3Y", "bitcoin:mySD89iqpmptrK3PhHFW9fa7BXiP7ANy3Y", "");
        doTest(
            "BTCTX:-TC4TO3$ZYZTC5NC83/SYOV+YGUGK:$BSF0P8/STNTKTKS.V84+JSA$LB+EHCG+8A725.2AZ-NAVX3VBV5K4MH7UL2.2M:" +
                "F*M9HSL*$2P7T*FX.ZT80GWDRV0QZBPQ+O37WDCNZBRM3EQ0S9SZP+3BPYZG02U/LA*89C2U.V1TS.CT1VF3DIN*HN3W-O-" +
                "0ZAKOAB32/.8:J501GJJTTWOA+5/6$MIYBERPZ41NJ6-WSG/*Z48ZH*LSAOEM*IXP81L:$F*W08Z60CR*C*P.JEEVI1F02J07L6+" +
                "W4L1G$/IC*$16GK6A+:I1-:LJ:Z-P3NW6Z6ADFB-F2AKE$2DWN23GYCYEWX9S8L+LF$VXEKH7/R48E32PU+A:9H:8O5",
            "BTCTX:-TC4TO3$ZYZTC5NC83/SYOV+YGUGK:$BSF0P8/STNTKTKS.V84+JSA$LB+EHCG+8A725.2AZ-NAVX3VBV5K4MH7UL2.2M:" +
                "F*M9HSL*$2P7T*FX.ZT80GWDRV0QZBPQ+O37WDCNZBRM3EQ0S9SZP+3BPYZG02U/LA*89C2U.V1TS.CT1VF3DIN*HN3W-O-" +
                "0ZAKOAB32/.8:J501GJJTTWOA+5/6$MIYBERPZ41NJ6-WSG/*Z48ZH*LSAOEM*IXP81L:$F*W08Z60CR*C*P.JEEVI1F02J07L6+" +
                "W4L1G$/IC*$16GK6A+:I1-:LJ:Z-P3NW6Z6ADFB-F2AKE$2DWN23GYCYEWX9S8L+LF$VXEKH7/R48E32PU+A:9H:8O5",
            ""
        );
        doTest("opc.tcp://test.samplehost.com:4841", "opc.tcp://test.samplehost.com:4841", "");
    }

    private static func doTest(contents: String, uri: String, title: String) {
        var fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.QR_CODE
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.URI.toString(), result.getType().toString())
        if (result is URIParsedResult) {
            var uriResult: URIParsedResult = (result as URIParsedResult).getOrThrow()
            @Assert(uri, uriResult.getURI())
            @Assert(title, uriResult.getTitle())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }

    private static func doTestNotUri(text: String) {
        var fakeResult: Result = Result(
            text,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.QR_CODE
        );

        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.TEXT.toString(), result.getType().toString())
        @Assert(text, result.getDisplayResult())
    }

    private static func doTestIsPossiblyMalicious(uri: String, malicious: Bool) {
        var fakeResult: Result = Result(
            uri,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.QR_CODE
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);

        if (malicious) {
            @Assert(ParsedResultType.TEXT.toString(), result.getType().toString())
        } else {
            @Assert(ParsedResultType.URI.toString(), result.getType().toString())
        }
    }
}
