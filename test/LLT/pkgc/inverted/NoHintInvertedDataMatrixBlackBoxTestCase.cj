// DEPENDENCE: ../common/abstract_negative_black_box_test_case.cj
// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/inverted
// EXEC: cjc %import-path %L %l %f ./abstract_negative_black_box_test_case.cj ./test_result.cj ./test_common.cj ./abstract_back_box_test_case.cj
// EXEC: ./main

import QRCode4cj.common.reader.*
import QRCode4cj.common.*
import QRCode4cj.datamatrix.encoder.SymbolShapeHint
import QRCode4cj.datamatrix.*
import std.unittest.*
import std.unittest.testmacro.*
import QRCode4cj.tools.UTF32String
import std.collection.*


main(): Int64 {
    let tester = NoHintInvertedDataMatrixBlackBoxTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Without hint inverted barcodes should not be found.
 */
@Test
public class NoHintInvertedDataMatrixBlackBoxTestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractNegativeBlackBoxTestCase = AbstractNegativeBlackBoxTestCase(
            "./inverted", MultiFormatReader(), BarcodeFormat.DATA_MATRIX);
        abs.addTest(0, 0.0);
        abs.addTest(0, 90.0);
        abs.addTest(0, 180.0);
        abs.addTest(0, 270.0);
        abs.testBlackBox();
    }
}
