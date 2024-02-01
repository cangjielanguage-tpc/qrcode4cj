/*
 * Copyright 2006 Jeremias Maerki.
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

package zxing.code.datamatrix.encoder

from std import time.*

/**
 * Symbol Character Placement Program. Adapted from Annex M.1 in ISO/IEC 16022:2000(E).
 */
public open class DefaultPlacement {
    private let codewords: String
    private let numrows: Int64
    private let numcols: Int64
    private let bits: Array<UInt8>
    private let codewordsArray: Array<Char>
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
        this.bits = Array<UInt8>(numcols * numrows, item: 255)
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
        var pos: Int64 = 0;
        var row: Int64 = 4;
        var col: Int64 = 0;

        do {
            // repeatedly first check for one of the special corner cases, then...
            if ((row == numrows) && (col == 0)) {
                corner1(pos);
                pos++
            }
            if ((row == numrows - 2) && (col == 0) && ((numcols % 4) != 0)) {
                corner2(pos);
                pos++
            }
            if ((row == numrows - 2) && (col == 0) && (numcols % 8 == 4)) {
                corner3(pos);
                pos++
            }
            if ((row == numrows + 4) && (col == 2) && ((numcols % 8) == 0)) {
                corner4(pos);
                pos++
            }

            // sweep upward diagonally, inserting successive characters...
            do {
                if ((row < numrows) && (col >= 0) && noBit(col, row)) {
                    utah(row, col, pos);
                    pos++
                }
                row -= 2
                col += 2
            } while (row >= 0 && (col < numcols))
            row++
            col += 3

            // and then sweep downward diagonally, inserting successive characters, ...
            do {
                if ((row >= 0) && (col < numcols) && noBit(col, row)) {
                    utah(row, col, pos);
                    pos++
                }
                row += 2
                col -= 2
            } while ((row < numrows) && (col >= 0))
            row += 3
            col++
            // ...until the entire array is scanned
        } while ((row < numrows) || (col < numcols))

        // Lastly, if the lower right-hand corner is untouched, fill in fixed pattern
        if (noBit(numcols - 1, numrows - 1)) {
            setBit(numcols - 1, numrows - 1, true);
            setBit(numcols - 2, numrows - 2, true);
        }
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

        var v: Int64 = codewordsArray[pos].hashCode();

        v &= 1 << (8 - bit)
        setBit(colt, rowt, v != 0);
    }

    /**
     * Places the 8 bits of a utah-shaped symbol character in ECC200.
     *
     * @param row the row
     * @param col the column
     * @param pos character position
     */
    private func utah(row: Int64, col: Int64, pos: Int64) {
        module(row - 2, col - 2, pos, 1);
        module(row - 2, col - 1, pos, 2);
        module(row - 1, col - 2, pos, 3);
        module(row - 1, col - 1, pos, 4);
        module(row - 1, col, pos, 5);
        module(row, col - 2, pos, 6);
        module(row, col - 1, pos, 7);
        module(row, col, pos, 8);
    }

    private func corner1(pos: Int64) {
        module(numrows - 1, 0, pos, 1);
        module(numrows - 1, 1, pos, 2);
        module(numrows - 1, 2, pos, 3);
        module(0, numcols - 2, pos, 4);
        module(0, numcols - 1, pos, 5);
        module(1, numcols - 1, pos, 6);
        module(2, numcols - 1, pos, 7);
        module(3, numcols - 1, pos, 8);
    }

    private func corner2(pos: Int64) {
        module(numrows - 3, 0, pos, 1);
        module(numrows - 2, 0, pos, 2);
        module(numrows - 1, 0, pos, 3);
        module(0, numcols - 4, pos, 4);
        module(0, numcols - 3, pos, 5);
        module(0, numcols - 2, pos, 6);
        module(0, numcols - 1, pos, 7);
        module(1, numcols - 1, pos, 8);
    }

    private func corner3(pos: Int64) {
        module(numrows - 3, 0, pos, 1);
        module(numrows - 2, 0, pos, 2);
        module(numrows - 1, 0, pos, 3);
        module(0, numcols - 2, pos, 4);
        module(0, numcols - 1, pos, 5);
        module(1, numcols - 1, pos, 6);
        module(2, numcols - 1, pos, 7);
        module(3, numcols - 1, pos, 8);
    }

    private func corner4(pos: Int64) {
        module(numrows - 1, 0, pos, 1);
        module(numrows - 1, numcols - 1, pos, 2);
        module(0, numcols - 3, pos, 3);
        module(0, numcols - 2, pos, 4);
        module(0, numcols - 1, pos, 5);
        module(1, numcols - 3, pos, 6);
        module(1, numcols - 2, pos, 7);
        module(1, numcols - 1, pos, 8);
    }
}
