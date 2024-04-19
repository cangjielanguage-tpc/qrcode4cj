/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned

// Results of minimal lookahead for code C
enum CType <: ToString & Equatable<CType> {
    UNCODABLE | ONE_DIGIT | TWO_DIGITS | FNC_1

    public operator func ==(right: CType): Bool {
        if (right.toString() == this.toString()) {
            true
        } else {
            false
        }
    }

    public operator func !=(right: CType): Bool {
        if (right.toString() != this.toString()) {
            true
        } else {
            false
        }
    }

    public func toString(): String {
        match (this) {
            case UNCODABLE => return "UNCODABLE"
            case ONE_DIGIT => return "ONE_DIGIT"
            case TWO_DIGITS => return "TWO_DIGITS"
            case FNC_1 => return "FNC_1"
        }
    }
}

/**
 * This object renders a CODE128 code as a {@link BitMatrix}.
 */
public open class Code128Writer <: OneDimensionalCodeWriter {
    private static let CODE_START_A: Int64 = 103
    private static let CODE_START_B: Int64 = 104
    private static let CODE_START_C: Int64 = 105
    private static let CODE_CODE_A: Int64 = 101
    private static let CODE_CODE_B: Int64 = 100
    private static let CODE_CODE_C: Int64 = 99
    private static let CODE_STOP: Int64 = 106

    // Dummy characters used to specify control characters in input
    private static let ESCAPE_FNC_1: Char = '\u{00f1}'
    private static let ESCAPE_FNC_2: Char = '\u{00f2}'
    private static let ESCAPE_FNC_3: Char = '\u{00f3}'
    private static let ESCAPE_FNC_4: Char = '\u{00f4}'

    private static let CODE_FNC_1: Int64 = 102 // Code A, Code B, Code C
    private static let CODE_FNC_2: Int64 = 97 // Code A, Code B
    private static let CODE_FNC_3: Int64 = 96 // Code A, Code B
    private static let CODE_FNC_4_A: Int64 = 101 // Code A
    private static let CODE_FNC_4_B: Int64 = 100 // Code B

