/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * JPEG格式模块
 */

package image.jpeg

import std.io.*
import std.collection.*
import std.fs.*
import image.color as color
import image.image as image
import image.drawer.*
import image.internals.model.*
import image.internals.imageutil.*

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
        "invalid JPEG format: ${msg}"
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
        "unsupported JPEG feature: ${msg}"
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

/* let member errUnsupportedSubsamplingRatio */
let errUnsupportedSubsamplingRatio = UnsupportedError("luma/chroma subsampling ratio")

/**
 * The class is Component inherited from ToString
 * @author changeden
 */
public class Component <: ToString {
    /** var member h type is Int64 */
    public var h: Int64 = 0

    /** var member v type is Int64 */
    public var v: Int64 = 0

    /** var member c type is UInt8 */
    public var c: UInt8 = 0

    /** var member tq type is UInt8 */
    public var tq: UInt8 = 0

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "h=${h} v=${v} c=${c} tq=${tq}"
    }
}

/* let member dcTable */
let dcTable = 0

/* let member acTable */
let acTable = 1

/* let member maxTc */
let maxTc = 1

/* let member maxTh */
let maxTh = 3

/* let member maxTq */
let maxTq = 3

/* let member maxComponents */
let maxComponents = 4

/* let member sof0Marker type is UInt8 */
let sof0Marker: UInt8 = 0xc0 // Start Of Frame (Baseline Sequential).

/* let member sof1Marker type is UInt8 */
let sof1Marker: UInt8 = 0xc1 // Start Of Frame (Extended Sequential).

/* let member sof2Marker type is UInt8 */
let sof2Marker: UInt8 = 0xc2 // Start Of Frame (Progressive).

/* let member dhtMarker type is UInt8 */
let dhtMarker: UInt8 = 0xc4 // Define Huffman Table.

/* let member rst0Marker type is UInt8 */
let rst0Marker: UInt8 = 0xd0 // ReSTart (0).

/* let member rst7Marker type is UInt8 */
let rst7Marker: UInt8 = 0xd7 // ReSTart (7).

/* let member soiMarker type is UInt8 */
let soiMarker: UInt8 = 0xd8 // Start Of Image.

/* let member eoiMarker type is UInt8 */
let eoiMarker: UInt8 = 0xd9 // End Of Image.

/* let member sosMarker type is UInt8 */
let sosMarker: UInt8 = 0xda // Start Of Scan.

/* let member dqtMarker type is UInt8 */
let dqtMarker: UInt8 = 0xdb // Define Quantization Table.

/* let member driMarker type is UInt8 */
let driMarker: UInt8 = 0xdd // Define Restart Interval.

/* let member comMarker type is UInt8 */
let comMarker: UInt8 = 0xfe // COMment.

// "APPlication specific" markers aren't part of the JPEG spec per se,
// but in practice, their use is described at
// https://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/JPEG.html
/* let member app0Marker type is UInt8 */
let app0Marker: UInt8 = 0xe0

/* let member app14Marker type is UInt8 */
let app14Marker: UInt8 = 0xee

/* let member app15Marker type is UInt8 */
let app15Marker: UInt8 = 0xef

/* let member adobeTransformUnknown type is UInt8 */
let adobeTransformUnknown: UInt8 = 0

/* let member adobeTransformYCbCr type is UInt8 */
let adobeTransformYCbCr: UInt8 = 1

/* let member adobeTransformYCbCrK type is UInt8 */
let adobeTransformYCbCrK: UInt8 = 2

/* let member unzig type is Array<Int64> */
let unzig: Array<Int64> = [
    0,
    1,
    8,
    16,
    9,
    2,
    3,
    10,
    17,
    24,
    32,
    25,
    18,
    11,
    4,
    5,
    12,
    19,
    26,
    33,
    40,
    48,
    41,
    34,
    27,
    20,
    13,
    6,
    7,
    14,
    21,
    28,
    35,
    42,
    49,
    56,
    57,
    50,
    43,
    36,
    29,
    22,
    15,
    23,
    30,
    37,
    44,
    51,
    58,
    59,
    52,
    45,
    38,
    31,
    39,
    46,
    53,
    60,
    61,
    54,
    47,
    55,
    62,
    63
]

/**
 * The class is Bits
 * @author changeden
 */
public class Bits {
    /** var member a type is UInt32 */
    public var a: UInt32 = 0 // accumulator.

    /** var member m type is UInt32 */
    public var m: UInt32 = 0 // mask. m==1<<(n-1) when n>0, with m==0 when n==0.

    /** var member n type is Int32 */
    public var n: Int32 = 0 // the number of unread bits in a.
}

/**
 * The class is Bytes
 * @author changeden
 */
public class Bytes {
    /** let member buf type is Array<UInt8> */
    public let buf: Array<UInt8> = Array<UInt8>(4096, item: 0)

    /** var member i type is Int64 */
    public var i: Int64 = 0

    /** var member j type is Int64 */
    public var j: Int64 = 0

    /** var member nUnreadable type is Int64 */
    public var nUnreadable: Int64 = 0
}

/* let member errMissingFF00 */
let errMissingFF00 = FormatError("missing 0xff00 sequence")

/**
 * The class is Decoder
 * @author changeden
 */
public class Decoder {
    /** var member r type is BufferedInputStream */
    public var r: BufferedInputStream<InputStream>

    /** var member bits type is Bits */
    public var bits: Bits = Bits()

    /** var member bytes type is Bytes */
    public var bytes: Bytes = Bytes()

    /** var member width type is Int64 */
    public var width: Int64 = 0

    /** var member height type is Int64 */
    public var height: Int64 = 0

    /** var member img1 type is ?image.Gray */
    public var img1: ?image.Gray = None

    /** var member img3 type is ?image.YCbCr */
    public var img3: ?image.YCbCr = None

    /** var member blackPix type is ?ArrayList<UInt8> */
    public var blackPix: ?Array<UInt8> = None

    /** var member blackStride type is Int64 */
    public var blackStride: Int64 = 0

    /** var member ri type is Int64 */
    public var ri: Int64 = 0

    /** var member nComp type is Int64 */
    public var nComp: Int64 = 0

    /** var member baseline type is Bool */
    public var baseline: Bool = false

    /** var member progressive type is Bool */
    public var progressive: Bool = false

