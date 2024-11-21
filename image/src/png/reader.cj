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
import std.collection.*
import image.color.*
import image.image as image
import image.color as color
import image.png.zlib as zlib
import image.internals.model.*
import image.internals.imageutil.*
import image.drawer.*

/* let member ctGrayscale type is UInt8 */
let ctGrayscale: UInt8 = 0

/* let member ctTrueColor type is UInt8 */
let ctTrueColor: UInt8 = 2

/* let member ctPaletted type is UInt8 */
let ctPaletted: UInt8 = 3

/* let member ctGrayscaleAlpha type is UInt8 */
let ctGrayscaleAlpha: UInt8 = 4

/* let member ctTrueColorAlpha type is UInt8 */
let ctTrueColorAlpha: UInt8 = 6

/* let member cbInvalid */
let cbInvalid = 0

/* let member cbG1 */
let cbG1 = 1

/* let member cbG2 */
let cbG2 = 2

/* let member cbG4 */
let cbG4 = 3

/* let member cbG8 */
let cbG8 = 4

/* let member cbGA8 */
let cbGA8 = 5

/* let member cbTC8 */
let cbTC8 = 6

/* let member cbP1 */
let cbP1 = 7

/* let member cbP2 */
let cbP2 = 8

/* let member cbP4 */
let cbP4 = 9

/* let member cbP8 */
let cbP8 = 10

/* let member cbTCA8 */
let cbTCA8 = 11

/* let member cbG16 */
let cbG16 = 12

/* let member cbGA16 */
let cbGA16 = 13

/* let member cbTC16 */
let cbTC16 = 14

/* let member cbTCA16 */
let cbTCA16 = 15

/*
 * The Function is cbPaletted
 *
 * @param cb of Int64
 *
 * @return Type of Bool
 */
func cbPaletted(cb: Int64): Bool {
    cbP1 <= cb && cb <= cbP8
}

/* let member ftNone type is UInt8 */
let ftNone: UInt8 = 0

/* let member ftSub type is UInt8 */
let ftSub: UInt8 = 1

/* let member ftUp type is UInt8 */
let ftUp: UInt8 = 2

/* let member ftAverage type is UInt8 */
let ftAverage: UInt8 = 3

/* let member ftPaeth type is UInt8 */
let ftPaeth: UInt8 = 4

/* let member nFilter */
let nFilter = 5

/* let member itNone type is UInt8 */
let itNone: UInt8 = 0

/* let member itAdam7 type is UInt8 */
let itAdam7: UInt8 = 1

/**
 * The class is InterlaceScan
 * @author changeden
 */
public class InterlaceScan {
    /** var member xFactor type is Int64 */
    public var xFactor: Int64 = 0

    /** var member yFactor type is Int64 */
    public var yFactor: Int64 = 0

    /** var member xOffset type is Int64 */
    public var xOffset: Int64 = 0

    /** var member yOffset type is Int64 */
    public var yOffset: Int64 = 0

    /**
     * The Function is init constructor
     *
     */
    // public init() {}

    /**
     * The Function is init constructor
     *
     * @param xFactor of Int64
     * @param yFactor of Int64
     * @param xOffset of Int64
     * @param yOffset of Int64
     */
    public init(xFactor: Int64, yFactor: Int64, xOffset: Int64, yOffset: Int64) {
        this.xFactor = xFactor
        this.yFactor = yFactor
        this.xOffset = xOffset
        this.yOffset = yOffset
    }
}

/* let member interlacing type is Array<InterlaceScan> */
let interlacing: Array<InterlaceScan> = [
    InterlaceScan(8, 8, 0, 0),
    InterlaceScan(8, 8, 4, 0),
    InterlaceScan(4, 8, 0, 4),
    InterlaceScan(4, 4, 2, 0),
    InterlaceScan(2, 4, 0, 2),
    InterlaceScan(2, 2, 1, 0),
    InterlaceScan(1, 2, 0, 1)
]

/* let member dsStart */
let dsStart = 0

/* let member dsSeenIHDR */
let dsSeenIHDR = 1

/* let member dsSeenPLTE */
let dsSeenPLTE = 2

/* let member dsSeentRNS */
let dsSeentRNS = 3

/* let member dsSeenIDAT */
let dsSeenIDAT = 4

/* let member dsSeenIEND */
let dsSeenIEND = 5

/* let member pngHeader type is Array<UInt8> */
let pngHeader: Array<UInt8> = [137, 80, 78, 71, 13, 10, 26, 10] // "\u{89}PNG\r\n\u{1a}\n"

/**
 * The class is FormatError inherited from Exception & ToString
 * @author changeden
 */
public class FormatError <: Exception & ToString {
    /* var member msg type is String */
    var msg: String = ""

    /**
     * The Function is init constructor
     *
     * @param msg of String
     */
    public init(msg: String) {
        super(msg)
        this.msg = msg
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public override func toString(): String {
        "png: invalid format: ${msg}"
    }

    /**
     * The Function is ==
     *
     * @param e of FormatError
     *
     * @return Type of Bool
     */
    public operator func ==(e: FormatError): Bool {
        msg == e.msg
    }

    /**
     * The Function is !=
     *
     * @param e of FormatError
     *
     * @return Type of Bool
     */
    public operator func !=(e: FormatError): Bool {
        !(this == e)
    }
}

/**
 * The class is UnsupportedError inherited from Exception & ToString
 * @author changeden
 */
public class UnsupportedError <: Exception & ToString {
    /* var member msg type is String */
    var msg: String = ""