    protected override func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        var returnData: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        returnData.append(BarcodeFormat.CODE_128)
        return returnData
    }

    public func encode(contents: String): Array<Bool> {
        return encode(contents, HashMap<EncodeHintType, Any>())
    }

    public func encode(contents: String, hints: HashMap<EncodeHintType, Any>): Array<Bool> {
        var contentsUtf = UTF32String(contents)
        var forcedCodeSet: Int64 = check(contentsUtf, hints)
        var hashmapvalue_bool = false
        if (let Some(hashmapvalue) <- hints.get(EncodeHintType.CODE128_COMPACT)) {
            hashmapvalue_bool = true
        }
        var hasCompactionHint: Bool = hints.size > 0 && hints.contains(EncodeHintType.CODE128_COMPACT) &&
            hashmapvalue_bool

        if (hasCompactionHint) {
            return MinimalEncoder().encode(contents)
        } else {
            return encodeFast(contentsUtf, forcedCodeSet)
        }
    }

    private static func check(contents: UTF32String, hints: HashMap<EncodeHintType, Any>): Int64 {
        var length: Int64 = contents.charSize

        excheck(length)

        // Check for forced code set hint.
        var forcedCodeSet: Int64 = -1
        forcedCodeSet = excheck(hints, forcedCodeSet)

        /* Check content */
        for (i in 0..length) {
            var c: Char = contents.get(i)

            // check for non ascii characters that are not special GS1 characters

            // special function characters
            if (!(c == ESCAPE_FNC_1 || c == ESCAPE_FNC_2 || c == ESCAPE_FNC_3 || c == ESCAPE_FNC_4)) {
                if (c.hashCode() > 127) {
                    // no full Latin-1 character set available at the moment shift
                    // and manual code change are not supported
                    throw IllegalArgumentException("Bad character in input: ASCII value=${c.hashCode()}")
                }
            }

            // check characters for compatibility with forced code set
            if (forcedCodeSet == CODE_CODE_A) {
                /* allows no ascii above 95 (no lower caps, no special symbols) */
                if (c.hashCode() > 95 && c.hashCode() <= 127) {
                    throw IllegalArgumentException(
                        "Bad character in input for forced code set A: ASCII value=${c.hashCode()}")
                }
            }
            if (forcedCodeSet == CODE_CODE_B) {
                /* allows no ascii below 32 (terminal symbols) */
                if (c.hashCode() <= 32) {
                    throw IllegalArgumentException(
                        "Bad character in input for forced code set B: ASCII value=${c.hashCode()}")
                }
            }
            if (forcedCodeSet == CODE_CODE_C) {
                /* allows only numbers and no FNC 2/3/4 */
                if (c.hashCode() < 48 || (c.hashCode() > 57 && c.hashCode() <= 127) || c == ESCAPE_FNC_2 || c ==
                    ESCAPE_FNC_3 || c == ESCAPE_FNC_4) {
                    throw IllegalArgumentException(
                        "Bad character in input for forced code set C: ASCII value=${c.hashCode()}")
                }
            }
        }
        return forcedCodeSet
    }

    private static func excheck(length: Int64) {
        // Check length
        if (length < 1 || length > 80) {
            throw IllegalArgumentException("Contents length should be between 1 and 80 characters, but got ${length}")
        }
    }

    private static func excheck(hints: HashMap<EncodeHintType, Any>, forcedCodeSet: Int64): Int64 {
        if (hints.size > 0 && hints.contains(EncodeHintType.FORCE_CODE_SET)) {
            var hashmapvalue = hints.get(EncodeHintType.FORCE_CODE_SET).getOrThrow() as String
            var codeSetHint: String = hashmapvalue.getOrThrow()
            match (codeSetHint) {
                case "A" => return CODE_CODE_A

                case "B" => return CODE_CODE_B

                case "C" => return CODE_CODE_C

                case _ => throw IllegalArgumentException("Unsupported code set hint: ${codeSetHint}")
            }
        }
        return forcedCodeSet
    }

    private static func encodeFast(contents: UTF32String, forcedCodeSet: Int64): Array<Bool> {
        var length: Int64 = contents.charSize

        var patterns: ArrayList<Array<Int64>> = ArrayList<Array<Int64>>()

        // temporary storage for patterns
        var checkSum: Int64 = 0
        var checkWeight: Int64 = 1
        var codeSet: Int64 = 0 // selected code (CODE_CODE_B or CODE_CODE_C)
        var position: Int64 = 0 // position in contents

        while (position < length) {
            /* Select code to use */
            var newCodeSet: Int64
            if (forcedCodeSet == -1) {
                newCodeSet = chooseCode(contents, position, codeSet)
            } else {
                newCodeSet = forcedCodeSet
            }

            //Get the pattern index
            var patternIndex: Int64 = 0
            if (newCodeSet == codeSet) {
                // Encode the current character, First handle escapes
                var data: Char = contents.get(position)
                (patternIndex, position) = extencodeFast(patternIndex, data, codeSet, contents, position, length)
                position++
            } else {
                // Should we change the current code? Do we
                // have a code set?
                if (codeSet == 0) {
                    /* No, we don't have a code set */
                    if (newCodeSet == CODE_CODE_A) {
                        patternIndex = CODE_START_A
                    } else if (newCodeSet == CODE_CODE_B) {
                        patternIndex = CODE_START_B
                    } else {
                        patternIndex = CODE_START_C
                    }
                } else {
                    /* Yes, we have a code set */
                    patternIndex = newCodeSet
                }
                codeSet = newCodeSet
            }

            /* Get the pattern */
            patterns.append(Code128Reader.CODE_PATTERNS[patternIndex])

            /* Compute checksum*/
            checkSum += patternIndex * checkWeight
            if (position != 0) {
                checkWeight++
            }
        }
        return produceResult(patterns, checkSum)
    }

    private static func extencodeFast(patternIndex: Int64, data: Char, codeSet: Int64, contents: UTF32String,
        position: Int64, length: Int64): (Int64, Int64) {
        var patternIndex_p = patternIndex
        var position_p = position
        if (data == ESCAPE_FNC_1) {
            patternIndex_p = CODE_FNC_1
        } else if (data == ESCAPE_FNC_2) {
            patternIndex_p = CODE_FNC_2
        } else if (data == ESCAPE_FNC_3) {
            patternIndex_p = CODE_FNC_3
        } else if (data == ESCAPE_FNC_4) {
            if (codeSet == CODE_CODE_A) {
                patternIndex_p = CODE_FNC_4_A
            } else {
                patternIndex_p = CODE_FNC_4_B
            }
        } else {
            // Then handle normal characters otherwise
            if (codeSet == CODE_CODE_A) {
                patternIndex_p = contents.get(position_p).hashCode() - ' '.hashCode()
                if (patternIndex_p < 0) {
                    // everything below a space character comes behind the underscore in the code patterns table
                    patternIndex_p += '`'.hashCode()
                }
            } else if (codeSet == CODE_CODE_B) {
                patternIndex_p = contents.get(position_p).hashCode() - ' '.hashCode()
            } else {
                // CODE_CODE_C
                if (position_p + 1 == length) {
                    // this is the last character, but the encoding is C, which always encodes two characers
                    throw IllegalArgumentException("Bad number of characters for digit only encoding.")
                }
                patternIndex_p = Int64.parse(contents.substring(position_p, 2).toString())
                position_p++
                // Also incremented below
            }
        }
        return (patternIndex_p, position_p)
    }

    static func produceResult(patterns: ArrayList<Array<Int64>>, checkSumin: Int64): Array<Bool> {
        // Compute and append checksum
        var checkSum: Int64 = checkSumin
        checkSum %= 103
        patterns.append(Code128Reader.CODE_PATTERNS[checkSum])

        // Append stop code
        patterns.append(Code128Reader.CODE_PATTERNS[CODE_STOP])

        // Compute code width
        var codeWidth: Int64 = 0

        for (i in 0..patterns.size) {
            for (j in 0..patterns[i].size) {
                codeWidth += patterns[i][j]
            }
        }

        // Compute result
        var result: Array<Bool> = Array<Bool>(codeWidth, item: false)
        var pos: Int64 = 0

        for (i in 0..patterns.size) {
            pos += appendPattern(result, pos, patterns[i], true)
        }

        return result
    }

    private static func findCType(value: UTF32String, start: Int64): CType {
        var last: Int64 = value.charSize
        if (start >= last) {
            return CType.UNCODABLE
        }
        var c_: Char = value.get(start)
        if (c_ == ESCAPE_FNC_1) {
            return CType.FNC_1
        }
        if (c_ < '0' || c_ > '9') {
            return CType.UNCODABLE
        }
        if (start + 1 >= last) {
            return CType.ONE_DIGIT
        }
        c_ = value.get(start + 1)
        if (c_ < '0' || c_ > '9') {
            return CType.ONE_DIGIT
        }
        return CType.TWO_DIGITS
    }

    private static func chooseCode(value: UTF32String, start: Int64, oldCode: Int64): Int64 {
        var lookahead: CType = findCType(value, start)
        if (lookahead == CType.ONE_DIGIT) {
            if (oldCode == CODE_CODE_A) {
                return CODE_CODE_A
            }
            return CODE_CODE_B
        }
        if (lookahead == CType.UNCODABLE) {
            return exchooseCode(start, value, oldCode)
        }
        if (oldCode == CODE_CODE_A && lookahead == CType.FNC_1) {
            return CODE_CODE_A
        }
        if (oldCode == CODE_CODE_C) { /* can continue in code C */
            return CODE_CODE_C
        }
        if (oldCode == CODE_CODE_B) {
            if (lookahead == CType.FNC_1) {
                return CODE_CODE_B
                // can continue in code B
            }

            /* Seen two consecutive digits, see what follows */
            lookahead = findCType(value, start + 2)
            if (lookahead == CType.UNCODABLE || lookahead == CType.ONE_DIGIT) {
                return CODE_CODE_B
                // not worth switching now
            }
            if (lookahead == CType.FNC_1) { // two digits, then FNC_1...
                lookahead = findCType(value, start + 3)
                if (lookahead == CType.TWO_DIGITS) { /* then two more digits, switch */
                    return CODE_CODE_C
                } else {
                    return CODE_CODE_B
                    // otherwise not worth switching
                }
            }

            // At this point, there are at least 4 consecutive digits. Look
            // ahead to choose whether to switch now or on the next round.
            return extracted(value, start)

            // even number of digits, switch now
        }

        // Here oldCode == 0, which means we are choosing the initial code
        if (lookahead == CType.FNC_1) { // ignore FNC_1
            lookahead = findCType(value, start + 1)
        }
        if (lookahead == CType.TWO_DIGITS) { // at least two digits, start in code C
            return CODE_CODE_C
        }
        return CODE_CODE_B
    }

    private static func exchooseCode(start: Int64, value: UTF32String, oldCode: Int64) {
        if (start < value.size) {
            var c: Char = value.get(start)
            if (c < ' ' || (oldCode == CODE_CODE_A && (c < '`' || (c >= ESCAPE_FNC_1 && c <= ESCAPE_FNC_4)))) {
                // can continue in code A, encodes ASCII 0 to 95 or FNC1 to FNC4
                return CODE_CODE_A
            }
        }
        return CODE_CODE_B
        // no choice

    }

    private static func extracted(value: UTF32String, start: Int64): Int64 {
        var index: Int64 = start + 4
        var lookahead = findCType(value, index)
        while (lookahead == CType.TWO_DIGITS) {
            lookahead = findCType(value, index)
            index += 2
        }
        if (lookahead == CType.ONE_DIGIT) { // odd number of digits, switch later
            return CODE_CODE_B
        }
        return CODE_CODE_C
    }
}