    /** var member jfif type is Bool */
    public var jfif: Bool = false

    /** var member adobeTransformValid type is Bool */
    public var adobeTransformValid: Bool = false

    /** var member adobeTransform type is UInt8 */
    public var adobeTransform: UInt8 = 0

    /** var member eobRun type is UInt16 */
    public var eobRun: UInt16 = 0

    /** let member comp type is Array<Component> */
    public let comp: Array<Component> = Array<Component>(maxComponents, @OverflowWrapping{_ => Component()})
    public let progCoeffs: Array<Array<Block>> = Array<Array<Block>>(maxComponents, {_ => Array<Block>()})

    /** let member huff type is Array<Array<Huffman>> */
    public let huff: Array<Array<Huffman>> = Array<Array<Huffman>>(
        maxTc + 1,
        {_ => Array<Huffman>(maxTh + 1, {_ => Huffman()})}
    )

    /** let member quant type is Array<Block> */
    public let quant: Array<Block> = Array<Block>(maxTq + 1, {_ => Block()})

    /** let member tmp type is Array<UInt8> */
    public let tmp: Array<UInt8> = Array<UInt8>(2 * blockSize, item: 0)

    /* var member rr type is Int64 */
    var rr: Int64 = 0

    /* var member rw type is Int64 */
    var rw: Int64 = 0

    /* let member rtmp type is Array<UInt8> */
    let rtmp: Array<UInt8> = Array<UInt8>(4096, item: 0)

    /**
     * The Function is init constructor
     *
     * @param r of BufferedInputStream
     */
    public init(r: BufferedInputStream<InputStream>) {
        this.r = r
    }

    /*
     * The Function is fill
     *
     * @return Type of Unit
     */
    func fill(): Unit {
        if (bytes.i != bytes.j) {
            throw Exception("jpeg: fill called when unread bytes exist")
        }
        if (bytes.j > 2) {
            bytes.buf[0] = bytes.buf[bytes.j - 2]
            bytes.buf[1] = bytes.buf[bytes.j - 1]
            bytes.i = 2
            bytes.j = 2
        }
        let s = bytes.j
        if (rr == rw) {
            rr = 0
            let n = r.read(rtmp)
            rw = n
        }
        let c = Array<UInt8>(bytes.buf.size - bytes.j, item: 0)
        let n = copy(c, rtmp[rr..rw])
        for (i in 0..n) {
            bytes.buf[s + i] = c[i]
        }
        bytes.j += n
        rr += n
        if (n <= 0) {
            throw EOF()
        }
    }

    /*
     * The Function is unreadByteStuffedByte
     *
     * @return Type of Unit
     */
    func unreadByteStuffedByte(): Unit {
        bytes.i -= bytes.nUnreadable
        bytes.nUnreadable = 0
        if (bits.n >= 8) {
            bits.a >>= 8
            bits.n -= 8
            bits.m >>= 8
        }
    }

    /*
     * The Function is readByte
     *
     * @return Type of UInt8
     */
    func readByte(): UInt8 {
        while (bytes.i == bytes.j) {
            fill()
        }
        let x = bytes.buf[bytes.i]
        bytes.i++
        bytes.nUnreadable = 0
        x
    }

    /*
     * The Function is readByteStuffedByte
     *
     * @return Type of UInt8
     */
    func readByteStuffedByte(): UInt8 {
        var x: UInt8 = 0
        if (bytes.i + 2 <= bytes.j) {
            x = bytes.buf[bytes.i]
            bytes.i++
            bytes.nUnreadable = 1
            if (x != 0xff) {
                return x
            }
            if (bytes.buf[bytes.i] != 0x00) {
                throw errMissingFF00
            }
            bytes.i++
            bytes.nUnreadable = 2
            return 0xff
        }

        bytes.nUnreadable = 0

        x = readByte()
        bytes.nUnreadable = 1
        if (x != 0xff) {
            return x
        }

        x = readByte()
        bytes.nUnreadable = 2
        if (x != 0x00) {
            throw errMissingFF00
        }
        return 0xff
    }

    /*
     * The Function is readFull
     *
     * @param p of Array<UInt8>
     */
    func readFull(p: Array<UInt8>) {
        if (bytes.nUnreadable != 0) {
            if (bits.n >= 8) {
                unreadByteStuffedByte()
            }
            bytes.nUnreadable = 0
        }
        var start = 0
        var buffer = Array<UInt8>(p.size, item: 0)
        while (true) {
            let n = copy(buffer, bytes.buf[bytes.i..bytes.j])
            for (i in 0..n) {
                p[start + i] = buffer[i]
            }
            bytes.i += n
            start += n
            if (start == p.size) {
                break
            }
            try {
                fill()
            } catch (e: EOF) {
                throw ErrUnexpectedEOF()
            }
        }
    }

    /*
     * The Function is ignore
     *
     * @param n of Int64
     */
    func ignore(n: Int64) {
        if (bytes.nUnreadable != 0) {
            if (bits.n >= 8) {
                unreadByteStuffedByte()
            }
            bytes.nUnreadable = 0
        }

        var mn = n
        while (true) {
            var m = bytes.j - bytes.i
            if (m > mn) {
                m = mn
            }
            bytes.i += m
            mn -= m
            if (mn == 0) {
                break
            }
            try {
                fill()
            } catch (e: EOF) {
                throw ErrUnexpectedEOF()
            }
        }
    }

