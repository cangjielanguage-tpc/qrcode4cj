/*
 * Copyright 2009 ZXing authors
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
    let tester = EAN13WriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Ari Pollak
 */
@Test
public class EAN13WriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        var testStr: String = "00001010001011010011101100110010011011110100111010101011001101101100100001010111001001110100010010100000";
        var result: BitMatrix = EAN13Writer().encode("5901234123457", BarcodeFormat.EAN_13, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testAddChecksumAndEncode(): Unit {
        var testStr: String = "00001010001011010011101100110010011011110100111010101011001101101100100001010111001001110100010010100000";
        var result: BitMatrix = EAN13Writer().encode("590123412345", BarcodeFormat.EAN_13, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testEncodeIllegalCharacters(): Unit {
        try {
            EAN13Writer().encode("5901234123abc", BarcodeFormat.EAN_13, 0, 0);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Illegal contents")
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