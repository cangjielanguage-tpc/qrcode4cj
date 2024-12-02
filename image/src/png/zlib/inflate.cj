/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * zlib压缩算法
 */

package image.png.zlib

import std.io.*
import image.image.*
import image.internals.model.*
import image.internals.imageutil.*

/* let member maxCodeLen */
let maxCodeLen = 16 // max length of Huffman code

// The next three numbers come from the RFC section 3.2.7, with the
// additional proviso in section 3.2.5 which implies that distance codes
// 30 and 31 should never occur in compressed data.
/* let member maxNumLit */
let maxNumLit = 286

/* let member maxNumDist */
let maxNumDist = 30

/* let member numCodes */
let numCodes = 19 // number of codes in Huffman meta-code

/**
 * The class is CorruptInputError inherited from Exception
 * @author changeden
 */
public class CorruptInputError <: Exception {
    /**
     * The Function is init constructor
     *
     * @param e of Int64
     */
    public init(e: Int64) {
        super("flate: corrupt input before offset ${e}")
    }
}

/**
 * The class is InternalError inherited from Exception
 * @author changeden
 */
public class InternalError <: Exception {
    /**
     * The Function is init constructor
     *
     * @param e of String
     */
    public init(e: String) {
        "flate: internal error: ${e}"
    }
}

/**
 * The class is ReadError inherited from Exception
 * @author changeden
 */
public class ReadError <: Exception {
    /**
     * The Function is init constructor
     *
     * @param offset of Int64
     */
    public init(offset: Int64) {
        super("flate: read error at offset ${offset}")
    }
}

/**
 * The class is WriteError inherited from Exception
 * @author changeden
 */
public class WriteError <: Exception {
    /**
     * The Function is init constructor
     *
     * @param offset of Int64
     */
    public init(offset: Int64) {
        super("flate: write error at offset ${offset}")
    }
}

/* let member huffmanChunkBits */
let huffmanChunkBits = 9

/* let member huffmanNumChunks */
let huffmanNumChunks = 1 << huffmanChunkBits

/* let member huffmanCountMask */
let huffmanCountMask = 15

/* let member huffmanValueShift */
let huffmanValueShift = 4

/* let member fixedHuffmanDecoder type is HuffmanDecoder */
let fixedHuffmanDecoder: HuffmanDecoder = HuffmanDecoder()

/*
 * The class is NextFunc
 * @author changeden
 */
class NextFunc {
    /** let member f type is () -> ?NextFunc */
    public let f: () -> ?NextFunc

    /**
     * The Function is init constructor
     *
     * @param f of ()->?NextFunc
     */
    public init(f: () -> ?NextFunc) {
        this.f = f
    }
}

/**
 * The class is HuffmanDecoder
 * @author changeden
 */
public class HuffmanDecoder {
    /** var member min type is Int64 */
    public var min: Int64 = 0

    /** var member chunks type is Array<UInt32> */
    public var chunks: Array<UInt32> = Array<UInt32>(huffmanNumChunks, item: 0)

    /** var member links type is Array<Array<UInt32>> */
    public var links: Array<Array<UInt32>> = []