    /*
     * The Function is processSOF
     *
     * @param n of Int64
     */
    func processSOF(n: Int64) {
        if (nComp != 0) {
            throw FormatError("multiple SOF markers")
        }
        nComp = match (n) {
            case 9 => 1
            case 15 => 3
            case 18 => 4
            case _ => throw UnsupportedError("number of components")
        }
        let buf = Array<UInt8>(n, item: 0)
        try {
            readFull(buf)
            for (i in 0..n) {
                tmp[i] = buf[i]
            }
        } catch (e: Exception) {
            for (i in 0..n) {
                tmp[i] = buf[i]
            }
            throw e
        }
        // We only support 8-bit precision.
        if (tmp[0] != 8) {
            throw UnsupportedError("precision")
        }
        height = Int64((Int32(tmp[1]) << 8) + Int32(tmp[2]))
        width = Int64((Int32(tmp[3]) << 8) + Int32(tmp[4]))
        if (Int64(tmp[5]) != nComp) {
            throw FormatError("SOF has wrong length")
        }

        for (i in 0..nComp) {
            comp[i].c = tmp[6 + 3 * i]

            // Section B.2.2 states that "the value of C_i shall be different from
            // the values of C_1 through C_(i-1)".
            for (j in 0..i) {
                if (comp[i].c == comp[j].c) {
                    throw FormatError("repeated component identifier")
                }
            }

            comp[i].tq = tmp[8 + 3 * i]
            if (Int64(comp[i].tq) > maxTq) {
                throw FormatError("bad Tq value")
            }

            let hv = tmp[7 + 3 * i]
            var h = Int64(hv >> 4)
            var v = Int64(hv & 0x0f)
            if (h < 1 || 4 < h || v < 1 || 4 < v) {
                throw FormatError("luma/chroma subsampling ratio")
            }
            if (h == 3 || v == 3) {
                throw errUnsupportedSubsamplingRatio
            }

            match (nComp) {
                case 1 =>
                    // If a JPEG image has only one component, section A.2 says "this data
                    // is non-interleaved by definition" and section A.2.2 says "[in this
                    // case...] the order of data units within a scan shall be left-to-right
                    // and top-to-bottom... regardless of the values of H_1 and V_1". Section
                    // 4.8.2 also says "[for non-interleaved data], the MCU is defined to be
                    // one data unit". Similarly, section A.1.1 explains that it is the ratio
                    // of H_i to max_j(H_j) that matters, and similarly for V. For grayscale
                    // images, H_1 is the maximum H_j for all components j, so that ratio is
                    // always 1. The component's (h, v) is effectively always (1, 1): even if
                    // the nominal (h, v) is (2, 1), a 20x5 image is encoded in three 8x8
                    // MCUs, not two 16x8 MCUs.
                    h = 1
                    v = 1
                case 3 =>
                        // For YCbCr images, we only support 4:4:4, 4:4:0, 4:2:2, 4:2:0,
                        // 4:1:1 or 4:1:0 chroma subsampling ratios. This implies that the
                        // (h, v) values for the Y component are either (1, 1), (1, 2),
                        // (2, 1), (2, 2), (4, 1) or (4, 2), and the Y component's values
                        // must be a multiple of the Cb and Cr component's values. We also
                        // assume that the two chroma components have the same subsampling
                        // ratio.
                        match (i) {
                    case 0 =>
                            // Y.
                            // We have already verified, above, that h and v are both
                            // either 1, 2 or 4, so invalid (h, v) combinations are those
                            // with v == 4.
                            if (v == 4) {
                        throw errUnsupportedSubsamplingRatio
                    }
                    case 1 =>
                                    // Cb.
                                    if (comp[0].h % h != 0 || comp[0].v % v != 0) {
                        throw errUnsupportedSubsamplingRatio
                    }
                    case 2 =>
                                    // Cr.
                                    if (comp[1].h != h || comp[1].v != v) {
                        throw errUnsupportedSubsamplingRatio
                    }
                    case _ => ()
                }
                case 4 =>
                        // For 4-component images (either CMYK or YCbCrK), we only support two
                        // hv vectors: [0x11 0x11 0x11 0x11] and [0x22 0x11 0x11 0x22].
                        // Theoretically, 4-component JPEG images could mix and match hv values
                        // but in practice, those two combinations are the only ones in use,
                        // and it simplifies the applyBlack code below if we can assume that:
                        //	- for CMYK, the C and K channels have full samples, and if the M
                        //	  and Y channels subsample, they subsample both horizontally and
                        //	  vertically.
                        //	- for YCbCrK, the Y and K channels have full samples.
                        match (i) {
                    case 0 => if (hv != 0x11 && hv != 0x22) {
                        throw errUnsupportedSubsamplingRatio
                    }
                    case 1 | 2 => if (hv != 0x11) {
                        throw errUnsupportedSubsamplingRatio
                    }
                    case 3 => if (comp[0].h != h || comp[0].v != v) {
                        throw errUnsupportedSubsamplingRatio
                    }
                    case _ => ()
                }
                case _ => ()
            }

            comp[i].h = h
            comp[i].v = v
        }
    }

    /*
     * The Function is processDQT
     *
     * @param n of Int64
     */
    func processDQT(n: Int64) {
        var breakLoop = false
        var mn = n
        while (mn > 0) {
            mn--
            let x = readByte()
            let tq = Int64(x) & 0x0f
            if (tq > maxTq) {
                throw FormatError("bad Tq value")
            }
            match (x >> 4) {
                case 0 =>
                    if (n < blockSize) {
                        breakLoop = true
                        break
                    }
                    mn -= blockSize
                    let buf = Array<UInt8>(blockSize, item: 0)
                    try {
                        readFull(buf)
                        for (i in 0..blockSize) {
                            tmp[i] = buf[i]
                        }
                    } catch (e: Exception) {
                        for (i in 0..blockSize) {
                            tmp[i] = buf[i]
                        }
                        throw e
                    }
                    for (i in 0..quant[tq].size()) {
                        quant[tq][i] = Int32(tmp[i])
                    }
                case 1 =>
                    let bs = 2 * blockSize
                    if (mn < bs) {
                        breakLoop = true
                        break
                    }
                    mn -= bs
                    let buf = Array<UInt8>(bs, item: 0)
                    try {
                        readFull(buf)
                        for (i in 0..bs) {
                            tmp[i] = buf[i]
                        }
                    } catch (e: Exception) {
                        for (i in 0..bs) {
                            tmp[i] = buf[i]
                        }
                        throw e
                    }
                    for (i in 0..quant[tq].size()) {
                        quant[tq][i] = (Int32(tmp[2 * i]) << 8) | Int32(tmp[2 * i + 1])
                    }
                case _ => throw FormatError("bad Tq value")
            }
            if (breakLoop) {
                break
            }
        }
        if (mn != 0) {
            throw FormatError("DQT has wrong length")
        }
    }

    /*
     * The Function is processDRI
     *
     * @param n of Int64
     */
    func processDRI(n: Int64) {
        if (n != 2) {
            throw FormatError("DRI has wrong length")
        }
        let buf = Array<UInt8>(2, item: 0)
        try {
            readFull(buf)
            for (i in 0..2) {
                tmp[i] = buf[i]
            }
        } catch (e: Exception) {
            for (i in 0..2) {
                tmp[i] = buf[i]
            }
            throw e
        }
        ri = (Int64(tmp[0]) << 8) + Int64(tmp[1])
    }

