/*
 * Copyright 2014 ZXing authors
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
    let tester = VINParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
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
        doTest("1M8GDM9AXKP042788", "1M8", "GDM9AX", "KP042788", "US", "GDM9A", 1989, 'P', "042788");
        doTest("I1M8GDM9AXKP042788", "1M8", "GDM9AX", "KP042788", "US", "GDM9A", 1989, 'P', "042788");
        doTest("LJCPCBLCX11000237", "LJC", "PCBLCX", "11000237", "CN", "PCBLC", 2001, '1', "000237");
    }

    private static func doTest(
        contents: String,
        wmi: String,
        vds: String,
        vis: String,
        country: String,
        attributes: String,
        year: Int64,
        plant: Char,
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
