package zxing.code.aztec.encoder

/**
 * State represents all information about a sequence necessary to generate the current output.
 * Note that a state is immutable.
 */
public class State {
    static var INITIAL_STATE: State = State(Token.EMPTY, HighLevelEncoder.MODE_UPPER, 0, 0)

    // The current mode of the encoding (or the mode to which we'll return if
    // we're in Binary Shift mode.
    private var mode: Int64

    // The list of tokens that we output.  If we are in Binary Shift mode, this
    // token list does *not* yet included the token for those bytes
    private var token: Token

    // If non-zero, the number of most recent bytes that should be output
    // in Binary Shift mode.
    private var binaryShiftByteCount: Int64

    // The total number of bits generated (including Binary Shift).
    private var bitCount: Int64
    private var binaryShiftCost: Int64

    private init(token: Token, mode: Int64, binaryBytes: Int64, bitCount: Int64) {
        this.token = token
        this.mode = mode
        this.binaryShiftByteCount = binaryBytes
        this.bitCount = bitCount
        this.binaryShiftCost = calculateBinaryShiftCost(binaryBytes)
    }

    public func getMode(): Int64 {
        return mode
    }

    public func getToken(): Token {
        return token
    }

    public func getBinaryShiftByteCount(): Int64 {
        return binaryShiftByteCount
    }

    public func getBitCount(): Int64 {
        return bitCount
    }

    public func appendFLGn(eci: Int64): State {
        var result: State = shiftAndAppend(HighLevelEncoder.MODE_PUNCT, 0) // 0: FLG(n)
        var token: Token = result.token
        var bitsAdded: Int64 = 3
        if (eci < 0) {
            token = token.add(0, 3) // 0: FNC1
        } else if (eci > 999999) {
            throw IllegalArgumentException("ECI code must be between 0 and 999999")
        } else {
            var eciDigits: Array<UInt8> = StandardCharsets.ISO_8859_1.newEncoder().getBytes(UTF32String(eci.toString()))
            token = token.add(eciDigits.size, 3) // 1-6: number of ECI digits
            for (i in 0..eciDigits.size) {
                token = token.add(Int64(eciDigits[i] - UInt8(UInt32('0'))) + 2, 4)
            }
            bitsAdded += eciDigits.size * 4
        }
        return State(token, mode, 0, bitCount + bitsAdded)
    }

    // Create a new state representing this state with a latch to a (not
    // necessary different) mode, and then a code.
    public func latchAndAppend(mode: Int64, value: Int64): State {
        var bitCount: Int64 = this.bitCount
        var token: Token = this.token
        if (mode != this.mode) {
            var latch: Int64 = HighLevelEncoder.LATCH_TABLE[this.mode][mode]
            token = token.add(latch & 0xFFFF, latch >> 16)
            bitCount += latch >> 16
        }
        var latchModeBitCount: Int64 = if (mode == HighLevelEncoder.MODE_DIGIT) {
            4
        } else {
            5
        }
        token = token.add(value, latchModeBitCount)
        return State(token, mode, 0, bitCount + latchModeBitCount);
    }

    // Create a new state representing this state, with a temporary shift
    // to a different mode to output a single value.
    public func shiftAndAppend(mode: Int64, value: Int64): State {
        var token: Token = this.token
        var thisModeBitCount: Int64 = if (this.mode == HighLevelEncoder.MODE_DIGIT) {
            4
        } else {
            5
        }

        // Shifts exist only to UPPER and PUNCT, both with tokens size 5.
        token = token.add(HighLevelEncoder.SHIFT_TABLE_[this.mode][mode], thisModeBitCount)
        token = token.add(value, 5)
        return State(token, this.mode, 0, this.bitCount + thisModeBitCount + 5)
    }

    // Create a new state representing this state, but an additional character
    // output in Binary Shift mode.
    public func addBinaryShiftChar(index: Int64): State {
        var token: Token = this.token
        var mode: Int64 = this.mode
        var bitCount: Int64 = this.bitCount
        if (this.mode == HighLevelEncoder.MODE_PUNCT || this.mode == HighLevelEncoder.MODE_DIGIT) {
            var latch: Int64 = HighLevelEncoder.LATCH_TABLE[mode][HighLevelEncoder.MODE_UPPER]
            token = token.add(latch & 0xFFFF, latch >> 16)
            bitCount += latch >> 16
            mode = HighLevelEncoder.MODE_UPPER
        }
        var deltaBitCount: Int64 = if (binaryShiftByteCount == 0 || binaryShiftByteCount == 31) {
            18
        } else {
            if (binaryShiftByteCount == 62) {
                9
            } else {
                8
            }
        }
        var result: State = State(token, mode, binaryShiftByteCount + 1, bitCount + deltaBitCount)
        if (result.binaryShiftByteCount == 2047 + 31) {
            // The string is as long as it's allowed to be.  We should end it.
            result = result.endBinaryShift(index + 1)
        }
        return result
    }

    // Create the state identical to this one, but we are no longer in
    // Binary Shift mode.
    public func endBinaryShift(index: Int64): State {
        if (binaryShiftByteCount == 0) {
            return this
        }
        var token: Token = this.token
        token = token.addBinaryShift(index - binaryShiftByteCount, binaryShiftByteCount)
        return State(token, mode, 0, this.bitCount)
    }

    // Returns true if "this" state is better (or equal) to be in than "that"
    // state under all possible circumstances.
    public func isBetterThanOrEqualTo(other: State): Bool {
        var newModeBitCount: Int64 = this.bitCount + (HighLevelEncoder.LATCH_TABLE[this.mode][other.mode] >> 16)
        if (this.binaryShiftByteCount < other.binaryShiftByteCount) {
            // add additional B/S encoding cost of other, if any
            newModeBitCount += other.binaryShiftCost - this.binaryShiftCost
        } else if (this.binaryShiftByteCount > other.binaryShiftByteCount && other.binaryShiftByteCount > 0) {
            // maximum possible additional cost (we end up exceeding the 31 byte boundary and other state can stay beneath it)
            newModeBitCount += 10
        }
        return newModeBitCount <= other.bitCount
    }

    public func toBitArray(text: Array<UInt8>): BitArray {
        var symbols: ArrayList<Token> = ArrayList<Token>()
        var token: ?Token = endBinaryShift(text.size).token

        //
        //
        while (let Some(t) <- token) {
            symbols.append(t)
            token = t.getPrevious()
        }
        var bitArray: BitArray = BitArray()

        // Add each token to the result in forward order
        var i: Int64 = symbols.size - 1
        while (i >= 0) {
            symbols.get(i).getOrThrow().appendTo(bitArray, text)
            i--
        }
        return bitArray
    }

    public func toString(): String {
        return "${HighLevelEncoder.MODE_NAMES[mode]} bits=${bitCount} bytes=${binaryShiftByteCount}"
    }

    private static func calculateBinaryShiftCost(binaryShiftByteCount: Int64): Int64 {
        if (binaryShiftByteCount > 62) {
            return 21 // B/S with extended size
        }
        if (binaryShiftByteCount > 31) {
            return 20 // two B/S
        }
        if (binaryShiftByteCount > 0) {
            return 10 // one B/S
        }
        return 0
    }
}
