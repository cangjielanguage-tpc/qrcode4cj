/*
 * Copyright 2007 ZXing authors
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

// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import zxing.code.common.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import math.*
from std import format.*
from std import collection.*
from charset import charset.tools.UTF32String

main(): Int64 {
    let tester = BitMatrixTestCaseT()
    tester.execute()
    tester.printResult()
    0
}

public class BitMatrixTestCase {
    public static let BIT_MATRIX_POINTS = [1, 2, 2, 0, 3, 1]

    public static func matrixToString(result: BitMatrix): String {
        @Assert(1, result.getHeight())
        var builder: StringBuilder = StringBuilder();
        for (i in 0..result.getWidth()) {
            builder.append(
                if (result.get(i, 0)) {
                    "1"
                } else {
                    "0"
                }
            );
        }
        return builder.toString();
    }

    public static func testXOR(dataMatrix: BitMatrix, flipMatrix: BitMatrix, expectedMatrix: BitMatrix) {
        var matrix: BitMatrix = dataMatrix.clone();
        matrix.xor(flipMatrix);

        assertEqual("expectedMatrix", "matrix", expectedMatrix, matrix)
    }

    public static func testRotate180(width: Int64, height: Int64) {
        var input: BitMatrix = getInput(width, height);
        input.rotate180();
        var expected: BitMatrix = getExpected(width, height);

        for (y in 0..height) {
            for (x in 0..width) {
                @Assert(expected.get(x, y), input.get(x, y))
            }
        }
    }

    private static func getExpected(width: Int64, height: Int64): BitMatrix {
        var result: BitMatrix = BitMatrix(width, height);

        var i: Int64 = 0;
        while (i < BIT_MATRIX_POINTS.size) {
            result.set(width - 1 - BIT_MATRIX_POINTS[i], height - 1 - BIT_MATRIX_POINTS[i + 1]);
            i += 2
        }
        return result
    }

    private static func getInput(width: Int64, height: Int64): BitMatrix {
        var result: BitMatrix = BitMatrix(width, height);

        var i: Int64 = 0;
        while (i < BIT_MATRIX_POINTS.size) {
            result.set(BIT_MATRIX_POINTS[i], BIT_MATRIX_POINTS[i + 1]);
            i += 2
        }
        return result
    }

    private static func arrayToString(data: Array<Int64>): String {
        var sb: StringBuilder = StringBuilder("{");

        for (i in 0..data.size) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append(data[i].format("X"))
        }
        return sb.append('}').toString();
    }
}

/**
 * @author Sean Owen
 * @author dswitkin@google.com (Daniel Switkin)
 */
@Test
public open class BitMatrixTestCaseT {
    @TestCase
    public func testGetSet(): Unit {
        var matrix: BitMatrix = BitMatrix(33);
        @Assert(33, matrix.getHeight())

        for (y in 0..33) {
            for (x in 0..33) {
                if (y * x % 3 == 0) {
                    matrix.set(x, y);
                }
            }
        }

        for (y in 0..33) {
            for (x in 0..33) {
                @Assert(y * x % 3 == 0, matrix.get(x, y))
            }
        }
    }

    @TestCase
    public func testSetRegion(): Unit {
        var matrix: BitMatrix = BitMatrix(5);
        matrix.setRegion(1, 1, 3, 3);

        for (y in 0..5) {
            for (x in 0..5) {
                @Assert(y >= 1 && y <= 3 && x >= 1 && x <= 3, matrix.get(x, y))
            }
        }
    }

    @TestCase
    public func testEnclosing(): Unit {
        var matrix: BitMatrix = BitMatrix(5);
        @Assert([],matrix.getEnclosingRectangle())
        matrix.setRegion(1, 1, 1, 1);
        @Assert([1, 1, 1, 1 ], matrix.getEnclosingRectangle())
        matrix.setRegion(1, 1, 3, 2);
        @Assert([1, 1, 3, 2 ], matrix.getEnclosingRectangle())
        matrix.setRegion(0, 0, 5, 5);
        @Assert([0, 0, 5, 5 ], matrix.getEnclosingRectangle())
    }

    @TestCase
    public func testOnBit(): Unit {
        var matrix: BitMatrix = BitMatrix(5);
        @Assert([],matrix.getTopLeftOnBit())
        @Assert([],matrix.getBottomRightOnBit())
        matrix.setRegion(1, 1, 1, 1);
        @Assert([ 1, 1 ], matrix.getTopLeftOnBit())
        @Assert([ 1, 1 ], matrix.getBottomRightOnBit())
        matrix.setRegion(1, 1, 3, 2);
        @Assert([ 1, 1 ], matrix.getTopLeftOnBit())
        @Assert([ 3, 2 ], matrix.getBottomRightOnBit())
        matrix.setRegion(0, 0, 5, 5);
        @Assert([ 0, 0 ], matrix.getTopLeftOnBit())
        @Assert([ 4, 4 ], matrix.getBottomRightOnBit())
    }

