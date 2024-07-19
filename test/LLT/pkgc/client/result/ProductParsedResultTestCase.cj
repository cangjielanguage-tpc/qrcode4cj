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
    let tester = ProductParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class ProductParsedResultTestCase {
    @TestCase
    public func testProduct(): Unit {
        doTest("123456789012", "123456789012", BarcodeFormat.UPC_A);
        doTest("00393157", "00393157", BarcodeFormat.EAN_8);
        doTest("5051140178499", "5051140178499", BarcodeFormat.EAN_13);
        doTest("01234565", "012345000065", BarcodeFormat.UPC_E);
    }

    private static func doTest(contents: String, normalized: String, format: BarcodeFormat) {
        var fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            format
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.PRODUCT.toString(), result.getType().toString())
        if (result is ProductParsedResult) {
            var productResult: ProductParsedResult = (result as ProductParsedResult).getOrThrow()
            @Assert(contents, productResult.getProductID())
            @Assert(normalized, productResult.getNormalizedProductID())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
