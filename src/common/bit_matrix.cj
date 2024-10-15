/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common

import QRCode4cj.tools.System

import QRCode4cj.tools.*

//import std.collection.*
/**
 * Represents a 2D matrix of bits. In function arguments below, and throughout the common
 * module, x is the column position, and y is the row position. The ordering is always x, y.
 * The origin is at the top-left.
 *
 * Internally the bits are represented in a 1-D array of 32-bit ints. However, each row begins
 * with a new int. This is done intentionally so that we can copy out a row into a BitArray very
 * efficiently.
 *
 * The ordering of bits is row-major. Within each int, the least significant bits are used first,
 * meaning they represent lower x values. This is compatible with BitArray's implementation.
 */
public class BitMatrix <: Equatable<BitMatrix> & ToString {
    public var width: Int64
    public var height: Int64
    public var rowSize: Int64
    public var bits: Array<Int32>
    public var flag: Bool = false
    public init() {
        this.width = 0
        this.height = 0
        this.rowSize = 0
        this.bits = Array<Int32>()
    }

    /**
     * Creates an empty square {@code BitMatrix}.
     *
     * @param dimension height and width
     */
    public init(dimension: Int64) {
        if (dimension < 1) {
            throw IllegalArgumentException("Both dimensions must be greater than 0")
        }
        this.width = dimension
        this.height = dimension
        this.rowSize = (dimension + 31) >> 5
        this.bits = Array<Int32>(this.rowSize * this.height, repeat: 0)
        this.flag = true
    }

    public init(width: Int64, height: Int64) {
        if (width < 1 || height < 1) {
            throw IllegalArgumentException("Both dimensions must be greater than 0")
        }
        this.width = width
        this.height = height
        this.rowSize = (width + 31) >> 5
        this.bits = Array<Int32>(this.rowSize * this.height, repeat: 0)
        this.flag = true
    }

    public init(width: Int64, height: Int64, rowSize: Int64, bits: Array<Int32>) {
        this.width = width
        this.height = height
        this.rowSize = rowSize
        this.bits = bits
        this.flag = true
    }

    /**
     * Interprets a 2D array of booleans as a {@code BitMatrix}, where "true" means an "on" bit.
     *
     * @param image bits of the image, as a row-major 2D array. Elements are arrays representing rows
     * @return {@code BitMatrix} representation of image
     */
    public static func parse(image: Array<Array<Bool>>): BitMatrix {
        let height = image.size
        let width = image[0].size
        let bits = BitMatrix(width, height)
        for (i in 0..height) {
            let imageI = image[i]
            for (j in 0..width) {
                if (imageI[j]) {
                    bits.set(j, i)
                }
            }
        }
        bits
    }

    public static func parse(stringRepresentation: UTF32String, setString: UTF32String, unsetString: UTF32String): BitMatrix {
        if (stringRepresentation.charSize == 0) {
            throw IllegalArgumentException()
        }
        let bits = Array<Bool>(stringRepresentation.charSize, repeat: false)
        var bitsPos = 0
        var rowStartPos = 0
        var rowLength = -1
        var nRows = 0
        var pos = 0
        while (pos < stringRepresentation.charSize) {
            if (stringRepresentation[pos] == r'\n' || stringRepresentation[pos] == r'\r') {
                if (bitsPos > rowStartPos) {
                    if (rowLength == -1) {
                        rowLength = bitsPos - rowStartPos
                    } else if (bitsPos - rowStartPos != rowLength) {
                        throw IllegalArgumentException("row lengths do not match")
                    }
                    rowStartPos = bitsPos
                    nRows++
                }
                pos++
            } else if (stringRepresentation[pos..stringRepresentation.charSize].startsWith(setString)) {
                pos += setString.charSize
                bits[bitsPos] = true
                bitsPos++
            } else if (stringRepresentation[pos..stringRepresentation.charSize].startsWith(unsetString)) {
                pos += unsetString.charSize
                bits[bitsPos] = false
                bitsPos++
            } else {
                throwError(stringRepresentation, pos)
            }
        }

        if (bitsPos > rowStartPos) {
            if (rowLength == -1) {
                rowLength = bitsPos - rowStartPos
            } else if (bitsPos - rowStartPos != rowLength) {
                throw IllegalArgumentException("row lengths do not match")
            }
            nRows++
        }

        let matrix = BitMatrix(rowLength, nRows)
        for (i in 0..bitsPos) {
            if (bits[i]) {
                matrix.set(i % rowLength, i / rowLength)
            }
        }
        matrix
    }

