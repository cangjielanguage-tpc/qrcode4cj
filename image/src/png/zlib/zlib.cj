/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * zlib压缩算法
 */
package image.png.zlib

import image.internals.imageutil.*
import std.io.*

/* let member zlibDeflate type is UInt8 */
let zlibDeflate: UInt8 = 8

/** let member ErrChecksum */
public let ErrChecksum = Exception("zlib: invalid checksum")

/** let member ErrDictionary */
public let ErrDictionary = Exception("zlib: invalid dictionary")

/** let member ErrHeader */
public let ErrHeader = Exception("zlib: invalid header")

/**
 * The Function is binaryUInt32
 *
 * @param b of Array<UInt8>
 *
 * @return Type of UInt32
 */
public func binaryUInt32(b: Array<UInt8>): UInt32 {
    if (b.size < 4) {
        throw Exception("二进制位数少于4")
    }
    UInt32(b[3]) | (UInt32(b[2]) << 8) | (UInt32(b[1]) << 16) | (UInt32(b[0]) << 24)
}

/**
 * The Function is binaryPutUInt32
 *
 * @param b of Array<UInt8>
 * @param v of UInt32
 * @param bStart of Int64, and the Default value is 0
 */
@OverflowWrapping
public func binaryPutUInt32(b: Array<UInt8>, v: UInt32, bStart!: Int64 = 0) {
    if (b.size < (4 + bStart)) {
        throw Exception("二进制位数少于4")
    }
    b[bStart + 0] = UInt8(v >> 24)
    b[bStart + 1] = UInt8(v >> 16)
    b[bStart + 2] = UInt8(v >> 8)
    b[bStart + 3] = UInt8(v)
}

/**
 * The interface is Resetter
 * @author changeden
 */
public interface Resetter {
    /*
     * The Function is reset
     *
     * @param r of InputStream
     * @param dict of Array<UInt8>
     *
     * @return Type of Unit
     */
    func reset(r: InputStream, dict: Array<UInt8>): Unit
}

/**
 * The class is ZlibReader inherited from Resetter
 * @author changeden
 */
public class ZlibReader <: Resetter {
    /* var member r type is InputStream */
    var r: InputStream

    /** var member decompressor type is ?Decompressor */
    public var decompressor: ?Decompressor = None

    /* var member digest type is Digest */
    var digest: Digest = Digest()

    /* var member err type is ?Exception */
    var err: ?Exception = None

    /* let member scratch type is Array<UInt8> */
    let scratch: Array<UInt8> = Array<UInt8>(4, item: 0)

    /**
     * The Function is init constructor
     *
     * @param r of InputStream
     */
    public init(r: InputStream) {
        this(r, [])
    }

    /**
     * The Function is init constructor
     *
     * @param r of InputStream
     * @param dict of Array<UInt8>
     */
    public init(r: InputStream, dict: Array<UInt8>) {
        this.r = r
        reset(r, dict)
    }

