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
// DEPENDENCE: ../../resources/blackbox/datamatrix-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import common.reader.*
from QRCode4cj import common.*
from std import unittest.*
from std import unittest.testmacro.*
from QRCode4cj import tools.UTF32String


main(): Int64 {
    let tester = DataMatrixBlackBox1TestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author bbrown@google.com (Brian Brown)
 */
@Test
public class DataMatrixBlackBox1TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./datamatrix-1",
            MultiFormatReader(),
            BarcodeFormat.DATA_MATRIX
        );
        abs.addTest(21, 21, 0.0);
        abs.addTest(21, 21, 90.0);
        abs.addTest(21, 21, 180.0);
        abs.addTest(21, 21, 270.0);
        abs.testBlackBox();
    }
}