enum Charset <: ToString & Equatable<Charset> {
    A | B | C | CNONE

    public operator func ==(right: Charset): Bool {
        if (right.toString() == this.toString()) {
            true
        } else {
            false
        }
    }

    public operator func !=(right: Charset): Bool {
        if (right.toString() != this.toString()) {
            true
        } else {
            false
        }
    }

    public func toString(): String {
        match (this) {
            case A => return "A"
            case B => return "B"
            case C => return "C"
            case CNONE => return "CNONE"
        }
    }
    public func ordinal(): Int64 {
        match (this) {
            case A => return 0
            case B => return 1
            case C => return 2
            case CNONE => return 3
        }
    }
}

enum Latch <: ToString & Equatable<Latch> {
    A | B | C | SHIFT | LNONE

    public operator func ==(right: Latch): Bool {
        if (right.toString() == this.toString()) {
            true
        } else {
            false
        }
    }

    public operator func !=(right: Latch): Bool {
        if (right.toString() != this.toString()) {
            true
        } else {
            false
        }
    }

    public func toString(): String {
        match (this) {
            case A => return "A"
            case B => return "B"
            case C => return "C"
            case SHIFT => return "SHIFT"
            case LNONE => return "LNONE"
        }
    }
    public static func valueOf(str: String): Latch {
        if (str == "A") {
            return A
        } else if (str == "B") {
            return B
        } else if (str == "C") {
            return C
        } else {
            return LNONE
        }
    }
}

