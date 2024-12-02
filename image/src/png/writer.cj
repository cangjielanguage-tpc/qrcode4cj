/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * PNG格式模块
 */

package image.png

import std.io.*
import std.fs.*
import image.image.*
import image.color as color
import image.png.zlib as zlib
import image.internals.model.*
import image.internals.imageutil.*

// 压缩等级
public enum CompressionLevel <: Hashable {
    | DefaultCompression
    | NoCompression
    | BestSpeed
    | BestCompression

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        match (this) {
            case DefaultCompression => 0
            case NoCompression => -1
            case BestSpeed => -2
            case BestCompression => -3
        }
    }
}

/**
 * The interface is EncoderBufferPool
 * @author changeden
 */
public interface EncoderBufferPool {
    /*
     * The Function is get
     *
     * @return Type of ?EncoderBuffer
     */
    func get(): ?EncoderBuffer

    /*
     * The Function is put
     *
     * @param e of EncoderBuffer
     *
     * @return Type of Unit
     */
    func put(e: EncoderBuffer): Unit
}

/**
 * The class is Encoder
 * @author changeden
 */
public class Encoder {
    /** var member compressionLevel type is CompressionLevel */
    public var compressionLevel: CompressionLevel = CompressionLevel.DefaultCompression

    /** var member bufferPool type is ?EncoderBufferPool */
    public var bufferPool: ?EncoderBufferPool = None

    /**
     * The Function is init constructor
     *
     */
    public init() {
        zlib.huffOffsetInit()
    }

    /**
     * The Function is encode
     *
     * @param w of File
     * @param m of Image
     */
    public func encode(w: File, m: Image) {
        let mw = m.bounds().dx()
        let mh = m.bounds().dy()
        if (mw <= 0 || mh <= 0 || mw >= (1 << 32) || mh >= (1 << 32)) {
            throw FormatError("invalid image size: ${mw}x${mh}")
        }

        var e: EncoderBuffer = match (bufferPool) {
            case Some(bf) =>
                let buffer = bf.get()
                match (buffer) {
                    case Some(me) => me
                    case None => EncoderBuffer()
                }
            case _ => EncoderBuffer()
        }

        if (let Some(bf) <- this.bufferPool) {
            bf.put(e)
        }

        e.enc = this
        let bos = BufferedOutputStream<OutputStream>(w)
        e.w = bos
        e.m = m

        var pal: ?color.Palette = None
        if (m is PalettedImage) {
            pal = (m.colorModel() as color.Palette).getOrThrow()
        }
        if (let Some(p) <- pal) {
            e.cb = if (p.size() <= 2) {
                cbP1
            } else if (p.size() <= 4) {
                cbP2
            } else if (p.size() <= 16) {
                cbP4
            } else {
                cbP8
            }
        } else {
            let cm = m.colorModel()
            e.cb = if (cm == color.GrayModel) {
                cbG8
            } else if (cm == color.Gray16Model) {
                cbG16
            } else if (cm == color.RGBAModel || cm == color.NRGBAModel || cm == color.AlphaModel) {
                if (opaque(m)) {
                    cbTC8
                } else {
                    cbTCA8
                }
            } else {
                if (opaque(m)) {
                    cbTC16
                } else {
                    cbTCA16
                }
            }
        }
        try {
            w.write(pngHeader)
        } catch (me: Exception) {
            e.err = me
        }
        e.writeIHDR()
        if (let Some(p) <- pal) {
            e.writePLTEAndTRNS(p)
        }
        e.writeIDATs()
        e.writeIEND()
        bos.flush()
        if (let Some(me) <- e.err) {
            throw me
        }
    }
}

/**
 * The class is EncoderBuffer inherited from OutputStream
 * @author changeden
 */
public class EncoderBuffer <: OutputStream {
    /* var member enc type is ?Encoder */
    var enc: ?Encoder = None

    /* var member w type is ?BufferedOutputStream */
    var w: ?BufferedOutputStream<OutputStream> = None

    /* var member m type is Image */
    var m: Image = nilImage

    /* var member cb type is Int64 */
    var cb: Int64 = 0

    /* var member err type is ?Exception */
    var err: ?Exception = None

    /* let member header type is Array<UInt8> */
    let header: Array<UInt8> = Array<UInt8>(8, item: 0)

    /* let member footer type is Array<UInt8> */
    let footer: Array<UInt8> = Array<UInt8>(4, item: 0)

