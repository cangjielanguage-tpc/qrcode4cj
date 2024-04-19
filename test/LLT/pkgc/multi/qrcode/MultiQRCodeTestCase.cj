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

// DEPENDENCE: ../../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../../common/test_result.cj
// DEPENDENCE: ../../../test_common.cj
// DEPENDENCE: ../../../resources/blackbox/multi-qrcode-1/1.png
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import multi.qrcode.QRCodeMultiReader
from QRCode4cj import multi.*
from std import fs.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*

main(): Int64 {
    let tester = MultiQRCodeTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link QRCodeMultiReader}.
 */
@Test
public class MultiQRCodeTestCase {
    @TestCase
    public func testMultiQRCodes(): Unit {
        try {
            // Very basic test for now
            var testImage: Path = Path("./1.png")

            var image: Image
            var opencvUtils: CvImageForZxing = CvImageForZxing()
            image = opencvUtils.opencvReadImg(testImage.toString())

            var imageiop = image as ImageI
            var imagei: ImageI = imageiop.getOrThrow()

            var source: LuminanceSource = BufferedImageLuminanceSource(imagei)
            var bitmap: BinaryBitmap = BinaryBitmap(HybridBinarizer(source))

            var reader: MultipleBarcodeReader = QRCodeMultiReader()
            var results: Array<Result> = reader.decodeMultiple(bitmap)
            @Assert(!results.isEmpty())
            @Assert(4, results.size)

            var barcodeContents: HashSet<String> = HashSet<String>()
            for (resultN in 0..results.size) {
                var result: Result = results[resultN]
                barcodeContents.put(result.getText())
                @Assert(BarcodeFormat.QR_CODE, result.getBarcodeFormat())
                @Assert(!result.getResultMetadata().isEmpty())
            }
            var expectedContents: HashSet<String> = HashSet<String>();
            expectedContents.put("You earned the class a 5 MINUTE DANCE PARTY!!  Awesome!  Way to go!  Let's boogie!")
            expectedContents.put("You earned the class 5 EXTRA MINUTES OF RECESS!!  Fabulous!!  Way to go!!")
            expectedContents.put(
                "You get to SIT AT MRS. SIGMON'S DESK FOR A DAY!!  Awesome!!  Way to go!! Guess I better clean up! :)")
            expectedContents.put("You get to CREATE OUR JOURNAL PROMPT FOR THE DAY!  Yay!  Way to go!  ")
            @Assert(expectedContents, barcodeContents)
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testProcessStructuredAppend(): Unit {
        var sa1: Result = Result("SA1", Array<UInt8>(), Array<ResultPoint>(), BarcodeFormat.QR_CODE)
        var sa2: Result = Result("SA2", Array<UInt8>(), Array<ResultPoint>(), BarcodeFormat.QR_CODE)
        var sa3: Result = Result("SA3", Array<UInt8>(), Array<ResultPoint>(), BarcodeFormat.QR_CODE)
        sa1.putMetadata(ResultMetadataType.STRUCTURED_APPEND_SEQUENCE, Int64(2))
        sa1.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, "L")
        sa2.putMetadata(ResultMetadataType.STRUCTURED_APPEND_SEQUENCE, Int64((1 << 4) + 2))
        sa2.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, "L")
        sa3.putMetadata(ResultMetadataType.STRUCTURED_APPEND_SEQUENCE, Int64((2 << 4) + 2))
        sa3.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, "L")

        var nsa: Result = Result("NotSA", Array<UInt8>(), Array<ResultPoint>(), BarcodeFormat.QR_CODE)
        nsa.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, "L")

        var inputs: Array<Result> = [sa3, sa1, nsa, sa2]

        var results: Array<Result> = QRCodeMultiReader.processStructuredAppend(inputs)
        @Assert(!results.isEmpty())
        @Assert(2, results.size)

        var barcodeContents: HashSet<String> = HashSet<String>()
        for (resultN in 0..results.size) {
            var result: Result = results[resultN]
            barcodeContents.put(result.getText())
        }
        var expectedContents: HashSet<String> = HashSet<String>()
        expectedContents.put("SA1SA2SA3")
        expectedContents.put("NotSA")
        @Assert(expectedContents, barcodeContents)
    }
}