    /**
     * The Function is init constructor
     *
     * @param msg of String
     */
    public init(msg: String) {
        super(msg)
        this.msg = msg
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public override func toString(): String {
        "png: unsupported feature: ${msg}"
    }

    /**
     * The Function is ==
     *
     * @param e of UnsupportedError
     *
     * @return Type of Bool
     */
    public operator func ==(e: UnsupportedError): Bool {
        msg == e.msg
    }

    /**
     * The Function is !=
     *
     * @param e of UnsupportedError
     *
     * @return Type of Bool
     */
    public operator func !=(e: UnsupportedError): Bool {
        !(this == e)
    }
}

/* let member chunkOrderError */
let chunkOrderError = FormatError("chunk out of order")

/*
 * The Function is min
 *
 * @param a of Int64
 * @param b of Int64
 *
 * @return Type of Int64
 */
func min(a: Int64, b: Int64): Int64 {
    if (a < b) {
        a
    } else {
        b
    }
}

/**
 * The class is Decoder inherited from InputStream
 * @author changeden
 */
public class Decoder <: InputStream {
    /** var member r type is BufferedInputStream */
    public var r: BufferedInputStream<InputStream>

    /** var member img type is Image */
    public var img: Image = image.nilImage

    /** var member crc type is Crc32IEEE */
    public var crc: zlib.Crc32IEEE = zlib.Crc32IEEE()

    /** var member width type is Int64 */
    public var width: Int64 = 0

    /** var member height type is Int64 */
    public var height: Int64 = 0

    /** var member depth type is Int64 */
    public var depth: Int64 = 0

    /** var member palette type is Palette */
    public var palette: Palette = Palette()

    /** var member cb type is Int64 */
    public var cb: Int64 = 0

    /** var member mstage type is Int64 */
    public var mstage: Int64 = 0

    /** var member idatLength type is UInt32 */
    public var idatLength: UInt32 = 0

    /** let member tmp type is Array<UInt8> */
    public let tmp: Array<UInt8> = Array<UInt8>(3 * 256, repeat: 0)

    /** var member interlace type is Int64 */
    public var interlace: Int64 = 0

    /** var member useTransparent type is Bool */
    public var useTransparent: Bool = false

    /** let member transparent type is Array<UInt8> */
    public let transparent: Array<UInt8> = Array<UInt8>(6, repeat: 0)

    /**
     * The Function is init constructor
     *
     * @param r of BufferedInputStream
     */
    public init(r: BufferedInputStream<InputStream>) {
        this.r = r
        zlib.huffOffsetInit()
    }

    /*
     * The Function is readToTemp
     *
     * @param l of Int64
     *
     * @return Type of Array<UInt8>
     */
    func readToTemp(l: Int64): Array<UInt8> {
        let b = this.tmp[0..l]
        r.read(b)
        b
    }

    /*
     * The Function is readFullToTemp
     *
     * @param length of Int64
     *
     * @return Type of Int64
     */
    func readFullToTemp(length: Int64): Int64 {
        let b = this.tmp[0..length]
        let n = readFull(this.r, b)
        n
    }

    /*
     * The Function is parseIHDR
     *
     * @param length of UInt32
     *
     * @return Type of Unit
     */
    @OverflowWrapping
    func parseIHDR(length: UInt32): Unit {
        if (length != 13) {
            throw FormatError("bad IHDR length")
        }
        let rb = readToTemp(13)
        crc.write(rb)
        if (tmp[10] != 0) {
            throw UnsupportedError("compression method")
        }
        if (tmp[11] != 0) {
            throw UnsupportedError("filter method")
        }
        if (tmp[12] != itNone && tmp[12] != itAdam7) {
            throw FormatError("invalid interlace method")
        }
        interlace = Int64(tmp[12])
        let w = Int32(zlib.binaryUInt32(tmp[0..4]))
        let h = Int32(zlib.binaryUInt32(tmp[4..8]))
        if (w <= 0 || h <= 0) {
            throw FormatError("non-positive dimension")
        }
        let nPixels64 = Int64(w) * Int64(h)
        let nPixels = Int32(nPixels64)
        if (nPixels64 != Int64(nPixels)) {
            throw UnsupportedError("dimension overflow")
        }

        // There can be up to 8 bytes per pixel, for 16 bits per channel RGBA.
        if (nPixels != ((nPixels * 8) / 8)) {
            throw UnsupportedError("dimension overflow")
        }
        depth = Int64(tmp[8])
        cb = match (depth) {
            case 1 =>
                let f = tmp[9]
                if (f == ctGrayscale) {
                    cbG1
                } else if (f == ctPaletted) {
                    cbP1
                } else {
                    cbInvalid
                }
            case 2 =>
                let f = tmp[9]
                if (f == ctGrayscale) {
                    cbG2
                } else if (f == ctPaletted) {
                    cbP2
                } else {
                    cbInvalid
                }
            case 4 =>
                let f = tmp[9]
                if (f == ctGrayscale) {
                    cbG4
                } else if (f == ctPaletted) {
                    cbP4
                } else {
                    cbInvalid
                }
            case 8 =>
                let f = tmp[9]
                if (f == ctGrayscale) {
                    cbG8
                } else if (f == ctTrueColor) {
                    cbTC8
                } else if (f == ctPaletted) {
                    cbP8
                } else if (f == ctGrayscaleAlpha) {
                    cbGA8
                } else if (f == ctTrueColorAlpha) {
                    cbTCA8
                } else {
                    cbInvalid
                }
            case 16 =>
                let f = tmp[9]
                if (f == ctGrayscale) {
                    cbG16
                } else if (f == ctTrueColor) {
                    cbTC16
                } else if (f == ctGrayscaleAlpha) {
                    cbGA16
                } else if (f == ctTrueColorAlpha) {
                    cbTCA16
                } else {
                    cbInvalid
                }
            case _ => cbInvalid
        }
        if (cb == cbInvalid) {
            throw UnsupportedError("bit depth ${ tmp[8]}, color type ${tmp[9]}")
        }
        this.width = Int64(w)
        this.height = Int64(h)
        verifyChecksum()
    }

