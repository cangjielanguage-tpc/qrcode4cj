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
    let tester = GeoParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link GeoParsedResult}.
 *
 * @author Sean Owen
 */
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
