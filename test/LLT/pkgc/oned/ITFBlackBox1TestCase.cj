// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/itf-1
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
    let tester = ITFBlackBox1TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class ITFBlackBox1TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./itf-1",
            MultiFormatReader(),
            BarcodeFormat.ITF
        )
        abs.addTest(14, 14, 0.0)
        abs.addTest(14, 14, 180.0)
        abs.testBlackBox()
    }
}
