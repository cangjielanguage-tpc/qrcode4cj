// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/aztec-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.aztec.*
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*
import std.unittest.*
import std.unittest.testmacro.*

main(): Int64 {
    let tester = AztecBlackBox1TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class AztecBlackBox1TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./aztec-1",
            AztecReader(),
            BarcodeFormat.AZTEC
        )
        abs.addTest(14, 14, 0.0)
        abs.addTest(14, 14, 90.0)
        abs.addTest(14, 14, 180.0)
        abs.addTest(14, 14, 270.0)
        abs.testBlackBox()
    }
}