    /** var member linkMask type is UInt32 */
    public var linkMask: UInt32 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /*
     * The Function is initiator
     *
     * @param lengths of Array<Int64>
     */
    func initiator(lengths: Array<Int64>) {
        let sanity = false
        if (this.min != 0) {
            reset()
        }
        let count = Array<Int64>(maxCodeLen, item: 0)
        var min = 0
        var max = 0
        for (n in lengths) {
            if (n == 0) {
                continue
            }
            if (min == 0 || n < min) {
                min = n
            }
            if (n > max) {
                max = n
            }
            count[n] = count[n] + 1
        }
        if (max == 0) {
            return true
        }
        var code = 0
        let nextcode = Array<Int64>(maxCodeLen, item: 0)
        for (i in min..=max) {
            code <<= 1
            nextcode[i] = code
            code += count[i]
        }

        if (code != (1 << UInt32(max)) && !(code == 1 && max == 1)) {
            return false
        }

        this.min = min

        if (max > huffmanChunkBits) {
            let numLinks = 1 << UInt64(max - huffmanChunkBits)
            this.linkMask = UInt32(numLinks - 1)

            // create link tables
            let link = nextcode[huffmanChunkBits + 1] >> 1
            this.links = Array<Array<UInt32>>(huffmanNumChunks - link, item: [])
            for (j in link..huffmanNumChunks) {
                var reverse = bitsReverse16(UInt16(j))
                reverse >>= UInt16(16 - huffmanChunkBits)
                let off = j - link
                if (sanity && this.chunks[Int64(reverse)] != 0) {
                    throw Exception("impossible: overwriting existing chunk")
                }
                this.chunks[Int64(reverse)] = UInt32(off << huffmanValueShift | (huffmanChunkBits + 1))
                this.links[off] = Array<UInt32>(numLinks, item: 0)
            }
        }

        for (i in 0..lengths.size) {
            let n = lengths[i]
            if (n == 0) {
                continue
            }
            let code = nextcode[n]
            nextcode[n] = nextcode[n] + 1
            let chunk = UInt32((i << huffmanValueShift) | n)
            var reverse = Int64(bitsReverse16(UInt16(code)))
            reverse >>= Int64(UInt32(16 - n))
            if (n <= huffmanChunkBits) {
                var off = reverse
                let step = Int64(1 << UInt32(n))
                while (off < this.chunks.size) {
                    if (sanity && this.chunks[off] != 0) {
                        throw Exception("impossible: overwriting existing chunk")
                    }
                    this.chunks[off] = chunk
                    off += step
                }
                // for (off in reverse..this.chunks.size : (1 << UInt32(n))) {

                // }
            } else {
                let j = reverse & (huffmanNumChunks - 1)
                if (sanity && Int64(UInt64(this.chunks[j]) & UInt64(huffmanCountMask)) != (huffmanChunkBits + 1)) {
                    // Longer codes should have been
                    // associated with a link table above.
                    throw Exception("impossible: not an indirect chunk")
                }
                let value = this.chunks[j] >> huffmanValueShift
                let linktab = this.links[Int64(value)]
                reverse >>= huffmanChunkBits
                for (off in reverse..linktab.size : (1 << UInt32(n - huffmanChunkBits))) {
                    if (sanity && linktab[off] != 0) {
                        throw Exception("impossible: overwriting existing chunk")
                    }
                    linktab[off] = chunk
                }
            }
        }

        if (sanity) {
            for (i in 0..this.chunks.size) {
                let chunk = this.chunks[i]
                if (chunk == 0) {
                    // As an exception, in the degenerate
                    // single-code case, we allow odd
                    // chunks to be missing.
                    if (code == 1 && i % 2 == 1) {
                        continue
                    }
                    throw Exception("impossible: missing chunk")
                }
            }
            for (linktab in this.links) {
                for (chunk in linktab) {
                    if (chunk == 0) {
                        throw Exception("impossible: missing chunk")
                    }
                }
            }
        }
        true
    }

    /*
     * The Function is reset
     *
     */
    func reset() {
        chunks = Array<UInt32>(huffmanNumChunks, item: 0)
        links = []
        linkMask = 0
    }
}

/* let member codeOrder type is Array<Int64> */
let codeOrder: Array<Int64> = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]

/**
 * The class is Decompressor inherited from Resetter
 * @author changeden
 */
public class Decompressor <: Resetter {
    /* var member r type is InputStream */
    var r: InputStream = ByteArrayStream()

    /** var member roffset type is Int64 */
    public var roffset: Int64 = 0

    /* var member b type is UInt32 */
    var b: UInt32 = 0

    /* var member nb type is UInt32 */
    var nb: UInt32 = 0

    /* var member h1 type is HuffmanDecoder */
    var h1: HuffmanDecoder = HuffmanDecoder()

    /* var member h2 type is HuffmanDecoder */
    var h2: HuffmanDecoder = HuffmanDecoder()

    /* var member bits type is Array<Int64> */
    var bits: Array<Int64> = Array<Int64>(maxNumLit + maxNumDist, item: 0)

