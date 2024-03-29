/*
 * Copyright 2013 ZXing authors
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
// DEPENDENCE: ../../resources/blackbox/pdf417-4
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main


from QRCode4cj import zxing.code.common.BarcodeFormat
from QRCode4cj import zxing.code.common.BinaryBitmap
from QRCode4cj import zxing.code.common.DecodeHintType
from QRCode4cj import zxing.code.common.LuminanceSource
from QRCode4cj import zxing.code.common.Qrcoder4cjReaderException
from QRCode4cj import zxing.code.common.Result
from QRCode4cj import zxing.code.common.ResultMetadataType
from QRCode4cj import zxing.code.common.HybridBinarizer
from QRCode4cj import zxing.code.multi.MultipleBarcodeReader
from QRCode4cj import zxing.code.pdf417.common.PDF417ResultMetadata
from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.pdf417.PDF417Reader
from std import fs.*
from std import log.*
from std import collection.*
from charset import charset.tools.UTF32String
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = PDF417BlackBox4TestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * This class tests Macro PDF417 barcode specific functionality. It ensures that information, which is split into
 * several barcodes can be properly combined again to yield the original data content.
 *
 * @author Guenther Grau
 */
@Test
public open class PDF417BlackBox4TestCase {
    public var log: SimpleLogger = SimpleLogger()

    private let barcodeReader: MultipleBarcodeReader = PDF417Reader(2);

    private let testResults: ArrayList<TestResult> = ArrayList<TestResult>();

    public var testBase: Path = Path("");

    public let expectedFormat: BarcodeFormat = BarcodeFormat.PDF_417;

    public let namesuffix: Array<String> = [".jpg", ".jpeg", ".gif", ".png", ".JPG", ".JPEG", ".GIF", ".PNG"]

    public static func buildTestBase(testBasePathSuffix: String): Path {
        // A little workaround to prevent aggravation in my IDE
        var testBase: Path = Path(testBasePathSuffix)
        if (!Directory.exists(testBase)) {
            // try starting with 'core' since the test base is often given as the project root
            testBase = Path("core").join(testBasePathSuffix)
        }
        return testBase
    }

    @TestCase
    public func testBlackBox(): Unit {
        this.testBase = buildTestBase("./pdf417-4")

        testResults.append(TestResult(3, 3, 0, 0, 0.0));

        @Assert(testResults.isEmpty(),false)

        var imageFiles: HashMap<String, ArrayList<Path>> = getImageFileLists();
        var testCount: Int64 = testResults.size;

        var passedCounts: Array<Int64> = Array<Int64>(testCount, item: 0)
        var tryHarderCounts: Array<Int64> = Array<Int64>(testCount, item: 0)

        var testBase: Path = this.testBase;

        for (testImageGroup in imageFiles.keys()) {
            log.info("Starting Image Group ${testImageGroup}");

            var fileBaseName: String = testImageGroup
            var expectedText: String
            var expectedTextFile: Path = testBase.join(fileBaseName + ".txt");
            if (File.exists(expectedTextFile)) {
                expectedText = readFileAsString(expectedTextFile, StandardCharsets.UTF_8)
            } else {
                expectedTextFile = testBase.join(fileBaseName + ".bin")
                @Assert(File.exists(expectedTextFile),true)
                expectedText = readFileAsString(expectedTextFile, StandardCharsets.ISO_8859_1)
            }

            for (x in 0..testCount) {
                var results: ArrayList<Result> = ArrayList<Result>();
                for (imageFile in imageFiles[testImageGroup]) {
                    var image: Image
                    var opencvUtils: CvImageForZxing = CvImageForZxing()
                    image = opencvUtils.opencvReadImg(imageFile.toString())

                    var imageiop = image as ImageI
                    var imagei: ImageI = imageiop.getOrThrow()

                    var rotation: Float32 = testResults[x].getRotation();
                    var rotatedImage: ImageI = rotateImage(imagei, rotation);
                    var source: LuminanceSource = BufferedImageLuminanceSource(rotatedImage);
                    var bitmap: BinaryBitmap = BinaryBitmap(HybridBinarizer(source));

                    try {
                        results.appendAll(decode(bitmap, false));
                    } catch (ignored: Qrcoder4cjReaderException) {
                        // ignore
                    }
                }

                results.sortBy(
                    {a: Result, b: Result => getMeta(a).getSegmentIndex().compare(getMeta(b).getSegmentIndex())},
                    stable: true
                )
                var resultText: ArrayList<Char> = ArrayList<Char>();
                var fileId: String = "";
                for (result in results) {
                    var resultMetadata: PDF417ResultMetadata = getMeta(result);
                    @Assert(resultMetadata.flag)
                    if (fileId.isEmpty()) {
                        fileId = resultMetadata.getFileId()
                    }
                    @Assert(fileId, resultMetadata.getFileId())
                    resultText.appendAll(result.getText().toRuneArray());
                }
                @Assert(expectedText, String(resultText))
                passedCounts[x] += 1
                tryHarderCounts[x] += 1
            }
        }

        // Print the results of all tests first
        var totalFound: Int64 = 0;
        var totalMustPass: Int64 = 0;

        var numberOfTests: Int64 = imageFiles.keys().size;
        for (x in 0..testResults.size) {
            var testResult: TestResult = testResults[x]
            log.info("Rotation ${testResult.getRotation()} degrees:")
            log.info(
                " ${passedCounts[x]} of ${numberOfTests} images passed (${testResult.getMustPassCount()} required)");
            log.info(
                " ${tryHarderCounts[x]} of ${numberOfTests} images passed with try harder (${testResult.getTryHarderCount()} required)"
            );
            totalFound += passedCounts[x] + tryHarderCounts[x]
            totalMustPass += testResult.getMustPassCount() + testResult.getTryHarderCount()
        }

        var totalTests: Int64 = numberOfTests * testCount * 2
        log.info(
            "Decoded ${totalFound} images out of ${totalTests} (${totalFound * 100 / totalTests}, ${totalMustPass} required)"
        );
        if (totalFound > totalMustPass) {
            log.warn("+++ Test too lax by ${totalFound - totalMustPass} images");
        } else if (totalFound < totalMustPass) {
            log.warn("--- Test failed by ${totalMustPass - totalFound} images");
        }
        // Then run through again and assert if any failed
        for (x in 0..testCount) {
            var testResult: TestResult = testResults[x]
            var label: String = "Rotation " + testResult.getRotation().toString() + " degrees: Too many images failed"
            @Assert(passedCounts[x] >= testResult.getMustPassCount())
            @Assert(tryHarderCounts[x] >= testResult.getTryHarderCount())
        }
    }

