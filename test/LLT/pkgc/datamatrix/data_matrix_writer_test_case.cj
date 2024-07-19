// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/datamatrix-3
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
    let tester = DataMatrixWriterTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}


@Test
public class DataMatrixWriterTestCase {
    @TestCase
    public func testDataMatrixImageWriter(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.DATA_MATRIX_SHAPE, SymbolShapeHint.FORCE_SQUARE);

        let bigEnough = 64;
        let writer: DataMatrixWriter = DataMatrixWriter();
        let matrix: BitMatrix = writer.encode("Hello Google", BarcodeFormat.DATA_MATRIX, bigEnough, bigEnough, hints);
        @Assert(matrix.flag)
        @Assert(bigEnough >= matrix.getWidth())
        @Assert(bigEnough >= matrix.getHeight())
    }

    @TestCase
    public func testDataMatrixWriter(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.DATA_MATRIX_SHAPE, SymbolShapeHint.FORCE_SQUARE);

        let bigEnough = 14;
        let writer: DataMatrixWriter = DataMatrixWriter();
        let matrix: BitMatrix = writer.encode("Hello Me", BarcodeFormat.DATA_MATRIX, bigEnough, bigEnough, hints);
        @Assert(matrix.flag)
        @Assert(bigEnough, matrix.getWidth())
        @Assert(bigEnough, matrix.getHeight())
    }

    @TestCase
    public func testDataMatrixTooSmall(): Unit {
        // The DataMatrix will not fit in this size, so the matrix should come back bigger
        var tooSmall = 8;
        let writer: DataMatrixWriter = DataMatrixWriter();
        let matrix: BitMatrix = writer.encode(
            "http://www.google.com/",
            BarcodeFormat.DATA_MATRIX,
            tooSmall,
            tooSmall,
            HashMap<EncodeHintType, Any>()
        );
        @Assert(matrix.flag)
        @Assert(tooSmall < matrix.getWidth())
        @Assert(tooSmall < matrix.getHeight())
    }
}
