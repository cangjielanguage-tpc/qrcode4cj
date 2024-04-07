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
from QRCode4cj import zxing.code.common.BarcodeFormat
from QRCode4cj import zxing.code.common.Result
from QRCode4cj import zxing.code.common.ResultPoint
from QRCode4cj import zxing.code.client.result.*

main(): Int64 {
    let tester = SMSMMSParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link SMSParsedResult}.
 *
 * @author Sean Owen
 */
@Test
public class SMSMMSParsedResultTestCase {
    @TestCase
    public func testSMS(): Unit {
        doTest("sms:+15551212", "+15551212", "", "", "", "sms:+15551212");
        doTest(
            "sms:+15551212?subject=foo&body=bar",
            "+15551212",
            "foo",
            "bar",
            "",
            "sms:+15551212?body=bar&subject=foo"
        );
        doTest(
            "sms:+15551212;via=999333",
            "+15551212",
            "",
            "",
            "999333",
            "sms:+15551212;via=999333"
        );
    }

    @TestCase
    public func testMMS(): Unit {
        doTest("mms:+15551212", "+15551212", "", "", "", "sms:+15551212");
        doTest(
            "mms:+15551212?subject=foo&body=bar",
            "+15551212",
            "foo",
            "bar",
            "",
            "sms:+15551212?body=bar&subject=foo"
        );
        doTest(
            "mms:+15551212;via=999333",
            "+15551212",
            "",
            "",
            "999333",
            "sms:+15551212;via=999333"
        );
    }

    private static func doTest(
        contents: String,
        number: String,
        subject: String,
        body: String,
        via: String,
        parsedURI: String
    ) {
        var fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.QR_CODE
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.SMS.toString(), result.getType().toString())

        if (result is SMSParsedResult) {
            var smsResult: SMSParsedResult = (result as SMSParsedResult).getOrThrow()
            @Assert(Array<String>([number] ), smsResult.getNumbers())
            @Assert(subject, smsResult.getSubject())
            @Assert(body, smsResult.getBody())
            @Assert(Array<String>([via] ), smsResult.getVias())
            @Assert(parsedURI, smsResult.getSMSURI())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
