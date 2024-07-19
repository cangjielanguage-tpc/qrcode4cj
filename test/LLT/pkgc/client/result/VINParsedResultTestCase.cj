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
    let tester = VINParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link VINParsedResult}.
 */
@Test
public class VINParsedResultTestCase {
    @TestCase
    public func testNotVIN(): Unit {
        var fakeResult: Result = Result(
            "1M8GDM9A1KP042788",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.TEXT.toString(), result.getType().toString())
        fakeResult = Result(
            "1M8GDM9AXKP042788",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_128
        )
        result = ResultParser.parseResult(fakeResult)
        @Assert(ParsedResultType.TEXT.toString(), result.getType().toString())
    }

    @TestCase
    public func testVIN(): Unit {
        doTest("1M8GDM9AXKP042788", "1M8", "GDM9AX", "KP042788", "US", "GDM9A", 1989, r'P', "042788");
        doTest("I1M8GDM9AXKP042788", "1M8", "GDM9AX", "KP042788", "US", "GDM9A", 1989, r'P', "042788");
        doTest("LJCPCBLCX11000237", "LJC", "PCBLCX", "11000237", "CN", "PCBLC", 2001, r'1', "000237");
    }

    private static func doTest(
        contents: String,
        wmi: String,
        vds: String,
        vis: String,
        country: String,
        attributes: String,
        year: Int64,
        plant: Rune,
        sequential: String
    ) {
        var fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(result.getType().toString(),ParsedResultType.VIN.toString())
        if (result is VINParsedResult) {
            var vinResult: VINParsedResult = (result as VINParsedResult).getOrThrow()
            @Assert(wmi, vinResult.getWorldManufacturerID())
            @Assert(vds, vinResult.getVehicleDescriptorSection())
            @Assert(vis, vinResult.getVehicleIdentifierSection())
            @Assert(country, vinResult.getCountryCode())
            @Assert(attributes, vinResult.getVehicleAttributes())
            @Assert(year, vinResult.getModelYear())
            @Assert(plant, vinResult.getPlantCode())
            @Assert(sequential, vinResult.getSequentialNumber())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
