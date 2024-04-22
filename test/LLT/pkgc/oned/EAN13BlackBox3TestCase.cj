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
// DEPENDENCE: ../../resources/blackbox/ean13-3
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import tools.*
from QRCode4cj import common.*
from QRCode4cj import common.reader.*
from QRCode4cj import oned.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import collection.*
from std import os.posix.*

main(): Int64 {
    let tester = EAN13BlackBox3TestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author dswitkin@google.com (Daniel Switkin)
 */
@Test
public class EAN13BlackBox3TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./ean13-3",
            MultiFormatReader(),
            BarcodeFormat.EAN_13
        )
        abs.addTest(53, 55, 0.0)
        abs.addTest(55, 55, 180.0)
        abs.testBlackBox()
    }
}
