// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.*
import QRCode4cj.qrcode.encoder.*
import QRCode4cj.qrcode.decoder.Mode
import QRCode4cj.qrcode.*
import QRCode4cj.qrcode.decoder.ErrorCorrectionLevel
import QRCode4cj.tools.UTF32String
import QRCode4cj.qrcode.decoder.Version
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*
import std.regex.*
import std.io.*

main(): Int64 {
    let tester = MaskUtilTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class MaskUtilTestCase {
    @TestCase
    public func testApplyMaskPenaltyRule1(): Unit {
        var matrix: ByteMatrix = ByteMatrix(4, 1);
        matrix.set(0, 0, 0);
        matrix.set(1, 0, 0);
        matrix.set(2, 0, 0);
        matrix.set(3, 0, 0);
        @Assert(0, MaskUtil.applyMaskPenaltyRule1(matrix))

        // Horizontal.
        matrix = ByteMatrix(6, 1)
        matrix.set(0, 0, 0);
        matrix.set(1, 0, 0);
        matrix.set(2, 0, 0);
        matrix.set(3, 0, 0);
        matrix.set(4, 0, 0);
        matrix.set(5, 0, 1);
        @Assert(3, MaskUtil.applyMaskPenaltyRule1(matrix))
        matrix.set(5, 0, 0);
        @Assert(4, MaskUtil.applyMaskPenaltyRule1(matrix))

        // Vertical.
        matrix = ByteMatrix(1, 6)
        matrix.set(0, 0, 0);
        matrix.set(0, 1, 0);
        matrix.set(0, 2, 0);
        matrix.set(0, 3, 0);
        matrix.set(0, 4, 0);
        matrix.set(0, 5, 1);
        @Assert(3, MaskUtil.applyMaskPenaltyRule1(matrix))
        matrix.set(0, 5, 0);
        @Assert(4, MaskUtil.applyMaskPenaltyRule1(matrix))
    }

    @TestCase
    public func testApplyMaskPenaltyRule2(): Unit {
        var matrix: ByteMatrix = ByteMatrix(1, 1);
        matrix.set(0, 0, 0);
        @Assert(0, MaskUtil.applyMaskPenaltyRule2(matrix))
        matrix = ByteMatrix(2, 2)
        matrix.set(0, 0, 0);
        matrix.set(1, 0, 0);
        matrix.set(0, 1, 0);
        matrix.set(1, 1, 1);
        @Assert(0, MaskUtil.applyMaskPenaltyRule2(matrix))
        matrix = ByteMatrix(2, 2)
        matrix.set(0, 0, 0);
        matrix.set(1, 0, 0);
        matrix.set(0, 1, 0);
        matrix.set(1, 1, 0);
        @Assert(3, MaskUtil.applyMaskPenaltyRule2(matrix))
        matrix = ByteMatrix(3, 3)
        matrix.set(0, 0, 0);
        matrix.set(1, 0, 0);
        matrix.set(2, 0, 0);
        matrix.set(0, 1, 0);
        matrix.set(1, 1, 0);
        matrix.set(2, 1, 0);
        matrix.set(0, 2, 0);
        matrix.set(1, 2, 0);
        matrix.set(2, 2, 0);

        // Four instances of 2x2 blocks.
        @Assert(3 * 4, MaskUtil.applyMaskPenaltyRule2(matrix))
    }

    @TestCase
    public func testApplyMaskPenaltyRule3(): Unit {
        // Horizontal 00001011101.
        var matrix: ByteMatrix = ByteMatrix(11, 1);
        matrix.set(0, 0, 0);
        matrix.set(1, 0, 0);
        matrix.set(2, 0, 0);
        matrix.set(3, 0, 0);
        matrix.set(4, 0, 1);
        matrix.set(5, 0, 0);
        matrix.set(6, 0, 1);
        matrix.set(7, 0, 1);
        matrix.set(8, 0, 1);
        matrix.set(9, 0, 0);
        matrix.set(10, 0, 1);
        @Assert(40, MaskUtil.applyMaskPenaltyRule3(matrix))

        // Horizontal 10111010000.
        matrix = ByteMatrix(11, 1)
        matrix.set(0, 0, 1);
        matrix.set(1, 0, 0);
        matrix.set(2, 0, 1);
        matrix.set(3, 0, 1);
        matrix.set(4, 0, 1);
        matrix.set(5, 0, 0);
        matrix.set(6, 0, 1);
        matrix.set(7, 0, 0);
        matrix.set(8, 0, 0);
        matrix.set(9, 0, 0);
        matrix.set(10, 0, 0);
        @Assert(40, MaskUtil.applyMaskPenaltyRule3(matrix))

        // Horizontal 1011101.
        matrix = ByteMatrix(7, 1)
        matrix.set(0, 0, 1);
        matrix.set(1, 0, 0);
        matrix.set(2, 0, 1);
        matrix.set(3, 0, 1);
        matrix.set(4, 0, 1);
        matrix.set(5, 0, 0);
        matrix.set(6, 0, 1);
        @Assert(0, MaskUtil.applyMaskPenaltyRule3(matrix))

        // Vertical 00001011101.
        matrix = ByteMatrix(1, 11)
        matrix.set(0, 0, 0);
        matrix.set(0, 1, 0);
        matrix.set(0, 2, 0);
        matrix.set(0, 3, 0);
        matrix.set(0, 4, 1);
        matrix.set(0, 5, 0);
        matrix.set(0, 6, 1);
        matrix.set(0, 7, 1);
        matrix.set(0, 8, 1);
        matrix.set(0, 9, 0);
        matrix.set(0, 10, 1);
        @Assert(40, MaskUtil.applyMaskPenaltyRule3(matrix))

        // Vertical 10111010000.
        matrix = ByteMatrix(1, 11)
        matrix.set(0, 0, 1);
        matrix.set(0, 1, 0);
        matrix.set(0, 2, 1);
        matrix.set(0, 3, 1);
        matrix.set(0, 4, 1);
        matrix.set(0, 5, 0);
        matrix.set(0, 6, 1);
        matrix.set(0, 7, 0);
        matrix.set(0, 8, 0);
        matrix.set(0, 9, 0);
        matrix.set(0, 10, 0);

        // Vertical 1011101.
        matrix = ByteMatrix(1, 7)
        matrix.set(0, 0, 1);
        matrix.set(0, 1, 0);
        matrix.set(0, 2, 1);
        matrix.set(0, 3, 1);
        matrix.set(0, 4, 1);
        matrix.set(0, 5, 0);
        matrix.set(0, 6, 1);
        @Assert(0, MaskUtil.applyMaskPenaltyRule3(matrix))
    }

    @TestCase
    public func testApplyMaskPenaltyRule4(): Unit {
        // Dark cell ratio = 0%
        var matrix: ByteMatrix = ByteMatrix(1, 1);
        matrix.set(0, 0, 0);
        @Assert(100, MaskUtil.applyMaskPenaltyRule4(matrix))

        // Dark cell ratio = 5%
        matrix = ByteMatrix(2, 1)
        matrix.set(0, 0, 0);
        matrix.set(0, 0, 1);
        @Assert(0, MaskUtil.applyMaskPenaltyRule4(matrix))

        // Dark cell ratio = 66.67%
        matrix = ByteMatrix(6, 1)
        matrix.set(0, 0, 0);
        matrix.set(1, 0, 1);
        matrix.set(2, 0, 1);
        matrix.set(3, 0, 1);
        matrix.set(4, 0, 1);
        matrix.set(5, 0, 0);
        @Assert(30, MaskUtil.applyMaskPenaltyRule4(matrix))
    }

    private static func testGetDataMaskBitInternal(maskPattern: Int64, expected: Array<Array<Int64>>): Bool {
        for (x in 0..6) {
            for (y in 0..6) {
                if ((expected[y][x] == 1) != MaskUtil.getDataMaskBit(maskPattern, x, y)) {
                    return false;
                }
            }
        }
        return true;
    }

    // See mask patterns on the page 43 of JISX0510:2004.
    @TestCase
    public func testGetDataMaskBit(): Unit {
        var mask0: Array<Array<Int64>> = [
            [1, 0, 1, 0, 1, 0],
            [0, 1, 0, 1, 0, 1],
            [1, 0, 1, 0, 1, 0],
            [0, 1, 0, 1, 0, 1],
            [1, 0, 1, 0, 1, 0],
            [0, 1, 0, 1, 0, 1]
        ]
        @Assert(true,testGetDataMaskBitInternal(0, mask0))
        var mask1: Array<Array<Int64>> = [
            [1, 1, 1, 1, 1, 1],
            [0, 0, 0, 0, 0, 0],
            [1, 1, 1, 1, 1, 1],
            [0, 0, 0, 0, 0, 0],
            [1, 1, 1, 1, 1, 1],
            [0, 0, 0, 0, 0, 0]
        ]
        @Assert(true,testGetDataMaskBitInternal(1, mask1))
        var mask2: Array<Array<Int64>> = [
            [1, 0, 0, 1, 0, 0],
            [1, 0, 0, 1, 0, 0],
            [1, 0, 0, 1, 0, 0],
            [1, 0, 0, 1, 0, 0],
            [1, 0, 0, 1, 0, 0],
            [1, 0, 0, 1, 0, 0]
        ]
        @Assert(true,testGetDataMaskBitInternal(2, mask2))
        var mask3: Array<Array<Int64>> = [
            [1, 0, 0, 1, 0, 0],
            [0, 0, 1, 0, 0, 1],
            [0, 1, 0, 0, 1, 0],
            [1, 0, 0, 1, 0, 0],
            [0, 0, 1, 0, 0, 1],
            [0, 1, 0, 0, 1, 0]
        ]
        @Assert(true,testGetDataMaskBitInternal(3, mask3))
        var mask4: Array<Array<Int64>> = [
            [1, 1, 1, 0, 0, 0],
            [1, 1, 1, 0, 0, 0],
            [0, 0, 0, 1, 1, 1],
            [0, 0, 0, 1, 1, 1],
            [1, 1, 1, 0, 0, 0],
            [1, 1, 1, 0, 0, 0]
        ]
        @Assert(true,testGetDataMaskBitInternal(4, mask4))
        var mask5: Array<Array<Int64>> = [
            [1, 1, 1, 1, 1, 1],
            [1, 0, 0, 0, 0, 0],
            [1, 0, 0, 1, 0, 0],
            [1, 0, 1, 0, 1, 0],
            [1, 0, 0, 1, 0, 0],
            [1, 0, 0, 0, 0, 0]
        ]
        @Assert(true,testGetDataMaskBitInternal(5, mask5))
        var mask6: Array<Array<Int64>> = [
            [1, 1, 1, 1, 1, 1],
            [1, 1, 1, 0, 0, 0],
            [1, 1, 0, 1, 1, 0],
            [1, 0, 1, 0, 1, 0],
            [1, 0, 1, 1, 0, 1],
            [1, 0, 0, 0, 1, 1]
        ]
        @Assert(true,testGetDataMaskBitInternal(6, mask6))
        var mask7: Array<Array<Int64>> = [
            [1, 0, 1, 0, 1, 0],
            [0, 0, 0, 1, 1, 1],
            [1, 0, 0, 0, 1, 1],
            [0, 1, 0, 1, 0, 1],
            [1, 1, 1, 0, 0, 0],
            [0, 1, 1, 1, 0, 0]
        ]
        @Assert(true,testGetDataMaskBitInternal(7, mask7))
    }
}
