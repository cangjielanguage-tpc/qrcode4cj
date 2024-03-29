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
// DEPENDENCE: ../../resources/blackbox/qrcode-6
// DEPENDENCE: ../../resources/golden/qrcode
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import zxing.code.common.BarcodeFormat
from QRCode4cj import zxing.code.common.reader.MultiFormatReader
from QRCode4cj import zxing.code.common.EncodeHintType
from QRCode4cj import zxing.code.common.Writer
from QRCode4cj import zxing.code.common.Qrcoder4cjWriterException
from QRCode4cj import zxing.code.common.BitMatrix
from QRCode4cj import zxing.code.qrcode.decoder.ErrorCorrectionLevel
from QRCode4cj import zxing.code.qrcode.QRCodeWriter
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import collection.*
from std import fs.*

main(): Int64 {
    let tester = QRCodeWriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported and expanded from C++
 */
@Test
public class QRCodeWriterTestCase {
    private static var BASE_IMAGE_PATH: Path = Path("./qrcode/");

    private static func loadImage(fileName: String): ImageI {
        var file: Path = BASE_IMAGE_PATH.join(fileName);
        if (!File.exists(file)) {
            // try starting with 'core' since the test base is often given as the project root
            file = Path("core").join(BASE_IMAGE_PATH).join(fileName)
        }
        @Assert( /*"Please download and install test images, and run from the 'core' directory",*/ File.exists(file))

        /*"Please download and install test images, and run from the 'core' directory",*/
        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(file.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        return imagei
    }

    // In case the golden images are not monochromatic, convert the RGB values to greyscale.
    private static func createMatrixFromImage(image: ImageI): BitMatrix {
        var width: Int64 = image.bounds().dx();
        var height: Int64 = image.bounds().dy();
        var pixels: Array<Int64> = Array<Int64>(width * height, item: 0)

        var matrix: BitMatrix = BitMatrix(width, height);

        for (y in 0..height) {
            for (x in 0..width) {
                var pixel: Int64 = pixels[y * width + x]
                let colorRGB: Color = image.at(x, y)
                var a = (grayModel(colorRGB) as GrayC).getOrThrow().y
                if (a <= 0x7F) {
                    matrix.set(x, y);
                }
            }
        }
        return matrix
    }

    @TestCase
    public func testQRCodeWriter(): Unit {
        // The QR should be multiplied up to fit, with extra padding if necessary
        var bigEnough: Int64 = 256;
        var writer: QRCodeWriter = QRCodeWriter();
        var matrix: BitMatrix = writer.encode(
            "http://www.google.com/",
            BarcodeFormat.QR_CODE,
            bigEnough,
            bigEnough,
            HashMap<EncodeHintType, Any>()
        );
        @Assert(matrix.flag)
        @Assert(bigEnough, matrix.getWidth())
        @Assert(bigEnough, matrix.getHeight())

        // The QR will not fit in this size, so the matrix should come back bigger
        var tooSmall: Int64 = 20;
        matrix = writer.encode(
            "http://www.google.com/",
            BarcodeFormat.QR_CODE,
            tooSmall,
            tooSmall,
            HashMap<EncodeHintType, Any>()
        )
        @Assert(matrix.flag)
        @Assert(tooSmall < matrix.getWidth())
        @Assert(tooSmall < matrix.getHeight())

        // We should also be able to handle non-square requests by padding them
        var strangeWidth: Int64 = 500;
        var strangeHeight: Int64 = 100;
        matrix = writer.encode(
            "http://www.google.com/",
            BarcodeFormat.QR_CODE,
            strangeWidth,
            strangeHeight,
            HashMap<EncodeHintType, Any>()
        )
        @Assert(matrix.flag)
        @Assert(strangeWidth, matrix.getWidth())
        @Assert(strangeHeight, matrix.getHeight())
    }

    private static func compareToGoldenFile(
        contents: String,
        ecLevel: ErrorCorrectionLevel,
        resolution: Int64,
        fileName: String
    ) {
        var image: ImageI = loadImage(fileName);

        //assertNotNull(image);
        var goldenResult: BitMatrix = createMatrixFromImage(image);
        @Assert(goldenResult.flag)

        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.ERROR_CORRECTION, ecLevel);
        var writer: QRCodeWriter = QRCodeWriter();
        var generatedResult: BitMatrix = writer.encode(
            contents,
            BarcodeFormat.QR_CODE,
            resolution,
            resolution,
            hints
        );

        @Assert(resolution, generatedResult.getWidth())
        @Assert(resolution, generatedResult.getHeight())
        @Assert(goldenResult, generatedResult)
    }

    // Golden images are generated with "qrcode_sample.cc". The images are checked with both eye balls
    // and cell phones. We expect pixel-perfect results, because the error correction level is known,
    // and the pixel dimensions matches exactly. 
    @TestCase
    public func testRegressionTest(): Unit {
        compareToGoldenFile(
            "http://www.google.com/",
            ErrorCorrectionLevel.M(0x00),
            99,
            "renderer-test-01.png"
        );
    }
}
