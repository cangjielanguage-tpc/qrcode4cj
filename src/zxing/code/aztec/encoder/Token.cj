package zxing.code.aztec.encoder

public abstract class Token {
    static var EMPTY: Token = SimpleToken(None, 0, 0)

    private var previous: ?Token = None

    public init(previous: ?Token) {
        this.previous = previous
    }

    func getPrevious(): ?Token {
        return previous
    }

    func add(value: Int64, bitCount: Int64): Token {
        return SimpleToken(this, value, bitCount)
    }

    func addBinaryShift(start: Int64, byteCount: Int64): Token {
        return BinaryShiftToken(this, start, byteCount)
    }

    public func appendTo(bitArray: BitArray, text: Array<UInt8>): Unit
}
