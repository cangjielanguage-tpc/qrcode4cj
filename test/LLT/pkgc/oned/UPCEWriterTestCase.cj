/*
 * Copyright 2016 ZXing authors
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
from QRCode4cj import zxing.code.tools.UTF32String
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import collection.*
from std import os.posix.*

main(): Int64 {
    let tester = UPCEWriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link UPCEWriter}.
 */
@Test
public class UPCEWriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        doTest(
            "05096893",
            "0000000000010101110010100111000101101011110110111001011101010100000000000"
        );
    }

    @TestCase
    public func testEncodeSystem1(): Unit {
        doTest(
            "12345670",
            "0000000000010100100110111101010001101110010000101001000101010100000000000"
        );
    }

    @TestCase
    public func testAddChecksumAndEncode(): Unit {
        doTest(
            "0509689",
            "0000000000010101110010100111000101101011110110111001011101010100000000000"
        );
    }

    private static func doTest(content: String, encoding: String) {
        var result: BitMatrix = UPCEWriter().encode(content, BarcodeFormat.UPC_E, encoding.size, 0);
        @Assert(encoding, matrixToString(result))
    }

    @TestCase
    public func testEncodeIllegalCharacters(): Unit {
        try {
            UPCEWriter().encode("05096abc", BarcodeFormat.UPC_E, 0, 0);
            @Assert(false)
        } catch (i: IllegalArgumentException) {
            @Assert(true)
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