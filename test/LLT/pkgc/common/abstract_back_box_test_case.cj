import std.convert.*
import std.fs.*
import std.log.*
import std.os.posix.*

import QRCode4cj.common.*
import std.unittest.*
import std.unittest.testmacro.*
import std.fs.*
import std.time.*
import std.collection.*
import std.math.*
import std.convert.*
import std.log.*
import std.os.posix.*
import QRCode4cj.aztec.common.*

import QRCode4cj.common as common
import QRCode4cj.common.reader.MultiFormatReader
import QRCode4cj.common.writer.MultiFormatWriter

public open class AbstractBlackBoxTestCase {
    // private static let log: SimpleLogger = SimpleLogger.getLogger(AbstractBlackBoxTestCase);
    public var log: SimpleLogger = SimpleLogger()

    public let testBase: Path
    public let barcodeReader: common.Reader
    public let expectedFormat: BarcodeFormat
    public let namesuffix: Array<String> = [".jpg", ".jpeg", ".gif", ".png", ".JPG", ".JPEG", ".GIF", ".PNG"]
    public var testResults: ArrayList<TestResult>
    public var hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>()

    public static func buildTestBase(testBasePathSuffix: String): Path {
        // A little workaround to prevent aggravation in my IDE
        var testBase: Path = Path(testBasePathSuffix)
        if (!Directory.exists(testBase)) {
            // try starting with 'core' since the test base is often given as the project root
            testBase = Path("core").join(testBasePathSuffix)
        }
        return testBase
    }

    public init(testBasePathSuffix: String, barcodeReader: common.Reader, expectedFormat: BarcodeFormat) {
        this.testBase = buildTestBase(testBasePathSuffix)
        this.barcodeReader = barcodeReader
        this.expectedFormat = expectedFormat
        this.testResults = ArrayList<TestResult>()
    }

    public func getTestBase(): Path {
        return testBase
    }

    public func addTest(mustPassCount: Int64, tryHarderCount: Int64, rotation: Float32) {
        addTest(mustPassCount, tryHarderCount, 0, 0, rotation);
    }

    public func addHint(hint: DecodeHintType) {
        hints.put(hint, true);
    }

    /**
     * Adds a new test for the current directory of images.
     *
     * @param mustPassCount The number of images which must decode for the test to pass.
     * @param tryHarderCount The number of images which must pass using the try harder flag.
     * @param maxMisreads Maximum number of images which can fail due to successfully reading the wrong contents
     * @param maxTryHarderMisreads Maximum number of images which can fail due to successfully
     * reading the wrong contents using the try harder flag
     * @param rotation The rotation in degrees clockwise to use for this test.
     */
    public func addTest(
        mustPassCount: Int64,
        tryHarderCount: Int64,
        maxMisreads: Int64,
        maxTryHarderMisreads: Int64,
        rotation: Float32
    ) {
        testResults.append(TestResult(mustPassCount, tryHarderCount, maxMisreads, maxTryHarderMisreads, rotation));
    }

