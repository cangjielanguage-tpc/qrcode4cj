/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * zlib压缩算法
 */
package image.png.zlib

import std.math.*
import std.collection.*
import std.io.*
import image.internals.model.*
import image.internals.imageutil.*

/** let member ZlibNoCompression */
public let ZlibNoCompression = 0

/** let member ZlibBestSpeed */
public let ZlibBestSpeed = 1

/** let member ZlibBestCompression */
public let ZlibBestCompression = 9

/** let member ZlibDefaultCompression */
public let ZlibDefaultCompression = -1

/** let member ZlibHuffmanOnly */
public let ZlibHuffmanOnly = -2

/* let member logWindowSize */
let logWindowSize = 15

/* let member windowSize */
let windowSize = 1 << logWindowSize

/* let member windowMask */
let windowMask = windowSize - 1

/* let member baseMatchLength */
let baseMatchLength = 3 // The smallest match length per the RFC section 3.2.5

/* let member minMatchLength */
let minMatchLength = 4 // The smallest match length that the compressor actually emits

/* let member maxMatchLength */
let maxMatchLength = 258 // The largest match length

/* let member baseMatchOffset */
let baseMatchOffset = 1 // The smallest match offset

/* let member maxMatchOffset */
let maxMatchOffset = 1 << 15 // The largest match offset

/* let member maxFlateBlockTokens */
let maxFlateBlockTokens = 1 << 14

/* let member maxStoreBlockSize type is Int32 */
let maxStoreBlockSize: Int32 = 65535

/* let member hashBits */
let hashBits = 17 // After 17 performance degrades

/* let member hashSize */
let hashSize = 1 << hashBits

/* let member hashMask */
let hashMask = (1 << hashBits) - 1

/* let member maxHashOffset */
let maxHashOffset = 1 << 24

/* let member skipNever */
let skipNever = (1 << 31) - 1

/*
 * The class is DeflateCompressionLevel
 * @author changeden
 */
class DeflateCompressionLevel {
    /* var member level */
    var level = 0

    /* var member good */
    var good = 0

    /* var member lazy */
    var lazy = 0

    /* var member nice */
    var nice = 0

    /* var member chain */
    var chain = 0

    /* var member fastSkipHashing */
    var fastSkipHashing = 0

    /**
     * The Function is init constructor
     *
     * @param level of Int64
     * @param good of Int64
     * @param lazy of Int64
     * @param nice of Int64
     * @param chain of Int64
     * @param fastSkipHashing of Int64
     */
    public init(level: Int64, good: Int64, lazy: Int64, nice: Int64, chain: Int64, fastSkipHashing: Int64) {
        this.level = level
        this.good = good
        this.lazy = lazy
        this.nice = nice
        this.chain = chain
        this.fastSkipHashing = fastSkipHashing
    }
}

/* let member levels type is Array<DeflateCompressionLevel> */
let levels: Array<DeflateCompressionLevel> = [
    DeflateCompressionLevel(0, 0, 0, 0, 0, 0),
    DeflateCompressionLevel(1, 0, 0, 0, 0, 0),
    DeflateCompressionLevel(2, 4, 0, 16, 8, 5),
    DeflateCompressionLevel(3, 4, 0, 32, 32, 6),
    DeflateCompressionLevel(4, 4, 4, 16, 16, skipNever),
    DeflateCompressionLevel(5, 8, 16, 32, 32, skipNever),
    DeflateCompressionLevel(6, 8, 16, 128, 128, skipNever),
    DeflateCompressionLevel(7, 8, 32, 128, 256, skipNever),
    DeflateCompressionLevel(8, 32, 128, 258, 1024, skipNever),
    DeflateCompressionLevel(9, 32, 258, 258, 4096, skipNever)
]

/* let member tableBits */
let tableBits = 14

/* let member tableSize */
let tableSize = 1 << tableBits

/* let member tableMask */
let tableMask = tableSize - 1

/* let member tableShift */
let tableShift = 32 - tableBits

/* let member bufferReset */
let bufferReset = Int32.Max - maxStoreBlockSize * 2

/*
 * The Function is load32
 *
 * @param mb of Array<UInt8>
 * @param i of Int32
 *
 * @return Type of UInt32
 */
func load32(mb: Array<UInt8>, i: Int32): UInt32 {
    let b = mb[Int64(i)..Int64(i + 4)]
    UInt32(b[0]) | (UInt32(b[1]) << 8) | (UInt32(b[2]) << 16) | (UInt32(b[3]) << 24)
}

/*
 * The Function is load64
 *
 * @param mb of Array<UInt8>
 * @param i of Int32
 *
 * @return Type of UInt64
 */
