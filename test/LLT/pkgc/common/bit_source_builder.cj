import std.io.*

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