    /*
     * The Function is parsePLTE
     *
     * @param length of UInt32
     *
     * @return Type of Unit
     */
    func parsePLTE(length: UInt32): Unit {
        let np = Int64(Int32(length / 3))
        if (length % 3 != 0 || np <= 0 || np > 256 || np > (1 << UInt32(depth))) {
            throw FormatError("bad PLTE length")
        }
        let n = readFullToTemp(3 * np)
        this.crc.write(this.tmp[0..n])
        if (this.cb == cbP1 || this.cb == cbP2 || this.cb == cbP4 || this.cb == cbP8) {
            let palette = Palette(np, {_ => color.RGBAC(0x00, 0x00, 0x00, 0xff)})
            for (i in 0..np) {
                palette[i] = color.RGBAC(this.tmp[3 * i + 0], this.tmp[3 * i + 1], this.tmp[3 * i + 2], 0xff)
            }
            this.palette = palette[0..np]
        } else if (!(this.cb == cbTC8 || this.cb == cbTCA8 || this.cb == cbTC16 || this.cb == cbTCA16)) {
            throw FormatError("PLTE, color type mismatch")
        }
        verifyChecksum()
    }

    /*
     * The Function is parsetRNS
     *
     * @param length of UInt32
     *
     * @return Type of Unit
     */
    func parsetRNS(length: UInt32): Unit {
        if (this.cb == cbG1 || this.cb == cbG2 || this.cb == cbG4 || this.cb == cbG8 || this.cb == cbG16) {
            if (length != 2) {
                throw FormatError("bad tRNS length")
            }
            let n = readFullToTemp(Int64(length))
            this.crc.write(this.tmp[0..n])
            copy(this.transparent, this.tmp[0..n])
            let tsp1 = if (this.cb == cbG1) {
                0xff
            } else if (this.cb == cbG2) {
                0x55
            } else if (this.cb == cbG4) {
                0x11
            } else {
                1
            }
            this.transparent[1] *= UInt8(tsp1)
            this.useTransparent = true
        } else if (this.cb == cbTC8 || this.cb == cbTC16) {
            if (length != 6) {
                throw FormatError("bad tRNS length")
            }
            let n = readFullToTemp(Int64(length))
            this.crc.write(this.tmp[0..n])
            copy(this.transparent, this.tmp[0..n])
            this.useTransparent = true
        } else if (this.cb == cbP1 || this.cb == cbP2 || this.cb == cbP4 || this.cb == cbP8) {
            if (length > 256) {
                throw FormatError("bad tRNS length")
            }
            let n = readFullToTemp(Int64(length))
            this.crc.write(this.tmp[0..n])
            if (this.palette.size() < n) {
                this.palette = this.palette[0..n]
            }
            for (i in 0..n) {
                let rgba = (this.palette[i] as color.RGBAC).getOrThrow()
                this.palette[i] = color.NRGBAC(rgba.r, rgba.g, rgba.b, this.tmp[i])
            }
        } else {
            FormatError("tRNS, color type mismatch")
        }
        verifyChecksum()
    }

    /**
     * The Function is read
     *
     * @param p of Array<UInt8>
     *
     * @return Type of Int64
     */
    public func read(p: Array<UInt8>): Int64 {
        if (p.size == 0) {
            return 0
        }
        while (this.idatLength == 0) {
            verifyChecksum()
            let _ = readFullToTemp(8)
            this.idatLength = zlib.binaryUInt32(this.tmp[0..4])
            if ("IDAT".toArray() != this.tmp[4..8]) {
                throw FormatError("not enough pixel data")
            }
            this.crc.reset()
            this.crc.write(this.tmp[4..8])
        }
        if (Int32(this.idatLength) < 0) {
            throw UnsupportedError("IDAT chunk length overflow")
        }
        let b = p[0..min(p.size, Int64(this.idatLength))]
        let n = this.r.read(b)
        this.crc.write(p[0..n])
        this.idatLength -= UInt32(n)
        n
    }

    /**
     * The Function is read
     *
     * @param readToArray of Array<UInt8>
     * @param off of Int64
     * @param cnt of Int64
     *
     * @return Type of Int64
     */
    public func read(_: Array<UInt8>, _: Int64, _: Int64): Int64 {
        0
    }