/**
 * Encodes minimally using Divide-And-Conquer with Memoization
 */
open class MinimalEncoder <: OneDimensionalCodeWriter {
    private static let CODE_START_A: Int64 = 103
    private static let CODE_START_B: Int64 = 104
    private static let CODE_START_C: Int64 = 105
    private static let CODE_CODE_A: Int64 = 101
    private static let CODE_CODE_B: Int64 = 100
    private static let CODE_CODE_C: Int64 = 99
    private static let CODE_STOP: Int64 = 106

    // Dummy characters used to specify control characters in input
    private static let ESCAPE_FNC_1: Char = '\u{00f1}'
    private static let ESCAPE_FNC_2: Char = '\u{00f2}'
    private static let ESCAPE_FNC_3: Char = '\u{00f3}'
    private static let ESCAPE_FNC_4: Char = '\u{00f4}'

    private static let CODE_FNC_1: Int64 = 102 // Code A, Code B, Code C
    private static let CODE_FNC_2: Int64 = 97 // Code A, Code B
    private static let CODE_FNC_3: Int64 = 96 // Code A, Code B
    private static let CODE_FNC_4_A: Int64 = 101 // Code A
    private static let CODE_FNC_4_B: Int64 = 100 // Code B
    static let A: String = " !\"#$%&'()*+,-./0123456789:<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\u{0000}\u{0001}\u{0002}" +
        "\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}\u{0008}\u{0009}\n\u{000B}\u{000C}\r\u{000E}\u{000F}\u{0010}\u{0011}" +
        "\u{0012}\u{0013}\u{0014}\u{0015}\u{0016}\u{0017}\u{0018}\u{0019}\u{001A}\u{001B}\u{001C}\u{001D}\u{001E}\u{001F}" +
        "\u{00FF}"
    static let B: String = " !\"#$%&'()*+,-./0123456789:<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqr" +
        "stuvwxyz{|}~\u{007F}\u{00FF}"

    private static let CODE_SHIFT: Int64 = 98

