package zxing.code.common

from std import collection.*
from std import math.*
import zxing.code.tools.numberOfTrailingZeros
import zxing.code.tools.intArraysHashCode

public class BitArray <: Hashable & ToString & Equatable<BitArray> {
    let EMPTY_BITS: Array<Int32> = []
    let LOAD_FACTOR = 0.75

    private var bits: Array<Int32>
    private var size: Int64

    public init() {
        this.size = 0
        this.bits = EMPTY_BITS
    }

    public init(size: Int64) {
        this.size = size
        this.bits = makeArray(size)
    }

    public init(bits: Array<Int32>, size: Int64) {
        this.bits = bits
        this.size = size
    }

    public func getSize(): Int64 {
        return size
    }

    public func getSizeInBytes(): Int64 {
        (this.size + 7) / 8
    }

    func ensureCapacity(newSize: Int64) {
        if (newSize > this.bits.size * 32) {
            let newBits = this.bits
            let newBitsSize = newBits.size

            let newSize = Int64(math.ceil(Float64(newSize) / LOAD_FACTOR))
            this.bits = Array<Int32>((newSize + 31) >> 5, {
                n => if (n < newBitsSize) {
                    newBits[n]
                } else {
                    0
                }
            })
        }
    }

    private static func makeArray(size: Int64): Array<Int32> {
        return Array<Int32>((size + 31) >> 5, item: 0)
    }

    /**
     * @param i bit to get
     * @return true iff bit i is set
     */
    public func get(i: Int64): Bool {
        return (bits[i >> 5] & (1 << (Int32(i) & 0x1F))) != 0
    }

    /**
     * Sets bit i.
     *
     * @param i bit to set
     */
    public func set(i: Int64): Unit {
        bits[i >> 5] |= 1 << (Int32(i) & 0x1F)
    }

    /**
     * Flips bit i.
     *
     * @param i bit to set
     */
    public func flip(i: Int64): Unit {
        bits[i >> 5] ^= 1 << (Int32(i) & 0x1F)
    }

    /**
     * @param fro first bit to check
     * @return index of first bit that is set, starting fro the given index, or size if none are set
     * at or beyond this given index
     * @see #getNextUnset(int)
     */
    public func getNextSet(fro: Int64): Int64 {
        if (fro >= size) {
            return size
        }

        var bitsOffset = fro >> 5
        var currentBits: Int64 = Int64(this.bits.get(bitsOffset).getOrThrow())

        // mask off lesser bits first
        currentBits &= -(1 << (fro & 0x1F))
        while (currentBits == 0) {
            bitsOffset++
            if (bitsOffset == this.bits.size) {
                return size
            }
            currentBits = Int64(bits[bitsOffset])
        }
        var result = (bitsOffset * 32) + numberOfTrailingZeros(Int64(currentBits))
        return math.min(result, size);
    }

    /**
     * @param from index to start looking for unset bit
     * @return index of next unset bit, or {@code size} if none are unset until the end
     * @see #getNextSet(int)
     */
    public func getNextUnset(fro: Int64): Int64 {
        if (fro >= size) {
            return size
        }
        var bitsOffset = fro >> 5

        var currentBits: Int32 = Int32(!(this.bits[bitsOffset]))

        // mask off lesser bits first
        var cdata: Int32 = Int32(-(1 << (fro & 0x1F)))
        currentBits &= cdata
        while (currentBits == 0) {
            bitsOffset++
            if (bitsOffset == this.bits.size) {
                return size
            }
            currentBits = Int32(!(this.bits[bitsOffset]))
        }
        var result = (bitsOffset * 32) + numberOfTrailingZeros(Int64(currentBits))
        return math.min(result, size)
    }

    /**
     * Sets a block of 32 bits, starting at bit i.
     *
     * @param i first bit to set
     * @param newBits the new value of the next 32 bits. Note again that the least-significant bit
     * corresponds to bit i, the next-least-significant to i+1, and so on.
     */
    public func setBulk(i: Int64, newBits: Int32): Unit {
        this.bits[i >> 5] = newBits
    }

