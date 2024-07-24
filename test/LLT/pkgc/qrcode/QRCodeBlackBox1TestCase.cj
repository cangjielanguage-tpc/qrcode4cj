// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/qrcode-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
 import QRCode4cj.common.reader.MultiFormatReader
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*

main(): Int64 {
    let tester = QRCodeBlackBox1TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class QRCodeBlackBox1TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./qrcode-1",
            MultiFormatReader(),
            BarcodeFormat.QR_CODE
        );
        abs.addTest(17, 17, 0.0f32);
        abs.addTest(14, 14, 90.0f32);
        abs.addTest(17, 17, 180.0f32);
        abs.addTest(14, 14, 270.0f32);
        abs.testBlackBox();
    }
}