    /* let member tmp type is Array<UInt8> */
    let tmp: Array<UInt8> = Array<UInt8>(4 * 256, item: 0)

    /* let member cr type is Array<Array<UInt8>> */
    let cr: Array<Array<UInt8>> = Array<Array<UInt8>>(nFilter, item: [])

    /* var member pr type is Array<UInt8> */
    var pr: Array<UInt8> = []

    /* var member zw type is ?ZlibWriter */
    var zw: ?zlib.ZlibWriter = None

    /* var member zwLevel type is Int64 */
    var zwLevel: Int64 = 0

    /* var member bw type is ?ByteArrayStream */
    var bw: ?ByteArrayStream = None

    /*
     * The Function is writeChunk
     *
     * @param b of Array<UInt8>
     * @param name of String
     */
    @OverflowWrapping
    func writeChunk(b: Array<UInt8>, name: String) {
        if (let Some(e) <- this.err) {
            throw e
        }
        let n = UInt32(b.size)
        if (Int64(n) != b.size) {
            this.err = UnsupportedError("${name} chunk is too large: ${b.size}")
            return
        }
        zlib.binaryPutUInt32(this.header, n)
        let nameCharArray = name.toArray()
        this.header[4] = nameCharArray[0]
        this.header[5] = nameCharArray[1]
        this.header[6] = nameCharArray[2]
        this.header[7] = nameCharArray[3]
        let crc = zlib.Crc32IEEE()
        crc.write(this.header[4..8])
        crc.write(b)
        zlib.binaryPutUInt32(this.footer, crc.sum32())
        try {
            this.w.getOrThrow().write(this.header[0..8])
        } catch (e: Exception) {
            this.err = e
            return
        }
        try {
            if (b.size > 0) {
                this.w.getOrThrow().write(b)
            }
        } catch (e: Exception) {
            this.err = e
            return
        }
        try {
            this.w.getOrThrow().write(this.footer[0..4])
        } catch (e: Exception) {
            this.err = e
        }
    }

    /*
     * The Function is writeIHDR
     *
     */
    func writeIHDR() {
        let b = this.m.bounds()
        zlib.binaryPutUInt32(this.tmp, UInt32(b.dx()), bStart: 0)
        zlib.binaryPutUInt32(this.tmp, UInt32(b.dy()), bStart: 4)
        let cb = this.cb
        if (cb == cbG8) {
            this.tmp[8] = 8
            this.tmp[9] = ctGrayscale
        } else if (cb == cbTC8) {
            this.tmp[8] = 8
            this.tmp[9] = ctTrueColor
        } else if (cb == cbP8) {
            this.tmp[8] = 8
            this.tmp[9] = ctPaletted
        } else if (cb == cbP4) {
            this.tmp[8] = 4
            this.tmp[9] = ctPaletted
        } else if (cb == cbP2) {
            this.tmp[8] = 2
            this.tmp[9] = ctPaletted
        } else if (cb == cbP1) {
            this.tmp[8] = 1
            this.tmp[9] = ctPaletted
        } else if (cb == cbTCA8) {
            this.tmp[8] = 8
            this.tmp[9] = ctTrueColorAlpha
        } else if (cb == cbG16) {
            this.tmp[8] = 16
            this.tmp[9] = ctGrayscale
        } else if (cb == cbTC16) {
            this.tmp[8] = 16
            this.tmp[9] = ctTrueColor
        } else if (cb == cbTCA16) {
            this.tmp[8] = 16
            this.tmp[9] = ctTrueColorAlpha
        }
        this.tmp[10] = 0 // default compression method
        this.tmp[11] = 0 // default filter method
        this.tmp[12] = 0 // non-interlaced
        writeChunk(this.tmp[0..13], "IHDR")
    }

    /*
     * The Function is writePLTEAndTRNS
     *
     * @param p of color.Palette
     */
    func writePLTEAndTRNS(p: color.Palette) {
        if (p.size() < 1 || p.size() > 256) {
            this.err = FormatError("bad palette length: ${p.size()}")
            return
        }
        var last = -1
        for (i in 0..p.size()) {
            let c = p[i]
            let c1 = (color.NRGBAModel.convert(c) as color.NRGBAC).getOrThrow()
            this.tmp[3 * i + 0] = c1.r
            this.tmp[3 * i + 1] = c1.g
            this.tmp[3 * i + 2] = c1.b
            if (c1.a != 0xff) {
                last = i
            }
            this.tmp[3 * 256 + i] = c1.a
        }
        writeChunk(this.tmp[0..(3 * p.size())], "PLTE")
        if (last != -1) {
            writeChunk(this.tmp[(3 * 256)..(3 * 256 + 1 + last)], "tRNS")
        }
    }

