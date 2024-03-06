/*
 * Copyright 2008 ZXing authors
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
// DEPENDENCE: ../../resources/blackbox/datamatrix-2
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import zxing.code.common.reader.*
from QRCode4cj import zxing.code.common.*
from std import unittest.*
from std import unittest.testmacro.*
from charset import charset.tools.UTF32String


main(): Int64 {
    let tester = DataMatrixBlackBox2TestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author dswitkin@google.com (Daniel Switkin)
 */
@Test
public class DataMatrixBlackBox2TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./datamatrix-2",
            MultiFormatReader(),
            BarcodeFormat.DATA_MATRIX
        );
        abs.addTest(13, 13, 0, 1, 0.0);
        abs.addTest(15, 15, 0, 1, 90.0);
        abs.addTest(17, 16, 0, 1, 180.0);
        abs.addTest(15, 15, 0, 1, 270.0);
        abs.testBlackBox();
    }
}