func load64(mb: Array<UInt8>, i: Int32): UInt64 {
    let b = mb[Int64(i)..Int64(i + 8)]
    UInt64(b[0]) | (UInt64(b[1]) << 8) | (UInt64(b[2]) << 16) | (UInt64(b[3]) << 24) | (UInt64(b[4]) << 32) | (UInt64(b[5]) <<
        40) | (UInt64(b[6]) << 48) | (UInt64(b[7]) << 56)
}

/*
 * The Function is hash
 *
 * @param u of UInt32
 *
 * @return Type of UInt32
 */
func hash(u: UInt32): UInt32 {
    (u * 0x1e35a7bd) >> tableShift
}

/* let member inputMargin */
let inputMargin = 16 - 1

/* let member minNonLiteralBlockSize */
let minNonLiteralBlockSize = 1 + 1 + inputMargin

/*
 * The class is TableEntry
 * @author changeden
 */
class TableEntry {
    /* var member val type is UInt32 */
    var val: UInt32 = 0

    /* var member offset type is Int32 */
    var offset: Int32 = 0

    /*
     * The Function is init constructor
     *
     */
    init() {}

    /*
     * The Function is init constructor
     *
     * @param offset of Int32
     * @param val of UInt32
     */
    init(offset: Int32, val: UInt32) {
        this.offset = offset
        this.val = val
    }
}

/*
 * The class is DeflateFast
 * @author changeden
 */
class DeflateFast {
    /* let member table type is Array<TableEntry> */
    let table: Array<TableEntry> = Array<TableEntry>(tableSize, @OverflowSaturating{_ => TableEntry()})
    var prev: Array<UInt8> = Array<UInt8>(Int64(maxStoreBlockSize), item: 0)

    /* var member cur type is Int32 */
    var cur: Int32 = maxStoreBlockSize

    /*
     * The Function is init constructor
     *
     */
    init() {}

    /*
     * The Function is encode
     *
     * @param dst of Array<Token>
     * @param src of Array<UInt8>
     *
     * @return Type of Array<Token>
     */
    func encode(dst: Array<Token>, src: Array<UInt8>): Array<Token> {
        if (this.cur >= bufferReset) {
            shiftOffsets()
        }
        if (src.size < minNonLiteralBlockSize) {
            this.cur += maxStoreBlockSize
            this.prev = []
            return emitLiteral(dst, src)
        }
        let sLimit = Int32(src.size - inputMargin)
        var nextEmit: Int32 = 0
        var s: Int32 = 0
        var cv = load32(src, s)
        var nextHash = hash(cv)

        var mdst = dst

        /*
         * The Function is emitRemainder
         *
         * @return Type of Array<Token>
         */
        func emitRemainder(): Array<Token> {
            if (Int64(nextEmit) < src.size) {
                mdst = emitLiteral(mdst, src[Int64(nextEmit)..src.size])
            }
            this.cur += Int32(src.size)
            this.prev = this.prev[0..src.size]
            copy(this.prev, src)
            return mdst
        }

        while (true) {
            var skip: Int32 = 32
            var nextS = s
            var candidate: TableEntry = TableEntry()
            while (true) {
                s = nextS
                let bytesBetweenHashLookups = skip >> 5
                nextS = s + bytesBetweenHashLookups
                skip += bytesBetweenHashLookups
                if (nextS > sLimit) {
                    return emitRemainder()
                }
                candidate = this.table[Int64(nextHash) & tableMask]
                let now = load32(src, nextS)
                this.table[Int64(nextHash) & tableMask] = TableEntry(s + this.cur, cv)
                nextHash = hash(now)

                let offset = s - (candidate.offset - this.cur)

                if (offset > Int32(maxMatchOffset) || cv != candidate.val) {
                    cv = now
                    continue
                }
                break
            }

            mdst = emitLiteral(mdst, src[Int64(nextEmit)..Int64(s)])

            while (true) {
                s += 4
                let t = candidate.offset - this.cur + 4
                let l = matchLen(s, t, src)
                let lastToken = matchToken(UInt32(Int64(l) + 4 - baseMatchLength), UInt32(Int64(s - t) - baseMatchOffset)
                )
                let nmdst = mdst
                mdst = Array<Token>(
                    mdst.size + 1,
                    {
                        n => if (n < nmdst.size) {
                            nmdst[n]
                        } else {
                            lastToken
                        }
                    }
                )
                s += l
                nextEmit = s
                if (s >= sLimit) {
                    return emitRemainder()
                }
                var x = load64(src, s - 1)
                let prevHash = hash(UInt32(x))
                this.table[Int64(prevHash) & tableMask] = TableEntry(this.cur + s - 1, UInt32(x))
                x >>= 8
                let currHash = hash(UInt32(x))
                candidate = this.table[Int64(currHash) & tableMask]
                this.table[Int64(currHash) & tableMask] = TableEntry(this.cur + s, UInt32(x))
                let offset = s - (candidate.offset - this.cur)
                if (offset > Int32(maxMatchOffset) || UInt32(x) != candidate.val) {
                    cv = UInt32(x >> 8)
                    nextHash = hash(cv)
                    s++
                    break
                }
            }
        }

        mdst
    }