    /*
     * The Function is processApp0Marker
     *
     * @param n of Int64
     */
    func processApp0Marker(n: Int64) {
        if (n < 5) {
            return ignore(n)
        }
        let buf = Array<UInt8>(5, item: 0)
        try {
            readFull(buf)
            for (i in 0..5) {
                tmp[i] = buf[i]
            }
        } catch (e: Exception) {
            for (i in 0..5) {
                tmp[i] = buf[i]
            }
            throw e
        }
        jfif = tmp[0] == UInt8(UInt32(r'J')) && tmp[1] == UInt8(UInt32(r'F')) && tmp[2] == UInt8(UInt32(r'I')) && tmp[3] ==
            UInt8(UInt32(r'F')) && tmp[4] == UInt8(UInt32(r'\u{00}'))
        if ((n - 5) > 0) {
            return ignore(n - 5)
        }
    }

    /*
     * The Function is processApp14Marker
     *
     * @param n of Int64
     */
    func processApp14Marker(n: Int64) {
        if (n < 12) {
            return ignore(n)
        }
        let buf = Array<UInt8>(12, item: 0)
        try {
            readFull(buf)
            for (i in 0..12) {
                tmp[i] = buf[i]
            }
        } catch (e: Exception) {
            for (i in 0..12) {
                tmp[i] = buf[i]
            }
            throw e
        }
        if (tmp[0] == UInt8(UInt32(r'A')) && tmp[1] == UInt8(UInt32(r'd')) && tmp[2] == UInt8(UInt32(r'o')) && tmp[3] ==
            UInt8(UInt32(r'b')) && tmp[4] == UInt8(UInt32(r'e'))) {
            adobeTransformValid = true
            adobeTransform = tmp[11]
        }
        if ((n - 12) > 0) {
            return ignore(n - 12)
        }
    }

    /*
     * The Function is ensureNBits
     *
     * @param n of Int32
     */
    func ensureNBits(n: Int32) {
        while (true) {
            var c: UInt8 = 0
            try {
                c = readByteStuffedByte()
            } catch (e: EOF) {
                throw errShortHuffmanData
            } catch (e: Exception) {
                throw e
            }
            bits.a = (bits.a << 8) | UInt32(c)
            bits.n += 8
            if (bits.m == 0) {
                bits.m = 1 << 7
            } else {
                bits.m <<= 8
            }
            if (bits.n >= n) {
                break
            }
        }
    }

    /*
     * The Function is receiveExtend
     *
     * @param t of UInt8
     *
     * @return Type of Int32
     */
    @OverflowWrapping
    func receiveExtend(t: UInt8): Int32 {
        if (bits.n < Int32(t)) {
            ensureNBits(Int32(t))
        }
        bits.n -= Int32(t)
        bits.m >>= UInt32(t)
        let s = Int32(1) << t
        var x = Int32((bits.a >> UInt8(bits.n))) & (s - 1)
        if (x < (s >> 1)) {
            x += ((-1) << t) + 1
        }
        x
    }

    /*
     * The Function is processDHT
     *
     * @param n of Int64
     */
    func processDHT(n: Int64) {
        var mn = n
        let buf0 = Array<UInt8>(17, item: 0)
        var buf1: Array<UInt8>
        while (mn > 0) {
            if (mn < 17) {
                throw FormatError("DHT has wrong length")
            }
            try {
                readFull(buf0)
                for (i in 0..17) {
                    tmp[i] = buf0[i]
                }
            } catch (e: Exception) {
                for (i in 0..17) {
                    tmp[i] = buf0[i]
                }
                throw e
            }
            let tc = Int64(tmp[0] >> 4)
            if (tc > maxTc) {
                throw FormatError("bad Tc value")
            }
            let th = Int64(tmp[0] & 0x0f)

            // The baseline th <= 1 restriction is specified in table B.5.
            if (th > maxTh || (baseline && th > 1)) {
                throw FormatError("bad Th value")
            }
            let h = huff[tc][th]

            h.nCodes = 0
            var nCodes = Array<Int32>(maxCodeLength, item: 0)
            for (i in 0..nCodes.size) {
                nCodes[i] = Int32(tmp[i + 1])
                h.nCodes += nCodes[i]
            }
            if (h.nCodes == 0) {
                throw FormatError("Huffman table has zero length")
            }
            if (Int64(h.nCodes) > maxNCodes) {
                throw FormatError("Huffman table has excessive length")
            }
            mn -= Int64(h.nCodes) + 17
            if (n < 0) {
                throw FormatError("DHT has wrong length")
            }
            buf1 = Array<UInt8>(Int64(h.nCodes), item: 0)
            try {
                readFull(buf1)
                for (i in 0..Int64(h.nCodes)) {
                    h.vals[i] = buf1[i]
                }
            } catch (e: Exception) {
                for (i in 0..Int64(h.nCodes)) {
                    h.vals[i] = buf1[i]
                }
                throw e
            }
            for (i in 0..h.lut.size) {
                h.lut[i] = 0
            }
            var x = 0
            var code: UInt32 = 0
            for (i in 0..lutSize) {
                code <<= 1
                for (_ in 0..Int64(nCodes[i])) {
                    let base = UInt8(code << (7 - i))
                    let lutValue = (UInt16(h.vals[x]) << 8) | UInt16(2 + i)
                    let nk = UInt8(1 << (7 - i))
                    for (k in 0..nk) {
                        h.lut[Int64(base | k)] = lutValue
                    }
                    code++
                    x++
                }
            }

            var c: Int32 = 0
            var index: Int32 = 0
            for (i in 0..nCodes.size) {
                let mn = nCodes[i]
                if (mn == 0) {
                    h.minCodes[i] = -1
                    h.maxCodes[i] = -1
                    h.valsIndices[i] = -1
                } else {
                    h.minCodes[i] = c
                    h.maxCodes[i] = c + mn - 1
                    h.valsIndices[i] = index
                    c += mn
                    index += mn
                }
                c <<= 1
            }
        }
    }