    static private func throwError(stringRepresentation: UTF32String, pos: Int64) {
        throw IllegalArgumentException(
            "illegal character encountered: " + stringRepresentation[pos..stringRepresentation.charSize].toString())
    }

    /**
     * <p>Gets the requested bit, where true means black.</p>
     *
     * @param x The horizontal component (i.e. which column)
     * @param y The vertical component (i.e. which row)
     * @return value of given bit in matrix
     */
    @OverflowWrapping
    public func get(x: Int64, y: Int64): Bool {
        return ((Int32(UInt32(0xffffffffi64 & Int64(this.bits[y * rowSize + (x >> 5)])) >> Int64(Int32(x) & 0x1f))) & 1) !=
            0
    }

    /**
     * <p>Sets the given bit to true.</p>
     *
     * @param x The horizontal component (i.e. which column)
     * @param y The vertical component (i.e. which row)
     */
    public func set(x: Int64, y: Int64) {
        this.bits[y * this.rowSize + (x >> 5)] |= 1 << (x & 0x1f)
    }

    public func unset(x: Int64, y: Int64) {
        this.bits[y * this.rowSize + (x >> 5)] &= !(1 << (x & 0x1f))
    }

    /**
     * <p>Flips the given bit.</p>
     *
     * @param x The horizontal component (i.e. which column)
     * @param y The vertical component (i.e. which row)
     */
    public func flip(x: Int64, y: Int64) {
        this.bits[y * this.rowSize + (x >> 5)] ^= 1 << (x & 0x1f)
    }

    /**
     * <p>Flips every bit in the matrix.</p>
     */
    public func flip() {
        for (i in 0..this.bits.size) {
            this.bits[i] = !this.bits[i]
        }
    }

    /**
     * Exclusive-or (XOR): Flip the bit in this {@code BitMatrix} if the corresponding
     * mask bit is set.
     *
     * @param mask XOR mask
     */
    public func xor(mask: BitMatrix) {
        if (width != mask.width || height != mask.height || rowSize != mask.rowSize) {
            throw IllegalArgumentException("input matrix dimensions do not match")
        }
        let rowArray = BitArray(width)
        for (y in 0..height) {
            let offset = y * rowSize
            let row = mask.getRow(y, rowArray).getBitArray()
            for (x in 0..rowSize) {
                bits[offset + x] ^= row[x]
            }
        }
    }

    /**
     * Clears all bits (sets to false).
     */
    public func clear() {
        for (i in 0..this.bits.size) {
            this.bits[i] = 0
        }
    }

    /**
     * <p>Sets a square region of the bit matrix to true.</p>
     *
     * @param left The horizontal position to begin at (inclusive)
     * @param top The vertical position to begin at (inclusive)
     * @param width The width of the region
     * @param height The height of the region
     */
    public func setRegion(left: Int64, top: Int64, width: Int64, height: Int64) {
        if (top < 0 || left < 0) {
            throw IllegalArgumentException("Left and top must be nonnegative")
        }
        if (height < 1 || width < 1) {
            throw IllegalArgumentException("Height and width must be at least 1")
        }
        let right = left + width
        let bottom = top + height
        if (bottom > this.height || right > this.width) {
            throw IllegalArgumentException("The region must fit inside the matrix")
        }
        var L = 1
        var xl = left >> 5
        var x1 = xl
        for (x in (left + 1)..right) {
            var x2 = x >> 5
            if (x2 != x1) {
                L += 1
                x1 = x2
            }
        }

        var arr = Array<Int32>(L, repeat: 0)
        for (x in left..right) {
            arr[(x >> 5) - xl] |= 1 << (x & 0x1f)
        }
        for (y in top..bottom) {
            let offset = y * rowSize
            for (x in 0..L) {
                bits[offset + xl + x] |= arr[x]
            }
        }
    }

