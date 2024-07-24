// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/maxicode-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.DecodeHintType
import QRCode4cj.common.reader.*
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*
import std.unittest.*
import std.unittest.testmacro.*

main(): Int64 {
    let tester = MaxiCodeBlackBox1TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class MaxiCodeBlackBox1TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./maxicode-1",
            MultiFormatReader(),
            BarcodeFormat.MAXICODE
        );
        abs.addHint(DecodeHintType.PURE_BARCODE)
        abs.addTest(7, 7, 0.0f32)

        abs.testBlackBox();
    }
}
