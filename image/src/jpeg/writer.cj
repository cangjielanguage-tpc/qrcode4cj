/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * JPEG格式模块
 */

package image.jpeg

import std.io.*
import std.fs.*
import image.image as image
import image.color as color
import image.internals.model.*

/*
 * The Function is min
 *
 * @param x of Int64
 * @param y of Int64
 *
 * @return Type of Int64
 */
func min(x: Int64, y: Int64): Int64 {
    if (x > y) {
        y
    } else {
        x
    }
}

/*
 * The Function is div
 *
 * @param a of Int32
 * @param b of Int32
 *
 * @return Type of Int32
 */
func div(a: Int32, b: Int32): Int32 {
    if (a >= 0) {
        (a + (b >> 1)) / b
    } else {
        -((-a + (b >> 1)) / b)
    }
}

/* let member bitCount type is Array<UInt8> */
let bitCount: Array<UInt8> = [
    0,
    1,
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
    4,
    4,
    4,
    4,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
    7,
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
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8,
    8
]

enum QuantIndex <: Hashable {
    quantIndexLuminance | quantIndexChrominance | nQuantIndex

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        match (this) {
            case quantIndexLuminance => 0
            case quantIndexChrominance => 1
            case nQuantIndex => 2
        }
    }

    /**
     * The Function is ==
     *
     * @param b of QuantIndex
     */
    public operator func ==(b: QuantIndex) {
        this.hashCode() == b.hashCode()
    }

    /**
     * The Function is !=
     *
     * @param b of QuantIndex
     */
    public operator func !=(b: QuantIndex) {
        !(this == b)
    }
}

/* let member unScaledQuant type is Array<Array<UInt8>> */
let unScaledQuant: Array<Array<UInt8>> = [
    [
        16,
        11,
        12,
        14,
        12,
        10,
        16,
        14,
        13,
        14,
        18,
        17,
        16,
        19,
        24,
        40,
        26,
        24,
        22,
        22,
        24,
        49,
        35,
        37,
        29,
        40,
        58,
        51,
        61,
        60,
        57,
        51,
        56,
        55,
        64,
        72,
        92,
        78,
        64,
        68,
        87,
        69,
        55,
        56,
        80,
        109,
        81,
        87,
        95,
        98,
        103,
        104,
        103,
        62,
        77,
        113,
        121,
        112,
        100,
        120,
        92,
        101,
        103,
        99
    ],
    [
        17,
        18,
        18,
        24,
        21,
        24,
        47,
        26,
        26,
        47,
        99,
        66,
        56,
        66,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99,
        99
    ]
]

enum HuffIndex <: Hashable {
    | huffIndexLuminanceDC
    | huffIndexLuminanceAC
    | huffIndexChrominanceDC
    | huffIndexChrominanceAC
    | nHuffIndex
    | otherHuffIndex(Int64)

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        match (this) {
            case huffIndexLuminanceDC => 0
            case huffIndexLuminanceAC => 1
            case huffIndexChrominanceDC => 2
            case huffIndexChrominanceAC => 3
            case nHuffIndex => 4
            case otherHuffIndex(n) => n
        }
    }

    /**
     * The Function is ==
     *
     * @param b of HuffIndex
     */
    public operator func ==(b: HuffIndex) {
        this.hashCode() == b.hashCode()
    }

    /**
     * The Function is !=
     *
     * @param b of HuffIndex
     */
    public operator func !=(b: HuffIndex) {
        !(this == b)
    }
}

/*
 * The class is HuffmanSpec
 * @author changeden
 */
class HuffmanSpec {
    /** var member count type is Array<UInt8> */
    public var count: Array<UInt8>

    /** var member value type is Array<UInt8> */
    public var value: Array<UInt8>

    /**
     * The Function is init constructor
     *
     * @param count of Array<UInt8>
     * @param value of Array<UInt8>
     */
    public init(count: Array<UInt8>, value: Array<UInt8>) {
        this.count = count
        this.value = value
    }
}

