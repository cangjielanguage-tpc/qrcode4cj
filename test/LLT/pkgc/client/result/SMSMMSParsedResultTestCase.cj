// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.math.*
import std.time.*
import std.unicode.*
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.Result
import QRCode4cj.common.ResultPoint
import QRCode4cj.client.result.*

main(): Int64 {
    let tester = SMSMMSParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

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