    /**
     * The Function is seek
     *
     * @param sp of SeekPosition
     *
     * @return Type of Int64
     */
    public func seek(_: SeekPosition): Int64 {
        0
    }

    /*
     * The Function is decode
     *
     * @return Type of Image
     */
    func decode(): Image {
        let r = zlib.ZlibReader(this)
        var img: Image = image.nilImage
        try {
            if (this.interlace == Int64(itNone)) {
                img = readImagePass(r, 0, false)
            } else if (this.interlace == Int64(itAdam7)) {
                img = readImagePass(None, 0, true)
                for (pass in 0..7) {
                    let imgPass = readImagePass(r, pass, false)
                    if (!(imgPass is image.NilImage)) {
                        mergePassInto(img, imgPass, pass)
                    }
                }
            }
            var n = 0
            var i = 0
            var merr: ?Exception = None
            let b = Array<UInt8>(1, repeat: 0)
            while (n == 0 && if (let None <- merr) {
                    true
                } else {
                    false
                }) {
                if (i == 100) {
                    throw ErrNoProgress()
                }
                let (nn, e) = r.read(b)
                merr = e
                n = nn
                i++
            }
            if (n != 0 || this.idatLength != 0) {
                throw FormatError("too much pixel data")
            }
            return img
        } catch (e: EOF) {
            return img
        } catch (e: ErrNoProgress) {
            throw e
        } catch (e: Exception) {
            // e.printStackTrace()
            // throw e
            throw FormatError(e.toString())
        } finally {
            r.close()
        }
    }

