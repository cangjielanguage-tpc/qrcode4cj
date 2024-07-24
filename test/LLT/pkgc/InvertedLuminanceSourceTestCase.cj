// DEPENDENCE: ../test_common.cj
// DEPENDENCE: ./common/abstract_back_box_test_case.cj
// DEPENDENCE: ./common/test_result.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import QRCode4cj.common.*

main(): Int64 {
    let tester = InvertedLuminanceSourceTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}


/**
 * Tests {@link InvertedLuminanceSource}.
 */
@Test
public class InvertedLuminanceSourceTestCase {
    @TestCase
    public func testInverted(): Unit {
        var image: RGBA_p = RGBA_p(Rectangle_p(Point(0, 0), Point(2, 1)))
        image.set(0, 0, RGBAC(0xFF, 0xFF, 0xFF, 0xFF));
        image.set(1, 0, RGBAC(0x00, 0x00, 0x00, 0xFF));

        var source: LuminanceSource = BufferedImageLuminanceSource(image)
        @Assert([UInt8(0xFF), 0], source.getRow(0, 0))
        var inverted: LuminanceSource = InvertedLuminanceSource(source)
        @Assert([0, UInt8(0xFF)], inverted.getRow(0, 0))
    }
}