/* let member theHuffmanSpec type is Array<HuffmanSpec> */
let theHuffmanSpec: Array<HuffmanSpec> = [
    HuffmanSpec(
        [0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    ),
    HuffmanSpec(
        [0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 125],
        [
            0x01,
            0x02,
            0x03,
            0x00,
            0x04,
            0x11,
            0x05,
            0x12,
            0x21,
            0x31,
            0x41,
            0x06,
            0x13,
            0x51,
            0x61,
            0x07,
            0x22,
            0x71,
            0x14,
            0x32,
            0x81,
            0x91,
            0xa1,
            0x08,
            0x23,
            0x42,
            0xb1,
            0xc1,
            0x15,
            0x52,
            0xd1,
            0xf0,
            0x24,
            0x33,
            0x62,
            0x72,
            0x82,
            0x09,
            0x0a,
            0x16,
            0x17,
            0x18,
            0x19,
            0x1a,
            0x25,
            0x26,
            0x27,
            0x28,
            0x29,
            0x2a,
            0x34,
            0x35,
            0x36,
            0x37,
            0x38,
            0x39,
            0x3a,
            0x43,
            0x44,
            0x45,
            0x46,
            0x47,
            0x48,
            0x49,
            0x4a,
            0x53,
            0x54,
            0x55,
            0x56,
            0x57,
            0x58,
            0x59,
            0x5a,
            0x63,
            0x64,
            0x65,
            0x66,
            0x67,
            0x68,
            0x69,
            0x6a,
            0x73,
            0x74,
            0x75,
            0x76,
            0x77,
            0x78,
            0x79,
            0x7a,
            0x83,
            0x84,
            0x85,
            0x86,
            0x87,
            0x88,
            0x89,
            0x8a,
            0x92,
            0x93,
            0x94,
            0x95,
            0x96,
            0x97,
            0x98,
            0x99,
            0x9a,
            0xa2,
            0xa3,
            0xa4,
            0xa5,
            0xa6,
            0xa7,
            0xa8,
            0xa9,
            0xaa,
            0xb2,
            0xb3,
            0xb4,
            0xb5,
            0xb6,
            0xb7,
            0xb8,
            0xb9,
            0xba,
            0xc2,
            0xc3,
            0xc4,
            0xc5,
            0xc6,
            0xc7,
            0xc8,
            0xc9,
            0xca,
            0xd2,
            0xd3,
            0xd4,
            0xd5,
            0xd6,
            0xd7,
            0xd8,
            0xd9,
            0xda,
            0xe1,
            0xe2,
            0xe3,
            0xe4,
            0xe5,
            0xe6,
            0xe7,
            0xe8,
            0xe9,
            0xea,
            0xf1,
            0xf2,
            0xf3,
            0xf4,
            0xf5,
            0xf6,
            0xf7,
            0xf8,
            0xf9,
            0xfa
        ]
    ),
    HuffmanSpec([0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]),
    HuffmanSpec(
        [0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0, 1, 2, 119],
        [
            0x00,
            0x01,
            0x02,
            0x03,
            0x11,
            0x04,
            0x05,
            0x21,
            0x31,
            0x06,
            0x12,
            0x41,
            0x51,
            0x07,
            0x61,
            0x71,
            0x13,
            0x22,
            0x32,
            0x81,
            0x08,
            0x14,
            0x42,
            0x91,
            0xa1,
            0xb1,
            0xc1,
            0x09,
            0x23,
            0x33,
            0x52,
            0xf0,
            0x15,
            0x62,
            0x72,
            0xd1,
            0x0a,
            0x16,
            0x24,
            0x34,
            0xe1,
            0x25,
            0xf1,
            0x17,
            0x18,
            0x19,
            0x1a,
            0x26,
            0x27,
            0x28,
            0x29,
            0x2a,
            0x35,
            0x36,
            0x37,
            0x38,
            0x39,
            0x3a,
            0x43,
            0x44,
            0x45,
            0x46,
            0x47,
            0x48,
            0x49,
            0x4a,
            0x53,
            0x54,
            0x55,
            0x56,
            0x57,
            0x58,
            0x59,
            0x5a,
            0x63,
            0x64,
            0x65,
            0x66,
            0x67,
            0x68,
            0x69,
            0x6a,
            0x73,
            0x74,
            0x75,
            0x76,
            0x77,
            0x78,
            0x79,
            0x7a,
            0x82,
            0x83,
            0x84,
            0x85,
            0x86,
            0x87,
            0x88,
            0x89,
            0x8a,
            0x92,
            0x93,
            0x94,
            0x95,
            0x96,
            0x97,
            0x98,
            0x99,
            0x9a,
            0xa2,
            0xa3,
            0xa4,
            0xa5,
            0xa6,
            0xa7,
            0xa8,
            0xa9,
            0xaa,
            0xb2,
            0xb3,
            0xb4,
            0xb5,
            0xb6,
            0xb7,
            0xb8,
            0xb9,
            0xba,
            0xc2,
            0xc3,
            0xc4,
            0xc5,
            0xc6,
            0xc7,
            0xc8,
            0xc9,
            0xca,
            0xd2,
            0xd3,
            0xd4,
            0xd5,
            0xd6,
            0xd7,
            0xd8,
            0xd9,
            0xda,
            0xe2,
            0xe3,
            0xe4,
            0xe5,
            0xe6,
            0xe7,
            0xe8,
            0xe9,
            0xea,
            0xf2,
            0xf3,
            0xf4,
            0xf5,
            0xf6,
            0xf7,
            0xf8,
            0xf9,
            0xfa
        ]
    )
]

/*
 * The class is HuffmanLUT
 * @author changeden
 */
class HuffmanLUT {
    /** var member h type is Array<UInt32> */
    public var h: Array<UInt32>

    /**
     * The Function is init constructor
     *
     */
    public init() {
        h = []
    }

    /**
     * The Function is init constructor
     *
     * @param s of HuffmanSpec
     */
    public init(s: HuffmanSpec) {
        var maxValue = 0
        for (v in s.value) {
            if (Int64(v) > maxValue) {
                maxValue = Int64(v)
            }
        }
        h = Array<UInt32>(maxValue + 1, item: 0)
        var code: UInt32 = 0
        var k = 0
        for (i in 0..s.count.size) {
            let nBits = UInt32(i + 1) << 24
            for (_ in 0..s.count[i]) {
                h[Int64(s.value[k])] = nBits | code
                code++
                k++
            }
            code <<= 1
        }
    }

    /**
     * The Function is []
     *
     * @param index of Int64
     *
     * @return Type of UInt32
     */
    public operator func [](index: Int64): UInt32 {
        h[index]
    }

    /**
     * The Function is []
     *
     * @param index of Int64
     * @param value of UInt32
     *
     * @return Type of Unit
     */
    public operator func [](index: Int64, value!: UInt32): Unit {
        h[index] = value
    }

    /**
     * The Function is []
     *
     * @param range of Range<Int64>
     *
     * @return Type of Array<UInt32>
     */
    public operator func [](range: Range<Int64>): Array<UInt32> {
        h[range]
    }

    /**
     * The Function is size
     *
     */
    public func size() {
        h.size
    }
}

/* let member theHuffmanLUT type is Array<HuffmanLUT> */
let theHuffmanLUT: Array<HuffmanLUT> = Array<HuffmanLUT>(theHuffmanSpec.size, {i => HuffmanLUT(theHuffmanSpec[i])})

/* let member nComponentSubSampling type is Array<Array<Rune>> */
let nComponentSubSampling: Array<Array<Rune>> = [[r'\u{22}', r'\u{11}', r'\u{11}'], [r'\u{00}', r'\u{01}', r'\u{01}']]

/* let member nComponentHuffmanMarker type is Array<Rune> */
let nComponentHuffmanMarker: Array<Rune> = [r'\u{00}', r'\u{10}', r'\u{01}', r'\u{11}']

/* let member sosHeaderY type is Array<UInt8> */
let sosHeaderY: Array<UInt8> = [0xff, 0xda, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3f, 0x00]

/* let member sosHeaderYCbCr type is Array<UInt8> */
let sosHeaderYCbCr: Array<UInt8> = [
    0xff,
    0xda,
    0x00,
    0x0c,
    0x03,
    0x01,
    0x00,
    0x02,
    0x11,
    0x03,
    0x11,
    0x00,
    0x3f,
    0x00
]

/**
 * The class is Encoder
 * @author changeden
 */
public class Encoder {
    /** var member w type is BufferedOutputStream */
    public var w: BufferedOutputStream<OutputStream>

    /** var member buf type is Array<UInt8> */
    public var buf: Array<UInt8> = Array<UInt8>(16, item: 0)

    /** var member bits type is UInt32 */
    public var bits: UInt32 = 0

    /** var member nBits type is UInt32 */
    public var nBits: UInt32 = 0

    /** let member quant type is Array<Array<UInt8>> */
    public let quant: Array<Array<UInt8>> = Array<Array<UInt8>>(
        nQuantIndex.hashCode(),
        {_ => Array<UInt8>(blockSize, item: 0)}
    )

    /**
     * The Function is init constructor
     *
     * @param w of BufferedOutputStream
     */
    public init(w: BufferedOutputStream<OutputStream>) {
        this.w = w
    }

    /*
     * The Function is flush
     *
     */
    func flush() {
        w.flush()
    }

    /*
     * The Function is write
     *
     * @param arrayToWrite of Array<UInt8>
     */
    func write(arrayToWrite: Array<UInt8>) {
        w.write(arrayToWrite)
    }

    /*
     * The Function is writeByte
     *
     * @param b of UInt8
     */
    func writeByte(b: UInt8) {
        write([b])
    }

    /*
     * The Function is emit
     *
     * @param bits of UInt32
     * @param nBits of UInt32
     */
    func emit(bits: UInt32, nBits: UInt32) {
        var mnBits = nBits
        mnBits += this.nBits
        var mbits = bits
        mbits <<= 32 - mnBits
        mbits |= this.bits

        while (mnBits >= 8) {
            let b = UInt8(mbits >> 24)
            writeByte(b)
            if (b == 0xff) {
                writeByte(0x00)
            }
            mbits <<= 8
            mnBits -= 8
        }
        this.bits = mbits
        this.nBits = mnBits
    }

    /*
     * The Function is emitHuff
     *
     * @param h of HuffIndex
     * @param value of Int32
     */
    func emitHuff(h: HuffIndex, value: Int32) {
        try {
            let x = theHuffmanLUT[h.hashCode()][Int64(value)]
            emit(x & ((1 << 24) - 1), x >> 24)
        } catch (e: Exception) {
            println("HuffIndex: ${h.hashCode()}, value: ${value}")
            throw e
        }
    }

    /*
     * The Function is emitHuffRLE
     *
     * @param h of HuffIndex
     * @param runLength of Int32
     * @param value of Int32
     */
    @OverflowWrapping
    func emitHuffRLE(h: HuffIndex, runLength: Int32, value: Int32) {
        var a = Int64(value)
        var b = value
        if (a < 0) {
            a = -a
            b--
        }
        let nBits = if (a < 0x100) {
            UInt32(bitCount[a])
        } else {
            8 + UInt32(bitCount[a >> 8])
        }
        emitHuff(h, (runLength << 4) | Int32(nBits))
        if (nBits > 0) {
            emit(UInt32(b) & ((1 << nBits) - 1), nBits)
        }
    }

    /*
     * The Function is writeMarkerHeader
     *
     * @param marker of UInt8
     * @param markerLen of Int64
     */
    func writeMarkerHeader(marker: UInt8, markerLen: Int64) {
        buf[0] = 0xff
        buf[1] = marker
        buf[2] = UInt8(markerLen >> 8)
        buf[3] = UInt8(markerLen & 0xff)
        write(buf[0..4])
    }

    /*
     * The Function is writeDQT
     *
     */
    func writeDQT() {
        let markerLen = 2 + nQuantIndex.hashCode() * (1 + blockSize)
        writeMarkerHeader(dqtMarker, markerLen)

        for (i in 0..quant.size) {
            writeByte(UInt8(i))
            write(quant[i])
        }
    }

    /*
     * The Function is writeSOF0
     *
     * @param size of Point
     * @param nComponent of Int64
     */
    func writeSOF0(size: Point, nComponent: Int64) {
        writeMarkerHeader(sof0Marker, 8 + 3 * nComponent)
        buf[0] = 8 // 8-bit color.
        buf[1] = UInt8(size.y >> 8)
        buf[2] = UInt8(size.y & 0xff)
        buf[3] = UInt8(size.x >> 8)
        buf[4] = UInt8(size.x & 0xff)
        buf[5] = UInt8(nComponent)
        if (nComponent == 1) {
            buf[6] = 1

            // No subsampling for grayscale image.
            buf[7] = 0x11
            buf[8] = 0x00
        } else {
            for (i in 0..nComponent) {
                buf[3 * i + 6] = UInt8(i + 1)
                buf[3 * i + 7] = UInt8(UInt32(nComponentSubSampling[0][i]))
                buf[3 * i + 8] = UInt8(UInt32(nComponentSubSampling[1][i]))
            }
        }
        write(buf[0..(3 * (nComponent - 1) + 9)])
    }

    /*
     * The Function is writeDHT
     *
     * @param nComponent of Int64
     */
    func writeDHT(nComponent: Int64) {
        var markerLen = 2
        let specs = if (nComponent == 1) {
            theHuffmanSpec[0..2]
        } else {
            theHuffmanSpec
        }
        for (s in specs) {
            markerLen += 1 + 16 + s.value.size
        }
        writeMarkerHeader(dhtMarker, markerLen)
        for (i in 0..specs.size) {
            let s = specs[i]
            writeByte(UInt8(UInt32(nComponentHuffmanMarker[i])))
            write(s.count)
            write(s.value)
        }
    }

    /*
     * The Function is writeBlock
     *
     * @param b of Block
     * @param q of QuantIndex
     * @param prevDC of Int32
     *
     * @return Type of Int32
     */
    func writeBlock(b: Block, q: QuantIndex, prevDC: Int32): Int32 {
        fdct(b)
        let dc = div(b[0], 8 * Int32(quant[q.hashCode()][0]))
        emitHuffRLE(otherHuffIndex(2 * q.hashCode() + 0), 0, dc - prevDC)
        let h = otherHuffIndex(2 * q.hashCode() + 1)
        var runLength: Int32 = 0
        for (zig in 1..blockSize) {
            let ac = div(b[unzig[zig]], 8 * Int32(quant[q.hashCode()][zig]))
            if (ac == 0) {
                runLength++
            } else {
                while (runLength > 15) {
                    emitHuff(h, 0xf0)
                    runLength -= 16
                }
                emitHuffRLE(h, runLength, ac)
                runLength = 0
            }
        }
        if (runLength > 0) {
            emitHuff(h, 0x00)
        }
        dc
    }

    /*
     * The Function is writeSOS
     *
     * @param m of Image
     */
    func writeSOS(m: Image) {
        if (m is image.Gray) {
            write(sosHeaderY)
        } else {
            write(sosHeaderYCbCr)
        }
        let b = Block()
        let cb = Array<Block>(4, {_ => Block()})
        let cr = Array<Block>(4, {_ => Block()})
        var prevDCY: Int32 = 0
        var prevDCCb: Int32 = 0
        var prevDCCr: Int32 = 0
        let bounds = m.bounds()
        if (m is image.Gray) {
            let mm = (m as image.Gray).getOrThrow()
            for (y in bounds.min.y..bounds.max.y : 8) {
                for (x in bounds.min.x..bounds.max.x : 8) {
                    let p = Point(x, y)
                    grayToY(mm, p, b)
                    prevDCY = writeBlock(b, quantIndexLuminance, prevDCY)
                }
            }
        } else {
            let rgba = m as image.RGBA
            let ycbcr = m as image.YCbCr
            for (y in bounds.min.y..bounds.max.y : 16) {
                for (x in bounds.min.x..bounds.max.x : 16) {
                    for (i in 0..4) {
                        let xOff = (i & 1) * 8
                        let yOff = (i & 2) * 4
                        let p = Point(x + xOff, y + yOff)
                        var resolved = false
                        if (!resolved) {
                            if (let Some(mrgba) <- rgba) {
                                rgbaToYCbCr(mrgba, p, b, cb[i], cr[i])
                                resolved = true
                            }
                        }
                        if (!resolved) {
                            if (let Some(mrgba) <- ycbcr) {
                                yCbCrToYCbCr(mrgba, p, b, cb[i], cr[i])
                                resolved = true
                            }
                        }
                        if (!resolved) {
                            toYCbCr(m, p, b, cb[i], cr[i])
                            resolved = true
                        }
                        prevDCY = writeBlock(b, quantIndexLuminance, prevDCY)
                    }
                    scale(b, cb)
                    prevDCCb = writeBlock(b, quantIndexChrominance, prevDCCb)
                    scale(b, cr)
                    prevDCCr = writeBlock(b, quantIndexChrominance, prevDCCr)
                }
            }
        }
        emit(0x7f, 7)
    }
}

/*
 * The Function is toYCbCr
 *
 * @param m of Image
 * @param p of Point
 * @param yBlock of Block
 * @param cbBlock of Block
 * @param crBlock of Block
 */
func toYCbCr(m: Image, p: Point, yBlock: Block, cbBlock: Block, crBlock: Block) {
    let bounds = m.bounds()
    let xmax = bounds.max.x - 1
    let ymax = bounds.max.y - 1
    for (j in 0..8) {
        for (i in 0..8) {
            let (r, g, b, _) = m.at(min(p.x + i, xmax), min(p.y + j, ymax)).rgba()
            let (yy, cb, cr) = color.RGBToYCbCr(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8))
            yBlock[8 * j + i] = Int32(yy)
            cbBlock[8 * j + i] = Int32(cb)
            crBlock[8 * j + i] = Int32(cr)
        }
    }
}

