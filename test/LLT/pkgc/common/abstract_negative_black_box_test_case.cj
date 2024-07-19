import QRCode4cj.common.reader.*
import std.convert.*
import std.fs.*
import std.collection.*
import std.random.*
import std.log.*
import std.io.*
import QRCode4cj.tools.UTF32String
import QRCode4cj.common.*
import QRCode4cj.common.writer.*
import std.unittest.*
import std.unittest.testmacro.*

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

    //private let barcodeReader: common.Reader
    public init(testBasePathSuffix: String) {
        super(testBasePathSuffix, MultiFormatReader(), BarcodeFormat.NONE);
    }

    public init(testBasePathSuffix: String, barcodeReader: Reader, expectedFormat: BarcodeFormat) {
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
        } catch (re: Qrcoder4cjReaderException) {
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
        } catch (re: Qrcoder4cjReaderException) {
            // continue
        }
        return true;
    }
}
