/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/datamatrix-3
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import common.reader.*
from QRCode4cj import common.*
from QRCode4cj import datamatrix.encoder.SymbolShapeHint
from QRCode4cj import datamatrix.*
from std import unittest.*
from std import unittest.testmacro.*
from QRCode4cj import tools.UTF32String
from std import collection.*


main(): Int64 {
    let tester = DataMatrixWriterTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}


/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author dswitkin@google.com (Daniel Switkin) - ported and expanded from C++
 */
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
