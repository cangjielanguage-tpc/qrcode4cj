/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * zlib压缩算法
 */

package image.png.zlib

import std.math.*
import std.sort.*
import std.io.*
import std.collection.*
import image.internals.imageutil.*

/* let member offsetCodeCount */
let offsetCodeCount = 30

/* let member endBlockMarker */
let endBlockMarker = 256

/* let member endBlockMarkerToken */
let endBlockMarkerToken = Token(256)

/* let member lengthCodesStart */
let lengthCodesStart = 257

/* let member codegenCodeCount */
let codegenCodeCount = 19

/* let member badCode type is UInt8 */
let badCode: UInt8 = 255

/* let member bufferFlushSize */
let bufferFlushSize = 240

/* let member bufferSize */
let bufferSize = bufferFlushSize + 8

/* let member lengthExtraBits type is Array<Int8> */
let lengthExtraBits: Array<Int8> = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    1,
    1,
    1,
    2,
    2,
    2,
    2,
    3,
    3,
    3,
    3,
    4,
    4,
    4,
    4,
    5,
    5,
    5,
    5,
    0
]

/* let member lengthBase type is Array<UInt32> */
let lengthBase: Array<UInt32> = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    10,
    12,
    14,
    16,
    20,
    24,
    28,
    32,
    40,
    48,
    56,
    64,
    80,
    96,
    112,
    128,
    160,
    192,
    224,
    255
]

/* let member offsetExtraBits type is Array<Int8> */
let offsetExtraBits: Array<Int8> = [
    0,
    0,
    0,
    0,
    1,
    1,
    2,
    2,
    3,
    3,
    4,
    4,
    5,
    5,
    6,
    6,
    7,
    7,
    8,
    8,
    9,
    9,
    10,
    10,
    11,
    11,
    12,
    12,
    13,
    13
]

/* let member offsetBase type is Array<UInt32> */
let offsetBase: Array<UInt32> = [
    0x000000,
    0x000001,
    0x000002,
    0x000003,
    0x000004,
    0x000006,
    0x000008,
    0x00000c,
    0x000010,
    0x000018,
    0x000020,
    0x000030,
    0x000040,
    0x000060,
    0x000080,
    0x0000c0,
    0x000100,
    0x000180,
    0x000200,
    0x000300,
    0x000400,
    0x000600,
    0x000800,
    0x000c00,
    0x001000,
    0x001800,
    0x002000,
    0x003000,
    0x004000,
    0x006000
]

/* let member codegenOrder type is Array<UInt32> */
let codegenOrder: Array<UInt32> = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]

/* let member lengthShift type is Int32 */
let lengthShift: Int32 = 22

/* let member offsetMask type is Int32 */
let offsetMask: Int32 = (1 << lengthShift) - 1

/* let member typeMask type is Int32 */
let typeMask: Int32 = 3 << 30

/* let member literalType type is Int32 */
let literalType: Int32 = 0 << 30

/* let member matchType type is Int32 */
let matchType: Int32 = 1 << 30

/* let member lengthCodes type is Array<UInt32> */
let lengthCodes: Array<UInt32> = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    8,
    9,
    9,
    10,
    10,
    11,
    11,
    12,
    12,
    12,
    12,
    13,
    13,
    13,
    13,
    14,
    14,
    14,
    14,
    15,
    15,
    15,
    15,
    16,
    16,
    16,
    16,
    16,
    16,
    16,
    16,
    17,
    17,
    17,
    17,
    17,
    17,
    17,
    17,
    18,
    18,
    18,
    18,
    18,
    18,
    18,
    18,
    19,
    19,
    19,
    19,
    19,
    19,
    19,
    19,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    20,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    21,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    22,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    23,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    24,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    25,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    26,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    27,
    28
]

/* let member offsetCodes type is Array<UInt32> */
let offsetCodes: Array<UInt32> = [
    0,
    1,
    2,
    3,
    4,
    4,
    5,
    5,
    6,
    6,
    6,
    6,
    7,
    7,
    7,
    7,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    9,
    9,
    9,
    9,
    9,
    9,
    9,
    9,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    11,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    12,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    13,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    14,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15,
    15
]

/*
 * The class is Token inherited from ToString
 * @author changeden
 */
class Token <: ToString {
    /* var member t type is UInt32 */
    var t: UInt32 = 0

    /*
     * The Function is init constructor
     *
     */
    init() {}

    /*
     * The Function is init constructor
     *
     * @param t of UInt32
     */
    init(t: UInt32) {
        this.t = t
    }

    /*
     * The Function is literal
     *
     * @return Type of UInt32
     */
    @OverflowWrapping
    func literal(): UInt32 {
        UInt32(Int32(this.t) - literalType)
    }

    /*
     * The Function is offset
     *
     * @return Type of UInt32
     */
    @OverflowWrapping
    func offset(): UInt32 {
        UInt32(Int32(t) & offsetMask)
    }

    /*
     * The Function is length
     *
     * @return Type of UInt32
     */
    @OverflowWrapping
    func length(): UInt32 {
        UInt32((Int32(t) - matchType) >> lengthShift)
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "${t}"
    }
}

/*
 * The Function is literalToken
 *
 * @param literal of UInt32
 *
 * @return Type of Token
 */
func literalToken(literal: UInt32): Token {
    Token(UInt32(literalType) + literal)
}

/*
 * The Function is matchToken
 *
 * @param xlength of UInt32
 * @param xoffset of UInt32
 *
 * @return Type of Token
 */
func matchToken(xlength: UInt32, xoffset: UInt32): Token {
    Token(UInt32(matchType) + (xlength << lengthShift) + xoffset)
}

/*
 * The Function is lengthCode
 *
 * @param len of UInt32
 *
 * @return Type of UInt32
 */
func lengthCode(len: UInt32): UInt32 {
    lengthCodes[Int64(len)]
}

/*
 * The Function is offsetCode
 *
 * @param off of UInt32
 *
 * @return Type of UInt32
 */