    /**
     * The Function is read
     *
     * @param p of Array<UInt8>
     *
     * @return Type of (Int64, ?Exception)
     */
    public func read(p: Array<UInt8>): (Int64, ?Exception) {
        if (let Some(e) <- this.err) {
            return (0, e)
        }
        let (n, merr) = this.decompressor.getOrThrow().read(p)
        this.err = merr
        if (n > 0) {
            this.digest.write(p[0..n])
        }

        if (let Some(e) <- this.err) {
            if (!(e is EOF)) {
                return (n, e)
            }
        } else {
            return (n, None)
        }
        let (nn, merr1) = readFullCustom(this.r, this.scratch)
        if (let Some(e) <- merr1) {
            let me = if (e is EOF) {
                ErrUnexpectedEOF()
            } else {
                e
            }
            this.err = me
            return (n, me)
        }
        let checksum = (UInt32(this.scratch[0]) << 24) | (UInt32(this.scratch[1]) << 16) | (UInt32(this.scratch[2]) << 8) |
            UInt32(this.scratch[3])
        if (checksum != this.digest.sum32()) {
            this.err = ErrChecksum
            return (n, ErrChecksum)
        }
        return (n, EOF())
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
        this.r = r
        this.err = None
        for (i in 0..scratch.size) {
            scratch[i] = 0
        }

        let b = Array<UInt8>(2, item: 0)
        let (_, merr) = readFullCustom(this.r, b)
        this.err = merr
        if (let Some(e) <- merr) {
            if (e is EOF) {
                this.err = ErrUnexpectedEOF()
            }
            throw this.err.getOrThrow()
        }

        let h = (UInt32(b[0]) << 8) | UInt32(b[1])
        if ((b[0] & 0x0f) != zlibDeflate || (h % 31 != 0)) {
            this.err = ErrHeader
            throw ErrHeader
        }
        let haveDict = (b[1] & 0x20) != 0
        if (haveDict) {
            let (_, merr1) = readFullCustom(this.r, this.scratch)
            this.err = merr1
            if (let Some(e) <- merr1) {
                if (e is EOF) {
                    this.err = ErrUnexpectedEOF()
                }
                throw this.err.getOrThrow()
            }
            let checksum = (UInt32(this.scratch[0]) << 24) | (UInt32(this.scratch[1]) << 16) | (UInt32(this.scratch[2]) <<
                8) | UInt32(this.scratch[3])
            if (checksum != adler32Checksum(dict)) {
                this.err = ErrDictionary
                throw ErrDictionary
            }
        }
        if (let Some(d) <- this.decompressor) {
            d.reset(this.r, dict)
        } else {
            this.decompressor = if (haveDict) {
                Decompressor(this.r, dict)
            } else {
                Decompressor(this.r)
            }
        }
        this.digest.reset()
    }
}

/**
 * The Function is zlibReadFull
 *
 * @param r of ZlibReader
 * @param buf of Array<UInt8>
 * @param min of Int64, and the Default value is buf.size
 *
 * @return Type of (Int64, ?Exception)
 */
public func zlibReadFull(r: ZlibReader, buf: Array<UInt8>, min!: Int64 = buf.size): (Int64, ?Exception) {
    let bs = buf.size
    if (bs < min) {
        return (0, ErrShortBuffer())
    }
    var n = 0
    var nerr: ?Exception = None
    try {
        while (n < min && if (let None <- nerr) {
                true
            } else {
                false
            }) {
            let b = Array<UInt8>(min - n, item: 0)
            let (nn, merr) = r.read(b)
            nerr = merr
            for (i in 0..nn) {
                buf[i + n] = b[i]
            }
            if (nn == 0) {
                break
            }
            n += nn
        }
        if (n >= min) {
            nerr = None
        }
    } catch (e: Exception) {
        nerr = e
    }
    if (n == 0) {
        let a = if (let Some(_) <- nerr) {
            true
        } else {
            false
        }
        return (n, nerr)
    }
    if (n >= min) {
        nerr = None
    } else if (n > 0 && if (let Some(e) <- nerr) {
        e is EOF
    } else {
        false
    }) {
        nerr = ErrUnexpectedEOF()
    }
    (n, nerr)
}

/**
 * The class is ZlibWriter
 * @author changeden
 */
public class ZlibWriter {
    /* var member w type is OutputStream */
    var w: OutputStream

    /* var member level type is Int64 */
    var level: Int64 = 0

    /* var member dict type is ?Array<UInt8> */
    var dict: ?Array<UInt8> = None

    /* var member compressor type is ?FlateWriter */
    var compressor: ?FlateWriter = None

    /* var member digest type is ?Digest */
    var digest: ?Digest = None

    /* var member err type is ?Exception */
    var err: ?Exception = None

    /* let member scratch type is Array<UInt8> */
    let scratch: Array<UInt8> = Array<UInt8>(4, item: 0)

    /* var member wroteHeader type is Bool */
    var wroteHeader: Bool = false

    /**
     * The Function is init constructor
     *
     * @param w of OutputStream
     */
    public init(w: OutputStream) {
        this(w, ZlibDefaultCompression, None)
    }

    /**
     * The Function is init constructor
     *
     * @param w of OutputStream
     * @param level of Int64
     */
    public init(w: OutputStream, level: Int64) {
        this(w, level, None)
    }