    /*
     * The Function is readImagePass
     *
     * @param r of ?ZlibReader
     * @param pass of Int64
     * @param allocateOnly of Bool
     *
     * @return Type of Image
     */
    @OverflowWrapping
    func readImagePass(r: ?zlib.ZlibReader, pass: Int64, allocateOnly: Bool): Image {
        var bitsPerPixel = 0
        var pixOffset = 0

        var gray: ?image.Gray = None
        var rgba: ?image.RGBA = None
        var paletted: ?image.Paletted = None
        var nrgba: ?image.NRGBA = None
        var gray16: ?image.Gray16 = None
        var rgba64: ?image.RGBA64 = None
        var nrgba64: ?image.NRGBA64 = None
        var img: Image = image.nilImage

        var width = this.width
        var height = this.height

        if (this.interlace == Int64(itAdam7) && !allocateOnly) {
            let p = interlacing[pass]
            width = (width - p.xOffset + p.xFactor - 1) / p.xFactor
            height = (height - p.yOffset + p.yFactor - 1) / p.yFactor
            if (width == 0 || height == 0) {
                return image.nilImage
            }
        }

        let rect = Rectangle(0, 0, width, height)
        if (this.cb == cbG1 || this.cb == cbG2 || this.cb == cbG4 || this.cb == cbG8) {
            bitsPerPixel = this.depth
            if (this.useTransparent) {
                let mnrgba = image.NRGBA(rect)
                nrgba = mnrgba
                img = mnrgba
            } else {
                let mgray = image.Gray(rect)
                gray = mgray
                img = mgray
            }
        } else if (this.cb == cbGA8) {
            bitsPerPixel = 16
            let mnrgba = image.NRGBA(rect)
            nrgba = mnrgba
            img = mnrgba
        } else if (this.cb == cbTC8) {
            bitsPerPixel = 24
            if (this.useTransparent) {
                let mnrgba = image.NRGBA(rect)
                nrgba = mnrgba
                img = mnrgba
            } else {
                let mrgba = image.RGBA(rect)
                rgba = mrgba
                img = mrgba
            }
        } else if (this.cb == cbP1 || this.cb == cbP2 || this.cb == cbP4 || this.cb == cbP8) {
            bitsPerPixel = this.depth
            let mpaletted = image.Paletted(rect, this.palette)
            paletted = mpaletted
            img = mpaletted
        } else if (this.cb == cbTCA8) {
            bitsPerPixel = 32
            let mnrgba = image.NRGBA(rect)
            nrgba = mnrgba
            img = mnrgba
        } else if (this.cb == cbG16) {
            bitsPerPixel = 16
            if (this.useTransparent) {
                let mnrgba64 = image.NRGBA64(rect)
                nrgba64 = mnrgba64
                img = mnrgba64
            } else {
                let mgray16 = image.Gray16(rect)
                gray16 = mgray16
                img = mgray16
            }
        } else if (this.cb == cbGA16) {
            bitsPerPixel = 32
            let mnrgba64 = image.NRGBA64(rect)
            nrgba64 = mnrgba64
            img = mnrgba64
        } else if (this.cb == cbTC16) {
            bitsPerPixel = 48
            if (this.useTransparent) {
                let mnrgba64 = image.NRGBA64(rect)
                nrgba64 = mnrgba64
                img = mnrgba64
            } else {
                let mrgba64 = image.RGBA64(rect)
                rgba64 = mrgba64
                img = mrgba64
            }
        } else if (this.cb == cbTCA16) {
            bitsPerPixel = 64
            let mnrgba64 = image.NRGBA64(rect)
            nrgba64 = mnrgba64
            img = mnrgba64
        }
        if (allocateOnly) {
            return img
        }
        let bytesPerPixel = (bitsPerPixel + 7) / 8

        let rowSize = 1 + (Int64(bitsPerPixel) * Int64(width) + 7) / 8
        if (rowSize != Int64(Int32(rowSize))) {
            throw UnsupportedError("dimension overflow")
        }

        var cr = Array<UInt8>(rowSize, repeat: 0)
        var pr = Array<UInt8>(rowSize, repeat: 0)

        if (let Some(mr) <- r) {
            for (y in 0..height) {
                // let (_, merr) = mr.read(cr)
                let (_, merr) = zlib.zlibReadFull(mr, cr)
                if (let Some(e) <- merr) {
                    if (e is EOF || e is ErrUnexpectedEOF) {
                        throw FormatError("not enough pixel data")
                    } else if (e is FormatError) {
                        break
                    } else {
                        throw e
                    }
                }

                let cdat = cr[1..cr.size]
                let pdat = pr[1..pr.size]
                let cr0 = cr[0]
                if (cr0 == ftNone) {}
                else if (cr0 == ftSub) {
                    for (i in bytesPerPixel..cdat.size) {
                        cdat[i] += cdat[i - bytesPerPixel]
                    }
                } else if (cr0 == ftUp) {
                    for (i in 0..pdat.size) {
                        cdat[i] = pdat[i] + cdat[i]
                    }
                } else if (cr0 == ftAverage) {
                    for (i in 0..bytesPerPixel) {
                        cdat[i] += pdat[i] / 2
                    }
                    for (i in bytesPerPixel..cdat.size) {
                        cdat[i] += UInt8((Int32(cdat[i - bytesPerPixel]) + Int32(pdat[i])) / 2)
                    }
                } else if (cr0 == ftPaeth) {
                    filterPaeth(cdat, pdat, bytesPerPixel)
                } else {
                    throw FormatError("bad filter type")
                }
                let cb = this.cb
                if (cb == cbG1) {
                    if (this.useTransparent) {
                        let nr = nrgba.getOrThrow()
                        let ty = this.transparent[1]
                        for (x in 0..width : 8) {
                            var b = cdat[x / 8]
                            var x2 = 0
                            while (x2 < 8 && (x + x2 < width)) {
                                let ycol = (b >> 7) * 0xff
                                let acol: UInt8 = if (ycol == ty) {
                                    0x00
                                } else {
                                    0xff
                                }
                                nr.setNRGBA(x + x2, y, color.NRGBAC(ycol, ycol, ycol, acol))
                                b <<= 1
                                x2++
                            }
                        }
                    } else {
                        let gr = gray.getOrThrow()
                        for (x in 0..width : 8) {
                            var b = cdat[x / 8]
                            var x2 = 0
                            while (x2 < 8 && (x + x2 < width)) {
                                gr.setGray(x + x2, y, color.GrayC((b >> 7) * 0xff))
                                b <<= 1
                                x2++
                            }
                        }
                    }
                } else if (cb == cbG2) {
                    if (this.useTransparent) {
                        let nr = nrgba.getOrThrow()
                        let ty = this.transparent[1]
                        for (x in 0..width : 4) {
                            var b = cdat[x / 4]
                            var x2 = 0
                            while (x2 < 4 && (x + x2 < width)) {
                                let ycol = (b >> 6) * 0x55
                                let acol: UInt8 = if (ycol == ty) {
                                    0x00
                                } else {
                                    0xff
                                }
                                nr.setNRGBA(x + x2, y, color.NRGBAC(ycol, ycol, ycol, acol))
                                b <<= 2
                                x2++
                            }
                        }
                    } else {
                        let gr = gray.getOrThrow()
                        let _ = this.transparent[1]
                        for (x in 0..width : 4) {
                            var b = cdat[x / 4]
                            var x2 = 0
                            while (x2 < 4 && (x + x2 < width)) {
                                gr.setGray(x + x2, y, color.GrayC((b >> 6) * 0x55))
                                b <<= 2
                                x2++
                            }
                        }
                    }
                } else if (cb == cbG4) {
                    if (this.useTransparent) {
                        let nr = nrgba.getOrThrow()
                        let ty = this.transparent[1]
                        for (x in 0..width : 2) {
                            var b = cdat[x / 2]
                            var x2 = 0
                            while (x2 < 2 && (x + x2 < width)) {
                                let ycol = (b >> 4) * 0x11
                                let acol: UInt8 = if (ycol == ty) {
                                    0x00
                                } else {
                                    0xff
                                }
                                nr.setNRGBA(x + x2, y, color.NRGBAC(ycol, ycol, ycol, acol))
                                b <<= 4
                                x2++
                            }
                        }
                    } else {
                        let gr = gray.getOrThrow()
                        let _ = this.transparent[1]
                        for (x in 0..width : 2) {
                            var b = cdat[x / 2]
                            var x2 = 0
                            while (x2 < 2 && (x + x2 < width)) {
                                gr.setGray(x + x2, y, color.GrayC((b >> 4) * 0x11))
                                b <<= 4
                                x2++
                            }
                        }
                    }
                } else if (cb == cbG8) {
                    if (this.useTransparent) {
                        let nr = nrgba.getOrThrow()
                        let ty = this.transparent[1]
                        for (x in 0..width) {
                            let ycol = cdat[x]
                            let acol: UInt8 = if (ycol == ty) {
                                0x00
                            } else {
                                0xff
                            }
                            nr.setNRGBA(x, y, color.NRGBAC(ycol, ycol, ycol, acol))
                        }
                    } else {
                        let g = gray.getOrThrow()
                        copy(g.pix, cdat, dstStart: pixOffset)
                        pixOffset += g.stride
                    }
                } else if (cb == cbGA8) {
                    let nr = nrgba.getOrThrow()
                    for (x in 0..width) {
                        let ycol = cdat[2 * x]
                        nr.setNRGBA(x, y, color.NRGBAC(ycol, ycol, ycol, cdat[2 * x + 1]))
                    }
                } else if (cb == cbTC8) {
                    if (this.useTransparent) {
                        let n = nrgba.getOrThrow()
                        let pix = n.pix
                        var i = pixOffset
                        var j = 0
                        let tr = this.transparent[1]
                        let tg = this.transparent[3]
                        let tb = this.transparent[5]
                        for (_ in 0..width) {
                            let r = cdat[j + 0]
                            let g = cdat[j + 1]
                            let b = cdat[j + 2]
                            let a: UInt8 = if (r == tr && g == tg && b == tb) {
                                0x00
                            } else {
                                0xff
                            }
                            pix[i + 0] = r
                            pix[i + 1] = g
                            pix[i + 2] = b
                            pix[i + 3] = a
                            i += 4
                            j += 3
                        }
                        pixOffset += n.stride
                    } else {
                        let n = rgba.getOrThrow()
                        let pix = n.pix
                        var i = pixOffset
                        var j = 0
                        for (_ in 0..width) {
                            pix[i + 0] = cdat[j + 0]
                            pix[i + 1] = cdat[j + 1]
                            pix[i + 2] = cdat[j + 2]
                            pix[i + 3] = 0xff
                            i += 4
                            j += 3
                        }
                        pixOffset += n.stride
                    }
                } else if (cb == cbP1) {
                    let p = paletted.getOrThrow()
                    for (x in 0..width : 8) {
                        var b = cdat[x / 8]
                        var x2 = 0
                        while (x2 < 8 && (x + x2) < width) {
                            let idx = b >> 7
                            if (p.palette.size() <= Int64(idx)) {
                                p.palette = p.palette[0..Int64(idx + 1)]
                            }
                            p.setColorIndex(x + x2, y, idx)
                            b <<= 1
                            x2++
                        }
                    }
                } else if (cb == cbP2) {
                    let p = paletted.getOrThrow()
                    for (x in 0..width : 4) {
                        var b = cdat[x / 4]
                        var x2 = 0
                        while (x2 < 4 && (x + x2) < width) {
                            let idx = b >> 6
                            if (p.palette.size() <= Int64(idx)) {
                                p.palette = p.palette[0..Int64(idx + 1)]
                            }
                            p.setColorIndex(x + x2, y, idx)
                            b <<= 2
                            x2++
                        }
                    }
                } else if (cb == cbP4) {
                    let p = paletted.getOrThrow()
                    for (x in 0..width : 2) {
                        var b = cdat[x / 2]
                        var x2 = 0
                        while (x2 < 2 && (x + x2) < width) {
                            let idx = b >> 4
                            if (p.palette.size() <= Int64(idx)) {
                                p.palette = p.palette[0..Int64(idx + 1)]
                            }
                            p.setColorIndex(x + x2, y, idx)
                            b <<= 4
                            x2++
                        }
                    }
                } else if (cb == cbP8) {
                    let p = paletted.getOrThrow()
                    if (p.palette.size() != 256) {
                        for (x in 0..width) {
                            if (p.palette.size() <= Int64(cdat[x])) {
                                p.palette = p.palette[0..Int64(cdat[x] + 1)]
                            }
                        }
                    }
                    copy(p.pix, cdat, dstStart: pixOffset)
                    pixOffset += p.stride
                } else if (cb == cbTCA8) {
                    let n = nrgba.getOrThrow()
                    copy(n.pix, cdat, dstStart: pixOffset)
                    pixOffset += n.stride
                } else if (cb == cbG16) {
                    if (this.useTransparent) {
                        let nr = nrgba64.getOrThrow()
                        let ty = (UInt16(this.transparent[0]) << 8) | UInt16(this.transparent[1])
                        for (x in 0..width) {
                            let ycol = (UInt16(cdat[2 * x + 0]) << 8) | UInt16(cdat[2 * x + 1])
                            let acol: UInt16 = if (ycol == ty) {
                                0x0000
                            } else {
                                0xffff
                            }
                            nr.setNRGBA64(x, y, color.NRGBA64C(ycol, ycol, ycol, acol))
                        }
                    } else {
                        let gr = gray16.getOrThrow()
                        for (x in 0..width) {
                            let ycol = (UInt16(cdat[2 * x + 0]) << 8) | UInt16(cdat[2 * x + 1])
                            gr.setGray16(x, y, color.Gray16C(ycol))
                        }
                    }
                } else if (cb == cbGA16) {
                    let nr = nrgba64.getOrThrow()
                    for (x in 0..width) {
                        let ycol = (UInt16(cdat[4 * x + 0]) << 8) | UInt16(cdat[4 * x + 1])
                        let acol = (UInt16(cdat[4 * x + 2]) << 8) | UInt16(cdat[4 * x + 3])
                        nr.setNRGBA64(x, y, color.NRGBA64C(ycol, ycol, ycol, acol))
                    }
                } else if (cb == cbTC16) {
                    if (this.useTransparent) {
                        let nr = nrgba64.getOrThrow()
                        let tr = (UInt16(this.transparent[0]) << 8) | UInt16(this.transparent[1])
                        let tg = (UInt16(this.transparent[2]) << 8) | UInt16(this.transparent[3])
                        let tb = (UInt16(this.transparent[4]) << 8) | UInt16(this.transparent[5])
                        for (x in 0..width) {
                            let rcol = (UInt16(cdat[6 * x + 0]) << 8) | UInt16(cdat[6 * x + 1])
                            let gcol = (UInt16(cdat[6 * x + 2]) << 8) | UInt16(cdat[6 * x + 3])
                            let bcol = (UInt16(cdat[6 * x + 4]) << 8) | UInt16(cdat[6 * x + 5])
                            let acol: UInt16 = if (rcol == tr && gcol == tg && bcol == tb) {
                                0x0000
                            } else {
                                0xffff
                            }
                            nr.setNRGBA64(x, y, color.NRGBA64C(rcol, gcol, bcol, acol))
                        }
                    } else {
                        let nr = rgba64.getOrThrow()
                        for (x in 0..width) {
                            let rcol = (UInt16(cdat[6 * x + 0]) << 8) | UInt16(cdat[6 * x + 1])
                            let gcol = (UInt16(cdat[6 * x + 2]) << 8) | UInt16(cdat[6 * x + 3])
                            let bcol = (UInt16(cdat[6 * x + 4]) << 8) | UInt16(cdat[6 * x + 5])
                            nr.setRGBA64(x, y, color.RGBA64C(rcol, gcol, bcol, 0xffff))
                        }
                    }
                } else if (cb == cbTCA16) {
                    let nr = nrgba64.getOrThrow()
                    for (x in 0..width) {
                        let rcol = (UInt16(cdat[8 * x + 0]) << 8) | UInt16(cdat[8 * x + 1])
                        let gcol = (UInt16(cdat[8 * x + 2]) << 8) | UInt16(cdat[8 * x + 3])
                        let bcol = (UInt16(cdat[8 * x + 4]) << 8) | UInt16(cdat[8 * x + 5])
                        let acol = (UInt16(cdat[8 * x + 6]) << 8) | UInt16(cdat[8 * x + 7])
                        nr.setNRGBA64(x, y, color.NRGBA64C(rcol, gcol, bcol, acol))
                    }
                }
                copy(cr, cdat, dstStart: 1)
                pr = cr
                cr = Array<UInt8>(rowSize, repeat: 0)
            }
        }

        img
    }

