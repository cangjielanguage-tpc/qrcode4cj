/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.qrcode.encoder

from std import math.*

public class MaskUtil {
    private static let N1: Int64 = 3;
    private static let N2: Int64 = 3;
    private static let N3: Int64 = 40;
    private static let N4: Int64 = 10;

    private func MaskUtil() {
        // do nothing
    }

    /**
     * Apply mask penalty rule 1 and return the penalty. Find repetitive cells with the same color and
     * give penalty to them. Example: 00000 or 11111.
     */
    public static func applyMaskPenaltyRule1(matrix: ByteMatrix): Int64 {
        var a = applyMaskPenaltyRule1Internal(matrix, true) + applyMaskPenaltyRule1Internal(matrix, false)

        return a
    }

    /**
     * Apply mask penalty rule 2 and return the penalty. Find 2x2 blocks with the same color and give
     * penalty to them. This is actually equivalent to the spec's rule, which is to find MxN blocks and give a
     * penalty proportional to (M-1)x(N-1), because this is the number of 2x2 blocks inside such a block.
     */
    public static func applyMaskPenaltyRule2(matrix: ByteMatrix): Int64 {
        var penalty_: Int64 = 0;
        var array: Array<Array<UInt8>> = matrix.getArray();
        var width: Int64 = matrix.getWidth();
        var height: Int64 = matrix.getHeight();
        for (y in 0..height - 1) {
            var arrayY: Array<UInt8> = array[y]
            for (x in 0..width - 1) {
                var value: UInt8 = arrayY[x]
                if (value == arrayY[x + 1] && value == array[y + 1][x] && value == array[y + 1][x + 1]) {
                    penalty_++
                }
            }
        }

        return N2 * penalty_
    }

    /**
     * Apply mask penalty rule 3 and return the penalty. Find consecutive runs of 1:1:3:1:1:4 starting with black
     * or 4:1:1:3:1:1 starting with white, and give penalty to them.  If we
     * find patterns like 000010111010000, we give penalty once.
     */
    public static func applyMaskPenaltyRule3(matrix: ByteMatrix): Int64 {
        var numPenalties: Int64 = 0;
        var array: Array<Array<UInt8>> = matrix.getArray();
        var width: Int64 = matrix.getWidth();
        var height: Int64 = matrix.getHeight();

        for (y in 0..height) {
            for (x in 0..width) {
                var arrayY: Array<UInt8> = array[y] // We can at least optimize this access
                if (x + 6 < width && arrayY[x] == 1 && arrayY[x + 1] == 0 && arrayY[x + 2] == 1 && arrayY[x + 3] == 1 &&
                    arrayY[x + 4] == 1 && arrayY[x + 5] == 0 && arrayY[x + 6] == 1 && (isWhiteHorizontal(
                    arrayY,
                    x - 4,
                    x
                ) || isWhiteHorizontal(arrayY, x + 7, x + 11))) {
                    numPenalties++
                }
                numPenalties = exapplyMaskPenaltyRule3(array, x, y, height, numPenalties)
            }
        }

        return numPenalties * N3
    }

    public static func exapplyMaskPenaltyRule3(array: Array<Array<UInt8>>, x: Int64, y: Int64, height: Int64,
        numPenalties: Int64): Int64 {
        var numPenalties_p = numPenalties
        if (y + 6 < height && array[y][x] == 1 && array[y + 1][x] == 0 && array[y + 2][x] == 1 && array[y + 3][x] == 1 &&
            array[y + 4][x] == 1 && array[y + 5][x] == 0 && array[y + 6][x] == 1 && (isWhiteVertical(array, x, y - 4, y) ||
            isWhiteVertical(array, x, y + 7, y + 11))) {
            numPenalties_p++
        }
        return numPenalties_p
    }

    private static func isWhiteHorizontal(rowArray: Array<UInt8>, start: Int64, to: Int64): Bool {
        if (start < 0 || rowArray.size < to) {
            return false;
        }

        for (i in start..to) {
            if (rowArray[i] == 1) {
                return false;
            }
        }
        return true;
    }

