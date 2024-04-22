/*
 * Copyright 2022 ZXing authors
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
// DEPENDENCE: ../../resources/blackbox/maxicode-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import common.BarcodeFormat
from QRCode4cj import common.DecodeHintType
from QRCode4cj import common.reader.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let tester = MaxiCodeBlackBox1TestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests all characters in Set A.
 *
 * @author Daniel Gredler
 * @see <a href="https://github.com/zxing/zxing/issues/1543">Defect 1543</a>
 */
@Test
public class MaxiCodeBlackBox1TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./maxicode-1",
            MultiFormatReader(),
            BarcodeFormat.MAXICODE
        );
        abs.addHint(DecodeHintType.PURE_BARCODE)
        abs.addTest(7, 7, 0.0f32)

        abs.testBlackBox();
    }
}