    /* var member codebits type is Array<Int64> */
    var codebits: Array<Int64> = Array<Int64>(numCodes, item: 0)

    /* var member dict type is DictDecoder */
    var dict: DictDecoder = DictDecoder()

    /* let member buf type is Array<UInt8> */
    let buf: Array<UInt8> = Array<UInt8>(4, item: 0)

    /* var member step type is ?(Decompressor) -> Unit */
    var step: ?(Decompressor) -> Unit = None

    /* var member stepState type is Int64 */
    var stepState: Int64 = 0

    /* var member final type is Bool */
    var final: Bool = false

    /* var member err type is ?Exception */
    var err: ?Exception = None

    /* var member toRead type is Array<UInt8> */
    var toRead: Array<UInt8> = []

    /* var member hl type is ?HuffmanDecoder */
    var hl: ?HuffmanDecoder = None

    /* var member hd type is ?HuffmanDecoder */
    var hd: ?HuffmanDecoder = None

    /* var member copyLen type is Int64 */
    var copyLen: Int64 = 0

    /* var member copyDist type is Int64 */
    var copyDist: Int64 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param r of InputStream
     */
    public init(r: InputStream) {
        fixedHuffmanDecoderInit()
        this.r = makeReader(r)
        this.step = @OverflowWrapping{_ => nextBlock()}
        this.dict.initiator(maxMatchOffset, None)
    }

    /**
     * The Function is init constructor
     *
     * @param r of InputStream
     * @param dict of Array<UInt8>
     */
    public init(r: InputStream, dict: Array<UInt8>) {
        fixedHuffmanDecoderInit()
        this.r = makeReader(r)
        this.step = @OverflowWrapping{_ => nextBlock()}
        this.dict.initiator(maxMatchOffset, dict)
    }

    /*
     * The Function is nextBlock
     *
     * @return Type of Unit
     */
    func nextBlock(): Unit {
        while (this.nb < 1 + 2) {
            try {
                moreBits()
            } catch (e: Exception) {
                this.err = e
                return
            }
        }
        this.final = (this.b & 1) == 1
        this.b >>= 1
        let typ = this.b & 3
        this.b >>= 2
        this.nb -= 3
        match (typ) {
            case 0 => dataBlock()
            case 1 =>
                this.hl = fixedHuffmanDecoder
                this.hd = None
                huffmanBlock()
            case 2 =>
                try {
                    readHuffman()
                } catch (e: Exception) {
                    this.err = e
                    throw e
                }
                this.hl = this.h1
                this.hd = this.h2
                huffmanBlock()

            case _ => this.err = CorruptInputError(this.roffset)
        }
    }

    /**
     * The Function is read
     *
     * @param b of Array<UInt8>
     *
     * @return Type of (Int64, ?Exception)
     */
    public func read(b: Array<UInt8>): (Int64, ?Exception) {
        while (true) {
            if (this.toRead.size > 0) {
                let n = copy(b, this.toRead)
                this.toRead = if (n >= this.toRead.size) {
                    []
                } else {
                    this.toRead[n..this.toRead.size]
                }
                if (this.toRead.size == 0) {
                    return (n, this.err)
                }
                return (n, None)
            }
            if (let Some(e) <- this.err) {
                return (0, e)
            }
            this.step.getOrThrow()(this)
            if (if (let Some(e) <- this.err) {
                true
            } else {
                false
            } && this.toRead.size == 0) {
                this.toRead = this.dict.readFlush()
            }
        }
        (0, None)
    }

    /**
     * The Function is close
     *
     */
    public func close() {
        if (let Some(e) <- this.err) {
            if (!(e is EOF)) {
                throw e
            }
        }
    }

    /**
     * The Function is reset
     *
     * @param r of InputStream
     * @param dict of Array<UInt8>
     *
     * @return Type of Unit
     */
    public func reset(r: InputStream, dict: Array<UInt8>): Unit {
        this.r = makeReader(r)
        roffset = 0
        b = 0
        nb = 0
        h1 = HuffmanDecoder()
        h2 = HuffmanDecoder()
        step = {b => b.nextBlock()}
        stepState = 0
        final = false
        err = None
        toRead = []
        hl = None
        hd = None
        copyLen = 0
        copyDist = 0
        for (i in 0..buf.size) {
            buf[i] = 0
        }
        this.dict.initiator(maxMatchOffset, dict)
    }