    private var memoizedCost: Array<Array<Int64>> = Array<Array<Int64>>()
    private var minPath: Array<Array<Latch>> = Array<Array<Latch>>()
    static func produceResult(patterns: ArrayList<Array<Int64>>, checkSumin: Int64): Array<Bool> {
        // Compute and append checksum
        var checkSum: Int64 = checkSumin
        checkSum %= 103
        patterns.append(Code128Reader.CODE_PATTERNS[checkSum])

        // Append stop code
        patterns.append(Code128Reader.CODE_PATTERNS[CODE_STOP])

        // Compute code width
        var codeWidth: Int64 = 0

        for (i in 0..patterns.size) {
            for (j in 0..patterns[i].size) {
                codeWidth += patterns[i][j]
            }
        }

        // Compute result
        var result: Array<Bool> = Array<Bool>(codeWidth, item: false)
        var pos: Int64 = 0

        for (i in 0..patterns.size) {
            pos += appendPattern(result, pos, patterns[i], true)
        }

        return result
    }

    public func encode(contents: String): Array<Bool> {
        let contentsUtf = UTF32String(contents)
        memoizedCost = Array<Array<Int64>>(4, {a: Int64 => Array<Int64>(contentsUtf.charSize, item: 0)})
        minPath = Array<Array<Latch>>(4, {b: Int64 => Array<Latch>(contentsUtf.charSize, item: LNONE)})

        encode(contentsUtf, Charset.CNONE, 0)

        var patterns: ArrayList<Array<Int64>> = ArrayList<Array<Int64>>()
        var checkSum: Array<Int64> = Array<Int64>(1, item: 0)
        var checkWeight: Array<Int64> = Array<Int64>(1, item: 1)
        var length: Int64 = contentsUtf.charSize
        var charset: Charset = Charset.CNONE

        var i: Int64 = 0

        while (i < length) {
            var latch: Latch = minPath[charset.ordinal()][i]
            (charset, latch) = exencode(charset, i, patterns, checkSum, checkWeight)
            match (charset) {
                case Charset.C => if (contentsUtf.get(i) == ESCAPE_FNC_1) {
                    addPattern(patterns, CODE_FNC_1, checkSum, checkWeight, i)
                } else {
                    addPattern(patterns, Int64.parse(contentsUtf.substring(i, 2).toString()), checkSum, checkWeight, i)
                    if (i + 1 < length) {
                        i++
                    }
                }
                case _ =>
                    // charset A or B
                    var patternIndex: Int64 = 0
                    if (contentsUtf.get(i) == ESCAPE_FNC_1) {
                        patternIndex = CODE_FNC_1
                    } else if (contentsUtf.get(i) == ESCAPE_FNC_2) {
                        patternIndex = CODE_FNC_2
                    } else if (contentsUtf.get(i) == ESCAPE_FNC_3) {
                        patternIndex = CODE_FNC_3
                    } else if (contentsUtf.get(i) == ESCAPE_FNC_4) {
                        if (charset == Charset.A && latch != Latch.SHIFT || charset == Charset.B && latch == Latch.SHIFT) {
                            patternIndex = CODE_FNC_4_A
                        } else {
                            patternIndex = CODE_FNC_4_B
                        }
                    } else {
                        patternIndex = contentsUtf.get(i).hashCode() - ' '.hashCode()
                    }
                    if ((charset == Charset.A && latch != Latch.SHIFT || charset == Charset.B && latch == Latch.SHIFT) &&
                        patternIndex < 0) {
                        patternIndex += '`'.hashCode()
                    }
                    addPattern(patterns, patternIndex, checkSum, checkWeight, i)
            }
            i++
        }
        // memoizedCost = Array<Array<Int64>>()
        // minPath = Array<Array<Latch>>()
        return produceResult(patterns, checkSum[0])
    }

    private func exencode(charset: Charset, i: Int64, patterns: ArrayList<Array<Int64>>, checkSum: Array<Int64>,
        checkWeight: Array<Int64>): (Charset, Latch) {
        var charset_p = charset
        var latch: Latch = minPath[charset_p.ordinal()][i]
        if (latch == Latch.A) {
            charset_p = Charset.A
            if (i == 0) {
                addPattern(patterns, CODE_START_A, checkSum, checkWeight, i)
            } else {
                addPattern(patterns, CODE_CODE_A, checkSum, checkWeight, i)
            }
        } else if (latch == Latch.B) {
            charset_p = Charset.B
            if (i == 0) {
                addPattern(patterns, CODE_START_B, checkSum, checkWeight, i)
            } else {
                addPattern(patterns, CODE_CODE_B, checkSum, checkWeight, i)
            }
        } else if (latch == Latch.C) {
            charset_p = Charset.C
            if (i == 0) {
                addPattern(patterns, CODE_START_C, checkSum, checkWeight, i)
            } else {
                addPattern(patterns, CODE_CODE_C, checkSum, checkWeight, i)
            }
        } else if (latch == Latch.SHIFT) {
            addPattern(patterns, CODE_SHIFT, checkSum, checkWeight, i)
        }
        return (charset_p, latch)
    }