    /*
     * The Function is matchLen
     *
     * @param s of Int32
     * @param t of Int32
     * @param src of Array<UInt8>
     *
     * @return Type of Int32
     */
    func matchLen(s: Int32, t: Int32, src: Array<UInt8>): Int32 {
        var s1 = Int64(s) + maxMatchLength - 4
        if (s1 > src.size) {
            s1 = src.size
        }
        if (t >= 0) {
            var b = src[Int64(t)..src.size]
            let a = src[Int64(s)..s1]
            b = b[0..a.size]
            for (i in 0..a.size) {
                if (a[i] != b[i]) {
                    return Int32(i)
                }
            }
            return Int32(a.size)
        }

        let tp = Int32(this.prev.size) + t
        if (tp < 0) {
            return 0
        }

        var a = src[Int64(s)..s1]
        var b = this.prev[Int64(tp)..this.prev.size]
        if (b.size > a.size) {
            b = b[0..a.size]
        }
        a = a[0..b.size]
        for (i in 0..b.size) {
            if (a[i] != b[i]) {
                return Int32(i)
            }
        }

        let n = Int32(b.size)
        if (Int64(s + n) == s1) {
            return n
        }

        a = src[Int64(s + n)..s1]
        b = src[0..a.size]
        for (i in 0..a.size) {
            if (a[i] != b[i]) {
                return Int32(i) + n
            }
        }
        return Int32(a.size) + n
    }

    /*
     * The Function is reset
     *
     */
    func reset() {
        this.prev = []
        this.cur += Int32(maxMatchOffset)
        if (this.cur >= bufferReset) {
            shiftOffsets()
        }
    }

    /*
     * The Function is shiftOffsets
     *
     */
    func shiftOffsets() {
        if (this.prev.size == 0) {
            for (i in 0..this.table.size) {
                this.table[i] = TableEntry()
            }
            this.cur = Int32(maxMatchOffset) + 1
            return
        }
        for (i in 0..this.table.size) {
            var v = this.table[i].offset - this.cur + Int32(maxMatchOffset) + 1
            if (v < 0) {
                v = 0
            }
            this.table[i].offset = v
        }
        this.cur = Int32(maxMatchOffset) + 1
    }
}

/*
 * The Function is emitLiteral
 *
 * @param dst of Array<Token>
 * @param lit of Array<UInt8>
 *
 * @return Type of Array<Token>
 */
func emitLiteral(dst: Array<Token>, lit: Array<UInt8>): Array<Token> {
    let ds = dst.size
    let ls = lit.size
    let mdst = Array<Token>(
        ds + ls,
        {
            n => if (n < ds) {
                dst[n]
            } else {
                Token()
            }
        }
    )
    for (i in 0..ls) {
        mdst[ds + i] = literalToken(UInt32(lit[i]))
    }
    mdst
}

/*
 * The class is Compressor
 * @author changeden
 */
class Compressor {
    /* var member compressionLevel type is DeflateCompressionLevel */
    var compressionLevel: DeflateCompressionLevel = levels[0]

    /* var member w type is ?HuffmanBitWriter */
    var w: ?HuffmanBitWriter = None

    /* var member bulkHasher type is ?(Array<UInt8>, Array<UInt32>) -> Unit */
    var bulkHasher: ?(Array<UInt8>, Array<UInt32>) -> Unit = None

    /* var member fill type is ?(Compressor, Array<UInt8>) -> Int64 */
    var fill: ?(Compressor, Array<UInt8>) -> Int64 = None

    /* var member step type is ?(Compressor) -> Unit */
    var step: ?(Compressor) -> Unit = None

    /* var member sync type is Bool */
    var sync: Bool = false

    /* var member bestSpeed type is ?DeflateFast */
    var bestSpeed: ?DeflateFast = None

    /* var member chainHead type is Int64 */
    var chainHead: Int64 = 0

    /* let member hashHead type is Array<UInt32> */
    let hashHead: Array<UInt32> = Array<UInt32>(hashSize, item: 0)

    /* let member hashPrev type is Array<UInt32> */
    let hashPrev: Array<UInt32> = Array<UInt32>(windowSize, item: 0)

    /* var member hashOffset type is Int64 */
    var hashOffset: Int64 = 0

