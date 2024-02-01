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

package zxing.code.common

/**
 * <p>This provides an easy abstraction to read bits at a time from a sequence of bytes, where the
 * number of bits read is not often a multiple of 8.</p>
 *
 * <p>This class is thread-safe but not reentrant -- unless the caller modifies the bytes array
 * it passed in, in which case all bets are off.</p>
 *
 * @author
 */
public class BitSource {
    public let bytes: Array<UInt8>

    public var byteOffset: Int64 = 0
    public var bitOffset: Int64 = 0

    /**
     * @param bytes bytes from which this will read bits. Bits will be read from the first byte first.
     * Bits are read within a byte from most-significant to least-significant bit.
     */
    public init(bytes: Array<UInt8>) {
        this.bytes = bytes
    }

    /**
     * @return index of next bit in current byte which would be read by the next call to {@link #readBits(int)}.
     */
    public func getBitOffset(): Int64 {
        return bitOffset
    }

    /**
     * @return index of next byte in input byte array which would be read by the next call to {@link #readBits(int)}.
     */
    public func getByteOffset(): Int64 {
        return byteOffset
    }

    /**
     * @param numBits number of bits to read
     * @return int representing the bits read. The bits will appear as the least-significant
     * bits of the int
     * @throws IllegalArgumentException if numBits isn't in [1,32] or more than is available
     */
    public func readBits(oNumBits: Int64): Int64 {
        var numBits = oNumBits
        if (numBits < 1 || numBits > 32 || numBits > available()) {
            throw IllegalArgumentException("${numBits}")
        }

        var result = 0

        if (bitOffset > 0) {
            let bitsLeft = 8 - bitOffset
            let toRead = math.min(numBits, bitsLeft)
            let bitsToNotRead = bitsLeft - toRead
            let mask = (0xFF >> (8 - toRead)) << bitsToNotRead
            result = (Int64(bytes[byteOffset]) & mask) >> bitsToNotRead
            numBits -= toRead
            bitOffset += toRead
            if (bitOffset == 8) {
                bitOffset = 0
                byteOffset++
            }
        }

        if (numBits > 0) {
            while (numBits >= 8) {
                result = (result << 8) | (Int64(bytes[byteOffset]) & 0xFF)
                byteOffset++
                numBits -= 8
            }

            if (numBits > 0) {
                let bitsToNotRead = 8 - numBits
                let mask = (0xFF >> bitsToNotRead) << bitsToNotRead
                result = (result << numBits) | ((Int64(bytes[byteOffset]) & mask) >> bitsToNotRead)
                bitOffset += numBits
            }
        }

        result
    }

    /**
     * @return number of bits that can be read successfully
     */
    public func available(): Int64 {
        return 8 * (bytes.size - byteOffset) - bitOffset
    }
}