    /**
     * The Function is write
     *
     * @param arrayToWrite of Array<UInt8>
     */
    public func write(arrayToWrite: Array<UInt8>) {
        writeChunk(arrayToWrite, "IDAT")
        if (let Some(e) <- this.err) {
            throw e
        }
    }

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
        let mbw = this.bw.getOrThrow()
        let buf = Array<UInt8>(4096, item: 0)
        var n = 0
        do {
            n = mbw.read(buf)
            if (n > 0) {
                this.write(buf[0..n])
            } else {
                break
            }
        } while (true)
    }

    /*
     * The Function is writeImage
     *
     * @param w of OutputStream
     * @param m of Image
     * @param cb of Int64
     * @param level of Int64
     */
    @OverflowWrapping
    func writeImage(w: OutputStream, m: Image, cb: Int64, level: Int64) {
        if (if (let None <- this.zw) {
            true
        } else {
            false
        } || this.zwLevel != level) {
            this.zw = zlib.ZlibWriter(w, level)
            this.zwLevel = level
        } else {
            this.zw.getOrThrow().reset(w)
        }
        try {
            let bitsPerPixel = if (cb == cbG8) {
                8
            } else if (cb == cbTC8) {
                24
            } else if (cb == cbP8) {
                8
            } else if (cb == cbP4) {
                4
            } else if (cb == cbP2) {
                2
            } else if (cb == cbP1) {
                1
            } else if (cb == cbTCA8) {
                32
            } else if (cb == cbTC16) {
                48
            } else if (cb == cbTCA16) {
                64
            } else if (cb == cbG16) {
                16
            } else {
                0
            }

            let b = m.bounds()
            let sz = 1 + (bitsPerPixel * b.dx() + 7) / 8
            for (i in 0..this.cr.size) {
                this.cr[i] = Array<UInt8>(sz, item: 0)
                this.cr[i][0] = UInt8(i)
            }
            let cr = this.cr
            this.pr = Array<UInt8>(sz, item: 0)
            var pr = this.pr

            for (y in b.min.y..b.max.y) {
                var i = 1
                if (cb == cbG8) {
                    if (m is Gray) {
                        let gray = (m as Gray).getOrThrow()
                        let offset = (y - b.min.y) * gray.stride
                        copy(cr[0], gray.pix, dstStart: 1, srcStart: offset, srcEnd: offset + b.dx())
                    } else {
                        for (x in b.min.x..b.max.x) {
                            let c = (color.GrayModel.convert(m.at(x, y)) as color.GrayC).getOrThrow()
                            cr[0][i] = c.y
                            i++
                        }
                    }
                } else if (cb == cbTC8) {
                    let cr0 = cr[0]
                    let (stride, pix) = if (m is RGBA) {
                        let r = (m as RGBA).getOrThrow()
                        (r.stride, r.pix)
                    } else if (m is NRGBA) {
                        let r = (m as NRGBA).getOrThrow()
                        (r.stride, r.pix)
                    } else {
                        (0, Array<UInt8>())
                    }
                    if (stride != 0) {
                        let j0 = (y - b.min.y) * stride
                        let j1 = j0 + b.dx() * 4
                        for (j in j0..j1 : 4) {
                            cr0[i + 0] = pix[j + 0]
                            cr0[i + 1] = pix[j + 1]
                            cr0[i + 2] = pix[j + 2]
                            i += 3
                        }
                    } else {
                        for (x in b.min.x..b.max.x) {
                            let (r, g, mb, _) = m.at(x, y).rgba()
                            cr0[i + 0] = UInt8(r >> 8)
                            cr0[i + 1] = UInt8(g >> 8)
                            cr0[i + 2] = UInt8(mb >> 8)
                            i += 3
                        }
                    }
                } else if (cb == cbP8) {
                    if (m is Paletted) {
                        let p = (m as Paletted).getOrThrow()
                        let offset = (y - b.min.y) * p.stride
                        copy(cr[0], p.pix, dstStart: 1, srcStart: offset, srcEnd: offset + b.dx())
                    } else {
                        let pi = (m as PalettedImage).getOrThrow()
                        for (x in b.min.x..b.max.x) {
                            cr[0][i] = pi.colorIndexAt(x, y)
                            i++
                        }
                    }
                } else if (cb == cbP4 || cb == cbP2 || cb == cbP1) {
                    let pi = (m as PalettedImage).getOrThrow()
                    var a: UInt8 = 0
                    var c: Int64 = 0
                    let pixelsPerByte = 8 / bitsPerPixel
                    for (x in b.min.x..b.max.x) {
                        a = (a << UInt32(bitsPerPixel)) | pi.colorIndexAt(x, y)
                        c++
                        if (c == pixelsPerByte) {
                            cr[0][i] = a
                            i += 1
                            a = 0
                            c = 0
                        }
                    }
                    if (c != 0) {
                        while (c != pixelsPerByte) {
                            a = a << UInt32(bitsPerPixel)
                            c++
                        }
                        cr[0][i] = a
                    }
                } else if (cb == cbTCA8) {
                    if (m is NRGBA) {
                        let r = (m as NRGBA).getOrThrow()
                        let offset = (y - b.min.y) * r.stride
                        copy(cr[0], r.pix, dstStart: 1, srcStart: offset, srcEnd: offset + b.dx() * 4)
                    } else {
                        for (x in b.min.x..b.max.x) {
                            let c = (color.NRGBAModel.convert(m.at(x, y)) as color.NRGBAC).getOrThrow()
                            cr[0][i + 0] = c.r
                            cr[0][i + 1] = c.g
                            cr[0][i + 2] = c.b
                            cr[0][i + 3] = c.a
                            i += 4
                        }
                    }
                } else if (cb == cbG16) {
                    for (x in b.min.x..b.max.x) {
                        let c = (color.Gray16Model.convert(m.at(x, y)) as color.Gray16C).getOrThrow()
                        cr[0][i + 0] = UInt8(c.y >> 8)
                        cr[0][i + 1] = UInt8(c.y)
                        i += 2
                    }
                } else if (cb == cbTC16) {
                    for (x in b.min.x..b.max.x) {
                        let (r, g, mb, _) = m.at(x, y).rgba()
                        cr[0][i + 0] = UInt8(r >> 8)
                        cr[0][i + 1] = UInt8(r)
                        cr[0][i + 2] = UInt8(g >> 8)
                        cr[0][i + 3] = UInt8(g)
                        cr[0][i + 4] = UInt8(mb >> 8)
                        cr[0][i + 5] = UInt8(mb)
                        i += 6
                    }
                } else if (cb == cbTCA16) {
                    for (x in b.min.x..b.max.x) {
                        let c = (color.NRGBA64Model.convert(m.at(x, y)) as color.NRGBA64C).getOrThrow()
                        cr[0][i + 0] = UInt8(c.r >> 8)
                        cr[0][i + 1] = UInt8(c.r)
                        cr[0][i + 2] = UInt8(c.g >> 8)
                        cr[0][i + 3] = UInt8(c.g)
                        cr[0][i + 4] = UInt8(c.b >> 8)
                        cr[0][i + 5] = UInt8(c.b)
                        cr[0][i + 6] = UInt8(c.a >> 8)
                        cr[0][i + 7] = UInt8(c.a)
                        i += 8
                    }
                }
                var f = Int64(ftNone)
                if (level != zlib.ZlibNoCompression && cb != cbP8 && cb != cbP4 && cb != cbP2 && cb != cbP1) {
                    let bpp = bitsPerPixel / 8
                    f = filter(cr, pr, bpp)
                }
                let (_, merr) = this.zw.getOrThrow().write(cr[f])
                if (let Some(e) <- merr) {
                    throw e
                }

                let (mpr, mcr) = (cr[0], pr)
                this.pr = mpr
                pr = mpr
                cr[0] = mcr
            }
        } catch (e: Exception) {
            throw e
        } finally {
            w.flush()
            this.zw.getOrThrow().close()
        }
    }

    /*
     * The Function is writeIDATs
     *
     */
    func writeIDATs() {
        if (let Some(_) <- this.err) {
            return
        }
        let bw = ByteArrayStream()
        this.bw = bw
        try {
            writeImage(bw, this.m, this.cb, levelToZlib(this.enc.getOrThrow().compressionLevel))
        } catch (e: Exception) {
            this.err = e
            return
        }
        try {
            this.flush()
        } catch (e: Exception) {
            this.err = e
        }
    }

    /*
     * The Function is writeIEND
     *
     */
    func writeIEND() {
        writeChunk([], "IEND")
    }
}

