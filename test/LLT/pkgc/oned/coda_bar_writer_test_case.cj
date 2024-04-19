/*
 * Copyright 2011 ZXing authors
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

// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/rssexpandedstacked-2
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import tools.*
from QRCode4cj import common.*
from QRCode4cj import common.reader.*
from QRCode4cj import oned.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import collection.*

main(): Int64 {
    let tester = CodaBarWriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author dsbnatut@gmail.com (Kazuki Nishiura)
 * @author Sean Owen
 */
@Test
public class CodaBarWriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        doTest(
            "B515-3/B",
            "00000" + "1001001011" + "0110101001" + "0101011001" + "0110101001" + "0101001101" + "0110010101" +
                "01101101011" + "01001001011" + "00000"
        );
    }

    @TestCase
    public func testEncode2(): Unit {
        doTest(
            "T123T",
            "00000" + "1011001001" + "0101011001" + "0101001011" + "0110010101" + "01011001001" + "00000"
        );
    }

    @TestCase
    public func testAltStartEnd(): Unit {
        @Expect(encode("T123456789-$T"), encode("A123456789-$A"))
    }

    public static func matrixToString(result: BitMatrix): String {
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

    private static func doTest(input: String, expected: String) {
        var result: BitMatrix = encode(input);
        @Expect(expected, matrixToString(result))
    }

    private static func encode(input: String): BitMatrix {
        return CodaBarWriter().encode(input, BarcodeFormat.CODABAR, 0, 0);
    }
}