    /* var member index type is Int64 */
    var index: Int64 = 0

    /* var member window type is Array<UInt8> */
    var window: Array<UInt8> = []

    /* var member windowEnd type is Int64 */
    var windowEnd: Int64 = 0

    /* var member blockStart type is Int64 */
    var blockStart: Int64 = 0

    /* var member byteAvailable type is Bool */
    var byteAvailable: Bool = false

    /* var member tokens type is ArrayList<Token> */
    var tokens: ArrayList<Token> = ArrayList<Token>()

    /* var member length type is Int64 */
    var length: Int64 = 0

    /* var member offset type is Int64 */
    var offset: Int64 = 0

    /* var member hash type is UInt32 */
    var hash: UInt32 = 0

    /* var member maxInsertIndex type is Int64 */
    var maxInsertIndex: Int64 = 0

    /* var member err type is ?Exception */
    var err: ?Exception = None

    /* let member hashMatch type is Array<UInt32> */
    let hashMatch: Array<UInt32> = Array<UInt32>(maxMatchLength - 1, item: 0)

    /*
     * The Function is fillDeflate
     *
     * @param b of Array<UInt8>
     *
     * @return Type of Int64
     */
    func fillDeflate(b: Array<UInt8>): Int64 {
        if (this.index >= 2 * windowSize - (minMatchLength + maxMatchLength)) {
            copy(this.window, this.window[windowSize..(2 * windowSize)])
            this.index -= windowSize
            this.windowEnd -= windowSize
            if (this.blockStart >= windowSize) {
                this.blockStart -= windowSize
            } else {
                this.blockStart = Int64(Int32.Max)
            }
            this.hashOffset += windowSize
            if (this.hashOffset > maxHashOffset) {
                let delta = this.hashOffset - 1
                this.hashOffset -= delta
                this.chainHead -= delta
                for (i in 0..this.hashPrev.size) {
                    let v = this.hashPrev[i]
                    this.hashPrev[i] = if (Int64(v) > delta) {
                        UInt32(Int64(v) - delta)
                    } else {
                        0
                    }
                }
                for (i in 0..this.hashHead.size) {
                    let v = this.hashHead[i]
                    this.hashHead[i] = if (Int64(v) > delta) {
                        UInt32(Int64(v) - delta)
                    } else {
                        0
                    }
                }
            }
        }
        let n = copy(this.window, b, dstStart: this.windowEnd)
        this.windowEnd += n
        n
    }

    /*
     * The Function is writeBlock
     *
     * @param tokens of Array<Token>
     * @param index of Int64
     */
    func writeBlock(tokens: Array<Token>, index: Int64) {
        if (index > 0) {
            let window: ?Array<UInt8> = if (this.blockStart <= index) {
                this.window[this.blockStart..index]
            } else {
                None
            }
            this.blockStart = index
            let w = this.w.getOrThrow()
            w.writeBlock(tokens, false, window)
            if (let Some(e) <- w.err) {
                throw e
            }
        }
    }

    /*
     * The Function is fillWindow
     *
     * @param b of Array<UInt8>
     */
    func fillWindow(b: Array<UInt8>) {
        if (this.compressionLevel.level < 2) {
            return
        }
        if (this.index != 0 || this.windowEnd != 0) {
            throw Exception("internal error: fillWindow called with stale data")
        }
        let n = copy(this.window, b, srcStart: if (b.size > windowSize) {
            b.size - windowSize
        } else {
            0
        })
        let loops = (n + 256 - minMatchLength) / 256
        for (j in 0..loops) {
            let index = j * 256
            var end = index + 256 + minMatchLength - 1
            if (end > n) {
                end = n
            }
            let toCheck = this.window[index..end]
            let dstSize = toCheck.size - minMatchLength + 1

            if (dstSize <= 0) {
                continue
            }

            let dst = this.hashMatch[0..dstSize]
            bulkHasher.getOrThrow()(toCheck, dst)
            var newH: UInt32 = 0
            for (i in 0..dst.size) {
                newH = dst[i]
                let di = i + index
                let hh = this.hashHead[Int64(newH) & hashMask]
                this.hashPrev[di & windowMask] = hh
                this.hashHead[Int64(newH) & hashMask] = UInt32(di + this.hashOffset)
            }
            this.hash = newH
        }
        this.windowEnd = n
        this.index = n
    }

