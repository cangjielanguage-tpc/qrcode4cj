// DEPENDENCE: ../test_common.cj
// DEPENDENCE: ./199.png
// DEPENDENCE: ../pkgc/common/abstract_back_box_test_case.cj
// DEPENDENCE: ../pkgc/common/test_result.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.common.writer.*
import QRCode4cj.tools.UTF32String
import QRCode4cj.aztec.common.*

main(): Int64 {
    let tester = Tester()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class Tester {
    @TestCase
    func test(): Unit {
        var res = aztecDecode("./199.png");
        @Assert(true,res.toArray() == [11,106])
    }
}

public func aztecDecode(imagePath: String): String {
    var result = ""
    try {
        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(imagePath)

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        var source: LuminanceSource = BufferedImageLuminanceSource(imagei);

        var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)

        var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer);

        var hintType: DecodeHintType = DecodeHintType.TRY_HARDER;
        var hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>();
        hints.put(hintType, true);

        var reader: MultiFormatReader = MultiFormatReader();

        var a: Result = Result();
        a = reader.decode(bitmap, hints)
        result = a.getText()

    } catch (e: Exception) {
        e.printStackTrace()
        println("解码失败：" + e.toString());
    }
    return result;
}

