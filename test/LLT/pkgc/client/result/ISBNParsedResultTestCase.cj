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
    let tester = ISBNParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link ISBNParsedResult}.
 *
 * @author Sean Owen
 */
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