    /**
     * Sets a range of bits.
     *
     * @param start start of range, inclusive.
     * @param end end of range, exclusive
     */
    public func setRange(start: Int64, end: Int64) {
        if (end < start || start < 0 || end > size) {
            throw IllegalArgumentException()
        }
        if (end == start) {
            return
        }
        let mEnd = end - 1
        let firstInt = start >> 5
        let lastInt = mEnd >> 5
        for (i in firstInt..=lastInt) {
            let f = if (i > firstInt) {
                0
            } else {
                start & 0x1F
            }
            let l = if (i < lastInt) {
                31
            } else {
                mEnd & 0x1F
            }
            this.bits[i] |= (2 << l) - (1 << f)
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
     * Efficient method to check if a range of bits is set, or not set.
     *
     * @param start start of range, inclusive.
     * @param end end of range, exclusive
     * @param value if true, checks that bits in range are set, otherwise checks that they are not set
     * @return true iff all bits are set or not set in range, according to value argument
     * @throws IllegalArgumentException if end is less than start or the range is not contained in the array
     */
    public func isRange(start: Int64, end: Int64, value: Bool): Bool {
        if (end < start || start < 0 || end > size) {
            throw IllegalArgumentException()
        }
        if (end == start) {
            return true
        }
        let mEnd = end - 1
        let firstInt = start >> 5
        let lastInt = mEnd >> 5
        for (i in firstInt..=lastInt) {
            let f = if (i > firstInt) {
                0
            } else {
                start & 0x1F
            }
            let l = if (i < lastInt) {
                31
            } else {
                mEnd & 0x1F
            }
            let mask = (2 << l) - (1 << f)
            if ((Int64(this.bits[i]) & mask) != (if (value) {
                mask
            } else {
                0
            })) {
                return false
            }
        }
        true
    }

    public func appendBit(bit: Bool) {
        ensureCapacity(this.size + 1)
        if (bit) {
            this.bits[this.size >> 5] |= 1 << (this.size & 0x1F)
        }
        this.size++
    }

    /**
     * Appends the least-significant bits, from value, in order from most-significant to
     * least-significant. For example, appending 6 bits from 0x000001E will append the bits
     * 0, 1, 1, 1, 1, 0 in that order.
     *
     * @param value {@code int} containing bits to append
     * @param numBits bits from value to append
     */
    public func appendBits(value: Int64, numBits: Int64) {
        if (numBits < 0 || numBits > 32) {
            throw IllegalArgumentException("Num bits must be between 0 and 32")
        }
        var nextSize = this.size
        ensureCapacity(nextSize + numBits)
        for (numBitsLeft in (numBits - 1)..=0 : -1) {
            if ((value & (1 << numBitsLeft)) != 0) {
                this.bits[nextSize >> 5] |= 1 << (nextSize & 0x1F)
            }
            nextSize++
        }
        this.size = nextSize
    }

    public func appendBitArray(other: BitArray) {
        let otherSize = other.size
        ensureCapacity(size + otherSize)
        for (i in 0..otherSize) {
            appendBit(other.get(i))
        }
    }

    public func xor(other: BitArray) {
        if (this.size != other.size) {
            throw IllegalArgumentException("Sizes don't match")
        }
        for (i in 0..this.bits.size) {
            this.bits[i] ^= other.bits[i]
        }
    }

    /**
     *
     * @param bitOffset first bit to start writing
     * @param array array to write into. Bytes are written most-significant byte first. This is the opposite
     * of the internal representation, which is exposed by {@link #getBitArray()}
     * @param offset position in array to start writing
     * @param numBytes how many bytes to write
     */
    @OverflowWrapping
    public func toBytes(bitOffset: Int64, array: Array<UInt8>, offset: Int64, numBytes: Int64) {
        var mBitOffset = bitOffset
        for (i in 0..numBytes) {
            var theByte = 0
            for (j in 0..8) {
                if (get(mBitOffset)) {
                    theByte |= 1 << (7 - j)
                }
                mBitOffset++
            }
            array[offset + i] = UInt8(theByte)
        }
    }

    /**
     * @return underlying array of ints. The first element holds the first 32 bits, and the least
     * significant bit is bit 0.
     */
    public func getBitArray(): Array<Int32> {
        return bits
    }

    public func reverse(num: Int32): Int32 {
        var i: Int32 = num

        // HD, Figure 7-1
        i = (i & 0x55555555) << 1 | (Int32(UInt32(0xffffffffi64 & Int64(i)) >> 1)) & 0x55555555
        i = (i & 0x33333333) << 2 | (Int32(UInt32(0xffffffffi64 & Int64(i)) >> 2)) & 0x33333333
        i = (i & 0x0f0f0f0f) << 4 | (Int32(UInt32(0xffffffffi64 & Int64(i)) >> 4)) & 0x0f0f0f0f
        i = (i << 24) | ((i & 0xff00) << 8) | (Int32(UInt32(0xffffffffi64 & Int64(i)) >> 8) & 0xff00) | (Int32(UInt32(0xffffffffi64 &
                    Int64(i)) >> 24))
        return i
    }

    /**
     * Reverses all bits in the array.
     */
    public func reverse() {
        let newBits = Array<Int32>(this.bits.size, item: 0)
        let len = (this.size - 1) >> 5
        let oldBitsLen = len + 1
        for (i in 0..oldBitsLen) {
            newBits[len - i] = reverse(this.bits[i])
        }
        if (this.size != oldBitsLen * 32) {
            let leftOffset = oldBitsLen * 32 - size
            var currentInt = Int32(UInt32(0xffffffffi64 & Int64(newBits[0])) >> leftOffset) 
            for (i in 1..oldBitsLen) {
                let nextInt = newBits[i]
                currentInt |= nextInt << (32 - Int32(leftOffset))
                newBits[i - 1] = currentInt

                currentInt = Int32(UInt32(0xffffffffi64 & Int64(nextInt)) >> leftOffset)
            }
            newBits[oldBitsLen - 1] = currentInt
        }
        bits = newBits
    }

    public operator func ==(o: BitArray): Bool {
        this.size == o.size && (this.bits == o.bits)
    }

    public operator func !=(o: BitArray): Bool {
        !(this.size == o.size && (this.bits == o.bits))
    }

    public func hashCode(): Int64 {
        return 31 * this.size + intArraysHashCode(bits)
    }

    public func toString(): String {
        var result = ""
        for (i in 0..this.size) {
            if ((i & 0x07) == 0) {
                result += " "
            }
            result += "${if(get(i)){'X'}else{'.'}}"
        }
        result
    }

    public func clone(): BitArray {
        BitArray(this.bits.clone(), this.size)
    }
}
