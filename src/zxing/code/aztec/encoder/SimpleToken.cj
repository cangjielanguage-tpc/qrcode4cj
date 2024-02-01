package zxing.code.aztec.encoder

from std import format.*
from charset import charset.tools.UTF32String

public class SimpleToken <: Token {
    // For normal words, indicates value and bitCount
    private var value: Int64
    private var bitCount: Int64

    public init(previous: ?Token, value: Int64, bitCount: Int64) {
        super(previous)
        this.value = value
        this.bitCount = bitCount
    }

    public override func appendTo(bitArray: BitArray, text: Array<UInt8>) {
        bitArray.appendBits(value, bitCount)
    }

    public func toString(): String {
        var value: Int64 = this.value & ((1 << bitCount) - 1)
        value |= 1 << bitCount
        return "<" + (value | (1 << bitCount)).format("#b")[Range<Int64>(0, 4, 1, true, true, false)] + ">"
    }
}
