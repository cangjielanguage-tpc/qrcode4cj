// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.math.*
import std.time.*
import std.unittest.*
import std.unittest.testmacro.*
import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.Result
import QRCode4cj.common.ResultPoint
import QRCode4cj.client.result.*

main(): Int64 {
    let tester = EmailAddressParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class EmailAddressParsedResultTestCase {
    @TestCase
    public func testEmailAddress(): Unit {
        doTest("srowen@example.org", "srowen@example.org", "", "");
        doTest("mailto:srowen@example.org", "srowen@example.org", "", "");
    }

    @TestCase
    public func testTos(): Unit {
        doTest(
            "mailto:srowen@example.org,bob@example.org",
            Array<String>(["srowen@example.org", "bob@example.org"]),
            Array<String>(),
            Array<String>(),
            "",
            ""
        );
        doTest(
            "mailto:?to=srowen@example.org,bob@example.org",
            Array<String>(["srowen@example.org", "bob@example.org"]),
            Array<String>(),
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testCCs(): Unit {
        doTest(
            "mailto:?cc=srowen@example.org",
            Array<String>(),
            Array<String>(["srowen@example.org"]),
            Array<String>(),
            "",
            ""
        );
        doTest(
            "mailto:?cc=srowen@example.org,bob@example.org",
            Array<String>(),
            Array<String>(["srowen@example.org", "bob@example.org"]),
            Array<String>(),
            "",
            ""
        );
    }

    @TestCase
    public func testBCCs(): Unit {
        doTest(
            "mailto:?bcc=srowen@example.org",
            Array<String>(),
            Array<String>(),
            Array<String>(["srowen@example.org"]),
            "",
            ""
        );
        doTest(
            "mailto:?bcc=srowen@example.org,bob@example.org",
            Array<String>(),
            Array<String>(),
            Array<String>(["srowen@example.org", "bob@example.org"]),
            "",
            ""
        );
    }

    @TestCase
    public func testAll(): Unit {
        doTest(
            "mailto:bob@example.org?cc=foo@example.org&bcc=srowen@example.org&subject=baz&body=buzz",
            Array<String>(["bob@example.org"]),
            Array<String>(["foo@example.org"]),
            Array<String>(["srowen@example.org"]),
            "baz",
            "buzz"
        );
    }

    @TestCase
    public func testEmailDocomo(): Unit {
        doTest("MATMSG:TO:srowen@example.org;;", "srowen@example.org", "", "");
        doTest("MATMSG:TO:srowen@example.org;SUB:Stuff;;", "srowen@example.org", "Stuff", "");
        doTest(
            "MATMSG:TO:srowen@example.org;SUB:Stuff;BODY:This is some text;;",
            "srowen@example.org",
            "Stuff",
            "This is some text"
        );
    }

    @TestCase
    public func testSMTP(): Unit {
        doTest("smtp:srowen@example.org", "srowen@example.org", "", "");
        doTest("SMTP:srowen@example.org", "srowen@example.org", "", "");
        doTest("smtp:srowen@example.org:foo", "srowen@example.org", "foo", "");
        doTest("smtp:srowen@example.org:foo:bar", "srowen@example.org", "foo", "bar");
    }

    private static func doTest(contents: String, to: String, subject: String, body: String) {
        doTest(contents, Array<String>([to]), Array<String>(), Array<String>(), subject, body);
    }

    private static func doTest(
        contents: String,
        tos: Array<String>,
        ccs: Array<String>,
        bccs: Array<String>,
        subject: String,
        body: String
    ) {
        var fakeResult: Result = Result(contents, Array<UInt8>(), Array<ResultPoint>(), BarcodeFormat.QR_CODE);
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.EMAIL_ADDRESS.toString(), result.getType().toString())

        if (result is EmailAddressParsedResult) {
            var emailResult: EmailAddressParsedResult = (result as EmailAddressParsedResult).getOrThrow()
            @Assert(tos, emailResult.getTos())
            @Assert(ccs, emailResult.getCCs())
            @Assert(bccs, emailResult.getBCCs())
            @Assert(subject, emailResult.getSubject())
            @Assert(body, emailResult.getBody())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