    /**
     * A fast method to retrieve one row of data from the matrix as a BitArray.
     *
     * @param y The row to retrieve
     * @param row An optional caller-allocated BitArray, will be allocated if null or too small
     * @return The resulting BitArray - this reference should always be used even when passing
     * your own row
     */
    public func getRow(y: Int64, row: BitArray): BitArray {
        var rowItem: BitArray = BitArray();
        if (row.getSize() < width) {
            rowItem = BitArray(width)
        } else {
            row.clear();
            rowItem = row
        }
        let offset = y * rowSize
        for (x in 0..rowSize) {
            rowItem.setBulk(x * 32, bits[offset + x]);
        }
        return rowItem
    }

    /**
     * @param y row to set
     * @param row {@link BitArray} to copy from
     */
    public func setRow(y: Int64, row: BitArray) {
        bits = System.arraycopy(row.getBitArray(), 0, bits, y * rowSize, rowSize)
    }

    /**
     * Modifies this {@code BitMatrix} to represent the same but rotated the given degrees (0, 90, 180, 270)
     *
     * @param degrees number of degrees to rotate through counter-clockwise (0, 90, 180, 270)
     */
    public func rotate(degrees: Int64) {
        match (degrees) {
            case 0 =>
                ()
                return
            case 90 =>
                rotate90()
                return
            case 180 =>
                rotate180()
                return
            case 270 =>
                rotate90()
                rotate180()
                return
            case _ => throw IllegalArgumentException("degrees must be a multiple of 0, 90, 180, or 270")
        }
    }

    /**
     * Modifies this {@code BitMatrix} to represent the same but rotated 180 degrees
     */
    public func rotate180() {
        var topRow = BitArray(width)
        var bottomRow = BitArray(width)
        let maxHeight = (height + 1) / 2

        for (i in 0..maxHeight) {
            topRow = getRow(i, topRow)
            let bottomRowIndex = height - 1 - i
            bottomRow = getRow(bottomRowIndex, bottomRow)

            topRow.reverse()
            bottomRow.reverse()

            setRow(i, bottomRow)
            setRow(bottomRowIndex, topRow)
        }
    }

    /**
     * Modifies this {@code BitMatrix} to represent the same but rotated 90 degrees counterclockwise
     */
    public func rotate90() {
        let newWidth = height
        let newHeight = width
        let newRowSize = (newWidth + 31) >> 5
        let newBits = Array<Int32>(newRowSize * newHeight, repeat: 0)
        for (y in 0..height) {
            for (x in 0..width) {
                let offset = y * rowSize + (x >> 5)
                if (((Int32(UInt32(0xffffffffi64 & Int64(bits[offset])) >> (x & 0x1f))) & 1) != 0) {
                    let newOffset = (newHeight - 1 - x) * newRowSize + (y >> 5)
                    newBits[newOffset] |= 1 << (y & 0x1f)
                }
            }
        }
        this.width = newWidth
        this.height = newHeight
        this.rowSize = newRowSize
        this.bits = newBits
    }