    /*
     * The Function is decodeHuffman
     *
     * @param h of Huffman
     *
     * @return Type of UInt8
     */
    func decodeHuffman(h: Huffman): UInt8 {
        if (h.nCodes == 0) {
            throw FormatError("uninitialized Huffman table")
        }

        /*
         * The Function is slowPath
         *
         * @return Type of UInt8
         */
        func slowPath(): UInt8 {
            var code: Int32 = 0
            for (i in 0..maxCodeLength) {
                if (bits.n == 0) {
                    ensureNBits(1)
                }
                if ((bits.a & bits.m) != 0) {
                    code |= 1
                }
                bits.n--
                bits.m >>= 1
                if (code <= h.maxCodes[i]) {
                    return h.vals[Int64(h.valsIndices[i] + code - h.minCodes[i])]
                }
                code <<= 1
            }
            throw FormatError("bad Huffman code")
        }
        if (bits.n < 8) {
            try {
                ensureNBits(8)
            } catch (e: Exception) {
                if (e is FormatError) {
                    let err = (e as FormatError).getOrThrow()
                    if (err != errMissingFF00 && err != errShortHuffmanData) {
                        throw e
                    }
                } else {
                    throw e
                }
                if (bytes.nUnreadable != 0) {
                    unreadByteStuffedByte()
                }
                return slowPath()
            }
        }
        let v = h.lut[Int64((bits.a >> UInt32(bits.n - Int32(lutSize))) & 0xff)]
        if (v != 0) {
            let n = (v & 0xff) - 1
            bits.n -= Int32(n)
            bits.m >>= UInt32(n)
            return UInt8(v >> 8)
        }
        return slowPath()
    }

    /*
     * The Function is decodeBit
     *
     * @return Type of Bool
     */
    func decodeBit(): Bool {
        if (bits.n == 0) {
            ensureNBits(1)
        }
        let ret = (bits.a & bits.m) != 0
        bits.n--
        bits.m >>= 1
        ret
    }

    /*
     * The Function is decodeBits
     *
     * @param n of Int32
     *
     * @return Type of UInt32
     */
    func decodeBits(n: Int32): UInt32 {
        if (bits.n < n) {
            ensureNBits(n)
        }
        var ret = bits.a >> UInt32(bits.n - n)
        ret &= (1 << UInt32(n)) - 1
        bits.n -= n
        bits.m >>= UInt32(n)
        ret
    }

    /*
     * The Function is decode
     *
     * @param r of BufferedInputStream
     * @param configOnly of Bool
     *
     * @return Type of Image
     */
    func decode(r: BufferedInputStream<InputStream>, configOnly: Bool): Image {
        this.r = r
        let buf = Array<UInt8>(2, item: 0)
        try {
            readFull(buf)
            for (i in 0..2) {
                tmp[i] = buf[i]
            }
        } catch (e: Exception) {
            for (i in 0..2) {
                tmp[i] = buf[i]
            }
            throw e
        }
        if (tmp[0] != 0xff || tmp[1] != soiMarker) {
            throw FormatError("missing SOI marker")
        }
        while (true) {
            try {
                readFull(buf)
                for (i in 0..2) {
                    tmp[i] = buf[i]
                }
            } catch (e: Exception) {
                for (i in 0..2) {
                    tmp[i] = buf[i]
                }
                throw e
            }
            while (tmp[0] != 0xff) {
                tmp[0] = tmp[1]
                tmp[1] = readByte()
            }
            var marker = tmp[1]
            if (marker == 0) {
                continue
            }
            while (marker == 0xff) {
                marker = readByte()
            }
            if (marker == eoiMarker) { // End Of Image.
                break
            }
            if (rst0Marker <= marker && marker <= rst7Marker) {
                continue
            }
            try {
                readFull(buf)
                for (i in 0..2) {
                    tmp[i] = buf[i]
                }
            } catch (e: Exception) {
                for (i in 0..2) {
                    tmp[i] = buf[i]
                }
                throw e
            }
            let n = (Int64(tmp[0]) << 8) + Int64(tmp[1]) - 2
            if (n < 0) {
                throw FormatError("short segment length")
            }
            if (marker == sof0Marker || marker == sof1Marker || marker == sof2Marker) {
                baseline = marker == sof0Marker
                progressive = marker == sof2Marker
                try {
                    processSOF(n)
                } catch (e: Exception) {
                    if (configOnly && jfif) {
                        throw e
                    }
                }
            } else if (marker == dhtMarker) {
                if (configOnly) {
                    ignore(n)
                } else {
                    processDHT(n)
                }
            } else if (marker == dqtMarker) {
                if (configOnly) {
                    ignore(n)
                } else {
                    processDQT(n)
                }
            } else if (marker == sosMarker) {
                if (configOnly) {
                    return image.RGBA()
                }
                processSOS(n)
            } else if (marker == driMarker) {
                if (configOnly) {
                    ignore(n)
                } else {
                    processDRI(n)
                }
            } else if (marker == app0Marker) {
                processApp0Marker(n)
            } else if (marker == app14Marker) {
                processApp14Marker(n)
            } else {
                if (app0Marker <= marker && marker <= app15Marker || marker == comMarker) {
                    ignore(n)
                } else if (marker < 0xc0) { // See Table B.1 "Marker code assignments".
                    throw FormatError("unknown marker")
                } else {
                    throw UnsupportedError("unknown marker")
                }
            }
        }
        if (progressive) {
            reconstructProgressiveImage()
        }
        if (let Some(ir) <- img1) {
            return (ir as Image).getOrThrow()
        }
        if (let Some(ir) <- img3) {
            if (let Some(_) <- blackPix) {
                return applyBlack()
            }
            if (isRGB()) {
                return convertToRGB()
            }
            return ir
        }
        throw FormatError("missing SOS marker")
    }