func offsetCode(off: UInt32): UInt32 {
    if (off < UInt32(offsetCodes.size)) {
        offsetCodes[Int64(off)]
    } else if ((off >> 7) < UInt32(offsetCodes.size)) {
        offsetCodes[Int64(off >> 7)] + 14
    } else {
        offsetCodes[Int64(off >> 14)] + 28
    }
}

/*
 * The class is Hcode inherited from ToString
 * @author changeden
 */
class Hcode <: ToString {
    /* var member code type is UInt16 */
    var code: UInt16 = 0

    /* var member len type is UInt16 */
    var len: UInt16 = 0

    /*
     * The Function is init constructor
     *
     */
    init() {}

    /*
     * The Function is init constructor
     *
     * @param code of UInt16
     * @param length of UInt16
     */
    init(code: UInt16, length: UInt16) {
        set(code, length)
    }

    /*
     * The Function is set
     *
     * @param code of UInt16
     * @param length of UInt16
     *
     * @return Type of Unit
     */
    func set(code: UInt16, length: UInt16): Unit {
        this.len = length
        this.code = code
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "code=${code} len=${len}"
    }
}

/* let member maxBitsLimit */
let maxBitsLimit = 16

extend<T> Array<T> where T <: Hashable {
    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("size=${this.size}")
        for (i in 0..this.size) {
            dfh.write("${i}=${this[i].hashCode()},")
        }
        return dfh.finish()
    }
}

/*
 * The class is HuffmanEncoder inherited from Hashable
 * @author changeden
 */
class HuffmanEncoder <: Hashable {
    /* var member codes type is Array<Hcode> */
    var codes: Array<Hcode>

    /* var member freqcache type is ?Array<LiteralNode> */
    var freqcache: ?Array<LiteralNode> = None

    /* let member bitCount type is Array<Int32> */
    let bitCount: Array<Int32> = Array<Int32>(17, repeat: 0)

    /* var member lns type is ByLiteral */
    var lns: ByLiteral = ByLiteral()

    /* var member lfs type is ByFreq */
    var lfs: ByFreq = ByFreq()

    /*
     * The Function is init constructor
     *
     * @param size of Int64
     */
    init(size: Int64) {
        this.codes = Array<Hcode>(size, {_ => Hcode()})
    }

    /*
     * The Function is bitLength
     *
     * @param freq of Array<Int32>
     *
     * @return Type of Int64
     */
    func bitLength(freq: Array<Int32>): Int64 {
        var total: Int32 = 0
        for (i in 0..freq.size) {
            let f = freq[i]
            if (f != 0) {
                total += Int32(f) * Int32(this.codes[i].len)
            }
        }
        Int64(total)
    }

    /*
     * The Function is bitCounts
     *
     * @param nlist of Array<LiteralNode>
     * @param maxBits of Int32
     *
     * @return Type of (Array<Int32>, Array<LiteralNode>)
     */
    func bitCounts(nlist: Array<LiteralNode>, maxBits: Int32): (Array<Int32>, Array<LiteralNode>) {
        if (maxBits >= Int32(maxBitsLimit)) {
            throw Exception("flate: maxBits too large")
        }
        var n: Int32 = Int32(nlist.size)
        let mlist = ArrayList<LiteralNode>(nlist)
        mlist.append(maxNode())
        let mmaxBits = if (maxBits > n - 1) {
            n - 1
        } else {
            maxBits
        }
        let levels = Array<LevelInfo>(maxBitsLimit, repeat: LevelInfo())
        let leafCounts = Array<Array<Int32>>(maxBitsLimit, {_ => Array<Int32>(maxBitsLimit, repeat: 0)})
        for (level in 1..=mmaxBits) {
            let l = Int64(level)
            levels[l] = LevelInfo(level, mlist[1].freq, mlist[2].freq, mlist[0].freq + mlist[1].freq)
            leafCounts[l][l] = 2
            if (level == 1) {
                levels[l].nextPairFreq = Int32.Max
            }
        }
        levels[Int64(mmaxBits)].needed = 2 * n - 4

        var level = Int64(mmaxBits)
        while (true) {
            let l = levels[level]
            if (l.nextPairFreq == Int32.Max && l.nextCharFreq == Int32.Max) {
                l.needed = 0
                levels[level + 1].nextPairFreq = Int32.Max
                level++
                continue
            }
            let prevFreq = l.lastFreq
            if (l.nextCharFreq < l.nextPairFreq) {
                let n = leafCounts[level][level] + 1
                l.lastFreq = l.nextCharFreq
                leafCounts[level][level] = n
                l.nextCharFreq = mlist[Int64(n)].freq
            } else {
                l.lastFreq = l.nextPairFreq
                copy(leafCounts[level], leafCounts[level - 1], dstEnd: level, srcEnd: level)
                levels[Int64(l.level - 1)].needed = 2
            }

            l.needed--
            if (l.needed == 0) {
                if (l.level == mmaxBits) {
                    break
                }
                levels[Int64(l.level + 1)].nextPairFreq = prevFreq + l.lastFreq
                level++
            } else {
                while (levels[level - 1].needed > 0) {
                    level--
                }
            }
        }

        if (leafCounts[Int64(mmaxBits)][Int64(mmaxBits)] != n) {
            throw Exception("leafCounts[maxBits][maxBits] != ${n}")
        }

        let bitCount = this.bitCount[0..Int64(mmaxBits + 1)]
        var bits = 1
        let counts = leafCounts[Int64(mmaxBits)]
        for (l in mmaxBits..0 : -1) {
            bitCount[bits] = counts[Int64(l)] - counts[Int64(l) - 1]
            bits++
        }
        copy(this.bitCount, bitCount)
        (bitCount, mlist.toArray())
    }

