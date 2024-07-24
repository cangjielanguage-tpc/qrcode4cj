// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/qrcode-5
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
 import QRCode4cj.common.reader.MultiFormatReader
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*

main(): Int64 {
    let tester = QRCodeBlackBox5TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class QRCodeBlackBox5TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./qrcode-5",
            MultiFormatReader(),
            BarcodeFormat.QR_CODE
        );
        abs.addTest(19, 19, 0.0f32);
        abs.addTest(19, 19, 90.0f32);
        abs.addTest(19, 19, 180.0f32);
        abs.addTest(19, 19, 270.0f32);
        abs.testBlackBox();
    }
}
