// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/pdf417-2
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main


import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.reader.MultiFormatReader
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = PDF417BlackBox2TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class PDF417BlackBox2TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./pdf417-2",
            MultiFormatReader(),
            BarcodeFormat.PDF_417
        );
        abs.addTest(25, 25, 0, 0, 0.0);
        abs.addTest(25, 25, 0, 0, 180.0);
    }
}