    /*
     * The Function is applyBlack
     *
     * @return Type of Image
     */
    func applyBlack(): Image {
        if (!adobeTransformValid) {
            throw UnsupportedError("unknown color model: 4-component JPEG doesn't have Adobe APP14 metadata")
        }

        if (adobeTransform != adobeTransformUnknown) {
            let bounds = img3.getOrThrow().bounds()
            let img = image.RGBA(bounds)
            drawYCbCr(img, bounds, img3.getOrThrow(), bounds.min)
            var iBase = 0
            var y = bounds.min.y
            while (y < bounds.max.y) {
                var i = iBase + 3
                var x = bounds.min.x
                while (x < bounds.max.x) {
                    img.pix[i] = 255 - blackPix.getOrThrow()[(y - bounds.min.y) * blackStride + (x - bounds.min.x)]
                    i += 4
                    x++
                }
                iBase += img.stride
                y++
            }
            return image.CMYK(img.pix, img.stride, img.rect)
        }

        let img3 = this.img3.getOrThrow()
        let bounds = img3.bounds()
        let img = image.CMYK(bounds)
        let translations = [
            (img3.y, img3.yStride),
            (img3.cb, img3.cStride),
            (img3.cr, img3.cStride),
            (blackPix.getOrThrow(), blackStride)
        ]
        for (t in 0..translations.size) {
            let (msrc, mstride) = translations[t]
            let subsample = comp[t].h != comp[0].h || comp[t].v != comp[0].v
            var iBase = 0
            for (y in bounds.min.y..bounds.max.y) {
                var sy = y - bounds.min.y
                if (subsample) {
                    sy /= 2
                }
                var i = iBase + t
                for (x in bounds.min.x..bounds.max.x) {
                    var sx = x - bounds.min.x
                    if (subsample) {
                        sx /= 2
                    }
                    img.pix[i] = 255 - msrc[sy * mstride + sx]
                    i += 4
                }
                iBase += img.stride
            }
        }
        img
    }

    /*
     * The Function is isRGB
     *
     * @return Type of Bool
     */
    func isRGB(): Bool {
        if (jfif) {
            return false
        }
        if (adobeTransformValid && adobeTransform == adobeTransformUnknown) {
            return true
        }
        comp[0].c == UInt8(UInt32(r'R')) && comp[1].c == UInt8(UInt32(r'G')) && comp[2].c == UInt8(UInt32(r'B'))
    }

    /*
     * The Function is convertToRGB
     *
     * @return Type of Image
     */
    func convertToRGB(): Image {
        let cScale = comp[0].h / comp[1].h
        let img3 = this.img3.getOrThrow()
        let bounds = img3.bounds()
        let img = image.RGBA(bounds)
        for (y in bounds.min.y..bounds.max.y) {
            let po = img.pixOffset(bounds.min.x, y)
            let yo = img3.yOffset(bounds.min.x, y)
            let co = img3.cOffset(bounds.min.x, y)
            let iMax = bounds.max.x - bounds.min.x
            for (i in 0..iMax) {
                img.pix[po + 4 * i + 0] = img3.y[yo + i]
                img.pix[po + 4 * i + 1] = img3.cb[co + i / cScale]
                img.pix[po + 4 * i + 2] = img3.cr[co + i / cScale]
                img.pix[po + 4 * i + 3] = 255
            }
        }
        img
    }

    /*
     * The Function is makeImg
     *
     * @param mxx of Int64
     * @param myy of Int64
     *
     * @return Type of Unit
     */
    func makeImg(mxx: Int64, myy: Int64): Unit {
        if (nComp == 1) {
            let m = image.Gray(Rectangle(0, 0, 8 * mxx, 8 * myy))
            img1 = m.subImage(Rectangle(0, 0, width, height)) as image.Gray
            return
        }
        let h0 = comp[0].h
        let v0 = comp[0].v
        let hRatio = h0 / comp[1].h
        let vRatio = v0 / comp[1].v
        let subsampleRatio: image.YCbCrSubsampleRatio = match ((hRatio << 4) | vRatio) {
            case 0x11 => image.YCbCrSubsampleRatio.YCbCrSubsampleRatio444
            case 0x12 => image.YCbCrSubsampleRatio.YCbCrSubsampleRatio440
            case 0x21 => image.YCbCrSubsampleRatio.YCbCrSubsampleRatio422
            case 0x22 => image.YCbCrSubsampleRatio.YCbCrSubsampleRatio420
            case 0x41 => image.YCbCrSubsampleRatio.YCbCrSubsampleRatio411
            case 0x42 => image.YCbCrSubsampleRatio.YCbCrSubsampleRatio410
            case _ => throw Exception("unreachable")
        }
        let m = image.YCbCr(Rectangle(0, 0, 8 * h0 * mxx, 8 * v0 * myy), subsampleRatio)
        img3 = m.subImage(Rectangle(0, 0, width, height)) as image.YCbCr
        if (nComp == 4) {
            let h3 = comp[3].h
            let v3 = comp[3].v
            blackPix = Array<UInt8>(8 * h3 * mxx * 8 * v3 * myy, item: 0)
            blackStride = 8 * h3 * mxx
        }
    }

