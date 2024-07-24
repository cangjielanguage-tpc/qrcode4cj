// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/qrcode-2
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
 import QRCode4cj.common.reader.MultiFormatReader
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*

main(): Int64 {
    let tester = QRCodeBlackBox2TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class QRCodeBlackBox2TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./qrcode-2",
            MultiFormatReader(),
            BarcodeFormat.QR_CODE
        );
        abs.addTest(31, 31, 0.0f32);
        abs.addTest(29, 29, 90.0f32);
        abs.addTest(30, 30, 180.0f32);
        abs.addTest(30, 30, 270.0f32);
        abs.testBlackBox();
    }
}
