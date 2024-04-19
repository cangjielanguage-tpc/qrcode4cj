/*
 * Copyright 2018 ZXing authors
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
    let tester = Code93ReaderTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Daisuke Makiuchi
 */
@Test
public class Code93ReaderTestCase {
    @TestCase
    public func testDecode(): Unit {
        doTest(
            "Code93!\n$%/+ :\u{001b};[{\u{007f}\u{0000}@`\u{007f}\u{007f}\u{007f}",
            "0000001010111101101000101001100101001011001001100101100101001001100101100100101000010101010000101110101101101010001001001101001101001110010101101011101011011101011101101110100101110101101001110101110110101101010001110110101100010101110110101000110101110110101000101101110110101101001101110110101100101101110110101100110101110110101011011001110110101011001101110110101001101101110110101001110101001100101101010001010111101111"
        );
    }

    private static func doTest(expectedResult: String, encodedResult: String) {
        var sut: Code93Reader = Code93Reader();
        var matrix: BitMatrix = BitMatrix.parse(UTF32String(encodedResult), UTF32String("1"), UTF32String("0"));
        var row: BitArray = BitArray(matrix.getWidth());
        matrix.getRow(0, row);

        var result: Result = sut.decodeRow(0, row, HashMap<DecodeHintType, Any>());
        @Expect(expectedResult, result.getText())
    }
}
