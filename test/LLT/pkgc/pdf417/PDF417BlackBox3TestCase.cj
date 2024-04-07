/*
 * Copyright 2009 ZXing authors
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
// DEPENDENCE: ../../resources/blackbox/qrcode-3
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main


from QRCode4cj import zxing.code.common.BarcodeFormat
from QRCode4cj import zxing.code.common.reader.MultiFormatReader
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = PDF417BlackBox3TestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link PDF417Reader} against more sample images.
 */
@Test
public class PDF417BlackBox3TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./qrcode-3",
            MultiFormatReader(),
            BarcodeFormat.QR_CODE
        );
        abs.addTest(19, 19, 0, 0, 0.0);
        abs.addTest(19, 19, 0, 0, 180.0);
    }
}
