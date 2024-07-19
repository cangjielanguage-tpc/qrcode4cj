// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/datamatrix-3
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.common.reader.*
import QRCode4cj.common.*
import std.unittest.*
import std.unittest.testmacro.*
import QRCode4cj.tools.UTF32String


main(): Int64 {
    let tester = DataMatrixBlackBox3TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class DataMatrixBlackBox3TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./datamatrix-3",
            MultiFormatReader(),
            BarcodeFormat.DATA_MATRIX
        );

        abs.addTest(18, 18, 0.0);
        abs.addTest(17, 17, 90.0);
        abs.addTest(18, 18, 180.0);
        abs.addTest(18, 18, 270.0);
        abs.testBlackBox();
    }
}