    /*
     * The Function is findMatch
     *
     * @param pos of Int64
     * @param prevHead of Int64
     * @param prevLength of Int64
     * @param lookahead of Int64
     *
     * @return Type of (Int64, Int64, Bool)
     */
    func findMatch(pos: Int64, prevHead: Int64, prevLength: Int64, lookahead: Int64): (Int64, Int64, Bool) {
        let minMatchLook = if (lookahead < maxMatchLength) {
            lookahead
        } else {
            maxMatchLength
        }
        let win = this.window[0..(pos + minMatchLook)]
        var nice = win.size - pos
        if (this.compressionLevel.nice < nice) {
            nice = this.compressionLevel.nice
        }
        var tries = this.compressionLevel.chain
        var length = prevLength
        if (length >= this.compressionLevel.good) {
            tries >>= 2
        }

        var wEnd = win[pos + length]
        let wPos = win[pos..win.size]
        let minIndex = pos - windowSize

        var i = prevHead
        var ok = false
        var offset = 0
        while (tries > 0) {
            if (wEnd == win[i + length]) {
                let n = matchLen(win[i..win.size], wPos, minMatchLook)
                if (n > length && (n > minMatchLength || (pos - i) <= 4096)) {
                    length = n
                    offset = pos - i
                    ok = true
                    if (n >= nice) {
                        break
                    }
                    wEnd = win[pos + n]
                }
            }
            if (i == minIndex) {
                break
            }
            i = Int64(this.hashPrev[i & windowMask]) - this.hashOffset
            if (i < minIndex || i < 0) {
                break
            }
            tries--
        }
        (length, offset, ok)
    }

    /*
     * The Function is writeStoredBlock
     *
     * @param buf of Array<UInt8>
     */
    func writeStoredBlock(buf: Array<UInt8>) {
        let w = this.w.getOrThrow()
        w.writeStoredHeader(buf.size, false)
        if (let Some(e) <- w.err) {
            throw e
        }
        w.writeBytes(buf)
        if (let Some(e) <- w.err) {
            throw e
        }
    }

    /*
     * The Function is encSpeed
     *
     */
    func encSpeed() {
        if (this.windowEnd < Int64(maxStoreBlockSize)) {
            if (!this.sync) {
                return
            }
            if (this.windowEnd < 128) {
                if (this.windowEnd == 0) {
                    return
                } else if (this.windowEnd <= 16) {
                    try {
                        writeStoredBlock(this.window[0..this.windowEnd])
                    } catch (e: Exception) {
                        this.err = e
                    }
                } else {
                    let w = this.w.getOrThrow()
                    w.writeBlockHuff(false, this.window, 0, this.windowEnd)
                    this.err = w.err
                }
                this.windowEnd = 0
                this.bestSpeed.getOrThrow().reset()
                return
            }
        }
        this.tokens.clear()
        this.tokens.appendAll(this.bestSpeed.getOrThrow().encode([], this.window[0..this.windowEnd]))

        let w = this.w.getOrThrow()
        if (this.tokens.size > (this.windowEnd - (this.windowEnd >> 4))) {
            w.writeBlockHuff(false, this.window, 0, this.windowEnd)
        } else {
            w.writeBlockDynamic(this.tokens.toArray(), false, this.window[0..this.windowEnd])
        }
        this.err = w.err
        this.windowEnd = 0
    }

    /*
     * The Function is initDeflate
     *
     */
    func initDeflate() {
        this.window = Array<UInt8>(2 * windowSize, item: 0)
        this.hashOffset = 1
        this.tokens = ArrayList<Token>(maxFlateBlockTokens + 1)
        this.length = minMatchLength - 1
        this.offset = 0
        this.byteAvailable = false
        this.index = 0
        this.hash = 0
        this.chainHead = -1
        this.bulkHasher = bulkHash4
    }