/*
 * The interface is Opaquer
 * @author changeden
 */
interface Opaquer {
    /*
     * The Function is opaque
     *
     * @return Type of Bool
     */
    func opaque(): Bool
}

/*
 * The Function is opaque
 *
 * @param m of Image
 *
 * @return Type of Bool
 */
func opaque(m: Image): Bool {
    if (m is Opaquer) {
        return (m as Opaquer).getOrThrow().opaque()
    }
    let b = m.bounds()
    for (y in b.min.y..b.max.y) {
        for (x in b.min.x..b.max.x) {
            let (_, _, _, a) = m.at(x, y).rgba()
            if (a != 0xffff) {
                return false
            }
        }
    }
    true
}

/*
 * The Function is abs8
 *
 * @param d of UInt8
 *
 * @return Type of Int64
 */
func abs8(d: UInt8): Int64 {
    if (d < 128) {
        Int64(d)
    } else {
        256 - Int64(d)
    }
}

/*
 * The Function is filter
 *
 * @param cr of Array<Array<UInt8>>
 * @param pr of Array<UInt8>
 * @param bpp of Int64
 *
 * @return Type of Int64
 */
@OverflowWrapping
func filter(cr: Array<Array<UInt8>>, pr: Array<UInt8>, bpp: Int64): Int64 {
    let cdat0 = cr[0][1..cr[0].size]
    let cdat1 = cr[1][1..cr[1].size]
    let cdat2 = cr[2][1..cr[2].size]
    let cdat3 = cr[3][1..cr[3].size]
    let cdat4 = cr[4][1..cr[4].size]
    let pdat = pr[1..pr.size]
    let n = cdat0.size

    var sum = 0
    for (i in 0..n) {
        cdat2[i] = cdat0[i] - pdat[i]
        sum += abs8(cdat2[i])
    }

    var best = sum
    var f = ftUp

    sum = 0
    for (i in 0..bpp) {
        cdat4[i] = cdat0[i] - pdat[i]
        sum += abs8(cdat4[i])
    }

    for (i in bpp..n) {
        cdat4[i] = cdat0[i] - paeth(cdat0[i - bpp], pdat[i], pdat[i - bpp])
        sum += abs8(cdat4[i])
        if (sum >= best) {
            break
        }
    }
    if (sum < best) {
        best = sum
        f = ftPaeth
    }

    sum = 0
    for (i in 0..n) {
        sum += abs8(cdat0[i])
        if (sum >= best) {
            break
        }
    }
    if (sum < best) {
        best = sum
        f = ftNone
    }

    sum = 0
    for (i in 0..bpp) {
        cdat1[i] = cdat0[i]
        sum += abs8(cdat1[i])
    }
    for (i in bpp..n) {
        cdat1[i] = cdat0[i] - cdat0[i - bpp]
        sum += abs8(cdat1[i])
        if (sum >= best) {
            break
        }
    }
    if (sum < best) {
        best = sum
        f = ftSub
    }

    sum = 0
    for (i in 0..bpp) {
        cdat3[i] = cdat0[i] - pdat[i] / 2
        sum += abs8(cdat3[i])
    }
    for (i in bpp..n) {
        cdat3[i] = cdat0[i] - UInt8((Int64(cdat0[i - bpp]) + Int64(pdat[i])) / 2)
        sum += abs8(cdat3[i])
        if (sum >= best) {
            break
        }
    }
    if (sum < best) {
        f = ftAverage
    }

    copy(cr[0], cdat0, dstStart: 1)
    copy(cr[1], cdat1, dstStart: 1)
    copy(cr[2], cdat2, dstStart: 1)
    copy(cr[3], cdat3, dstStart: 1)
    copy(cr[4], cdat4, dstStart: 1)

    Int64(f)
}

/*
 * The Function is levelToZlib
 *
 * @param l of CompressionLevel
 *
 * @return Type of Int64
 */
func levelToZlib(l: CompressionLevel): Int64 {
    match (l) {
        case DefaultCompression => zlib.ZlibDefaultCompression
        case NoCompression => zlib.ZlibNoCompression
        case BestSpeed => zlib.ZlibBestSpeed
        case BestCompression => zlib.ZlibBestCompression
    }
}

/**
 * 编码PNG图片
 *
 * @param w of File 文件流（输出）
 * @param m of Image 输入图片
 */
public func encode(w: File, m: Image) {
    Encoder().encode(w, m)
}
