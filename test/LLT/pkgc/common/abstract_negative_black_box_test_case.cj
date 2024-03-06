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

from QRCode4cj import zxing.code.common.reader.*
from std import convert.*
from std import fs.*
from std import collection.*
from std import random.*
from std import log.*
from std import io.*
from charset import charset.tools.UTF32String

/**
 * This abstract class looks for negative results, i.e. it only allows a certain number of false
 * positives in images which should not decode. This helps ensure that we are not too lenient.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public class ATestResult {
    private let falsePositivesAllowed: Int64
    private let rotation: Float32

    init(falsePositivesAllowed: Int64, rotation: Float32) {
        this.falsePositivesAllowed = falsePositivesAllowed
        this.rotation = rotation
    }

    func getFalsePositivesAllowed(): Int64 {
        return falsePositivesAllowed
    }

    func getRotation(): Float32 {
        return rotation
    }
}

public class AbstractNegativeBlackBoxTestCase <: AbstractBlackBoxTestCase {
    //private static var log: SimpleLogger = SimpleLogger()
    private var testAResults: ArrayList<ATestResult> = ArrayList<ATestResult>()

    //private let barcodeReader: zxing.code.common.Reader
    public init(testBasePathSuffix: String) {
        super(testBasePathSuffix, MultiFormatReader(), BarcodeFormat.NONE);
    }

    public init(testBasePathSuffix: String, barcodeReader: zxing.code.common.Reader, expectedFormat: BarcodeFormat) {
        super(testBasePathSuffix, barcodeReader, expectedFormat);
    }

    public func addTest(falsePositivesAllowed: Int64, rotation: Float32) {
        testAResults.append(ATestResult(falsePositivesAllowed, rotation));
    }

    public func testBlackBox(): Unit {
        @Assert(testAResults.isEmpty(),false)

        var imageFiles: ArrayList<Path> = getImageFiles();
        var falsePositives: Array<Int64> = Array<Int64>(testAResults.size, item: 0)

        for (testImage in imageFiles) {
            log.info("Starting ${testImage}")

            var image: Image
            var opencvUtils: CvImageForZxing = CvImageForZxing()
            image = opencvUtils.opencvReadImg(testImage.toString())

            var testImageFileName: String = testImage.fileName.getOrThrow();
            let fileBaseName = testImageFileName[Range<Int64>(
                    0,
                    testImageFileName.indexOf('.'.toString()).getOrThrow(),
                    1,
                    true,
                    true,
                    false
                )]
            if (!File.exists(testImage)) {
                throw IOException("Could not read image: ${testImage.fileName.getOrThrow()}");
            }
            for (x in 0..testAResults.size) {
                var testResult: ATestResult = testAResults.get(x).getOrThrow()
                if (!checkForFalsePositives(image, testResult.getRotation())) {
                    falsePositives[x] = falsePositives[x] + 1
                }
            }
        }

        var totalFalsePositives: Int64 = 0;
        var totalAllowed: Int64 = 0;

        for (x in 0..testAResults.size) {
            var testResult: ATestResult = testAResults.get(x).getOrThrow()
            totalFalsePositives += falsePositives[x]
            totalAllowed += testResult.getFalsePositivesAllowed()
        }

        if (totalFalsePositives < totalAllowed) {
            log.warn("+++ Test too lax by ${totalAllowed - totalFalsePositives} images");
        } else if (totalFalsePositives > totalAllowed) {
            log.warn("--- Test failed by ${totalFalsePositives - totalAllowed} images");
        }
        for (x in 0..testAResults.size) {
            var testResult: ATestResult = testAResults.get(x).getOrThrow()
            log.info(
                "Rotation ${testResult.getRotation()} degrees: ${falsePositives[x]} of ${imageFiles.size} images were false positives (${testResult.getFalsePositivesAllowed()} allowed)"
            );
            var label = "Rotation ${ testResult.getRotation() } degrees: Too many false positives found"
            @Assert(falsePositives[x] <= testResult.getFalsePositivesAllowed())
        }
    }

    /**
     * Make sure ZXing does NOT find a barcode in the image.
     *
     * @param image The image to test
     * @param rotationInDegrees The amount of rotation to apply
     * @return true if nothing found, false if a non-existent barcode was detected
     */
    private func checkForFalsePositives(image: Image, rotationInDegrees: Float32): Bool {
        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()
        var rotatedImage: ImageI = rotateImage(imagei, rotationInDegrees);
        var source: LuminanceSource = BufferedImageLuminanceSource(rotatedImage);
        var bitmap: BinaryBitmap = BinaryBitmap(HybridBinarizer(source))
        var result: Result
        try {
            result = getReader().decode(bitmap)
            log.info(
                "Found false positive: '${result.getText()}' with format '${result.getBarcodeFormat()}' (rotation: ${Int64(rotationInDegrees)})"
            )
            return false;
        } catch (re: ReaderException) {
            // continue
        }

        // Try "try harder" getMode
        let hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>()
        hints.put(DecodeHintType.TRY_HARDER, true);
        try {
            result = getReader().decode(bitmap, hints)
            log.info(
                "Try harder found false positive: '${result.getText()}' with format '${result.getBarcodeFormat()}' (rotation: ${Int64(rotationInDegrees)})"
            )
            return false;
        } catch (re: ReaderException) {
            // continue
        }
        return true;
    }
}
