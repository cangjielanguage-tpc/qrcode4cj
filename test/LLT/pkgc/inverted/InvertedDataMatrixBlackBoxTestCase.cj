// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/inverted
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
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
    let tester = InvertedDataMatrixBlackBoxTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Inverted barcodes
 */
@Test
public class InvertedDataMatrixBlackBoxTestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./inverted",
            MultiFormatReader(),
            BarcodeFormat.DATA_MATRIX
        );
        abs.addHint(DecodeHintType.ALSO_INVERTED);
        abs.addTest(1, 1, 0.0);
        abs.addTest(1, 1, 90.0);
        abs.addTest(1, 1, 180.0);
        abs.addTest(1, 1, 270.0);
        abs.testBlackBox();
    }
}
