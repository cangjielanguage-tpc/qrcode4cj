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

/**
 * Class that lets one easily build an array of bytes by appending bits at a time.
 *
 * @author Sean Owen
 */
public class BitSourceBuilder {
    private let output: ByteArrayStream
    private var nextByte: Int64
    private var bitsLeftInNextByte: Int64

    public init() {
        output = ByteArrayStream()
        nextByte = 0
        bitsLeftInNextByte = 8
    }

    @OverflowWrapping
    public func write(value: Int64, numBits: Int64): Unit {
        if (numBits <= bitsLeftInNextByte) {
            nextByte <<= numBits
            nextByte |= value

            bitsLeftInNextByte -= numBits
            if (bitsLeftInNextByte == 0) {
                output.write([UInt8(nextByte)])
                nextByte = 0
                bitsLeftInNextByte = 8
            }
        } else {
            let bitsToWriteNow: Int64 = bitsLeftInNextByte
            let numRestOfBits: Int64 = numBits - bitsToWriteNow
            let mask: Int64 = 0xFF >> (8 - bitsToWriteNow)
            let valueToWriteNow: Int64 = (value >> numRestOfBits) & mask
            write(valueToWriteNow, bitsToWriteNow);
            write(value, numRestOfBits);
        }
    }

    public func clone(): ByteArrayStream {
        if (bitsLeftInNextByte < 8) {
            write(0, bitsLeftInNextByte);
        }
        return output.clone();
    }

    public func toByteArray(): Array<UInt8> {
        if (bitsLeftInNextByte < 8) {
            write(0, bitsLeftInNextByte);
        }
        return output.bytes();
    }
}
