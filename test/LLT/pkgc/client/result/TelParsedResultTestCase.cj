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
    let tester = TelParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class TelParsedResultTestCase {
    @TestCase
    public func testTel(): Unit {
        doTest("tel:+15551212", "+15551212", "");
        doTest("tel:2125551212", "2125551212", "");
    }

    private func doTest(contents: String, number: String, title: String) {
        let fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.QR_CODE
        );
        let result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.TEL.toString(), result.getType().toString())

        if (result is TelParsedResult) {
            var telResult: TelParsedResult = (result as TelParsedResult).getOrThrow()
            @Assert(number, telResult.getNumber())
            @Assert(title, telResult.getTitle())
            @Assert("tel:" + number, telResult.getTelURI())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