    private static func addPattern(
        patterns: ArrayList<Array<Int64>>,
        patternIndex: Int64,
        checkSum: Array<Int64>,
        checkWeight: Array<Int64>,
        position: Int64
    ) {
        patterns.append(Code128Reader.CODE_PATTERNS[patternIndex])
        if (position != 0) {
            checkWeight[0] = checkWeight[0] + 1
        }
        checkSum[0] += patternIndex * checkWeight[0]
    }

    private static func isDigit(c: Char): Bool {
        return c >= '0' && c <= '9'
    }

    private func canEncode(contents: UTF32String, charset: Charset, position: Int64): Bool {
        var c: Char = contents.get(position)

        match (charset) {
            case A => if (c == ESCAPE_FNC_1 || c == ESCAPE_FNC_2 || c == ESCAPE_FNC_3 || c == ESCAPE_FNC_4) {
                return true
            } else {
                if (let Some(index) <- A.indexOf(c.toString())) {
                    return index >= 0
                } else {
                    return false
                }
            }
            case B => if (c == ESCAPE_FNC_1 || c == ESCAPE_FNC_2 || c == ESCAPE_FNC_3 || c == ESCAPE_FNC_4) {
                return true
            } else {
                if (let Some(index) <- B.indexOf(c.toString())) {
                    return index >= 0
                } else {
                    return false
                }
            }

            case C => return c == ESCAPE_FNC_1 || (position + 1 < contents.charSize && isDigit(c) && isDigit(
                contents.get(position + 1)))
            case _ => return false
        }
    }

    /**
     * Encode the string starting at position position starting with the character set charset
     * */
    private func encode(contents: UTF32String, charset: Charset, position: Int64): Int64 {
        var mCost: Int64 = memoizedCost[charset.ordinal()][position]
        if (mCost > 0) {
            return mCost
        }

        var minCost: Int64 = 0x7fffffff
        var minLatch: Latch = Latch.LNONE
        var atEnd: Bool = position + 1 >= contents.charSize

        var sets: Array<Charset> = Array<Charset>([Charset.A, Charset.B])

        for (i in 0..2) {
            if (canEncode(contents, sets[i], position)) {
                var cost: Int64 = 1
                var latch: Latch = Latch.LNONE
                if (charset != sets[i]) {
                    cost++
                    latch = Latch.valueOf(sets[i].toString())
                }
                if (!atEnd) {
                    cost += encode(contents, sets[i], position + 1)
                }
                if (cost < minCost) {
                    minCost = cost
                    minLatch = latch
                }
                cost = 1
                if (charset == sets[(i + 1) % 2]) {
                    cost++
                    latch = Latch.SHIFT
                    if (!atEnd) {
                        cost += encode(contents, charset, position + 1)
                    }
                    if (cost < minCost) {
                        minCost = cost
                        minLatch = latch
                    }
                }
            }
        }
        if (canEncode(contents, Charset.C, position)) {
            (minCost, minLatch) = getminCostminLatch(minCost, minLatch, contents, charset, position)
        }
        if (minCost == 0x7fffffff) {
            throw IllegalArgumentException("Bad character in input: ASCII value=${contents.get(position).hashCode()}")
        }
        memoizedCost[charset.ordinal()][position] = minCost
        minPath[charset.ordinal()][position] = minLatch
        return minCost
    }

    private func getminCostminLatch(minCost: Int64, minLatch: Latch, contents: UTF32String, charset: Charset,
        position: Int64): (Int64, Latch) {
        var cost: Int64 = 1
        var latch: Latch = Latch.LNONE
        if (charset != Charset.C) {
            cost++
            latch = Latch.C
        }
        var advance: Int64 = 0
        if (contents.get(position) == ESCAPE_FNC_1) {
            advance = 1
        } else {
            advance = 2
        }
        if (position + advance < contents.charSize) {
            cost += encode(contents, Charset.C, position + advance)
        }
        if (cost < minCost) {
            return (cost, latch)
        }
        return (minCost, minLatch)
    }
}