    /*
     * The Function is readHuffman
     *
     */
    func readHuffman() {
        while (this.nb < 14) {
            moreBits()
        }
        let nlit = Int64(this.b & 0x1F) + 257
        if (nlit > maxNumLit) {
            throw CorruptInputError(this.roffset)
        }
        this.b >>= 5
        let ndist = Int64(this.b & 0x1F) + 1
        if (ndist > maxNumDist) {
            throw CorruptInputError(this.roffset)
        }
        this.b >>= 5
        let nclen = Int64(this.b & 0xF) + 4

        // numCodes is 19, so nclen is always valid.
        this.b >>= 4
        this.nb -= 14

        for (i in 0..nclen) {
            while (this.nb < 3) {
                moreBits()
            }
            this.codebits[codeOrder[i]] = Int64(this.b & 0x7)
            this.b >>= 3
            this.nb -= 3
        }
        for (i in nclen..codeOrder.size) {
            this.codebits[codeOrder[i]] = 0
        }
        if (!this.h1.initiator(this.codebits[0..this.codebits.size])) {
            throw CorruptInputError(this.roffset)
        }

        var i = 0
        var n = nlit + ndist
        while (i < n) {
            let (x, merr) = huffSym(this.h1)
            if (let Some(e) <- merr) {
                throw e
            }
            if (x < 16) {
                // Actual length.
                this.bits[i] = x
                i++
                continue
            }
            var rep = 0
            var nb: UInt32 = 0
            var b = 0
            match (x) {
                case 16 =>
                    rep = 3
                    nb = 2
                    if (i == 0) {
                        throw CorruptInputError(this.roffset)
                    }
                    b = this.bits[i - 1]
                case 17 =>
                    rep = 3
                    nb = 3
                    b = 0
                case 18 =>
                    rep = 11
                    nb = 7
                    b = 0
                case _ => throw InternalError("unexpected length code")
            }
            while (this.nb < nb) {
                moreBits()
            }
            rep += Int64(this.b & UInt32((1 << nb) - 1))
            this.b >>= nb
            this.nb -= nb
            if (i + rep > n) {
                throw CorruptInputError(this.roffset)
            }
            for (j in 0..rep) {
                this.bits[i] = b
                i++
            }
        }

        if (!this.h1.initiator(this.bits[0..nlit]) || !this.h2.initiator(this.bits[nlit..(nlit + ndist)])) {
            throw CorruptInputError(this.roffset)
        }

        if (this.h1.min < this.bits[endBlockMarker]) {
            this.h1.min = this.bits[endBlockMarker]
        }
    }

    /* let member stateInit */
    let stateInit = 0

    /* let member stateDict */
    let stateDict = 1

