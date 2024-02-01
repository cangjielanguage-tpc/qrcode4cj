/*
 * Copyright 2016 ZXing authors
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


// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/multi-1/1.png
// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import zxing.code.multi.GenericMultipleBarcodeReader
from QRCode4cj import zxing.code.multi.MultipleBarcodeReader
from QRCode4cj import zxing.code.common.*
from std import fs.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*

main(): Int64 {
    let tester = MultiTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link MultipleBarcodeReader}.
 */
@Test
public class MultiTestCase {
    @TestCase
    public func testMulti(): Unit {
        // Very basic test for now
        var testBase: Path = Path("./1.png")

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(testBase.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        var source: LuminanceSource = BufferedImageLuminanceSource(imagei)
        var bitmap: BinaryBitmap = BinaryBitmap(HybridBinarizer(source))

        var reader: MultipleBarcodeReader = GenericMultipleBarcodeReader(MultiFormatReader())
        var results: Array<Result> = reader.decodeMultiple(bitmap)
        @Assert(!results.isEmpty())
        @Assert(2, results.size)

        @Assert("031415926531", results[0].getText())
        @Assert(BarcodeFormat.UPC_A, results[0].getBarcodeFormat())

        @Assert("www.airtable.com/jobs", results[1].getText())
        @Assert(BarcodeFormat.QR_CODE, results[1].getBarcodeFormat())
    }
}