    public func getEnclosingRectangle(): Array<Int64> {
        var left = this.width
        var top = this.height
        var right = -1
        var bottom = -1
        for (y in 0..height) {
            for (x32 in 0..rowSize) {
                let theBits = bits[y * rowSize + x32]
                if (theBits != 0) {
                    if (y < top) {
                        top = y
                    }
                    if (y > bottom) {
                        bottom = y
                    }
                    if (x32 * 32 < left) {
                        var bit = 0
                        while ((theBits << (31 - bit)) == 0) {
                            bit++
                        }
                        if ((x32 * 32 + bit) < left) {
                            left = x32 * 32 + bit
                        }
                    }
                    if (x32 * 32 + 31 > right) {
                        var bit = 31
                        while (Int32(UInt32(0xffffffffi64 & Int64(theBits)) >> bit) == 0) {
                            bit--
                        }
                        if ((x32 * 32 + bit) > right) {
                            right = x32 * 32 + bit
                        }
                    }
                }
            }
        }

        if (right < left || bottom < top) {
            return Array<Int64>();
        }

        return [left, top, right - left + 1, bottom - top + 1]
    }

    public func getTopLeftOnBit(): Array<Int64> {
        var bitsOffset = 0
        while (bitsOffset < this.bits.size && this.bits[bitsOffset] == 0) {
            bitsOffset++
        }
        if (bitsOffset == this.bits.size) {
            return Array<Int64>()
        }
        let y = bitsOffset / rowSize
        var x = (bitsOffset % rowSize) * 32

        let theBits = bits[bitsOffset]
        var bit = 0
        while ((Int32(theBits) << (31 - bit)) == 0) {
            bit++
        }
        x += bit
        return [x, y]
    }

    public func getBottomRightOnBit(): Array<Int64> {
        var bitsOffset = this.bits.size - 1
        while (bitsOffset >= 0 && this.bits[bitsOffset] == 0) {
            bitsOffset--
        }
        if (bitsOffset < 0) {
            return Array<Int64>();
        }

        let y = bitsOffset / rowSize
        var x = (bitsOffset % rowSize) * 32

        let theBits = bits[bitsOffset]
        var bit = 31

        while (Int32(UInt32(0xffffffffi64 & Int64(theBits)) >> bit) == 0) {
            bit--
        }
        x += bit

        return [x, y]
    }

    /**
     * @return The width of the matrix
     */
    public func getWidth(): Int64 {
        return width
    }

    /**
     * @return The height of the matrix
     */
    public func getHeight(): Int64 {
        return height
    }

    /**
     * @return The row size of the matrix
     */
    public func getRowSize(): Int64 {
        return rowSize
    }

    @OverflowWrapping
    public func hashCode(): Int64 {
        var hash = width
        hash = 31 * hash + width
        hash = 31 * hash + height
        hash = 31 * hash + rowSize
        hash = 31 * hash + intArraysHashCode(this.bits)
        return hash
    }

    /**
     * @return string representation using "X" for set and " " for unset bits
     */
    public func toString(): String {
        toString("X ", "  ")
    }

    /**
     * @param setString representation of a set bit
     * @param unsetString representation of an unset bit
     * @return string representation of entire matrix utilizing given strings
     */
    public func toString(setString: String, unsetString: String): String {
        toString(setString, unsetString, "\n")
    }

    /**
     * @param setString representation of a set bit
     * @param unsetString representation of an unset bit
     * @param lineSeparator newline character in string representation
     * @return string representation of entire matrix utilizing given strings and line separator
     * @deprecated call {@link #toString(String,String)} only, which uses \n line separator always
     */
    public func toString(setString: String, unsetString: String, lineSeparator: String): String {
        var result = String()
        for (y in 0..height) {
            for (x in 0..width) {
                result += if (get(x, y)) {
                    setString
                } else {
                    unsetString
                }
            }
            result += lineSeparator
        }
        result
    }

    public func clone(): BitMatrix {
        BitMatrix(this.width, this.height, this.rowSize, this.bits.clone())
    }

    public operator func !=(right: BitMatrix): Bool {
        if (right.width != this.width || right.height != this.height || right.rowSize != this.rowSize || right.bits !=
            this.bits) {
            true;
        } else {
            false;
        }
    }

    public operator func ==(right: BitMatrix): Bool {
        if (right.width == this.width && right.height == this.height && right.rowSize == this.rowSize && right.bits ==
            this.bits) {
            true;
        } else {
            false;
        }
    }
}