/*
 * The Function is grayToY
 *
 * @param m of image.Gray
 * @param p of Point
 * @param yBlock of Block
 */
func grayToY(m: image.Gray, p: Point, yBlock: Block) {
    let b = m.bounds()
    let xmax = b.max.x - 1
    let ymax = b.max.y - 1
    let pix = m.pix
    for (j in 0..8) {
        for (i in 0..8) {
            let idx = m.pixOffset(min(p.x + i, xmax), min(p.y + j, ymax))
            yBlock[8 * j + i] = Int32(pix[idx])
        }
    }
}

/*
 * The Function is rgbaToYCbCr
 *
 * @param m of image.RGBA
 * @param p of Point
 * @param yBlock of Block
 * @param cbBlock of Block
 * @param crBlock of Block
 */
func rgbaToYCbCr(m: image.RGBA, p: Point, yBlock: Block, cbBlock: Block, crBlock: Block) {
    let b = m.bounds()
    let xmax = b.max.x - 1
    let ymax = b.max.y - 1
    let pix = m.pix
    for (j in 0..8) {
        var sj = p.y + j
        if (sj > ymax) {
            sj = ymax
        }
        let offset = (sj - b.min.y) * m.stride - b.min.x * 4
        for (i in 0..8) {
            var sx = p.x + i
            if (sx > xmax) {
                sx = xmax
            }
            let (yy, cb, cr) = color.RGBToYCbCr(pix[offset + sx * 4], pix[offset + sx * 4 + 1], pix[offset + sx * 4 + 2]
            )
            yBlock[8 * j + i] = Int32(yy)
            cbBlock[8 * j + i] = Int32(cb)
            crBlock[8 * j + i] = Int32(cr)
        }
    }
}

