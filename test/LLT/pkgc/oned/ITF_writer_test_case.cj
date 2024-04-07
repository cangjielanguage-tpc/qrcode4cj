/*
 * Copyright 2017 ZXing authors
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

from QRCode4cj import zxing.code.tools.*
from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.common.reader.*
from QRCode4cj import zxing.code.oned.*
from charset import charset.tools.UTF32String
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import collection.*
from std import os.posix.*

main(): Int64 {
    let tester = ITFWriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link ITFWriter}.
 */
@Test
public class ITFWriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        doTest(
            "00123456789012",
            "0000010101010111000111000101110100010101110001110111010001010001110100011" +
                "100010101000101011100011101011101000111000101110100010101110001110100000"
        );
    }

    private static func doTest(input: String, expected: String) {
        var result: BitMatrix = ITFWriter().encode(input, BarcodeFormat.ITF, 0, 0)
        @Expect(expected, matrixToString(result))
    }

    @TestCase
    public func testEncodeIllegalCharacters(): Unit {
        try {
            ITFWriter().encode("00123456789abc", BarcodeFormat.ITF, 0, 0);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Input should only contain digits 0-9")
        }
    }
}

public func matrixToString(result: BitMatrix): String {
    @Assert(1, result.getHeight())
    var builder: StringBuilder = StringBuilder();
    for (i in 0..result.getWidth()) {
        builder.append(
            if (result.get(i, 0)) {
                "1"
            } else {
                "0"
            }
        );
    }
    return builder.toString();
}
