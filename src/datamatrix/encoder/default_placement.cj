/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.datamatrix.encoder

import std.time.*

/**
 * Symbol Character Placement Program. Adapted from Annex M.1 in ISO/IEC 16022:2000(E).
 */
public open class DefaultPlacement {
    private let codewords: String
    private let numrows: Int64
    private let numcols: Int64
    private let bits: Array<UInt8>
    private let codewordsArray: Array<Rune>
    /**
     * Main constructor
     *
     * @param codewords the codewords to place
     * @param numcols   the number of columns
     * @param numrows   the number of rows
     */
    public init(codewords: String, numcols: Int64, numrows: Int64) {
        this.codewords = codewords
        this.codewordsArray = this.codewords.toRuneArray()
        this.numcols = numcols
        this.numrows = numrows
        this.bits = Array<UInt8>(numcols * numrows, repeat: 255)
    }

    public func getNumrows(): Int64 {
        return numrows
    }

    public func getNumcols(): Int64 {
        return numcols
    }

    public func getBits(): Array<UInt8> {
        return bits
    }

    public func getBit(col: Int64, row: Int64): Bool {
        return bits[row * numcols + col] == 1
    }

    private func setBit(col: Int64, row: Int64, bit: Bool) {
        if (bit) {
            bits[row * numcols + col] = 1
        } else {
            bits[row * numcols + col] = 0
        }
    }

    private func noBit(col: Int64, row: Int64): Bool {
        return bits[row * numcols + col] == 255
    }

    public func place() {
        var pos: Int64 = 0
        var row: Int64 = 4
        var col: Int64 = 0

        do {
            // repeatedly first check for one of the special corner cases, then...
            if ((row == numrows) && (col == 0)) {
                corner1(pos)
                pos++
            }
            if ((row == numrows - 2) && (col == 0) && ((numcols % 4) != 0)) {
                corner2(pos)
                pos++
            }
            if ((row == numrows - 2) && (col == 0) && (numcols % 8 == 4)) {
                corner3(pos)
                pos++
            }
            if ((row == numrows + 4) && (col == 2) && ((numcols % 8) == 0)) {
                corner4(pos)
                pos++
            }

            /* sweep upward diagonally, inserting successive characters... */
            (row, col, pos) = explace2(row, col, pos)
            row++
            col += 3
            (row, col, pos) = explace(row, col, pos)

            row += 3
            col++
        // ...until the entire array is scanned
        } while ((row < numrows) || (col < numcols))

        /* Lastly, if the lower right-hand corner is untouched, fill in fixed pattern */
        if (noBit(numcols - 1, numrows - 1)) {
            setBit(numcols - 1, numrows - 1, true)
            setBit(numcols - 2, numrows - 2, true)
        }
    }
    func explace2(row: Int64, col: Int64, pos: Int64): (Int64, Int64, Int64) {
        var row_p = row
        var col_p = col
        var pos_p = pos
        do {
            if ((row_p < numrows) && (col_p >= 0) && noBit(col_p, row_p)) {
                utah(row_p, col_p, pos_p)
                pos_p++
            }
            row_p -= 2
            col_p += 2
        } while (row_p >= 0 && (col_p < numcols))
        return (row_p, col_p, pos_p)
    }

    func explace(row: Int64, col: Int64, pos: Int64): (Int64, Int64, Int64) {
        var row_p = row
        var col_p = col
        var pos_p = pos
        do {
            if ((row_p >= 0) && (col_p < numcols) && noBit(col_p, row_p)) {
                utah(row_p, col_p, pos_p)
                pos_p++
            }
            row_p += 2
            col_p -= 2
        } while ((row_p < numrows) && (col_p >= 0))
        return (row_p, col_p, pos_p)
    }

    private func module(row: Int64, col: Int64, pos: Int64, bit: Int64) {
        var rowt = row
        var colt = col
        if (rowt < 0) {
            rowt += numrows
            colt += 4 - ((numrows + 4) % 8)
        }
        if (colt < 0) {
            colt += numcols
            rowt += 4 - ((numcols + 4) % 8)
        }

        var v: Int64 = codewordsArray[pos].hashCode()

        v &= 1 << (8 - bit)
        setBit(colt, rowt, v != 0)
    }

    /**
     * Places the 8 bits of a utah-shaped symbol character in ECC200.
     *
     * @param row the row
     * @param col the column
     * @param pos character position
     */
    private func utah(row_: Int64, col: Int64, pos: Int64) {
        module(row_ - 2, col - 2, pos, 1)
        module(row_ - 2, col - 1, pos, 2)
        module(row_ - 1, col - 2, pos, 3)
        module(row_ - 1, col - 1, pos, 4)
        module(row_ - 1, col, pos, 5)
        module(row_, col - 2, pos, 6)
        module(row_, col - 1, pos, 7)
        module(row_, col, pos, 8)
    }

    private func corner1(pos_: Int64) {
        module(numrows - 1, 0, pos_, 1)
        module(numrows - 1, 1, pos_, 2)
        module(numrows - 1, 2, pos_, 3)
        module(0, numcols - 2, pos_, 4)
        module(0, numcols - 1, pos_, 5)
        module(1, numcols - 1, pos_, 6)
        module(2, numcols - 1, pos_, 7)
        module(3, numcols - 1, pos_, 8)
    }

    private func corner2(pos_: Int64) {
        module(numrows - 3, 0, pos_, 1)
        module(numrows - 2, 0, pos_, 2)
        module(numrows - 1, 0, pos_, 3)
        module(0, numcols - 4, pos_, 4)
        module(0, numcols - 3, pos_, 5)
        module(0, numcols - 2, pos_, 6)
        module(0, numcols - 1, pos_, 7)
        module(1, numcols - 1, pos_, 8)
    }

    private func corner3(pos_: Int64) {
        module(numrows - 3, 0, pos_, 1)
        module(numrows - 2, 0, pos_, 2)
        module(numrows - 1, 0, pos_, 3)
        module(0, numcols - 2, pos_, 4)
        module(0, numcols - 1, pos_, 5)
        module(1, numcols - 1, pos_, 6)
        module(2, numcols - 1, pos_, 7)
        module(3, numcols - 1, pos_, 8)
    }

    private func corner4(pos_: Int64) {
        module(numrows - 1, 0, pos_, 1)
        module(numrows - 1, numcols - 1, pos_, 2)
        module(0, numcols - 3, pos_, 3)
        module(0, numcols - 2, pos_, 4)
        module(0, numcols - 1, pos_, 5)
        module(1, numcols - 3, pos_, 6)
        module(1, numcols - 2, pos_, 7)
        module(1, numcols - 1, pos_, 8)
    }
}
