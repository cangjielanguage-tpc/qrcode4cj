// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/upce-3
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
    let tester = UPCEBlackBox3ReflectiveTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}


@Test
public class UPCEBlackBox3ReflectiveTestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./upce-3",
            MultiFormatReader(),
            BarcodeFormat.UPC_E
        )

        abs.addTest(6, 8, 0.0)
        abs.addTest(6, 8, 180.0)
        abs.testBlackBox()
    }
}