    /*
     * The Function is mergePassInto
     *
     * @param dst of Image
     * @param src of Image
     * @param pass of Int64
     */
    func mergePassInto(dst: Image, src: Image, pass: Int64) {
        let p = interlacing[pass]
        var srcPix: Array<UInt8> = []
        var dstPix: Array<UInt8> = []
        var stride = 0
        var rect: Rectangle = Rectangle()
        var bytesPerPixel = 0
        if (dst is image.Alpha) {
            let target = (dst as image.Alpha).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 1
        } else if (dst is image.Alpha16) {
            let target = (dst as image.Alpha16).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 2
        } else if (dst is image.Gray) {
            let target = (dst as image.Gray).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 1
        } else if (dst is image.Gray16) {
            let target = (dst as image.Gray16).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 2
        } else if (dst is image.NRGBA) {
            let target = (dst as image.NRGBA).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 4
        } else if (dst is image.NRGBA64) {
            let target = (dst as image.NRGBA64).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 8
        } else if (dst is image.Paletted) {
            let target = (dst as image.Paletted).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 1
        } else if (dst is image.RGBA) {
            let target = (dst as image.RGBA).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 4
        } else if (dst is image.RGBA64) {
            let target = (dst as image.RGBA64).getOrThrow()
            dstPix = target.pix
            stride = target.stride
            rect = target.rect
            bytesPerPixel = 8
        }
        var s = 0
        let bounds = src.bounds()
        for (y in bounds.min.y..bounds.max.y) {
            let dBase = (y * p.yFactor + p.yOffset - rect.min.y) * stride + (p.xOffset - rect.min.x) * bytesPerPixel
            for (x in bounds.min.x..bounds.max.x) {
                let d = dBase + x * p.xFactor * bytesPerPixel
                copy(dstPix, srcPix[s..(s + bytesPerPixel)], dstStart: d)
                s += bytesPerPixel
            }
        }
    }

