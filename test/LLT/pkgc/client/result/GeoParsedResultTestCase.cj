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
    let tester = GeoParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class GeoParsedResultTestCase {
    private static let EPSILON: Float64 = 1.0E-10;

    @TestCase
    public func testGeo(): Unit {
        doTest("geo:1,2", 1.0, 2.0, 0.0, "", "geo:1.000000,2.000000");
        doTest("geo:80.330000,-32.334400,3.350000", 80.33, -32.3344, 3.35, "", "");
        doTest("geo:-20.330000,132.334400,0.010000", -20.33, 132.3344, 0.01, "", "");
        doTest("geo:-20.330000,132.334400,0.010000?q=foobar", -20.33, 132.3344, 0.01, "q=foobar", "");
        doTest("GEO:-20.330000,132.334400,0.010000?q=foobar", -20.33, 132.3344, 0.01, "q=foobar", "");
    }

    private static func doTest(
        contents: String,
        latitude: Float64,
        longitude: Float64,
        altitude: Float64,
        query: String,
        uri: String
    ) {
        var fakeResult: Result = Result(
            contents,
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.QR_CODE
        );
        var result: ParsedResult = ResultParser.parseResult(fakeResult);
        @Assert(ParsedResultType.GEO.toString(), result.getType().toString())
        if (result is GeoParsedResult) {
            var geoResult: GeoParsedResult = (result as GeoParsedResult).getOrThrow()
            @Assert(latitude, geoResult.getLatitude())
            @Assert(longitude, geoResult.getLongitude())
            @Assert(altitude, geoResult.getAltitude())
            @Assert(query, geoResult.getQuery())
            var uriTest: String = ""
            if (uri == "") {
                uriTest = contents.toLower()
            } else {
                uriTest = uri
            }
            @Assert(uriTest, geoResult.getGeoURI())
        } else {
            println("Invalid result type: " + result.getType().toString())
        }
    }
}