    /*
     * The Function is deflate
     *
     */
    func deflate() {
        if ((this.windowEnd - this.index) < (minMatchLength + maxMatchLength) && !this.sync) {
            return
        }
        this.maxInsertIndex = this.windowEnd - (minMatchLength - 1)
        if (this.index < this.maxInsertIndex) {
            this.hash = hash4(this.window[this.index..(this.index + minMatchLength)])
        }
        while (true) {
            if (this.index > this.windowEnd) {
                throw Exception("index > windowEnd")
            }
            let lookahead = this.windowEnd - this.index

            // if (this.tokens.size > 790) {
            //     throw Exception()
            // }
            if (lookahead < (minMatchLength + maxMatchLength)) {
                if (!this.sync) {
                    return
                }
                if (this.index > this.windowEnd) {
                    throw Exception("index > windowEnd")
                }
                if (lookahead == 0) {
                    if (this.byteAvailable) {
                        this.tokens.append(literalToken(UInt32(this.window[this.index - 1])))
                        this.byteAvailable = false
                    }
                    if (this.tokens.size > 0) {
                        try {
                            writeBlock(this.tokens.toArray(), this.index)
                        } catch (e: Exception) {
                            this.err = e
                            return
                        }
                        this.tokens.clear()
                    }
                    return
                }
            }
            if (this.index < this.maxInsertIndex) {
                this.hash = hash4(this.window[this.index..(this.index + minMatchLength)])
                let hh = this.hashHead[Int64(this.hash) & hashMask]
                this.chainHead = Int64(hh)
                this.hashPrev[this.index & windowMask] = UInt32(this.chainHead)
                this.hashHead[Int64(this.hash) & hashMask] = UInt32(this.index + this.hashOffset)
            }
            let prevLength = this.length
            let prevOffset = this.offset
            this.length = minMatchLength - 1
            this.offset = 0
            var minIndex = this.index - windowSize
            if (minIndex < 0) {
                minIndex = 0
            }

            if ((this.chainHead - this.hashOffset) >= minIndex && (this.compressionLevel.fastSkipHashing != skipNever &&
                lookahead > (minMatchLength - 1) ||
                this.compressionLevel.fastSkipHashing == skipNever && lookahead > prevLength && prevLength < this.
                compressionLevel.lazy)) {
                let (newLength, newOffset, ok) = findMatch(
                    this.index,
                    this.chainHead - this.hashOffset,
                    minMatchLength - 1,
                    lookahead
                )
                if (ok) {
                    this.length = newLength
                    this.offset = newOffset
                }
            }

            if (this.compressionLevel.fastSkipHashing != skipNever && this.length >= minMatchLength ||
                this.compressionLevel.fastSkipHashing == skipNever && prevLength >= minMatchLength && this.length <=
                prevLength) {
                this.tokens.append(
                    if (this.compressionLevel.fastSkipHashing != skipNever) {
                        matchToken(UInt32(this.length - baseMatchLength), UInt32(this.offset - baseMatchOffset))
                    } else {
                        matchToken(UInt32(prevLength - baseMatchLength), UInt32(prevOffset - baseMatchOffset))
                    }
                )
                if (this.length <= this.compressionLevel.fastSkipHashing) {
                    let newIndex = if (this.compressionLevel.fastSkipHashing == skipNever) {
                        this.index + prevLength - 1
                    } else {
                        this.index + this.length
                    }
                    var index = this.index + 1
                    while (index < newIndex) {
                        if (index < this.maxInsertIndex) {
                            this.hash = hash4(this.window[index..(index + minMatchLength)])
                            let hh = this.hashHead[Int64(this.hash) & hashMask]
                            this.hashPrev[index & windowMask] = hh
                            this.hashHead[Int64(this.hash) & hashMask] = UInt32(index + this.hashOffset)
                        }
                        index++
                    }
                    this.index = index

                    if (this.compressionLevel.fastSkipHashing == skipNever) {
                        this.byteAvailable = false
                        this.length = minMatchLength - 1
                    }
                } else {
                    this.index += this.length
                    if (this.index < this.maxInsertIndex) {
                        this.hash = hash4(this.window[this.index..(this.index + minMatchLength)])
                    }
                }
                if (this.tokens.size == maxFlateBlockTokens) {
                    try {
                        writeBlock(this.tokens.toArray(), this.index)
                    } catch (e: Exception) {
                        this.err = e
                        return
                    }
                    this.tokens.clear()
                }
            } else {
                if (this.compressionLevel.fastSkipHashing != skipNever || this.byteAvailable) {
                    var i = this.index - 1
                    if (this.compressionLevel.fastSkipHashing != skipNever) {
                        i = this.index
                    }
                    this.tokens.append(literalToken(UInt32(this.window[i])))
                    if (this.tokens.size == maxFlateBlockTokens) {
                        try {
                            writeBlock(this.tokens.toArray(), i + 1)
                        } catch (e: Exception) {
                            this.err = e
                            return
                        }
                        this.tokens.clear()
                    }
                }
                this.index++
                if (this.compressionLevel.fastSkipHashing == skipNever) {
                    this.byteAvailable = true
                }
            }
        }
    }

    /*
     * The Function is fillStore
     *
     * @param b of Array<UInt8>
     *
     * @return Type of Int64
     */
    func fillStore(b: Array<UInt8>): Int64 {
        let n = copy(this.window, b, dstStart: this.windowEnd)
        this.windowEnd += n
        n
    }

    /*
     * The Function is store
     *
     */
    func store() {
        if (this.windowEnd > 0 && (this.windowEnd == Int64(maxStoreBlockSize) || this.sync)) {
            try {
                writeStoredBlock(this.window[0..this.windowEnd])
            } catch (e: Exception) {
                this.err = e
            }
            this.windowEnd = 0
        }
    }