    /**
     * The Function is init constructor
     *
     * @param w of OutputStream
     * @param level of Int64
     * @param dict of ?Array<UInt8>
     */
    public init(w: OutputStream, level: Int64, dict: ?Array<UInt8>) {
        if (level < ZlibHuffmanOnly || level > ZlibBestCompression) {
            throw Exception("zlib: invalid compression level: ${level}")
        }
        this.w = w
        this.level = level
        this.dict = dict
    }

    /**
     * The Function is reset
     *
     * @param w of OutputStream
     */
    public func reset(w: OutputStream) {
        this.w = w
        if (let Some(c) <- this.compressor) {
            c.reset(w)
        }
        if (let Some(c) <- this.digest) {
            c.reset()
        }
        this.err = None
        for (i in 0..scratch.size) {
            scratch[i] = 0
        }
        this.wroteHeader = false
    }

    /*
     * The Function is writeHeader
     *
     * @return Type of ?Exception
     */
    func writeHeader(): ?Exception {
        this.wroteHeader = true
        this.scratch[0] = 0x78
        let level = this.level
        if (level == -2 || level == 0 || level == 1) {
            this.scratch[1] = 0 << 6
        } else if (level == 2 || level == 3 || level == 4 || level == 5) {
            this.scratch[1] = 1 << 6
        } else if (level == 6 || level == -1) {
            this.scratch[1] = 2 << 6
        } else if (level == 7 || level == 8 || level == 9) {
            this.scratch[1] = 3 << 6
        } else {
            throw Exception("unreachable")
        }
        if (let Some(_) <- this.dict) {
            this.scratch[1] |= 1 << 5
        }
        this.scratch[1] += UInt8(31 - ((UInt16(this.scratch[0]) << 8) + UInt16(this.scratch[1])) % 31)
        try {
            this.w.write(this.scratch[0..2])
        } catch (e: Exception) {
            return e
        }
        if (let Some(d) <- this.dict) {
            binaryPutUInt32(this.scratch, adler32Checksum(d))
            try {
                this.w.write(this.scratch[0..4])
            } catch (e: Exception) {
                return e
            }
        }
        if (let None <- this.compressor) {
            try {
                this.compressor = FlateWriter(this.w, this.level, this.dict ?? Array<UInt8>())
            } catch (e: Exception) {
                return e
            }
            this.digest = Digest()
        }
        None
    }

    /**
     * The Function is write
     *
     * @param p of Array<UInt8>
     *
     * @return Type of (Int64, ?Exception)
     */
    public func write(p: Array<UInt8>): (Int64, ?Exception) {
        if (!this.wroteHeader) {
            this.err = writeHeader()
        }
        if (let Some(e) <- this.err) {
            return (0, e)
        }
        if (p.size == 0) {
            return (0, None)
        }
        var n = 0
        var err: ?Exception = None
        try {
            n = this.compressor.getOrThrow().writeCustom(p)
        } catch (e: Exception) {
            this.err = e
            err = e
            return (n, e)
        }
        this.digest.getOrThrow().write(p)
        (n, err)
    }

    /**
     * The Function is flush
     *
     * @return Type of ?Exception
     */
    public func flush(): ?Exception {
        if (!this.wroteHeader) {
            this.err = writeHeader()
        }
        if (let Some(e) <- this.err) {
            return e
        }
        try {
            this.compressor.getOrThrow().flush()
        } catch (e: Exception) {
            this.err = e
        }
        this.err
    }

    /**
     * The Function is close
     *
     * @return Type of ?Exception
     */
    public func close(): ?Exception {
        if (!this.wroteHeader) {
            this.err = writeHeader()
        }
        if (let Some(e) <- this.err) {
            return e
        }
        try {
            this.compressor.getOrThrow().close()
        } catch (e: Exception) {
            this.err = e
        }
        if (let Some(e) <- this.err) {
            return e
        }
        let checksum = this.digest.getOrThrow().sum32()
        binaryPutUInt32(this.scratch, checksum)
        try {
            this.w.write(this.scratch[0..4])
        } catch (e: Exception) {
            this.err = e
        }
        this.err
    }
}