    /*
     * The Function is readLiteral
     *
     * @return Type of ?NextFunc
     */
    func readLiteral(): ?NextFunc {
        var v = 0
        let (vv, merr) = huffSym(this.hl)
        if (let Some(e) <- merr) {
            this.err = e
            return None
        } else {
            v = vv
        }
        var n: UInt32 = 0
        var length = 0
        if (v < 256) {
            this.dict.writeByte(UInt8(v))
            if (this.dict.availWrite() == 0) {
                this.toRead = this.dict.readFlush()
                this.step = {d => d.huffmanBlock()}
                this.stepState = stateInit
                return None
            }
            return NextFunc(readLiteral)
        } else if (v == 256) {
            finishBlock()
            return None
        } else if (v < 265) {
            length = v - (257 - 3)
            n = 0
        } else if (v < 269) {
            length = v * 2 - (265 * 2 - 11)
            n = 1
        } else if (v < 273) {
            length = v * 4 - (269 * 4 - 19)
            n = 2
        } else if (v < 277) {
            length = v * 8 - (273 * 8 - 35)
            n = 3
        } else if (v < 281) {
            length = v * 16 - (277 * 16 - 67)
            n = 4
        } else if (v < 285) {
            length = v * 32 - (281 * 32 - 131)
            n = 5
        } else if (v < maxNumLit) {
            length = 258
            n = 0
        } else {
            this.err = CorruptInputError(this.roffset)
            return None
        }
        if (n > 0) {
            while (this.nb < n) {
                try {
                    moreBits()
                } catch (e: Exception) {
                    this.err = e
                    return None
                }
            }
            length += Int64(this.b & UInt32((1 << n) - 1))
            this.b >>= n
            this.nb -= n
        }
        var dist = 0
        if (let Some(mhd) <- this.hd) {
            let (mdist, merr1) = huffSym(mhd)
            dist = mdist
            var f = false
            if (let Some(e) <- merr1) {
                this.err = e
                f = true
            }
            if (f) {
                return None
            }
        } else {
            while (this.nb < 5) {
                try {
                    moreBits()
                } catch (e: Exception) {
                    this.err = e
                    return None
                }
            }
            dist = Int64(bitsReverse8(UInt8((this.b & 0x1F) << 3)))
            this.b >>= 5
            this.nb -= 5
        }

        if (dist < 4) {
            dist++
        } else if (dist < maxNumDist) {
            let nb = UInt32(dist - 2) >> 1
            var extra = (dist & 1) << nb
            while (this.nb < nb) {
                try {
                    moreBits()
                } catch (e: Exception) {
                    this.err = e
                    return None
                }
            }
            extra |= Int64(this.b & UInt32((1 << nb) - 1))
            this.b >>= nb
            this.nb -= nb
            dist = (1 << (nb + 1)) + 1 + extra
        } else {
            this.err = CorruptInputError(this.roffset)
            return None
        }

        if (dist > this.dict.histSize()) {
            this.err = CorruptInputError(this.roffset)
            return None
        }

        this.copyLen = length
        this.copyDist = dist
        NextFunc(copyHistory)
    }

    /*
     * The Function is copyHistory
     *
     * @return Type of ?NextFunc
     */
    func copyHistory(): ?NextFunc {
        var cnt = this.dict.tryWriteCopy(this.copyDist, this.copyLen)
        if (cnt == 0) {
            cnt = this.dict.writeCopy(this.copyDist, this.copyLen)
        }
        this.copyLen -= cnt

        if (this.dict.availWrite() == 0 || this.copyLen > 0) {
            this.toRead = this.dict.readFlush()
            this.step = {d => d.huffmanBlock()}
            this.stepState = stateDict
            return None
        }
        NextFunc(readLiteral)
    }

    /*
     * The Function is huffmanBlock
     *
     * @return Type of Unit
     */
    func huffmanBlock(): Unit {
        var nextFunc: ?NextFunc = None
        if (this.stepState == stateInit) {
            nextFunc = NextFunc(readLiteral)
        } else if (this.stepState == stateDict) {
            nextFunc = NextFunc(copyHistory)
        }
        while (if (let Some(_) <- nextFunc) {
                true
            } else {
                false
            }) {
            nextFunc = nextFunc.getOrThrow().f()
        }
    }

    /*
     * The Function is dataBlock
     *
     * @return Type of Unit
     */
    @OverflowWrapping
    func dataBlock(): Unit {
        this.nb = 0
        this.b = 0
        let mbuf = Array<UInt8>(4, item: 0)
        let (nr, merr) = readFullCustom(this.r, mbuf)
        for (i in 0..nr) {
            this.buf[i] = mbuf[i]
        }
        this.roffset += nr
        if (let Some(e) <- merr) {
            this.err = noEOF(e)
            return
        }
        let n = Int64(this.buf[0]) | (Int64(this.buf[1]) << 8)
        let nn = Int64(this.buf[2]) | (Int64(this.buf[3]) << 8)
        if (UInt16(nn) != UInt16(!n)) {
            this.err = CorruptInputError(this.roffset)
            return
        }
        if (n == 0) {
            this.toRead = this.dict.readFlush()
            finishBlock()
            return
        }

        this.copyLen = n
        copyData()
    }

