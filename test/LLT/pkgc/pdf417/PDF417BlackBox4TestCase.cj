// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/pdf417-4
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main


import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.BinaryBitmap
import QRCode4cj.common.DecodeHintType
import QRCode4cj.common.LuminanceSource
import QRCode4cj.common.Qrcoder4cjReaderException
import QRCode4cj.common.Result
import QRCode4cj.common.ResultMetadataType
import QRCode4cj.common.HybridBinarizer
import QRCode4cj.multi.MultipleBarcodeReader
import QRCode4cj.pdf417.common.PDF417ResultMetadata
import QRCode4cj.common.*
import QRCode4cj.pdf417.PDF417Reader
import std.fs.*
import std.log.*
import std.collection.*
import QRCode4cj.tools.UTF32String
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = PDF417BlackBox4TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class PDF417BlackBox4TestCase {
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
                    stable: true,
                    comparator: {a: Result, b: Result => getMeta(a).getSegmentIndex().compare(getMeta(b).getSegmentIndex())}
                )
                var resultText: ArrayList<Rune> = ArrayList<Rune>();
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