    @TestCase
    public func testRectangularMatrix(): Unit {
        var matrix: BitMatrix = BitMatrix(75, 20);
        @Assert(75, matrix.getWidth())
        @Assert(20, matrix.getHeight())
        matrix.set(10, 0);
        matrix.set(11, 1);
        matrix.set(50, 2);
        matrix.set(51, 3);
        matrix.flip(74, 4);
        matrix.flip(0, 5);

        // Should all be on
        @Assert(matrix.get(10, 0))
        @Assert(matrix.get(11, 1))
        @Assert(matrix.get(50, 2))
        @Assert(matrix.get(51, 3))
        @Assert(matrix.get(74, 4))
        @Assert(matrix.get(0, 5))

        // Flip a couple back off
        matrix.flip(50, 2);
        matrix.flip(51, 3);
        @Assert(false,matrix.get(50, 2))
        @Assert(false,matrix.get(51, 3))
    }

    @TestCase
    public func testRectangularSetRegion(): Unit {
        var matrix: BitMatrix = BitMatrix(320, 240);
        @Assert(320, matrix.getWidth())
        @Assert(240, matrix.getHeight())
        matrix.setRegion(105, 22, 80, 12);

        // Only bits in the region should be on
        for (y in 0..240) {
            for (x in 0..320) {
                @Assert(y >= 22 && y < 34 && x >= 105 && x < 185, matrix.get(x, y))
            }
        }
    }

    @TestCase
    public func testGetRow(): Unit {
        var matrix: BitMatrix = BitMatrix(102, 5);

        for (x in 0..102) {
            if ((x & 0x03) == 0) {
                matrix.set(x, 2);
            }
        }

        // Should allocate
        var array: BitArray = matrix.getRow(2, BitArray());
        @Assert(102, array.getSize())

        // Should reallocate
        var array2: BitArray = BitArray(60);
        array2 = matrix.getRow(2, array2)
        @Assert(102, array2.getSize())

        // Should use provided object, with original BitArray size
        var array3: BitArray = BitArray(200);
        array3 = matrix.getRow(2, array3)
        @Assert(200, array3.getSize())

        for (x in 0..102) {
            var flag: Bool = (x & 0x03) == 0

            @Assert(flag, array.get(x))
            @Assert(flag, array2.get(x))
            @Assert(flag, array3.get(x))
        }
    }

    @TestCase
    public func testRotate90Simple(): Unit {
        var matrix: BitMatrix = BitMatrix(3, 3);
        matrix.set(0, 0);
        matrix.set(0, 1);
        matrix.set(1, 2);
        matrix.set(2, 1);

        matrix.rotate90();

        @Assert(matrix.get(0, 2))
        @Assert(matrix.get(1, 2))
        @Assert(matrix.get(2, 1))
        @Assert(matrix.get(1, 0))
    }

    @TestCase
    public func testRotate180Simple(): Unit {
        var matrix: BitMatrix = BitMatrix(3, 3);
        matrix.set(0, 0);
        matrix.set(0, 1);
        matrix.set(1, 2);
        matrix.set(2, 1);

        matrix.rotate180();

        @Assert(matrix.get(2, 2))
        @Assert(matrix.get(2, 1))
        @Assert(matrix.get(1, 0))
        @Assert(matrix.get(0, 1))
    }

    @TestCase
    public func testRotate180(): Unit {
        BitMatrixTestCase.testRotate180(7, 4);
        BitMatrixTestCase.testRotate180(7, 5);
        BitMatrixTestCase.testRotate180(8, 4);
        BitMatrixTestCase.testRotate180(8, 5);
    }

