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
    let tester = Code93WriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link Code93Writer}.
 */
@Test
public class Code93WriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        doTest(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
            "000001010111101101010001101001001101000101100101001100100101100010101011010001011001" +
                "001011000101001101001000110101010110001010011001010001101001011001000101101101101001" +
                "101100101101011001101001101100101101100110101011011001011001101001101101001110101000" +
                "101001010010001010001001010000101001010001001001001001000101010100001000100101000010" +
                "10100111010101000010101011110100000"
        );

        doTest(
            "\u{0000}\u{0001}\u{001a}\u{001b}\u{001f} $%+!,09:;@AZ[_`az{\u{007f}",
            "00000" + "101011110" + "111011010" + "110010110" + "100100110" + "110101000" + // bU aA
                "100100110" + "100111010" +
                "111011010" + "110101000" + // aZ bA
                "111011010" + "110010010" + "111010010" + "111001010" + // bE space $
                "110101110" +
                "101110110" + "111010110" + "110101000" + // % + cA
                "111010110" + "101011000" + "100010100" + "100001010" + // cL 0 9
                "111010110" + "100111010" + "111011010" + "110001010" + // cZ bF
                "111011010" + "110011010" + "110101000" +
                "100111010" + // bV A Z
                "111011010" + "100011010" + "111011010" + "100101100" + // bK bO
                "111011010" + "101101100" +
                "100110010" + "110101000" + // bW dA
                "100110010" + "100111010" + "111011010" + "100010110" + // dZ bP
                "111011010" +
                "110100110" + // bT
            "110100010" + "110101100" + // checksum: 12 28
            "101011110" + "100000"
        );
    }

    private static func doTest(input: String, expected: String) {
        var result: BitMatrix = Code93Writer().encode(input, BarcodeFormat.CODE_93, 0, 0);
        @Expect(expected, matrixToString(result))
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