// DEPENDENCE: ../common/abstract_negative_black_box_test_case.cj
// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/falsepositives
// EXEC: cjc %import-path %L %l %f ./abstract_negative_black_box_test_case.cj ./test_result.cj ./test_common.cj ./abstract_back_box_test_case.cj
// EXEC: ./main


import std.unittest.*
import std.unittest.testmacro.*
import QRCode4cj.tools.UTF32String
import std.collection.*
import QRCode4cj.multi.qrcode.QRCodeMultiReader
import QRCode4cj.multi.*

main(): Int64 {
    let tester = FalsePositivesBlackBoxTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class FalsePositivesBlackBoxTestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractNegativeBlackBoxTestCase = AbstractNegativeBlackBoxTestCase(
            "./falsepositives");
        abs.addTest(2, 0.0);
        abs.addTest(2, 90.0);
        abs.addTest(2, 180.0);
        abs.addTest(2, 270.0);
        abs.testBlackBox();
    }
}