    /*
     * The Function is processSOS
     *
     * @param n of Int64
     *
     * @return Type of Unit
     */
    func processSOS(n: Int64): Unit {
        if (this.nComp == 0) {
            throw FormatError("missing SOF marker")
        }
        if ((n < 6) || ((4 + 2 * this.nComp) < n) || (n % 2 != 0)) {
            throw FormatError("SOS has wrong length")
        }
        let buf = Array<UInt8>(n, item: 0)
        try {
            readFull(buf)
            for (i in 0..n) {
                tmp[i] = buf[i]
            }
        } catch (e: Exception) {
            for (i in 0..n) {
                tmp[i] = buf[i]
            }
            throw e
        }
        let mnComp = Int64(tmp[0])
        if (n != 4 + 2 * mnComp) {
            throw FormatError("SOS length inconsistent with number of components")
        }
        let scan = Array<Array<UInt8>>(maxComponents, {_ => [0, 0, 0]}) // compIndex, td, ta
        var totalHV = 0
        for (i in 0..mnComp) {
            let cs = tmp[1 + 2 * i]
            var compIndex = -1
            for (j in 0..this.nComp) {
                if (cs == this.comp[j].c) {
                    compIndex = j
                }
            }
            if (compIndex < 0) {
                throw FormatError("unknown component selector")
            }
            scan[i][0] = UInt8(compIndex)
            for (j in 0..i) {
                if (scan[i][0] == scan[j][0]) {
                    throw FormatError("repeated component selector")
                }
            }
            totalHV += comp[compIndex].h * comp[compIndex].v

            scan[i][1] = this.tmp[2 + 2 * i] >> 4
            var t = scan[i][1]
            if (t > UInt8(maxTh) || (baseline && t > 1)) {
                throw FormatError("bad Td value")
            }
            scan[i][2] = this.tmp[2 + 2 * i] & 0x0f
            t = scan[i][2]
            if (t > UInt8(maxTh) || (baseline && t > 1)) {
                throw FormatError("bad Ta value")
            }
        }
        if (this.nComp > 1 && totalHV > 10) {
            throw FormatError("total sampling factors too large")
        }
        var zigStart: Int32 = 0
        var zigEnd: Int32 = Int32(blockSize - 1)
        var ah: UInt32 = 0
        var al: UInt32 = 0
        if (this.progressive) {
            zigStart = Int32(tmp[1 + 2 * mnComp])
            zigEnd = Int32(tmp[2 + 2 * mnComp])
            ah = UInt32(tmp[3 + 2 * mnComp] >> 4)
            al = UInt32(tmp[3 + 2 * mnComp] & 0x0f)
            if ((zigStart == 0 && zigEnd != 0) || zigStart > zigEnd || blockSize <= Int64(zigEnd)) {
                throw FormatError("bad spectral selection bounds")
            }
            if (zigStart != 0 && mnComp != 1) {
                throw FormatError("progressive AC coefficients for more than one component")
            }
            if (ah != 0 && ah != al + 1) {
                throw FormatError("bad successive approximation values")
            }
        }

        let h0 = comp[0].h
        let v0 = comp[0].v
        let mxx = (width + 8 * h0 - 1) / (8 * h0)
        let myy = (height + 8 * v0 - 1) / (8 * v0)
        if (if (let None <- img1) {
            true
        } else {
            false
        } && if (let None <- img3) {
            true
        } else {
            false
        }) {
            makeImg(mxx, myy)
        }
        if (this.progressive) {
            for (i in 0..mnComp) {
                let compIndex = Int64(scan[i][0])
                if (progCoeffs[compIndex].size == 0) {
                    progCoeffs[compIndex] = Array<Block>(
                        mxx * myy * comp[compIndex].h * comp[compIndex].v,
                        {_ => Block()}
                    )
                }
            }
        }
        this.bits = Bits()
        var mcu = 0
        var expectedRST = rst0Marker
        var b = Block()
        var dc = Array<Int32>(maxComponents, item: 0)
        var bx = 0
        var by = 0
        var blockCount = 0
        for (my in 0..myy) {
            for (mx in 0..mxx) {
                for (i in 0..mnComp) {
                    let compIndex = Int64(scan[i][0])
                    let hi = this.comp[compIndex].h
                    let vi = this.comp[compIndex].v
                    for (j in 0..(hi * vi)) {
                        if (mnComp != 1) {
                            bx = hi * mx + (j % hi)
                            by = vi * my + j / hi
                        } else {
                            let q = mxx * hi
                            bx = blockCount % q
                            by = blockCount / q
                            blockCount++
                            if (((bx * 8) >= width) || ((by * 8) >= height)) {
                                continue
                            }
                        }
                        b = if (this.progressive) {
                            progCoeffs[compIndex][by * mxx * hi + bx]
                        } else {
                            Block()
                        }
                        if (ah != 0) {
                            refine(b, this.huff[acTable][Int64(scan[i][2])], zigStart, zigEnd, 1 << al)
                        } else {
                            var zig = zigStart
                            if (zig == 0) {
                                zig++

                                // Decode the DC coefficient, as specified in section F.2.2.1.
                                let value = decodeHuffman(huff[dcTable][Int64(scan[i][1])])
                                if (value > 16) {
                                    throw UnsupportedError("excessive DC component")
                                }
                                let dcDelta = receiveExtend(value)
                                dc[compIndex] += dcDelta
                                b[0] = dc[compIndex] << al
                            }
                            if (zig <= zigEnd && eobRun > 0) {
                                eobRun--
                            } else {
                                let huff = this.huff[acTable][Int64(scan[i][2])]
                                while (zig <= zigEnd) {
                                    let value = decodeHuffman(huff)
                                    let val0 = value >> 4
                                    let val1 = value & 0x0f
                                    if (val1 != 0) {
                                        zig += Int32(val0)
                                        if (zig > zigEnd) {
                                            break
                                        }
                                        let ac = receiveExtend(val1)
                                        b[unzig[Int64(zig)]] = ac << al
                                    } else {
                                        if (val0 != 0x0f) {
                                            eobRun = UInt16(1 << val0)
                                            if (val0 != 0) {
                                                let bits = decodeBits(Int32(val0))
                                                eobRun |= UInt16(bits)
                                            }
                                            eobRun--
                                            break
                                        }
                                        zig += 0x0f
                                    }
                                    zig++
                                }
                            }
                        }
                        if (this.progressive) {
                            progCoeffs[compIndex][by * mxx * hi + bx] = b
                            continue
                        }
                        reconstructBlock(b, bx, by, Int64(compIndex))
                    } // for j
                } // for i
                mcu++
                let mxy = mxx * myy
                if (ri > 0 && (mcu % ri) == 0 && mcu < mxy) {
                    let buf = Array<UInt8>(2, item: 0)
                    try {
                        readFull(buf)
                        for (i in 0..2) {
                            tmp[i] = buf[i]
                        }
                    } catch (e: Exception) {
                        for (i in 0..2) {
                            tmp[i] = buf[i]
                        }
                        throw e
                    }
                    if (tmp[0] == 0xff && tmp[1] == 0x00) {
                        let buf = Array<UInt8>(2, item: 0)
                        try {
                            readFull(buf)
                            for (i in 0..2) {
                                tmp[i] = buf[i]
                            }
                        } catch (e: Exception) {
                            for (i in 0..2) {
                                tmp[i] = buf[i]
                            }
                            throw e
                        }
                    }
                    if (tmp[0] != 0xff || tmp[1] != expectedRST) {
                        throw FormatError("bad RST marker")
                    }
                    expectedRST++
                    if (expectedRST == rst7Marker + 1) {
                        expectedRST = rst0Marker
                    }
                    this.bits = Bits()
                    dc = Array<Int32>(maxComponents, item: 0)
                    eobRun = 0
                }
            } // for mx
        } // for my
    }

