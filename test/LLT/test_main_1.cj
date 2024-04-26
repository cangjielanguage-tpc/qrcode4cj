// DEPENDENCE: ./test_common.cj
// DEPENDENCE: ./pic/aztec-1.png
// DEPENDENCE: ./pkgc/common/abstract_back_box_test_case.cj
// DEPENDENCE: ./pkgc/common/test_result.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let tester = Tester()
    tester.execute()
    tester.printResult()
    0
}

@Test
public class Tester {
    @TestCase
    func t1(): Unit {
        var res = decode("./aztec-1.png", 1);
        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg("./aztec-1.png")
        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()
        var source: LuminanceSource = BufferedImageLuminanceSource(imagei);
        var bitmap: BinaryBitmap = BinaryBitmap(HybridBinarizer(source));
        bitmap.toString()
        @Assert("Code 2D!",res)
    }
}
