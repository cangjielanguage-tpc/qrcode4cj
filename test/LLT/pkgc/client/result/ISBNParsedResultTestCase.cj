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
    let tester = ISBNParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class ISBNParsedResultTestCase {
    @TestCase
    public func testISBN(): Unit {
        doTest("9784567890123");
    }

    private static func doTest(contents: String) {
        var fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.EAN_13
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.ISBN.toString(), result.getType().toString())
        if (result is ISBNParsedResult) {
            var isbnResult: ISBNParsedResult = (result as ISBNParsedResult).getOrThrow()
            @Assert(contents, isbnResult.getISBN())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