    private static func isWhiteVertical(array: Array<Array<UInt8>>, col: Int64, start: Int64, to: Int64): Bool {
        if (start < 0 || array.size < to) {
            return false
        }

        for (i_ in start..to) {
            if (array[i_][col] == 1) {
                return false
            }
        }
        return true
    }

    /**
     * Apply mask penalty rule 4 and return the penalty. Calculate the ratio of dark cells and give penalty
     * if the ratio is far from 50%. It gives 10 penalty for 5% distance.
     */
    public static func applyMaskPenaltyRule4(matrix: ByteMatrix): Int64 {
        var numDarkCells: Int64 = 0;
        var array: Array<Array<UInt8>> = matrix.getArray();
        var width: Int64 = matrix.getWidth();
        var height: Int64 = matrix.getHeight();

        for (y in 0..height) {
            var arrayY: Array<UInt8> = array[y]

            for (x in 0..width) {
                if (arrayY[x] == 1) {
                    numDarkCells++
                }
            }
        }
        var numTotalCells: Int64 = matrix.getHeight() * matrix.getWidth()
        var fivePercentVariances: Int64 = abs(numDarkCells * 2 - numTotalCells) * 10 / numTotalCells

        return fivePercentVariances * N4
    }

    /**
     * Return the mask bit for "getMaskPattern" at "x" and "y". See 8.8 of JISX0510:2004 for mask
     * pattern conditions.
     */
    public static func getDataMaskBit(maskPattern: Int64, x: Int64, y: Int64): Bool {
        var intermediate: Int64 = 0
        var temp: Int64
        match (maskPattern) {
            case 0 => intermediate = (y + x) & 0x1
            case 1 => intermediate = y & 0x1
            case 2 => intermediate = x % 3
            case 3 => intermediate = (y + x) % 3
            case 4 => intermediate = ((y / 2) + (x / 3)) & 0x1
            case 5 =>
                temp = y * x
                intermediate = (temp & 0x1) + (temp % 3)
            case 6 =>
                temp = y * x
                intermediate = ((temp & 0x1) + (temp % 3)) & 0x1
            case 7 =>
                temp = y * x
                intermediate = ((temp % 3) + ((y + x) & 0x1)) & 0x1
            case _ => throw IllegalArgumentException("Invalid mask pattern: " + maskPattern.toString());
        }
        return intermediate == 0
    }

    /**
     * Helper function for applyMaskPenaltyRule1. We need this for doing this calculation in both
     * vertical and horizontal orders respectively.
     */
    private static func applyMaskPenaltyRule1Internal(matrix: ByteMatrix, isHorizontal: Bool): Int64 {
        var penalty: Int64 = 0;

        var iLimit: Int64
        if (isHorizontal) {
            iLimit = matrix.getHeight()
        } else {
            iLimit = matrix.getWidth()
        }

        var jLimit: Int64
        if (isHorizontal) {
            jLimit = matrix.getWidth()
        } else {
            jLimit = matrix.getHeight()
        }

        var array: Array<Array<UInt8>> = matrix.getArray();

        for (i in 0..iLimit) {
            var numSameBitCells: Int64 = 0;
            var prevBit: UInt8 = 0;

            for (j in 0..jLimit) {
                var bit: UInt8
                if (isHorizontal) {
                    bit = array[i][j]
                } else {
                    bit = array[j][i]
                }

                if (bit == prevBit) {
                    numSameBitCells++
                } else {
                    if (numSameBitCells >= 5) {
                        penalty += N1 + (numSameBitCells - 5)
                    }
                    numSameBitCells = 1

                    // Include the cell itself.
                    prevBit = bit
                }
            }
            if (numSameBitCells >= 5) {
                penalty += N1 + (numSameBitCells - 5)
            }
        }

        return penalty
    }
}
