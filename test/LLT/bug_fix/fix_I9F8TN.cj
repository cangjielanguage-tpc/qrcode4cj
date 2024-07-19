// DEPENDENCE: ../test_common.cj
// DEPENDENCE: ../pkgc/common/abstract_back_box_test_case.cj
// DEPENDENCE: ../pkgc/common/test_result.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import std.unittest.*
import std.unittest.testmacro.*
import std.fs.*
import std.time.*
import std.collection.*
import std.convert.*
import std.log.*
import std.math.*
import std.os.posix.*
import QRCode4cj.aztec.common.*
import QRCode4cj.common.*
import QRCode4cj.common.writer.*
import QRCode4cj.common.reader.*

main(): Int64 {
    let tester = Tester()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class Tester {
    @TestCase
    func Tester01(): Unit {
        var content = "Google モバイル中文"
        var mfw = MultiFormatWriter();
        var encodeBitMatrix: BitMatrix
        encodeBitMatrix = mfw.encode(content, BarcodeFormat.QR_CODE, 120, 120)
        var binaryBitMap = bitMatrixToBinaryBitmap(encodeBitMatrix, encodeBitMatrix.getWidth(),
            encodeBitMatrix.getHeight())
        var mfr = MultiFormatReader()
        var deRe = ""
        var hints_DE = HashMap<DecodeHintType, Any>()
        hints_DE.put(DecodeHintType.TRY_HARDER, true)
        deRe = mfr.decode(binaryBitMap, hints_DE).getText()
        @Assert(deRe,content)
    }
}

public func bitMatrixToBinaryBitmap(bitMatrix: BitMatrix, width: Int64, height: Int64): BinaryBitmap {
    var image = Gray_p(Rectangle_p(0, 0, width, height))
    for (y in 0..height) {
        for (x in 0..width) {
            var gryc: GrayC
            if (bitMatrix.get(x, y)) {
                gryc = GrayC(0)
            } else {
                gryc = GrayC(255)
            }

            var colors: GrayC = (grayModel(gryc) as GrayC).getOrThrow()
            image.setGray(x, y, colors)
        }
    }
    var imageiop = image as ImageI
    var imagei: ImageI = imageiop.getOrThrow()
    var source: LuminanceSource = BufferedImageLuminanceSource(imagei)
    var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)
    var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer)
    return bitmap
}
