package zxing.code.aztec.encoder

import zxing.code.common.BitArray
from std import math.*

public class BinaryShiftToken <: Token {
    private var binaryShiftStart: Int64
    private var binaryShiftByteCount: Int64

    public init(
        previous: ?Token,
        binaryShiftStart: Int64,
        binaryShiftByteCount: Int64
    ) {
        super(previous)
        this.binaryShiftStart = binaryShiftStart
        this.binaryShiftByteCount = binaryShiftByteCount
    }

    public func appendTo(bitArray: BitArray, text: Array<UInt8>): Unit {
        var bsbc: Int64 = binaryShiftByteCount
        for (i in 0..bsbc) {
            if (i == 0 || (i == 31 && bsbc <= 62)) {
                // We need a header before the first character, and before
                // character 31 when the total byte code is <= 62
                bitArray.appendBits(31, 5) // BINARY_SHIFT
                if (bsbc > 62) {
                    bitArray.appendBits(bsbc - 31, 16)
                } else if (i == 0) {
                    // 1 <= binaryShiftByteCode <= 62
                    bitArray.appendBits(min(bsbc, 31), 5)
                } else {
                    // 32 <= binaryShiftCount <= 62 and i == 31
                    bitArray.appendBits(bsbc - 31, 5)
                }
            }
            var item: UInt8 = text[binaryShiftStart + i]
            bitArray.appendBits(Int64(item), 8)
        }
    }

    public func toString(): String {
        return "<${binaryShiftStart}::${(binaryShiftStart + binaryShiftByteCount - 1)}>"
    }
}
