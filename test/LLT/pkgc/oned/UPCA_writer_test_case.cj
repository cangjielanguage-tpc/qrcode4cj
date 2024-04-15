/*
 * Copyright 2010 ZXing authors
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
    let tester = UPCAWriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author qwandor@google.com (Andrew Walbran)
 */
@Test
public class UPCAWriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        var testStr: String = "00001010100011011011101100010001011010111101111010101011100101110100100111011001101101100101110010100000";
        var result: BitMatrix = UPCAWriter().encode("485963095124", BarcodeFormat.UPC_A, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testAddChecksumAndEncode(): Unit {
        var testStr: String = "00001010011001001001101111010100011011000101011110101010001001001000111010011100101100110110110010100000";
        var result: BitMatrix = UPCAWriter().encode("12345678901", BarcodeFormat.UPC_A, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
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