/*
 * The Function is yCbCrToYCbCr
 *
 * @param m of image.YCbCr
 * @param p of Point
 * @param yBlock of Block
 * @param cbBlock of Block
 * @param crBlock of Block
 */
func yCbCrToYCbCr(m: image.YCbCr, p: Point, yBlock: Block, cbBlock: Block, crBlock: Block) {
    let b = m.bounds()
    let xmax = b.max.x - 1
    let ymax = b.max.y - 1
    for (j in 0..8) {
        var sy = p.y + j
        if (sy > ymax) {
            sy = ymax
        }
        for (i in 0..8) {
            var sx = p.x + i
            if (sx > xmax) {
                sx = xmax
            }
            let yi = m.yOffset(sx, sy)
            let ci = m.cOffset(sx, sy)
            yBlock[8 * j + i] = Int32(m.y[yi])
            cbBlock[8 * j + i] = Int32(m.cb[ci])
            crBlock[8 * j + i] = Int32(m.cr[ci])
        }
    }
}

/*
 * The Function is scale
 *
 * @param dst of Block
 * @param src of Array<Block>
 */
func scale(dst: Block, src: Array<Block>) {
    for (i in 0..4) {
        let dstOff = ((i & 2) << 4) | ((i & 1) << 2)
        for (y in 0..4) {
            for (x in 0..4) {
                let j = 16 * y + 2 * x
                let sum = src[i][j] + src[i][j + 1] + src[i][j + 8] + src[i][j + 9]
                dst[8 * y + x + dstOff] = (sum + 2) >> 2
            }
        }
    }
}