    /*
     * The Function is copyData
     *
     * @return Type of Unit
     */
    func copyData(): Unit {
        var mbuf = this.dict.writeSlice()
        if (mbuf.size > this.copyLen) {
            mbuf = mbuf[0..this.copyLen]
        }
        let (cnt, merr) = readFullCustom(this.r, mbuf)
        this.dict.writeSlice(mbuf)
        this.roffset += cnt
        this.copyLen -= cnt
        this.dict.writeMark(cnt)
        if (let Some(e) <- merr) {
            this.err = noEOF(e)
            return
        }
        if (this.dict.availWrite() == 0 || this.copyLen > 0) {
            this.toRead = this.dict.readFlush()
            this.step = {d => d.copyData()}
            return
        }
        finishBlock()
    }

    /*
     * The Function is finishBlock
     *
     * @return Type of Unit
     */
    func finishBlock(): Unit {
        if (this.final) {
            if (this.dict.availRead() > 0) {
                this.toRead = this.dict.readFlush()
            }
            this.err = EOF()
        }
        this.step = {d => d.nextBlock()}
    }

    /*
     * The Function is moreBits
     *
     */
    func moreBits(): ?Exception {
        let (c, merr) = readByte(this.r)
        if (let Some(e) <- merr) {
            return noEOF(e)
        }
        this.roffset++
        this.b |= UInt32(c) << this.nb
        this.nb += 8
        None
    }

    /*
     * The Function is huffSym
     *
     * @param mh of ?HuffmanDecoder
     *
     * @return Type of (Int64, ?Exception)
     */
    func huffSym(mh: ?HuffmanDecoder): (Int64, ?Exception) {
        let h = mh.getOrThrow()
        var n = UInt32(h.min)
        var nb = this.nb
        var b = this.b
        while (true) {
            while (nb < n) {
                let (c, merr) = readByte(this.r)
                if (let Some(e) <- merr) {
                    this.b = b
                    this.nb = nb
                    return (0, noEOF(e))
                }
                this.roffset++
                b |= UInt32(c) << (nb & 31)
                nb += 8
            }
            var chunk = h.chunks[Int64(b & UInt32(huffmanNumChunks - 1))]
            n = UInt32(Int64(chunk) & huffmanCountMask)
            if (Int64(n) > huffmanChunkBits) {
                chunk = h.links[Int64(chunk) >> huffmanValueShift][Int64((b >> huffmanChunkBits) & h.linkMask)]
                n = UInt32(Int64(chunk) & huffmanCountMask)
            }
            if (n <= nb) {
                if (n == 0) {
                    this.b = b
                    this.nb = nb
                    this.err = CorruptInputError(this.roffset)
                    return (0, this.err)
                }
                this.b = b >> (n & 31)
                this.nb = nb - n
                return (Int64(chunk >> huffmanValueShift), None)
            }
        }
        (0, None)
    }
}

/*
 * The Function is noEOF
 *
 * @param e of Exception
 *
 * @return Type of Exception
 */
func noEOF(e: Exception): Exception {
    if (e is EOF) {
        ErrUnexpectedEOF()
    } else {
        e
    }
}

/*
 * The Function is makeReader
 *
 * @param r of InputStream
 *
 * @return Type of InputStream
 */
func makeReader(r: InputStream): InputStream {
    r
}

/* var member fixedOnce */
var fixedOnce = false

/*
 * The Function is fixedHuffmanDecoderInit
 *
 */
func fixedHuffmanDecoderInit(): Unit {
    if (fixedOnce) {
        return
    }
    fixedOnce = true

    let bits = Array<Int64>(288, item: 0)
    for (i in 0..144) {
        bits[i] = 8
    }
    for (i in 144..256) {
        bits[i] = 9
    }
    for (i in 256..280) {
        bits[i] = 7
    }
    for (i in 280..288) {
        bits[i] = 8
    }
    fixedHuffmanDecoder.initiator(bits)
}
