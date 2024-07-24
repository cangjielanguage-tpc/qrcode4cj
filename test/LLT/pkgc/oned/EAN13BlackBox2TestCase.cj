// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/ean13-2
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.tools.*
import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.oned.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.collection.*
import std.os.posix.*

main(): Int64 {
    let tester = EAN13BlackBox2TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class EAN13BlackBox2TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./ean13-2",
            MultiFormatReader(),
            BarcodeFormat.EAN_13
        )

        abs.addTest(12, 17, 0, 1, 0.0)
        abs.addTest(11, 17, 0, 1, 180.0)
        abs.testBlackBox()
    }
}