/** let member DefaultQuality */
public let DefaultQuality = 75

/**
 * The class is Options
 * @author changeden
 */
public class Options {
    /** 质量（1~100） */
    public var quality: Int64 = DefaultQuality

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param quality of Int64
     */
    public init(quality: Int64) {
        this.quality = quality
    }
}

/**
 * 编码JPEG图片
 *
 * @param w of File 文件流（输出）
 * @param m of Image 输入图片
 * @param o of ?Options 编码选项
 */
public func encode(w: File, m: Image, o: ?Options) {
    let b = m.bounds()
    if (b.dx() >= (1 << 16) || b.dy() >= (1 << 16)) {
        throw Exception("jpeg: image is too large to encode")
    }
    var quality = if (let Some(r) <- o) {
        r.quality
    } else {
        DefaultQuality
    }
    if (quality < 1) {
        quality = 1
    } else if (quality > 100) {
        quality = 100
    }
    var scale = if (quality < 50) {
        5000 / quality
    } else {
        200 - quality * 2
    }
    let bs = BufferedOutputStream<OutputStream>(w)
    let e = Encoder(bs)
    for (i in 0..e.quant.size) {
        for (j in 0..e.quant[i].size) {
            var x = Int64(unScaledQuant[i][j])
            x = (x * scale + 50) / 100
            if (x < 1) {
                x = 1
            } else if (x > 255) {
                x = 255
            }
            e.quant[i][j] = UInt8(x)
        }
    }
    let nComponent = if (m is image.Gray) {
        1
    } else {
        3
    }
    e.buf[0] = 0xff
    e.buf[1] = 0xd8
    e.write(e.buf[0..2])

    // Write the quantization tables.
    e.writeDQT()

    // Write the image dimensions.
    e.writeSOF0(b.size(), nComponent)

    // Write the Huffman tables.
    e.writeDHT(nComponent)

    // Write the image data.
    e.writeSOS(m)

    // Write the End Of Image marker.
    e.buf[0] = 0xff
    e.buf[1] = 0xd9
    e.write(e.buf[0..2])
    e.flush()
    bs.flush()
    w.close()
}