    public func getImageFiles(): ArrayList<Path> {
        let src = "Please download and install test images, and run from the 'core' directory"
        if (!Directory.exists(testBase)) {
            // @Expect(Directory.exists(testBase))
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

    public func getReader(): common.Reader {
        return barcodeReader
    }

    public static func selfrotate(src: ImageI, rotateAngle: Int64): ImageI {
        if (rotateAngle % 360 == 0) {
            return src
        }
        let bounds = src.bounds()
        let sW = bounds.dx()
        let sH = bounds.dy()
        var dst = Gray_p(Rectangle_p(0, 0, sW, sH))
        if (rotateAngle % 360 == 180) {
            for (y in 0..sH) {
                for (x in 0..sW) {
                    let colors: Color = src.at(sW - x - 1, sH - y - 1)
                    let (a1, a2, a3, a4) = colors.rgba();

                    if (a4 == 0) {
                        dst.setGray(x, y, GrayC(255))
                    } else {
                        if (src is RGBA_p) {
                            let colorRGB: Color = (src as RGBA_p).getOrThrow().rgbaAt(sW - x - 1, sH - y -
                                1)
                            let coloritem = (colorRGB as RGBAC).getOrThrow();
                            dst.set(
                                x,
                                y,
                                GrayC(
                                    UInt8((Int64(coloritem.r) * 306 + Int64(coloritem.g) * 601 + Int64(coloritem.b) * 117 +
                                            0x200) >> 10)
                                )
                            )
                        } else {
                            dst.set(x, y, colors)
                        }
                    }
                }
            }
            return dst
        } else if (rotateAngle % 360 == 90) {
            dst = Gray_p(Rectangle_p(0, 0, sH, sW))
            for (y in 0..sH) {
                for (x in 0..sW) {
                    let colors: Color = src.at(x, y)
                    let (a1, a2, a3, a4) = colors.rgba();

                    if (a4 == 0) {
                        dst.setGray(sH - y - 1, x, GrayC(255))
                    } else {
                        if (src is RGBA_p) {
                            let colorRGB: Color = (src as RGBA_p).getOrThrow().rgbaAt(x, y)
                            let coloritem = (colorRGB as RGBAC).getOrThrow();
                            dst.set(
                                sH - y - 1,
                                x,
                                GrayC(
                                    UInt8((Int64(coloritem.r) * 306 + Int64(coloritem.g) * 601 + Int64(coloritem.b) * 117 +
                                            0x200) >> 10)
                                )
                            )
                        } else {
                            dst.set(sH - y - 1, x, colors)
                        }
                    }
                }
            }

            return dst
        } else if (rotateAngle % 360 == 270) {
            dst = Gray_p(Rectangle_p(0, 0, sH, sW))
            for (y in 0..sH) {
                for (x in 0..sW) {
                    let colors: Color = src.at(x, y)
                    let (a1, a2, a3, a4) = colors.rgba();

                    if (a4 == 0) {
                        dst.setGray(y, sW - x - 1, GrayC(255))
                    } else {
                        if (src is RGBA_p) {
                            let colorRGB: Color = (src as RGBA_p).getOrThrow().rgbaAt(x, y)
                            let coloritem = (colorRGB as RGBAC).getOrThrow();
                            dst.set(
                                y,
                                sW - x - 1,
                                GrayC(
                                    UInt8((Int64(coloritem.r) * 306 + Int64(coloritem.g) * 601 + Int64(coloritem.b) * 117 +
                                            0x200) >> 10)
                                )
                            )
                        } else {
                            dst.set(y, sW - x - 1, colors)
                        }
                    }
                }
            }
            return dst
        } else {
            return rotate(src, rotateAngle)
        }
    }
    public func decode(
        source: BinaryBitmap,
        rotation: Float32,
        expectedText: String,
        expectedMetadata: HashMap<String, String>,
        tryHarder: Bool
    ): Bool {
        var suffix: String = ""
        if (tryHarder) {
            suffix = " (try harder, rotation: ${Int64(rotation)})"
        } else {
            suffix = " (rotation: ${Int64(rotation)})"
        }
        var hints: HashMap<DecodeHintType, Any> = this.hints.clone();
        if (tryHarder) {
            hints.put(DecodeHintType.TRY_HARDER, true);
        }

        // Try in 'pure' mode mostly to exercise PURE_BARCODE code paths for exceptions;
        // not expected to pass, generally
        var result: ?Result = None

        try {
            var pureHints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>(hints);

            pureHints.put(DecodeHintType.PURE_BARCODE, true)
            result = barcodeReader.decode(source, pureHints)
        } catch (re: Qrcoder4cjReaderException) {
            // continue
        }

        if (let None <- result) {
            result = barcodeReader.decode(source, hints)
        }

        if (expectedFormat != result.getOrThrow().getBarcodeFormat()) {
            log.info(
                "Format mismatch: expected '${expectedFormat}' but got '${result.getOrThrow().getBarcodeFormat()}'${suffix}"
            );
            return false;
        }

        var resultText: String = result.getOrThrow().getText();
        if (!(expectedText == (resultText))) {
            log.info("Content mismatch: expected '${expectedText}' but got '${resultText}'${suffix}")
            return false;
        }

        var resultMetadata: HashMap<ResultMetadataType, Any> = result.getOrThrow().getResultMetadata();
        for ((metadatumk, metadatumv) in expectedMetadata) {
            let rstype: ResultMetadataType = ResultMetadataType.OTHER
            var key: ResultMetadataType = rstype.valueOf(metadatumk)
            var expectedValue: String = metadatumv
            var actualValueAny: ?Any = None
            if (resultMetadata.size > 0) {
                actualValueAny = resultMetadata.get(key)
            }

            var actualValue: String = (actualValueAny as String).getOrThrow()

            if (!(expectedValue == (actualValue))) {
                log.info("Metadata mismatch for key '${key}': expected '${expectedValue}' but got '${actualValue}'");
                return false;
            }
        }

        return true;
    }

    public func readFileAsString(filePath: Path, charset: MyCharset): String {
        var file: File = File(filePath, OpenOption.Open(true, false));

        var buffer: Array<Byte> = Array<Byte>(file.length, item: b'\0')
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

        return selfrotate(original, Int64(degrees))
    }
    public open func testBlackBox(): Unit {
        log.level = LogLevel.ALL
        @Assert(testResults.isEmpty(),false)

        var imageFiles: ArrayList<Path> = getImageFiles();
        var testCount: Int64 = testResults.size;

        var passedCounts: Array<Int64> = Array<Int64>(testCount, item: 0)
        var misreadCounts: Array<Int64> = Array<Int64>(testCount, item: 0)
        var tryHarderCounts: Array<Int64> = Array<Int64>(testCount, item: 0)
        var tryHarderMisreadCounts: Array<Int64> = Array<Int64>(testCount, item: 0)

        for (testImage in imageFiles) {
            log.info("Starting ${testImage}")

            var image: Image
            var opencvUtils: CvImageForZxing = CvImageForZxing()
            image = opencvUtils.opencvReadImg(testImage.toString())

            var imageiop = image as ImageI
            var imagei: ImageI = imageiop.getOrThrow()

            // 判断图片格式并解析
            var testImageFileName: String = testImage.fileName.getOrThrow();
            let fileBaseName = testImageFileName[Range<Int64>(
                    0,
                    testImageFileName.indexOf('.'.toString()).getOrThrow(),
                    1,
                    true,
                    true,
                    false
                )]

            var expectedTextFile: Path = testBase.join(fileBaseName + ".txt");
            var expectedText: String
            if (File.exists(expectedTextFile)) {
                expectedText = readFileAsString(expectedTextFile, StandardCharsets.UTF_8)
            } else {
                expectedTextFile = testBase.join(fileBaseName + ".bin")
                @Assert(File.exists(expectedTextFile),true)
                expectedText = readFileAsString(expectedTextFile, StandardCharsets.ISO_8859_1)
            }

            let expectedMetadataFile: Path = testBase.join(fileBaseName + ".metadata.txt");
            var expectedMetadata: HashMap<String, String> = HashMap<String, String>();
            if (File.exists(expectedMetadataFile)) {
                var reader: Array<Byte> = File.openRead(expectedMetadataFile).readToEnd()
                var strkey: Array<String> = reader.toString().split("=")
                if (strkey.size == 2) {
                    expectedMetadata[strkey[0]] = strkey[1]
                }
            }

            for (x in 0..testCount) {
                // 图片旋转
                var rotation: Float32 = testResults.get(x).getOrThrow().getRotation()

                var rotatedImage: ImageI = rotateImage(imagei, rotation)

                var source: LuminanceSource = BufferedImageLuminanceSource(rotatedImage);

                var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)

                var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer);

                try {
                    if (decode(bitmap, rotation, expectedText, expectedMetadata, false)) {
                        passedCounts[x] = passedCounts[x] + 1
                    } else {
                        misreadCounts[x] = misreadCounts[x] + 1
                    }
                } catch (ignored: Qrcoder4cjReaderException) {
                    log.info("could not read at rotation ${rotation}");
                }
                try {
                    if (decode(bitmap, rotation, expectedText, expectedMetadata, true)) {
                        tryHarderCounts[x] = tryHarderCounts[x] + 1
                    } else {
                        tryHarderMisreadCounts[x] = tryHarderMisreadCounts[x] + 1
                    }
                } catch (ignored: Qrcoder4cjReaderException) {
                    log.info("could not read at rotation ${rotation} w/TH");
                }
            }
        }

        // Print the results of all tests first
        var totalFound: Int64 = 0;
        var totalMustPass: Int64 = 0;
        var totalMisread: Int64 = 0;
        var totalMaxMisread: Int64 = 0;

        for (x in 0..testResults.size) {
            var testResult: TestResult = testResults.get(x).getOrThrow()
            log.info("Rotation ${Int64(testResult.getRotation())} degrees:")
            log.info(
                " ${passedCounts[x]} of ${imageFiles.size} images passed (${testResult.getMustPassCount()} required)")
            var failed: Int64 = imageFiles.size - passedCounts[x]
            log.info(" ${misreadCounts[x]} failed due to misreads, ${failed - misreadCounts[x]} not detected")
            log.info(
                " ${tryHarderCounts[x]} of ${imageFiles.size} images passed with try harder (${testResult.getTryHarderCount()} required)"
            );
            failed = imageFiles.size - tryHarderCounts[x]
            log.info(
                " ${tryHarderMisreadCounts[x]} failed due to misreads, ${failed - tryHarderMisreadCounts[x]} not detected"
            );
            totalFound += passedCounts[x] + tryHarderCounts[x]
            totalMustPass += testResult.getMustPassCount() + testResult.getTryHarderCount()
            totalMisread += misreadCounts[x] + tryHarderMisreadCounts[x]
            totalMaxMisread += testResult.getMaxMisreads() + testResult.getMaxTryHarderMisreads()
        }
        var totalTests: Int64 = imageFiles.size * testCount * 2
        log.info(
            "Decoded ${totalFound} images out of ${totalTests} (${totalFound * 100 / totalTests}%, ${totalMustPass} required)"
        );
        if (totalFound > totalMustPass) {
            log.warn("+++ Test too lax by ${ totalFound - totalMustPass} images")
        } else if (totalFound < totalMustPass) {
            log.warn("--- Test failed by ${totalMustPass - totalFound} images");
        }
        if (totalMisread < totalMaxMisread) {
            log.warn("+++ Test expects too many misreads by ${totalMaxMisread - totalMisread} images");
        } else if (totalMisread > totalMaxMisread) {
            log.warn("--- Test had too many misreads by ${totalMisread - totalMaxMisread} images");
        }
        // Then run through again and assert if any failed
        for (x in 0..testCount) {
            var testResult: TestResult = testResults.get(x).getOrThrow()
            var label = "Rotation ${testResult.getRotation()} degrees: Too many images failed"
            @Assert(
                 passedCounts[x] >= testResult.getMustPassCount())
            let label2 = "Try harder, ${label}"
            @Assert(
                 tryHarderCounts[x] >= testResult.getTryHarderCount())
            label = "Rotation ${testResult.getRotation()} degrees: Too many images misread"
            @Assert(
                 misreadCounts[x] <= testResult.getMaxMisreads())
            let label3 = "Try harder, ${label}"
            @Assert(
                 tryHarderMisreadCounts[x] <= testResult.getMaxTryHarderMisreads())
        }
    }
}
