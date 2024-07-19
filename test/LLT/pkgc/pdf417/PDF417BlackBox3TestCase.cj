// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/qrcode-3
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main


import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.reader.MultiFormatReader
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = PDF417BlackBox3TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link PDF417Reader} against more sample images.
 */
@Test
public class PDF417BlackBox3TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./qrcode-3",
            MultiFormatReader(),
            BarcodeFormat.QR_CODE
        );
        abs.addTest(19, 19, 0, 0, 0.0);
        abs.addTest(19, 19, 0, 0, 180.0);
    }
}