    @TestCase
    public func testParse(): Unit {
        var emptyMatrix: BitMatrix = BitMatrix(3, 3);
        var fullMatrix: BitMatrix = BitMatrix(3, 3);
        fullMatrix.setRegion(0, 0, 3, 3);
        var centerMatrix: BitMatrix = BitMatrix(3, 3);
        centerMatrix.setRegion(1, 1, 1, 1);
        var emptyMatrix24: BitMatrix = BitMatrix(2, 4);

        @Assert(emptyMatrix, BitMatrix.parse(UTF32String("   \n   \n   \n"), UTF32String("x"), UTF32String(" ")))
        @Assert(emptyMatrix, BitMatrix.parse(UTF32String("   \n   \r\r\n   \n\r"), UTF32String("x"), UTF32String(" ")))
        @Assert(emptyMatrix, BitMatrix.parse(UTF32String("   \n   \n   "), UTF32String("x"), UTF32String(" ")))

        @Assert(fullMatrix, BitMatrix.parse(UTF32String("xxx\nxxx\nxxx\n"), UTF32String("x"), UTF32String(" ")))

        @Assert(centerMatrix, BitMatrix.parse(UTF32String("   \n x \n   \n"), UTF32String("x"), UTF32String(" ")))
        @Assert(centerMatrix, BitMatrix.parse(UTF32String("      \n  x   \n      \n"), UTF32String("x "), UTF32String("  ")))
        try {
            @Assert(centerMatrix, BitMatrix.parse(UTF32String("   \n xy\n   \n"), UTF32String("x"), UTF32String(" ")))
        } catch (ex: IllegalArgumentException) {
            // good
        }
        @Assert(emptyMatrix24, BitMatrix.parse(UTF32String("  \n  \n  \n  \n"), UTF32String("x"), UTF32String(" ")))

        @Assert(centerMatrix, BitMatrix.parse(UTF32String(centerMatrix.toString("x", ".")), UTF32String("x"), UTF32String(".")))
    }

    @TestCase
    public func testParseBoolean(): Unit {
        var emptyMatrix: BitMatrix = BitMatrix(3, 3);
        var fullMatrix: BitMatrix = BitMatrix(3, 3);
        fullMatrix.setRegion(0, 0, 3, 3);
        var centerMatrix: BitMatrix = BitMatrix(3, 3);
        centerMatrix.setRegion(1, 1, 1, 1);

        var matrix: Array<Array<Bool>> = Array<Array<Bool>>(3, {n => Array<Bool>(3, item: false)});
        @Assert(emptyMatrix, BitMatrix.parse(matrix))
        matrix[1][1] = true
        @Assert(centerMatrix, BitMatrix.parse(matrix))

        matrix = Array<Array<Bool>>(3, {n => Array<Bool>(3, item: true)})
        @Assert(fullMatrix, BitMatrix.parse(matrix))
    }

    @TestCase
    public func testUnset(): Unit {
        var emptyMatrix: BitMatrix = BitMatrix(3, 3);
        var matrix: BitMatrix = emptyMatrix.clone();
        matrix.set(1, 1);
        @Assert(emptyMatrix!=matrix)

        matrix.unset(1, 1);
        @Assert(emptyMatrix, matrix)
        matrix.unset(1, 1);
        @Assert(emptyMatrix, matrix)
    }

    @TestCase
    public func testXOR(): Unit {
        var emptyMatrix: BitMatrix = BitMatrix(3, 3);
        var fullMatrix: BitMatrix = BitMatrix(3, 3);
        fullMatrix.setRegion(0, 0, 3, 3);
        var centerMatrix: BitMatrix = BitMatrix(3, 3);
        centerMatrix.setRegion(1, 1, 1, 1);
        var invertedCenterMatrix: BitMatrix = fullMatrix.clone();
        invertedCenterMatrix.unset(1, 1);
        var badMatrix: BitMatrix = BitMatrix(4, 4);

        BitMatrixTestCase.testXOR(emptyMatrix, emptyMatrix, emptyMatrix);
        BitMatrixTestCase.testXOR(emptyMatrix, centerMatrix, centerMatrix);
        BitMatrixTestCase.testXOR(emptyMatrix, fullMatrix, fullMatrix);

        BitMatrixTestCase.testXOR(centerMatrix, emptyMatrix, centerMatrix);
        BitMatrixTestCase.testXOR(centerMatrix, centerMatrix, emptyMatrix);
        BitMatrixTestCase.testXOR(centerMatrix, fullMatrix, invertedCenterMatrix);

        BitMatrixTestCase.testXOR(invertedCenterMatrix, emptyMatrix, invertedCenterMatrix);
        BitMatrixTestCase.testXOR(invertedCenterMatrix, centerMatrix, fullMatrix);
        BitMatrixTestCase.testXOR(invertedCenterMatrix, fullMatrix, centerMatrix);

        BitMatrixTestCase.testXOR(fullMatrix, emptyMatrix, fullMatrix);
        BitMatrixTestCase.testXOR(fullMatrix, centerMatrix, invertedCenterMatrix);
        BitMatrixTestCase.testXOR(fullMatrix, fullMatrix, emptyMatrix);

        try {
            emptyMatrix.clone().xor(badMatrix);
        } catch (ex: IllegalArgumentException) {
            // good
        }
        try {
            badMatrix.clone().xor(emptyMatrix);
        } catch (ex: IllegalArgumentException) {
            // good
        }
    }
}
