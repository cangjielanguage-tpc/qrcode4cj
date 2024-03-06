/*
 * Copyright 2020 ZXing authors
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

// DEPENDENCE: ../test_common.cj
// DEPENDENCE: ./common/abstract_back_box_test_case.cj
// DEPENDENCE: ./common/test_result.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from QRCode4cj import zxing.code.common.*

main(): Int64 {
    let tester = InvertedLuminanceSourceTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}


/**
 * Tests {@link InvertedLuminanceSource}.
 */
@Test
public open class InvertedLuminanceSourceTestCase {
    @TestCase
    public func testInverted(): Unit {
        var image: RGBA_p = RGBA_p(Rectangle_p(Point(0, 0), Point(2, 1)))
        image.set(0, 0, RGBAC(0xFF, 0xFF, 0xFF, 0xFF));
        image.set(1, 0, RGBAC(0x00, 0x00, 0x00, 0xFF));

        var source: LuminanceSource = BufferedImageLuminanceSource(image)
        @Assert([UInt8(0xFF), 0], source.getRow(0, 0))
        var inverted: LuminanceSource = InvertedLuminanceSource(source)
        @Assert([0, UInt8(0xFF)], inverted.getRow(0, 0))
    }
}