    /*
     * The Function is refine
     *
     * @param b of Block
     * @param h of Huffman
     * @param zigStart of Int32
     * @param zigEnd of Int32
     * @param delta of Int32
     *
     * @return Type of Unit
     */
    func refine(b: Block, h: Huffman, zigStart: Int32, zigEnd: Int32, delta: Int32): Unit {
        if (zigStart == 0) {
            if (zigEnd != 0) {
                throw Exception("unreachable")
            }
            if (decodeBit()) {
                b[0] |= delta
            }
            return
        }
        var zig = zigStart
        if (eobRun == 0) {
            var breakLoop = false
            while (zig <= zigEnd) {
                var z: Int32 = 0
                let value = decodeHuffman(h)
                let val0 = value >> 4
                let val1 = value & 0x0f
                match (val1) {
                    case 0 => if (val0 != 0x0f) {
                        this.eobRun = UInt16(1 << val0)
                        if (val0 != 0) {
                            let bits = decodeBits(Int32(val0))
                            this.eobRun |= UInt16(bits)
                        }
                        breakLoop = true
                    }
                    case 1 =>
                        z = delta
                        if (!decodeBit()) {
                            z = -z
                        }
                    case _ => throw FormatError("unexpected Huffman code")
                }
                if (breakLoop) {
                    break
                }
                zig = refineNonZeroes(b, zig, zigEnd, Int32(val0), delta)
                if (zig > zigEnd) {
                    throw FormatError("too many coefficients")
                }
                if (z != 0) {
                    b[unzig[Int64(zig)]] = z
                }
                zig++
            }
        }
        if (eobRun > 0) {
            eobRun--
            refineNonZeroes(b, zig, zigEnd, -1, delta)
        }
    }

    /*
     * The Function is refineNonZeroes
     *
     * @param b of Block
     * @param zig of Int32
     * @param zigEnd of Int32
     * @param nz of Int32
     * @param delta of Int32
     *
     * @return Type of Int32
     */
    func refineNonZeroes(b: Block, zig: Int32, zigEnd: Int32, nz: Int32, delta: Int32): Int32 {
        var mzig = Int64(zig)
        var mzigEnd = Int64(zigEnd)
        var mnz = nz
        while (mzig <= mzigEnd) {
            let u = unzig[mzig]
            if (b[u] == 0) {
                if (nz == 0) {
                    break
                }
                mnz--
                mzig++
                continue
            }
            if (!decodeBit()) {
                mzig++
                continue
            }
            if (b[u] >= 0) {
                b[u] += delta
            } else {
                b[u] -= delta
            }
            mzig++
        }
        Int32(mzig)
    }

    /*
     * The Function is reconstructProgressiveImage
     *
     * @return Type of Unit
     */
    func reconstructProgressiveImage(): Unit {
        let h0 = comp[0].h
        let mxx = (width + 8 * h0 - 1) / (8 * h0)
        for (i in 0..this.nComp) {
            if (progCoeffs[i].size == 0) {
                continue
            }
            let v = 8 * this.comp[0].v / this.comp[i].v
            let h = 8 * this.comp[0].h / this.comp[i].h
            let stride = mxx * this.comp[i].h
            var by = 0
            while (by * v < this.height) {
                var bx = 0
                while (bx * h < this.width) {
                    reconstructBlock(progCoeffs[i][by * stride + bx], bx, by, i)
                    bx++
                }
                by++
            }
        }
    }

    /*
     * The Function is reconstructBlock
     *
     * @param b of Block
     * @param bx of Int64
     * @param by of Int64
     * @param compIndex of Int64
     *
     * @return Type of Unit
     */
    func reconstructBlock(b: Block, bx: Int64, by: Int64, compIndex: Int64): Unit {
        let qt = quant[Int64(comp[compIndex].tq)]
        for (zig in 0..blockSize) {
            b[unzig[zig]] *= qt[zig]
        }
        idct(b)
        var dst = Array<UInt8>()
        var dstIndex = 0
        var stride = 0
        if (nComp == 1) {
            let img = this.img1.getOrThrow()
            dstIndex = 8 * (by * img.stride + bx)
            dst = img.pix
            stride = img.stride
        } else {
            match (compIndex) {
                case 0 =>
                    let img = this.img3.getOrThrow()
                    dstIndex = 8 * (by * img.yStride + bx)
                    dst = img.y
                    stride = img.yStride
                case 1 =>
                    let img = this.img3.getOrThrow()
                    dstIndex = 8 * (by * img.cStride + bx)
                    dst = img.cb
                    stride = img.cStride
                case 2 =>
                    let img = this.img3.getOrThrow()
                    dstIndex = 8 * (by * img.cStride + bx)
                    dst = img.cr
                    stride = img.cStride
                case 3 =>
                    let img = this.blackPix.getOrThrow()
                    dstIndex = 8 * (by * blackStride + bx)
                    dst = img
                    stride = blackStride

                case _ => throw UnsupportedError("too many components")
            }
        }
        for (y in 0..8) {
            let y8 = y * 8
            let yStride = y * stride
            for (x in 0..8) {
                var c = b[y8 + x]
                if (c < -128) {
                    c = 0
                } else if (c > 127) {
                    c = 255
                } else {
                    c += 128
                }
                dst[yStride + x + dstIndex] = UInt8(c)
            }
        }
    }
}

/**
 * 解码JPEG图片
 *
 * @param r of BufferedInputStream 输入流
 *
 * @return Type of Image
 */
public func decode(r: BufferedInputStream<InputStream>): Image {
    return Decoder(r).decode(r, false)
}

/**
 * 解码JPEG图片
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
 * 获取JPEG图片信息
 *
 * @param r of BufferedInputStream 输入流
 *
 * @return Type of image.Config
 */
public func decodeConfig(r: BufferedInputStream<InputStream>): image.Config {
    let inst = Decoder(r)
    inst.decode(r, true)
    match (inst.nComp) {
        case 1 => image.Config(color.GrayModel, inst.width, inst.height)
        case 3 =>
            let cm = if (inst.isRGB()) {
                color.RGBAModel
            } else {
                color.YCbCrModel
            }
            image.Config(cm, inst.width, inst.height)
        case 4 => image.Config(color.CMYKModel, inst.width, inst.height)
        case _ => throw FormatError("missing SOF marker")
    }
}

/**
 * 获取JPEG图片信息
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
 * JPEG格式模块注册器
 *
 * @return Type of Unit
 */
public func register(): Unit {
    image.registerFormat("jpeg", [255, 216], decode, decodeConfig)
}