    /*
     * The Function is assignEncodingAndSize
     *
     * @param bitCount of Array<Int32>
     * @param list of Array<LiteralNode>
     */
    func assignEncodingAndSize(bitCount: Array<Int32>, list: Array<LiteralNode>) {
        var code: UInt16 = 0
        var mlist = list
        for (n in 0..bitCount.size) {
            let bits = bitCount[n]
            code <<= 1
            if (n == 0 || bits == 0) {
                continue
            }
            let chunk = mlist[(mlist.size - Int64(bits))..mlist.size]
            this.lns.sort(chunk)
            for (node in chunk) {
                this.codes[Int64(node.literal)] = Hcode(reverseBits(code, UInt8(n)), UInt16(n))
                code++
            }
            mlist = mlist[0..(mlist.size - Int64(bits))]
        }
    }

    /*
     * The Function is generate
     *
     * @param freq of Array<Int32>
     * @param maxBits of Int32
     */
    func generate(freq: Array<Int32>, maxBits: Int32) {
        if (let None <- this.freqcache) {
            this.freqcache = Array<LiteralNode>(maxNumLit + 1, {_ => LiteralNode()})
        }
        var list = this.freqcache.getOrThrow()
        list = list[0..(freq.size + 1)]

        var count = 0
        for (i in 0..freq.size) {
            let f = freq[i]
            if (f != 0) {
                list[count] = LiteralNode(UInt16(i), f)
                count++
            } else {
                list[count] = LiteralNode()
                this.codes[i].len = 0
            }
        }
        list[freq.size] = LiteralNode()
        copy(this.freqcache.getOrThrow(), list)
        list = list[0..count]
        if (count <= 2) {
            for (i in 0..list.size) {
                let node = list[i]
                this.codes[Int64(node.literal)].set(UInt16(i), 1)
            }
            return
        }
        this.lfs.sort(list)
        let (mbitCount, mlist) = bitCounts(list, maxBits)
        copy(this.freqcache.getOrThrow(), mlist)
        assignEncodingAndSize(mbitCount, list)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("HuffmanEncoder")
        dfh.write(codes.size.hashCode())
        if (let Some(f) <- freqcache) {
            f.hashCode()
        }
        dfh.write(bitCount.hashCode())
        dfh.write(lns.hashCode())
        dfh.write(lfs.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is ==
     *
     * @param r of HuffmanEncoder
     *
     * @return Type of Bool
     */
    public operator func ==(r: HuffmanEncoder): Bool {
        this.hashCode() == r.hashCode()
    }

    /**
     * The Function is !=
     *
     * @param r of HuffmanEncoder
     *
     * @return Type of Bool
     */
    public operator func !=(r: HuffmanEncoder): Bool {
        this.hashCode() != r.hashCode()
    }
}

/*
 * The class is LiteralNode inherited from Hashable & ToString
 * @author changeden
 */
class LiteralNode <: Hashable & ToString {
    /* var member literal type is UInt16 */
    var literal: UInt16 = 0

    /* var member freq type is Int32 */
    var freq: Int32 = 0

    /*
     * The Function is init constructor
     *
     */
    init() {}

    /*
     * The Function is init constructor
     *
     * @param literal of UInt16
     * @param freq of Int32
     */
    init(literal: UInt16, freq: Int32) {
        this.literal = literal
        this.freq = freq
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=LiteralNode")
        dfh.write("literal=${literal}, freq=${freq}")
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "literal=${literal} freq=${freq}"
    }
}

/*
 * The class is LevelInfo inherited from ToString
 * @author changeden
 */
class LevelInfo <: ToString {
    /* var member level type is Int32 */
    var level: Int32 = 0

    /* var member lastFreq type is Int32 */
    var lastFreq: Int32 = 0

    /* var member nextCharFreq type is Int32 */
    var nextCharFreq: Int32 = 0

    /* var member nextPairFreq type is Int32 */
    var nextPairFreq: Int32 = 0

    /* var member needed type is Int32 */
    var needed: Int32 = 0

    /*
     * The Function is init constructor
     *
     */
    init() {}

    /*
     * The Function is init constructor
     *
     * @param level of Int32
     * @param lastFreq of Int32
     * @param nextCharFreq of Int32
     * @param nextPairFreq of Int32
     */
    init(level: Int32, lastFreq: Int32, nextCharFreq: Int32, nextPairFreq: Int32) {
        this.level = level
        this.lastFreq = lastFreq
        this.nextCharFreq = nextCharFreq
        this.nextPairFreq = nextPairFreq
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "level=${level} lastFreq=${lastFreq} nextCharFreq=${nextCharFreq} nextPairFreq=${nextPairFreq} needed=${needed}"
    }
}

/*
 * The class is LiteralNodeSortByLiteral inherited from Comparable<LiteralNodeSortByLiteral> & Hashable
 * @author changeden
 */
class LiteralNodeSortByLiteral <: Comparable<LiteralNodeSortByLiteral> & Hashable {
    /* var member b type is LiteralNode */
    var b: LiteralNode

    /*
     * The Function is init constructor
     *
     * @param b of LiteralNode
     */
    init(b: LiteralNode) {
        this.b = b
    }

    /**
     * The Function is <
     *
     * @param rhs of LiteralNodeSortByLiteral
     *
     * @return Type of Bool
     */
    public operator func <(rhs: LiteralNodeSortByLiteral): Bool {
        this.b.literal < rhs.b.literal
    }

    /**
     * The Function is >
     *
     * @param rhs of LiteralNodeSortByLiteral
     *
     * @return Type of Bool
     */
    public operator func >(rhs: LiteralNodeSortByLiteral): Bool {
        this.b.literal > rhs.b.literal
    }

    /**
     * The Function is <=
     *
     * @param rhs of LiteralNodeSortByLiteral
     *
     * @return Type of Bool
     */
    public operator func <=(rhs: LiteralNodeSortByLiteral): Bool {
        this.b.literal <= rhs.b.literal
    }

    /**
     * The Function is >=
     *
     * @param rhs of LiteralNodeSortByLiteral
     *
     * @return Type of Bool
     */
    public operator func >=(rhs: LiteralNodeSortByLiteral): Bool {
        this.b.literal >= rhs.b.literal
    }

    /**
     * The Function is ==
     *
     * @param rhs of LiteralNodeSortByLiteral
     *
     * @return Type of Bool
     */
    public operator func ==(rhs: LiteralNodeSortByLiteral): Bool {
        this.b.literal == rhs.b.literal
    }

    /**
     * The Function is !=
     *
     * @param rhs of LiteralNodeSortByLiteral
     *
     * @return Type of Bool
     */
    public operator func !=(rhs: LiteralNodeSortByLiteral): Bool {
        this.b.literal != rhs.b.literal
    }

    /**
     * The Function is compare
     *
     * @param rhs of LiteralNodeSortByLiteral
     *
     * @return Type of Ordering
     */
    public func compare(rhs: LiteralNodeSortByLiteral): Ordering {
        if (this > rhs) {
            Ordering.GT
        } else if (this < rhs) {
            Ordering.LT
        } else {
            Ordering.EQ
        }
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=LiteralNodeSortByLiteral")
        dfh.write("b=${b.hashCode()}")
        return dfh.finish()
    }
}

/*
 * The class is ByLiteral inherited from Hashable
 * @author changeden
 */
class ByLiteral <: Hashable {
    /* var member b type is Array<LiteralNodeSortByLiteral> */
    var b: Array<LiteralNodeSortByLiteral> = []

    /*
     * The Function is sort
     *
     * @param a of Array<LiteralNode>
     */
    func sort(a: Array<LiteralNode>) {
        this.b = Array<LiteralNodeSortByLiteral>(a.size, {
            n => LiteralNodeSortByLiteral(a[n])
        })
        this.b.sort()
        for (i in 0..a.size) {
            a[i] = this.b[i].b
        }
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=ByLiteral")
        dfh.write("b=${b.hashCode()}")
        return dfh.finish()
    }
}

/*
 * The class is LiteralNodeSortByFreq inherited from Comparable<LiteralNodeSortByFreq> & Hashable
 * @author changeden
 */
class LiteralNodeSortByFreq <: Comparable<LiteralNodeSortByFreq> & Hashable {
    /* var member b type is LiteralNode */
    var b: LiteralNode

    /*
     * The Function is init constructor
     *
     * @param b of LiteralNode
     */
    init(b: LiteralNode) {
        this.b = b
    }

    /**
     * The Function is <
     *
     * @param rhs of LiteralNodeSortByFreq
     *
     * @return Type of Bool
     */
    public operator func <(rhs: LiteralNodeSortByFreq): Bool {
        if (this.b.freq == rhs.b.freq) {
            return this.b.literal < rhs.b.literal
        }
        this.b.freq < rhs.b.freq
    }

    /**
     * The Function is >
     *
     * @param rhs of LiteralNodeSortByFreq
     *
     * @return Type of Bool
     */
    public operator func >(rhs: LiteralNodeSortByFreq): Bool {
        if (this.b.freq == rhs.b.freq) {
            return this.b.literal > rhs.b.literal
        }
        this.b.freq > rhs.b.freq
    }

    /**
     * The Function is <=
     *
     * @param rhs of LiteralNodeSortByFreq
     *
     * @return Type of Bool
     */
    public operator func <=(rhs: LiteralNodeSortByFreq): Bool {
        if (this.b.freq == rhs.b.freq) {
            return this.b.literal <= rhs.b.literal
        }
        this.b.freq < rhs.b.freq
    }

    /**
     * The Function is >=
     *
     * @param rhs of LiteralNodeSortByFreq
     *
     * @return Type of Bool
     */
    public operator func >=(rhs: LiteralNodeSortByFreq): Bool {
        if (this.b.freq == rhs.b.freq) {
            return this.b.literal >= rhs.b.literal
        }
        this.b.freq > rhs.b.freq
    }

    /**
     * The Function is ==
     *
     * @param rhs of LiteralNodeSortByFreq
     *
     * @return Type of Bool
     */
    public operator func ==(rhs: LiteralNodeSortByFreq): Bool {
        this.b.freq == rhs.b.freq && this.b.literal == rhs.b.literal
    }

    /**
     * The Function is !=
     *
     * @param rhs of LiteralNodeSortByFreq
     *
     * @return Type of Bool
     */
    public operator func !=(rhs: LiteralNodeSortByFreq): Bool {
        !(this.b.freq == rhs.b.freq && this.b.literal == rhs.b.literal)
    }

    /**
     * The Function is compare
     *
     * @param rhs of LiteralNodeSortByFreq
     *
     * @return Type of Ordering
     */
    public func compare(rhs: LiteralNodeSortByFreq): Ordering {
        if (this > rhs) {
            Ordering.GT
        } else if (this < rhs) {
            Ordering.LT
        } else {
            Ordering.EQ
        }
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=LiteralNodeSortByFreq")
        dfh.write("b=${b.hashCode()}")
        return dfh.finish()
    }
}

/*
 * The class is ByFreq inherited from Hashable
 * @author changeden
 */
class ByFreq <: Hashable {
    /* var member b type is Array<LiteralNodeSortByFreq> */
    var b: Array<LiteralNodeSortByFreq> = []

    /*
     * The Function is sort
     *
     * @param a of Array<LiteralNode>
     */
    func sort(a: Array<LiteralNode>) {
        this.b = Array<LiteralNodeSortByFreq>(a.size, {
            n => LiteralNodeSortByFreq(a[n])
        })
        this.b.sort()
        for (i in 0..a.size) {
            a[i] = this.b[i].b
        }
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=ByFreq")
        dfh.write("b=${b.hashCode()}")
        return dfh.finish()
    }
}

/*
 * The Function is maxNode
 *
 * @return Type of LiteralNode
 */
func maxNode(): LiteralNode {
    LiteralNode(UInt16.Max, Int32.Max)
}

/*
 * The Function is generateFixedLiteralEncoding
 *
 * @return Type of HuffmanEncoder
 */
func generateFixedLiteralEncoding(): HuffmanEncoder {
    let h = HuffmanEncoder(maxNumLit)
    let codes = h.codes
    var bits: UInt16 = 0
    var size: UInt16 = 0
    for (ch in 0..UInt16(maxNumLit)) {
        if (ch < 144) {
            bits = ch + 48
            size = 8
        } else if (ch < 256) {
            bits = ch + 400 - 144
            size = 9
        } else if (ch < 280) {
            bits = ch - 256
            size = 7
        } else {
            bits = ch + 192 - 280
            size = 8
        }
        codes[Int64(ch)] = Hcode(reverseBits(bits, UInt8(size)), size)
    }
    h
}

/*
 * The Function is generateFixedOffsetEncoding
 *
 * @return Type of HuffmanEncoder
 */
func generateFixedOffsetEncoding(): HuffmanEncoder {
    let h = HuffmanEncoder(30)
    let codes = h.codes
    for (ch in 0..codes.size) {
        codes[ch] = Hcode(reverseBits(UInt16(ch), 5), 5)
    }
    h
}

/*
 * The Function is reverseBits
 *
 * @param number of UInt16
 * @param bitLength of UInt8
 *
 * @return Type of UInt16
 */
func reverseBits(number: UInt16, bitLength: UInt8): UInt16 {
    bitsReverse16(number << (16 - bitLength))
}

/* var member fixedLiteralEncoding type is HuffmanEncoder */
var fixedLiteralEncoding: HuffmanEncoder = generateFixedLiteralEncoding()

/* var member fixedOffsetEncoding type is HuffmanEncoder */
var fixedOffsetEncoding: HuffmanEncoder = generateFixedOffsetEncoding()

/* let member huffOffset */
let huffOffset = HuffmanEncoder(offsetCodeCount)

/* var member huffOffsetInited */
var huffOffsetInited = false

/**
 * The Function is huffOffsetInit
 *
 */
public func huffOffsetInit() {
    if (huffOffsetInited) {
        return
    }
    huffOffsetInited = true
    huffOffset.generate(
        Array<Int32>(offsetCodeCount, {
            n => if (n == 0) {
                1
            } else {
                0
            }
        }),
        15
    )
}

/*
 * The class is HuffmanBitWriter
 * @author changeden
 */
class HuffmanBitWriter {
    /* var member writer type is OutputStream */
    var writer: OutputStream

    /* var member bits type is UInt64 */
    var bits: UInt64 = 0

    /* var member nbits type is UInt32 */
    var nbits: UInt32 = 0

    /* let member bytes type is Array<UInt8> */
    let bytes: Array<UInt8> = Array<UInt8>(bufferSize, repeat: 0)

    /* let member codegenFreq type is Array<Int32> */
    let codegenFreq: Array<Int32> = Array<Int32>(codegenCodeCount, repeat: 0)

    /* var member nbytes type is Int64 */
    var nbytes: Int64 = 0

    /* var member literalFreq type is Array<Int32> */
    var literalFreq: Array<Int32>

    /* var member offsetFreq type is Array<Int32> */
    var offsetFreq: Array<Int32>

    /* var member codegen type is Array<UInt8> */
    var codegen: Array<UInt8>

    /* var member literalEncoding type is ?HuffmanEncoder */
    var literalEncoding: ?HuffmanEncoder = None

    /* var member offsetEncoding type is ?HuffmanEncoder */
    var offsetEncoding: ?HuffmanEncoder = None

    /* var member codegenEncoding type is ?HuffmanEncoder */
    var codegenEncoding: ?HuffmanEncoder = None

    /* var member err type is ?Exception */
    var err: ?Exception = None

    /*
     * The Function is init constructor
     *
     * @param w of OutputStream
     */
    init(w: OutputStream) {
        this.writer = w
        this.literalFreq = Array<Int32>(maxNumLit, repeat: 0)
        this.offsetFreq = Array<Int32>(offsetCodeCount, repeat: 0)
        this.codegen = Array<UInt8>(maxNumLit + offsetCodeCount + 1, repeat: 0)
        this.literalEncoding = HuffmanEncoder(maxNumLit)
        this.codegenEncoding = HuffmanEncoder(codegenCodeCount)
        this.offsetEncoding = HuffmanEncoder(offsetCodeCount)
    }

    /*
     * The Function is reset
     *
     * @param w of OutputStream
     */
    func reset(w: OutputStream) {
        this.writer = w
        this.bits = 0
        this.nbits = 0
        this.nbytes = 0
        this.err = None
    }

    /*
     * The Function is flush
     *
     */
    @OverflowWrapping
    func flush() {
        if (let Some(_) <- this.err) {
            this.nbits = 0
            return
        }
        var n = this.nbytes
        while (this.nbits != 0) {
            this.bytes[n] = UInt8(this.bits)
            this.bits >>= 8
            if (this.nbits > 8) {
                this.nbits -= 8
            } else {
                this.nbits = 0
            }
            n++
        }
        this.bits = 0
        write(this.bytes[0..n])
        this.nbytes = 0
    }

    /*
     * The Function is write
     *
     * @param b of Array<UInt8>
     */
    func write(b: Array<UInt8>) {
        if (let Some(_) <- this.err) {
            return
        }
        try {
            this.writer.write(b)
        } catch (e: Exception) {
            this.err = e
        }
    }

    /*
     * The Function is writeBits
     *
     * @param b of Int32
     * @param nb of UInt32
     */
    @OverflowWrapping
    func writeBits(b: Int32, nb: UInt32) {
        if (let Some(_) <- this.err) {
            return
        }
        this.bits |= UInt64(b) << this.nbits
        this.nbits += nb
        if (this.nbits >= 48) {
            let bits = this.bits
            this.bits >>= 48
            this.nbits -= 48
            var n = this.nbytes
            this.bytes[n + 0] = UInt8(bits)
            this.bytes[n + 1] = UInt8(bits >> 8)
            this.bytes[n + 2] = UInt8(bits >> 16)
            this.bytes[n + 3] = UInt8(bits >> 24)
            this.bytes[n + 4] = UInt8(bits >> 32)
            this.bytes[n + 5] = UInt8(bits >> 40)
            n += 6
            if (n >= bufferFlushSize) {
                write(this.bytes[0..n])
                n = 0
            }
            this.nbytes = n
        }
    }

    /*
     * The Function is writeBytes
     *
     * @param bytes of Array<UInt8>
     */
    @OverflowWrapping
    func writeBytes(bytes: Array<UInt8>) {
        if (let Some(_) <- this.err) {
            return
        }
        var n = this.nbytes
        if ((this.nbits & 7) != 0) {
            this.err = InternalError("writeBytes with unfinished bits")
            return
        }
        while (this.nbits != 0) {
            this.bytes[n] = UInt8(this.bits)
            this.bits >>= 8
            this.nbits -= 8
            n++
        }
        if (n != 0) {
            write(this.bytes[0..n])
        }
        this.nbytes = 0
        write(bytes)
    }

    /*
     * The Function is generateCodegen
     *
     * @param numLiterals of Int64
     * @param numOffsets of Int64
     * @param litEnc of HuffmanEncoder
     * @param offEnc of HuffmanEncoder
     */
    func generateCodegen(numLiterals: Int64, numOffsets: Int64, litEnc: HuffmanEncoder, offEnc: HuffmanEncoder) {
        for (i in 0..this.codegenFreq.size) {
            this.codegenFreq[i] = 0
        }
        let codegen = this.codegen
        for (i in 0..numLiterals) {
            codegen[i] = UInt8(litEnc.codes[i].len)
        }
        for (i in numLiterals..(numLiterals + numOffsets)) {
            codegen[i] = UInt8(offEnc.codes[i - numLiterals].len)
        }
        codegen[numLiterals + numOffsets] = badCode
        var size = codegen[0]
        var count = 1
        var outIndex = 0
        var inIndex = 1
        while (size != badCode) {
            let nextSize = codegen[inIndex]
            if (nextSize == size) {
                count++
                inIndex++
                continue
            }

            if (size != 0) {
                codegen[outIndex] = size
                outIndex++
                this.codegenFreq[Int64(size)] = this.codegenFreq[Int64(size)] + 1
                count--
                while (count >= 3) {
                    let n = if (6 > count) {
                        count
                    } else {
                        6
                    }
                    codegen[outIndex] = 16
                    outIndex++
                    codegen[outIndex] = UInt8(n - 3)
                    outIndex++
                    this.codegenFreq[16] = this.codegenFreq[16] + 1
                    count -= n
                }
            } else {
                while (count >= 11) {
                    let n = if (138 > count) {
                        count
                    } else {
                        138
                    }
                    codegen[outIndex] = 18
                    outIndex++
                    codegen[outIndex] = UInt8(n - 11)
                    outIndex++
                    this.codegenFreq[18] = this.codegenFreq[18] + 1
                    count -= n
                }
                if (count >= 3) {
                    codegen[outIndex] = 17
                    outIndex++
                    codegen[outIndex] = UInt8(count - 3)
                    outIndex++
                    this.codegenFreq[17] = this.codegenFreq[17] + 1
                    count = 0
                }
            }
            count--
            while (count >= 0) {
                codegen[outIndex] = size
                outIndex++
                this.codegenFreq[Int64(size)] = this.codegenFreq[Int64(size)] + 1
                count--
            }

            size = nextSize
            count = 1

            inIndex++
        }
        codegen[outIndex] = badCode
    }

    /*
     * The Function is dynamicSize
     *
     * @param litEnc of HuffmanEncoder
     * @param offEnc of HuffmanEncoder
     * @param extraBits of Int64
     *
     * @return Type of (Int64, Int64)
     */
    func dynamicSize(litEnc: HuffmanEncoder, offEnc: HuffmanEncoder, extraBits: Int64): (Int64, Int64) {
        var numCodegens = this.codegenFreq.size
        while (numCodegens > 4 && this.codegenFreq[Int64(codegenOrder[numCodegens - 1])] == 0) {
            numCodegens--
        }
        let header = 17 + (3 * numCodegens) + this.codegenEncoding.getOrThrow().bitLength(this.codegenFreq) +
            Int64(this.codegenFreq[16]) * 2 + Int64(this.codegenFreq[17]) * 3 + Int64(this.codegenFreq[18]) * 7
        let size = header + litEnc.bitLength(this.literalFreq) + offEnc.bitLength(this.offsetFreq) + extraBits
        (size, numCodegens)
    }

    /*
     * The Function is fixedSize
     *
     * @param extraBits of Int64
     *
     * @return Type of Int64
     */
    func fixedSize(extraBits: Int64): Int64 {
        3 + fixedLiteralEncoding.bitLength(this.literalFreq) + fixedOffsetEncoding.bitLength(this.offsetFreq) + extraBits
    }

    /*
     * The Function is storedSize
     *
     * @param input of ?Array<UInt8>
     *
     * @return Type of (Int64, Bool)
     */
    func storedSize(input: ?Array<UInt8>): (Int64, Bool) {
        if (let None <- input) {
            return (0, false)
        }
        if (input.getOrThrow().size <= Int64(maxStoreBlockSize)) {
            return ((input.getOrThrow().size + 5) * 8, true)
        }
        (0, false)
    }

    /*
     * The Function is writeCode
     *
     * @param c of Hcode
     */
    @OverflowWrapping
    func writeCode(c: Hcode) {
        if (let Some(_) <- this.err) {
            return
        }
        this.bits |= UInt64(c.code) << this.nbits
        this.nbits += UInt32(c.len)
        if (this.nbits >= 48) {
            let bits = this.bits
            this.bits >>= 48
            this.nbits -= 48
            var n = this.nbytes
            this.bytes[n + 0] = UInt8(bits)
            this.bytes[n + 1] = UInt8(bits >> 8)
            this.bytes[n + 2] = UInt8(bits >> 16)
            this.bytes[n + 3] = UInt8(bits >> 24)
            this.bytes[n + 4] = UInt8(bits >> 32)
            this.bytes[n + 5] = UInt8(bits >> 40)
            n += 6
            if (n >= bufferFlushSize) {
                write(this.bytes[0..n])
                n = 0
            }
            this.nbytes = n
        }
    }

    /*
     * The Function is writeDynamicHeader
     *
     * @param numLiterals of Int64
     * @param numOffsets of Int64
     * @param numCodegens of Int64
     * @param isEof of Bool
     */
    @OverflowWrapping
    func writeDynamicHeader(numLiterals: Int64, numOffsets: Int64, numCodegens: Int64, isEof: Bool) {
        if (let Some(_) <- this.err) {
            return
        }
        var firstBits: Int32 = 4
        if (isEof) {
            firstBits = 5
        }
        writeBits(firstBits, 3)
        writeBits(Int32(numLiterals - 257), 5)
        writeBits(Int32(numOffsets - 1), 5)
        writeBits(Int32(numCodegens - 4), 4)

        var codes = this.codegenEncoding.getOrThrow().codes
        for (i in 0..numCodegens) {
            let value = UInt32(codes[Int64(codegenOrder[i])].len)
            writeBits(Int32(value), 3)
        }

        var i = 0
        codes = this.codegenEncoding.getOrThrow().codes
        while (true) {
            var codeWord = Int64(this.codegen[i])
            i++
            if (codeWord == Int64(badCode)) {
                break
            }
            writeCode(codes[Int64(UInt32(codeWord))])
            if (codeWord == 16) {
                writeBits(Int32(this.codegen[i]), 2)
                i++
            } else if (codeWord == 17) {
                writeBits(Int32(this.codegen[i]), 3)
                i++
            } else if (codeWord == 18) {
                writeBits(Int32(this.codegen[i]), 7)
                i++
            }
        }
    }

    /*
     * The Function is writeStoredHeader
     *
     * @param length of Int64
     * @param isEof of Bool
     */
    func writeStoredHeader(length: Int64, isEof: Bool) {
        if (let Some(_) <- this.err) {
            return
        }
        var flag: Int32 = if (isEof) {
            1
        } else {
            0
        }
        writeBits(flag, 3)
        flush()
        writeBits(Int32(length), 16)
        writeBits(Int32(!UInt16(length)), 16)
    }

    /*
     * The Function is writeFixedHeader
     *
     * @param isEof of Bool
     */
    func writeFixedHeader(isEof: Bool) {
        if (let Some(_) <- this.err) {
            return
        }
        var value: Int32 = if (isEof) {
            3
        } else {
            2
        }
        writeBits(value, 3)
    }

    /*
     * The Function is writeBlock
     *
     * @param tokens of Array<Token>
     * @param eof of Bool
     * @param input of ?Array<UInt8>
     */
    func writeBlock(tokens: Array<Token>, eof: Bool, input: ?Array<UInt8>) {
        if (let Some(_) <- this.err) {
            return
        }
        let mtokens = Array<Token>(
            tokens.size + 1,
            {
                n => if (n < tokens.size) {
                    tokens[n]
                } else {
                    endBlockMarkerToken
                }
            }
        )

        let (numLiterals, numOffsets) = indexTokens(mtokens)

        var extraBits = 0
        let (mstoredSize, storable) = storedSize(input)
        if (storable) {
            for (lc in (lengthCodesStart + 8)..numLiterals) {
                extraBits += Int64(this.literalFreq[lc]) * Int64(lengthExtraBits[lc - lengthCodesStart])
            }
            for (oc in 4..numOffsets) {
                extraBits += Int64(this.offsetFreq[oc]) * Int64(offsetExtraBits[oc])
            }
        }

        var literalEncoding = fixedLiteralEncoding
        var offsetEncoding = fixedOffsetEncoding
        var size = fixedSize(extraBits)

        generateCodegen(numLiterals, numOffsets, this.literalEncoding.getOrThrow(), this.offsetEncoding.getOrThrow())
        this.codegenEncoding.getOrThrow().generate(this.codegenFreq, 7)
        let (mdynamicSize, numCodegens) = dynamicSize(
            this.literalEncoding.getOrThrow(),
            this.offsetEncoding.getOrThrow(),
            extraBits
        )

        if (mdynamicSize < size) {
            size = mdynamicSize
            literalEncoding = this.literalEncoding.getOrThrow()
            offsetEncoding = this.offsetEncoding.getOrThrow()
        }

        if (storable && (mstoredSize < size)) {
            let minput = if (let Some(i) <- input) {
                i
            } else {
                Array<UInt8>()
            }
            writeStoredHeader(minput.size, eof)
            writeBytes(minput)
            return
        }

        if (literalEncoding == fixedLiteralEncoding) {
            writeFixedHeader(eof)
        } else {
            writeDynamicHeader(numLiterals, numOffsets, numCodegens, eof)
        }

        writeTokens(mtokens, literalEncoding.codes, offsetEncoding.codes)
    }

    /*
     * The Function is writeBlockDynamic
     *
     * @param tokens of Array<Token>
     * @param eof of Bool
     * @param input of Array<UInt8>
     */
    func writeBlockDynamic(tokens: Array<Token>, eof: Bool, input: Array<UInt8>) {
        if (let Some(_) <- this.err) {
            return
        }
        let mtokens = Array<Token>(
            tokens.size + 1,
            {
                n => if (n < tokens.size) {
                    tokens[n]
                } else {
                    endBlockMarkerToken
                }
            }
        )

        let (numLiterals, numOffsets) = indexTokens(mtokens)
        generateCodegen(numLiterals, numOffsets, this.literalEncoding.getOrThrow(), this.offsetEncoding.getOrThrow())
        this.codegenEncoding.getOrThrow().generate(this.codegenFreq, 7)
        let (size, numCodegens) = dynamicSize(this.literalEncoding.getOrThrow(), this.offsetEncoding.getOrThrow(), 0)

        let (ssize, storable) = storedSize(input)
        if (storable && ssize < (size + size >> 4)) {
            writeStoredHeader(input.size, eof)
            writeBytes(input)
            return
        }

        writeDynamicHeader(numLiterals, numOffsets, numCodegens, eof)

        writeTokens(mtokens, this.literalEncoding.getOrThrow().codes, this.offsetEncoding.getOrThrow().codes)
    }

    /*
     * The Function is indexTokens
     *
     * @param tokens of Array<Token>
     *
     * @return Type of (Int64, Int64)
     */
    func indexTokens(tokens: Array<Token>): (Int64, Int64) {
        for (i in 0..this.literalFreq.size) {
            this.literalFreq[i] = 0
        }
        for (i in 0..this.offsetFreq.size) {
            this.offsetFreq[i] = 0
        }
        for (t in tokens) {
            if (t.t < UInt32(matchType)) {
                this.literalFreq[Int64(t.literal())] = this.literalFreq[Int64(t.literal())] + 1
                continue
            }
            let length = t.length()
            let offset = t.offset()
            this.literalFreq[lengthCodesStart + Int64(lengthCode(length))] = this.literalFreq[lengthCodesStart + Int64(lengthCode(
                        length))] + 1
            this.offsetFreq[Int64(offsetCode(offset))] = this.offsetFreq[Int64(offsetCode(offset))] + 1
        }
        var numLiterals = this.literalFreq.size
        while (this.literalFreq[numLiterals - 1] == 0) {
            numLiterals--
        }
        var numOffsets = this.offsetFreq.size
        while (numOffsets > 0 && this.offsetFreq[numOffsets - 1] == 0) {
            numOffsets--
        }
        if (numOffsets == 0) {
            this.offsetFreq[0] = 1
            numOffsets = 1
        }
        this.literalEncoding.getOrThrow().generate(this.literalFreq, 15)
        this.offsetEncoding.getOrThrow().generate(this.offsetFreq, 15)
        (numLiterals, numOffsets)
    }

    /*
     * The Function is writeTokens
     *
     * @param tokens of Array<Token>
     * @param leCodes of Array<Hcode>
     * @param oeCodes of Array<Hcode>
     */
    func writeTokens(tokens: Array<Token>, leCodes: Array<Hcode>, oeCodes: Array<Hcode>) {
        if (let Some(e) <- this.err) {
            return
        }
        for (t in tokens) {
            if (t.t < UInt32(matchType)) {
                writeCode(leCodes[Int64(t.literal())])
                continue
            }
            let length = t.length()
            let lengthCode = lengthCode(length)
            writeCode(leCodes[Int64(lengthCode) + lengthCodesStart])
            let extraLengthBits = UInt32(lengthExtraBits[Int64(lengthCode)])
            if (extraLengthBits > 0) {
                let extraLength = Int32(length - lengthBase[Int64(lengthCode)])
                writeBits(extraLength, extraLengthBits)
            }
            let offset = t.offset()
            let offsetCode = offsetCode(offset)
            writeCode(oeCodes[Int64(offsetCode)])
            let extraOffsetBits = UInt32(offsetExtraBits[Int64(offsetCode)])
            if (extraOffsetBits > 0) {
                let extraOffset = Int32(offset - offsetBase[Int64(offsetCode)])
                writeBits(extraOffset, extraOffsetBits)
            }
        }
    }

    /*
     * The Function is writeBlockHuff
     *
     * @param eof of Bool
     * @param input of Array<UInt8>
     * @param start of Int64
     * @param end of Int64
     */
    func writeBlockHuff(eof: Bool, input: Array<UInt8>, start: Int64, end: Int64) {
        if (let Some(_) <- this.err) {
            return
        }
        for (i in 0..this.literalFreq.size) {
            this.literalFreq[i] = 0
        }

        histogram(input, this.literalFreq, start, end)

        this.literalFreq[Int64(endBlockMarkerToken.t)] = 1

        let numLiterals = endBlockMarkerToken.t + 1
        this.offsetFreq[0] = 1
        let numOffsets = 1

        this.literalEncoding.getOrThrow().generate(this.literalFreq, 15)

        generateCodegen(Int64(numLiterals), numOffsets, this.literalEncoding.getOrThrow(), huffOffset)
        this.codegenEncoding.getOrThrow().generate(this.codegenFreq, 7)
        let (size, numCodegens) = dynamicSize(this.literalEncoding.getOrThrow(), huffOffset, 0)

        let (ssize, storable) = storedSize(input)
        if (storable && ssize < (size + size >> 4)) {
            writeStoredHeader(input.size, eof)
            writeBytes(input)
            return
        }

        writeDynamicHeader(Int64(numLiterals), numOffsets, numCodegens, eof)

        let encoding = this.literalEncoding.getOrThrow().codes[0..257]
        var n = this.nbytes
        for (i in start..end) {
            let t = input[i]
            let c = encoding[Int64(t)]
            this.bits |= UInt64(c.code) << this.nbits
            this.nbits += UInt32(c.len)
            if (this.nbits < 48) {
                continue
            }
            let bits = this.bits
            this.bits >>= 48
            this.nbits -= 48
            this.bytes[n + 0] = UInt8(bits)
            this.bytes[n + 1] = UInt8(bits >> 8)
            this.bytes[n + 2] = UInt8(bits >> 16)
            this.bytes[n + 3] = UInt8(bits >> 24)
            this.bytes[n + 4] = UInt8(bits >> 32)
            this.bytes[n + 5] = UInt8(bits >> 40)
            n += 6
            if (n < bufferFlushSize) {
                continue
            }
            write(this.bytes[0..n])
            if (let Some(e) <- this.err) {
                return
            }
            n = 0
        }
        this.nbytes = n
        writeCode(encoding[Int64(endBlockMarkerToken.t)])
    }
}

/*
 * The Function is histogram
 *
 * @param b of Array<UInt8>
 * @param h of Array<Int32>
 * @param start of Int64
 * @param end of Int64
 */
func histogram(b: Array<UInt8>, h: Array<Int32>, start: Int64, end: Int64) {
    if (h.size < 256) {
        throw Exception("h.size must be >= 256, and h's elements must be all zeroes.")
    }
    for (i in start..end) {
        h[Int64(b[i])] = h[Int64(b[i])] + 1
    }
}