    private static func getMeta(result: Result): PDF417ResultMetadata {
        if (result.getResultMetadata().size == 0) {
            return PDF417ResultMetadata()
        } else {
            return (result.getResultMetadata()[ResultMetadataType.PDF417_EXTRA_METADATA] as PDF417ResultMetadata).
                getOrThrow();
        }
    }

    func decode(source: BinaryBitmap, tryHarder: Bool): Array<Result> {
        var hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>();
        if (tryHarder) {
            hints.put(DecodeHintType.TRY_HARDER, true);
        }

        return barcodeReader.decodeMultiple(source, hints);
    }

    func getImageFileLists(): HashMap<String, ArrayList<Path>> {
        var result: HashMap<String, ArrayList<Path>> = HashMap<String, ArrayList<Path>>();
        for (file in getImageFiles()) {
            var testImageFileName: String = file.fileName.getOrThrow();
            var fileBaseName: String = UTF32String(testImageFileName).substring(
                0,
                testImageFileName.indexOf('-'.toString()).getOrThrow()
            ).toString();

            var files: ArrayList<Path>
            if (result.contains(fileBaseName)) {
                files = result[fileBaseName]
            } else {
                files = ArrayList<Path>()
            }
            files.append(file);
            result.put(fileBaseName, files);
        }
        return result
    }

    public func getImageFiles(): ArrayList<Path> {
        let src = "Please download and install test images, and run from the 'core' directory"
        if (!Directory.exists(testBase)) {
        }
        var paths = ArrayList<Path>();

        let dir: Directory = Directory(testBase)
        let data: ArrayList<FileInfo> = dir.entryList()
        for (one in data) {
            for (suffix in namesuffix) {
                if (one.path.toString().count(suffix) > 0) {
                    paths.append(one.path);
                }
            }
        }

        return paths
    }

    public func readFileAsString(filePath: Path, charset: MyCharset): String {
        var file: File = File(filePath, OpenOption.Open(true, false));

        var buffer: Array<UInt8> = Array<UInt8>(file.length, item: 0)
        var charsize: Int64 = file.read(buffer)
        if (charsize == 0) {
            log.info(
                "String contents of file ${filePath} end with a newline. " +
                    "This may not be intended and cause a test failure"
            );
        }
        var stringContents: String = charset.newDecoder().decode(buffer)
        if (stringContents.endsWith("\n")) {
            log.info(
                "String contents of file ${filePath} end with a newline. " +
                    "This may not be intended and cause a test failure"
            );
        }

        return stringContents
    }

    public func rotateImage(original: ImageI, degrees: Float32): ImageI {
        if (degrees == 0.0) {
            return original
        }

        return AbstractBlackBoxTestCase.selfrotate(original, Int64(degrees))
    }
}
