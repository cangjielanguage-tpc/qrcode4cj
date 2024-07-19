// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/aztec-2
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.aztec.*
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*

main(): Int64 {
    let tester = AztecBlackBox2TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class AztecBlackBox2TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./aztec-2",
            AztecReader(),
            BarcodeFormat.AZTEC
        )
        abs.addTest(5, 5, 0.0)
        abs.addTest(4, 4, 90.0)
        abs.addTest(6, 6, 180.0)
        abs.addTest(3, 3, 270.0)
        abs.testBlackBox()
    }
}
