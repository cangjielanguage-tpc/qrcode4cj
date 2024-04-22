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

from QRCode4cj import tools.*
from QRCode4cj import common.*
from QRCode4cj import common.reader.*
from QRCode4cj import oned.*
from QRCode4cj import tools.UTF32String
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import collection.*
from std import os.posix.*

main(): Int64 {
    let tester = EAN8WriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Ari Pollak
 */
@Test
public class EAN8WriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        var testStr: String = "0000001010001011010111101111010110111010101001110111001010001001011100101000000";

        var result: BitMatrix = EAN8Writer().encode("96385074", BarcodeFormat.EAN_8, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testAddChecksumAndEncode(): Unit {
        var testStr: String = "0000001010001011010111101111010110111010101001110111001010001001011100101000000";
        var result: BitMatrix = EAN8Writer().encode("9638507", BarcodeFormat.EAN_8, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testEncodeIllegalCharacters(): Unit {
        try {
            EAN8Writer().encode("96385abc", BarcodeFormat.EAN_8, 0, 0);
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
