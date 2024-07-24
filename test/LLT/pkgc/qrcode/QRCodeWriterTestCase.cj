// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/qrcode-6
// DEPENDENCE: ../../resources/golden/qrcode
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.reader.MultiFormatReader
import QRCode4cj.common.EncodeHintType
import QRCode4cj.common.Writer
import QRCode4cj.common.Qrcoder4cjWriterException
import QRCode4cj.common.BitMatrix
import QRCode4cj.qrcode.decoder.ErrorCorrectionLevel
import QRCode4cj.qrcode.QRCodeWriter
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*
import std.collection.*
import std.fs.*

main(): Int64 {
    let tester = QRCodeWriterTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

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