    /*
     * The Function is parseIDAT
     *
     * @param length of UInt32
     */
    func parseIDAT(length: UInt32) {
        this.idatLength = length
        this.img = this.decode()
        verifyChecksum()
    }

    /*
     * The Function is parseIEND
     *
     * @param length of UInt32
     */
    func parseIEND(length: UInt32) {
        if (length != 0) {
            throw FormatError("bad IEND length")
        }
        verifyChecksum()
    }

    /*
     * The Function is parseChunk
     *
     */
    func parseChunk() {
        readFullToTemp(8)
        var length = zlib.binaryUInt32(this.tmp[0..4])
        this.crc.reset()
        let b = this.tmp[4..8]
        this.crc.write(b)
        match (String.fromUtf8(b)) {
            case "IHDR" =>
                if (this.mstage != dsStart) {
                    throw chunkOrderError
                }
                this.mstage = dsSeenIHDR
                return parseIHDR(length)
            case "PLTE" =>
                if (this.mstage != dsSeenIHDR) {
                    throw chunkOrderError
                }
                this.mstage = dsSeenPLTE
                return parsePLTE(length)
            case "tRNS" =>
                if (cbPaletted(this.cb)) {
                    if (this.mstage != dsSeenPLTE) {
                        throw chunkOrderError
                    }
                } else if (this.mstage != dsSeenIHDR) {
                    throw chunkOrderError
                }
                this.mstage = dsSeentRNS
                return parsetRNS(length)
            case "IDAT" => if (this.mstage < dsSeenIHDR || this.mstage > dsSeenIDAT || (this.mstage == dsSeenIHDR &&
                cbPaletted(this.cb))) {
                throw chunkOrderError
            } else if (this.mstage != dsSeenIDAT) {
                this.mstage = dsSeenIDAT
                return parseIDAT(length)
            }
            case "IEND" =>
                if (this.mstage != dsSeenIDAT) {
                    throw chunkOrderError
                }
                this.mstage = dsSeenIEND
                return parseIEND(length)
            case _ => ()
        }
        if (length > 0x7fffffff) {
            throw FormatError("Bad chunk length: ${length}")
        }

        while (length > 0) {
            let b = Array<UInt8>(min(4096, Int64(length)), repeat: 0)
            let n = readFull(this.r, b)
            this.crc.write(b[0..n])
            length -= UInt32(n)
        }
        verifyChecksum()
    }