    /*
     * The Function is storeHuff
     *
     */
    func storeHuff() {
        if (this.windowEnd < this.window.size && !this.sync || this.windowEnd == 0) {
            return
        }
        let w = this.w.getOrThrow()
        w.writeBlockHuff(false, this.window, 0, this.windowEnd)
        this.err = w.err
        this.windowEnd = 0
    }

    /*
     * The Function is write
     *
     * @param b of Array<UInt8>
     *
     * @return Type of (Int64, ?Exception)
     */
    func write(b: Array<UInt8>): (Int64, ?Exception) {
        if (let Some(e) <- this.err) {
            return (0, e)
        }
        var mb = b
        let n = mb.size
        while (mb.size > 0) {
            this.step.getOrThrow()(this)
            let mbs = this.fill.getOrThrow()(this, mb)
            mb = if (mb.size > mbs) {
                mb[mbs..mb.size]
            } else {
                []
            }
            if (let Some(e) <- this.err) {
                return (0, e)
            }
        }
        (n, None)
    }

    /*
     * The Function is syncFlush
     *
     */
    func syncFlush() {
        if (let Some(e) <- this.err) {
            throw e
        }
        this.sync = true
        this.step.getOrThrow()(this)
        if (let None <- this.err) {
            let w = this.w.getOrThrow()
            w.writeStoredHeader(0, false)
            w.flush()
            this.err = w.err
        }
        this.sync = false
        if (let Some(e) <- this.err) {
            throw e
        }
    }

    /*
     * The Function is initiator
     *
     * @param w of OutputStream
     * @param mlevel of Int64
     */
    func initiator(w: OutputStream, mlevel: Int64) {
        this.w = HuffmanBitWriter(w)
        let maxStoreBlockSize64 = Int64(maxStoreBlockSize)
        var level = mlevel

        /*
         * The Function is fallthroguh
         *
         */
        func fallthroguh() {
            this.compressionLevel = levels[level]
            initDeflate()
            this.fill = {d: Compressor, b: Array<UInt8> => d.fillDeflate(b)}
            this.step = {d => d.deflate()}
        }
        if (level == ZlibNoCompression) {
            this.window = Array<UInt8>(maxStoreBlockSize64, item: 0)
            this.fill = {d: Compressor, b: Array<UInt8> => d.fillStore(b)}
            this.step = {d => d.store()}
        } else if (level == ZlibHuffmanOnly) {
            this.window = Array<UInt8>(maxStoreBlockSize64, item: 0)
            this.fill = {d: Compressor, b: Array<UInt8> => d.fillStore(b)}
            this.step = {d => d.storeHuff()}
        } else if (level == ZlibBestSpeed) {
            this.compressionLevel = levels[level]
            this.window = Array<UInt8>(maxStoreBlockSize64, item: 0)
            this.fill = {d: Compressor, b: Array<UInt8> => d.fillStore(b)}
            this.step = {d => d.encSpeed()}
            this.bestSpeed = DeflateFast()
            this.tokens = ArrayList<Token>(maxStoreBlockSize64, {_ => Token()})
        } else if (level == ZlibDefaultCompression) {
            level = 6
            fallthroguh()
        } else if (2 <= level && level <= 9) {
            fallthroguh()
        } else {
            throw Exception("flate: invalid compression level ${level}: want value in range [-2, 9]")
        }
    }

    /*
     * The Function is reset
     *
     * @param w of OutputStream
     */
    func reset(w: OutputStream) {
        this.w.getOrThrow().reset(w)
        this.sync = false
        this.err = None
        let level = this.compressionLevel.level
        if (level == ZlibNoCompression) {
            this.windowEnd = 0
        } else if (level == ZlibBestSpeed) {
            this.windowEnd = 0
            this.tokens.clear()
            this.bestSpeed.getOrThrow().reset()
        } else {
            this.chainHead = -1
            for (i in 0..this.hashHead.size) {
                this.hashHead[i] = 0
            }
            for (i in 0..this.hashPrev.size) {
                this.hashPrev[i] = 0
            }
            this.hashOffset = 1
            this.index = 0
            this.windowEnd = 0
            this.blockStart = 0
            this.byteAvailable = false
            this.tokens.clear()
            this.length = minMatchLength - 1
            this.offset = 0
            this.hash = 0
            this.maxInsertIndex = 0
        }
    }

    /*
     * The Function is close
     *
     */
    func close() {
        if (let Some(e) <- this.err) {
            throw e
        }
        this.sync = true
        this.step.getOrThrow()(this)
        if (let Some(e) <- this.err) {
            throw e
        }
        let w = this.w.getOrThrow()
        w.writeStoredHeader(0, true)
        if (let Some(e) <- w.err) {
            throw e
        }
        w.flush()
        if (let Some(e) <- w.err) {
            throw e
        }
    }
}

