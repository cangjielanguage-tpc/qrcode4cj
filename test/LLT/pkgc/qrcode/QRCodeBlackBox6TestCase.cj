// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/qrcode-6
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
 import QRCode4cj.common.reader.MultiFormatReader
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*

main(): Int64 {
    let tester = QRCodeBlackBox6TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * These tests are supplied by Tim Gernat and test finder pattern detection at small size and under
 * rotation, which was a weak spot.
 */
@Test
public class QRCodeBlackBox6TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./qrcode-6",
            MultiFormatReader(),
            BarcodeFormat.QR_CODE
        );
        abs.addTest(15, 15, 0.0f32);
        abs.addTest(14, 14, 90.0f32);
        abs.addTest(13, 13, 180.0f32);
        abs.addTest(14, 14, 270.0f32);
        abs.testBlackBox();
    }
}
