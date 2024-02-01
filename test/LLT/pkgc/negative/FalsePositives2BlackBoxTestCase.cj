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

// DEPENDENCE: ../common/abstract_negative_black_box_test_case.cj
// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/falsepositives-2
// EXEC: cjc %import-path %L %l %f ./abstract_negative_black_box_test_case.cj ./test_result.cj ./test_common.cj ./abstract_back_box_test_case.cj
// EXEC: ./main


from std import unittest.*
from std import unittest.testmacro.*
from charset import charset.tools.UTF32String
from std import collection.*
from QRCode4cj import zxing.code.multi.qrcode.QRCodeMultiReader
from QRCode4cj import zxing.code.multi.*

main(): Int64 {
    let tester = FalsePositives2BlackBoxTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}
/**
 * Additional random images with high contrast patterns which should not find any barcodes.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
@Test
public class FalsePositives2BlackBoxTestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractNegativeBlackBoxTestCase = AbstractNegativeBlackBoxTestCase(
            "./falsepositives-2");
        abs.addTest(4, 0.0);
        abs.addTest(4, 90.0);
        abs.addTest(4, 180.0);
        abs.addTest(4, 270.0);
        abs.testBlackBox();
    }
}