    /*
     * The Function is checkHeader
     *
     * @return Type of Unit
     */
    func checkHeader(): Unit {
        let headerSize = pngHeader.size
        readToTemp(headerSize)
        if (!arrayEquals(pngHeader, this.tmp[0..headerSize])) {
            throw FormatError("not a PNG file")
        }
    }

    /*
     * The Function is verifyChecksum
     *
     * @return Type of Unit
     */
    func verifyChecksum(): Unit {
        let _ = readToTemp(4)
        if (zlib.binaryUInt32(tmp[0..4]) != crc.sum32()) {
            throw FormatError("invalid checksum")
        }
    }
}

/**
 * 解码PNG图片
 *
 * @param r of BufferedInputStream 输入流
 *
 * @return Type of Image
 */
public func decode(r: BufferedInputStream<InputStream>): Image {
    let inst = Decoder(r)
    try {
        inst.checkHeader()
    } catch (e: EOF) {
        throw ErrUnexpectedEOF()
    } catch (e: Exception) {
        throw e
    }
    while (inst.mstage != dsSeenIEND) {
        try {
            inst.parseChunk()
        } catch (e: EOF) {
            throw ErrUnexpectedEOF()
        } catch (e: Exception) {
            throw e
        }
    }
    inst.img
}

/**
 * 解码PNG图片
 *
 * @param r of File 文件流（输入）
 *
 * @return Type of Image
 */
public func decode(r: File): Image {
    let bs = BufferedInputStream<InputStream>(r)
    decode(bs)
}

/**
 * 获取PNG图片信息
 *
 * @param r of BufferedInputStream 输入流
 *
 * @return Type of image.Config
 */
public func decodeConfig(r: BufferedInputStream<InputStream>): image.Config {
    let inst = Decoder(r)
    try {
        inst.checkHeader()
    } catch (e: EOF) {
        throw ErrUnexpectedEOF()
    } catch (e: Exception) {
        throw e
    }
    while (true) {
        try {
            inst.parseChunk()
        } catch (e: EOF) {
            throw ErrUnexpectedEOF()
        } catch (e: Exception) {
            throw e
        }
        let paletted = cbPaletted(inst.cb)
        if (inst.mstage == dsSeenIHDR && !paletted) {
            break
        }
        if (inst.mstage == dsSeenPLTE && paletted) {
            break
        }
    }

    let cb = inst.cb
    var cm: color.Model = if (cb == cbG1 || cb == cbG2 || cb == cbG4 || cb == cbG8) {
        color.GrayModel
    } else if (cb == cbGA8) {
        color.NRGBAModel
    } else if (cb == cbTC8) {
        color.RGBAModel
    } else if (cb == cbP1 || cb == cbP2 || cb == cbP4 || cb == cbP8) {
        inst.palette
    } else if (cb == cbTCA8) {
        color.NRGBAModel
    } else if (cb == cbG16) {
        color.Gray16Model
    } else if (cb == cbGA16) {
        color.NRGBA64Model
    } else if (cb == cbTC16) {
        color.RGBA64Model
    } else if (cb == cbTCA16) {
        color.NRGBA64Model
    } else {
        color.GrayModel
    }
    image.Config(cm, inst.width, inst.height)
}

/**
 * 获取PNG图片信息
 *
 * @param r of File 文件流（输入）
 *
 * @return Type of image.Config
 */
public func decodeConfig(r: File): image.Config {
    let bs = BufferedInputStream<InputStream>(r)
    decodeConfig(bs)
}

/**
 * PNG格式模块注册器
 *
 * @return Type of Unit
 */
public func register(): Unit {
    image.registerFormat("png", pngHeader, decode, decodeConfig)
}
