// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/datamatrix-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.reader.*
import QRCode4cj.common.*
import std.unittest.*
import std.unittest.testmacro.*
import QRCode4cj.tools.UTF32String


main(): Int64 {
    let tester = DataMatrixBlackBox1TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class DataMatrixBlackBox1TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./datamatrix-1",
            MultiFormatReader(),
            BarcodeFormat.DATA_MATRIX
        );
        abs.addTest(21, 21, 0.0);
        abs.addTest(21, 21, 90.0);
        abs.addTest(21, 21, 180.0);
        abs.addTest(21, 21, 270.0);
        abs.testBlackBox();
    }
}
