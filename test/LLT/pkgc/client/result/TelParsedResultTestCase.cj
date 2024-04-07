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
    let tester = TelParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link TelParsedResult}.
 *
 * @author Sean Owen
 */
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
