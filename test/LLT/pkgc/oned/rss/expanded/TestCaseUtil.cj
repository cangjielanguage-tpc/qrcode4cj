import std.regex.*
import std.collection.*
import std.convert.*
import std.fs.*
import std.log.*
import std.os.posix.*
import QRCode4cj.tools.UTF32String
import QRCode4cj.common.*
import std.unittest.*
import std.unittest.testmacro.*

class TestCaseUtil {
    private TestCaseUtil() {}

    private static func getBufferedImage(pathin: String, name: String): ImageI {
        var path = AbstractBlackBoxTestCase.buildTestBase(pathin).join(name)

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(path.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()
        return imagei
    }

    static func getBinaryBitmap(path: String, name: String): BinaryBitmap {
        var imagei: ImageI = getBufferedImage(path, name)
        var luminanceSource: BufferedImageLuminanceSource = BufferedImageLuminanceSource(imagei)

        var binaryMap: BinaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(luminanceSource))

        return binaryMap
    }
}
