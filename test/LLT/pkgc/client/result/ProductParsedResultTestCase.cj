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
    let tester = ProductParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
}


/**
 * Tests {@link ProductParsedResult}.
 *
 * @author Sean Owen
 */
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
