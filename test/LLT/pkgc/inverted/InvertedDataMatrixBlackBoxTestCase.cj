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
// DEPENDENCE: ../../resources/blackbox/inverted
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import common.reader.*
from QRCode4cj import common.*
from QRCode4cj import datamatrix.encoder.SymbolShapeHint
from QRCode4cj import datamatrix.*
from std import unittest.*
from std import unittest.testmacro.*
from QRCode4cj import tools.UTF32String
from std import collection.*


main(): Int64 {
    let tester = InvertedDataMatrixBlackBoxTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * Inverted barcodes
 */
@Test
public class InvertedDataMatrixBlackBoxTestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./inverted",
            MultiFormatReader(),
            BarcodeFormat.DATA_MATRIX
        );
        abs.addHint(DecodeHintType.ALSO_INVERTED);
        abs.addTest(1, 1, 0.0);
        abs.addTest(1, 1, 90.0);
        abs.addTest(1, 1, 180.0);
        abs.addTest(1, 1, 270.0);
        abs.testBlackBox();
    }
}