/* let member hashmul type is UInt32 */
let hashmul: UInt32 = 0x1e35a7bd

/*
 * The Function is hash4
 *
 * @param b of Array<UInt8>
 *
 * @return Type of UInt32
 */
@OverflowWrapping
func hash4(b: Array<UInt8>): UInt32 {
    UInt32(((UInt32(b[3]) | (UInt32(b[2]) << 8) | (UInt32(b[1]) << 16) | (UInt32(b[0]) << 24)) * hashmul) >> (32 -
            hashBits))
}

/*
 * The Function is bulkHash4
 *
 * @param b of Array<UInt8>
 * @param dst of Array<UInt32>
 */
func bulkHash4(b: Array<UInt8>, dst: Array<UInt32>) {
    if (b.size < minMatchLength) {
        return
    }
    var hb = UInt32(b[3]) | (UInt32(b[2]) << 8) | (UInt32(b[1]) << 16) | (UInt32(b[0]) << 24)
    dst[0] = (hb * hashmul) >> (32 - hashBits)
    let end = b.size - minMatchLength + 1
    for (i in 1..end) {
        hb = (hb << 8) | UInt32(b[i + 3])
        dst[i] = (hb * hashmul) >> (32 - hashBits)
    }
}

/*
 * The Function is matchLen
 *
 * @param a of Array<UInt8>
 * @param b of Array<UInt8>
 * @param max of Int64
 *
 * @return Type of Int64
 */
func matchLen(a: Array<UInt8>, b: Array<UInt8>, max: Int64): Int64 {
    // 检测数组长度
    a[max - 1]
    b[max - 1]
    for (i in 0..max) {
        if (b[i] != a[i]) {
            return i
        }
    }
    max
}

/**
 * The class is FlateWriter inherited from OutputStream
 * @author changeden
 */
public class FlateWriter <: OutputStream {
    /* var member d type is Compressor */
    var d: Compressor = Compressor()

    /* var member dict type is Array<UInt8> */
    var dict: Array<UInt8> = []

    /**
     * The Function is init constructor
     *
     * @param w of OutputStream
     * @param level of Int64
     */
    public init(w: OutputStream, level: Int64) {
        this.d.initiator(w, level)
    }

    /**
     * The Function is init constructor
     *
     * @param w of OutputStream
     * @param level of Int64
     * @param dict of Array<UInt8>
     */
    public init(w: OutputStream, level: Int64, dict: Array<UInt8>) {
        let _ = DictWriter(w)
        this.d.initiator(w, level)
        this.d.fillWindow(dict)
        this.dict = dict
    }

    /**
     * The Function is writeCustom
     *
     * @param arrayToWrite of Array<UInt8>
     *
     * @return Type of Int64
     */
    public func writeCustom(arrayToWrite: Array<UInt8>): Int64 {
        let (n, err) = this.d.write(arrayToWrite)
        if (let Some(e) <- err) {
            throw e
        }
        n
    }

    /**
     * The Function is write
     *
     * @param arrayToWrite of Array<UInt8>
     */
    public func write(_: Array<UInt8>) {}

    /**
     * The Function is write
     *
     * @param arrayToWrite of Array<UInt8>
     * @param off of Int64
     * @param cnt of Int64
     *
     * @return Type of Int64
     */
    public func write(_: Array<UInt8>, _: Int64, _: Int64): Int64 {
        0
    }

    /**
     * The Function is flush
     *
     * @return Type of Unit
     */
    public func flush(): Unit {
        this.d.syncFlush()
    }

    /**
     * The Function is close
     *
     */
    public func close() {
        this.d.close()
    }

    /**
     * The Function is reset
     *
     * @param dst of OutputStream
     */
    public func reset(dst: OutputStream) {
        if (this.d.w.getOrThrow().writer is DictWriter) {
            let dw = (this.d.w.getOrThrow().writer as DictWriter).getOrThrow()
            dw.w = dst
            this.d.reset(dw)
            this.d.fillWindow(this.dict)
        } else {
            this.d.reset(dst)
        }
    }
}

/*
 * The class is DictWriter inherited from OutputStream
 * @author changeden
 */
class DictWriter <: OutputStream {
    /* var member w type is OutputStream */
    var w: OutputStream

    /*
     * The Function is init constructor
     *
     * @param w of OutputStream
     */
    init(w: OutputStream) {
        this.w = w
    }

    /**
     * The Function is write
     *
     * @param arrayToWrite of Array<UInt8>
     *
     * @return Type of Int64
     * @since 0.30.4
     */
    public func write(arrayToWrite: Array<UInt8>) {
        this.w.write(arrayToWrite)
    }

    /**
     * The Function is flush
     *
     * @return Type of Unit
     */
    public func flush(): Unit {}
}
