/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about other function.
 */

package image.internals.imageutil

import std.io.*
import std.collection.*

/*
 * 获取最小值
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

public interface Indexable<T> {
    operator func [](idx: Int64): T
    operator func [](idx: Int64, value!: T): Unit

    func length(): Int64
}
extend<T> Array<T> <: Indexable<T> {
    public func length(): Int64 {
        this.size
    }
}
extend<T> ArrayList<T> <: Indexable<T> {
    public func length(): Int64 {
        this.size
    }
}

/**
 * The Function is copy<T>
 *
 * @param dst of Array<T>
 * @param src of Array<T>
 * @param dstStart of Int64, and the Default value is 0
 * @param dstEnd of Int64, and the Default value is dst.size
 * @param srcStart of Int64, and the Default value is 0
 * @param srcEnd of Int64, and the Default value is src.size
 *
 * @return Type of Int64
 * @since 0.30.4
 */
public func copy<T>(
    dst: Indexable<T>,
    src: Indexable<T>,
    dstStart!: Int64 = 0,
    dstEnd!: Int64 = dst.length(),
    srcStart!: Int64 = 0,
    srcEnd!: Int64 = src.length()
): Int64 {
    let n = min(min(dst.length(), dstEnd - dstStart), min(src.length(), srcEnd - srcStart))
    for (i in 0..n) {
        dst[i + dstStart] = src[i + srcStart]
    }
    n
}

/**
 * 读取输入流
 *
 * @param r of InputStream
 * @param buf of Array<UInt8>
 * @param min of Int64, and the Default value is buf.size
 *
 * @return Type of Int64
 */
public func readFull(r: InputStream, buf: Array<UInt8>, min!: Int64 = buf.size): Int64 {
    let bs = buf.size
    if (bs < min) {
        throw ErrShortBuffer()
    }
    var n = 0
    try {
        n = r.read(buf)
    } catch (e: Exception) {
        throw e
    }
    if (n > 0 && n < min) {
        throw ErrUnexpectedEOF()
    }
    if (buf.size > 0 && n == 0) {
        throw EOF()
    }
    n
}

/**
 * 读取输入流
 *
 * @param r of InputStream
 * @param buf of Array<UInt8>
 * @param min of Int64, and the Default value is buf.size
 *
 * @return Type of (Int64, ?Exception)
 */
public func readFullCustom(r: InputStream, buf: Array<UInt8>, min!: Int64 = buf.size): (Int64, ?Exception) {
    let bs = buf.size
    if (bs < min) {
        return (0, ErrShortBuffer())
    }
    var n = 0
    try {
        n = r.read(buf)
    } catch (e: Exception) {
        return (n, e)
    }
    if (n > 0 && n < min) {
        return (n, ErrUnexpectedEOF())
    }
    if (buf.size > 0 && n == 0) {
        return (0, EOF())
    }
    (n, None)
}

/**
 * 从输入流读出单字节
 *
 * @param r of InputStream
 *
 * @return Type of (UInt8, ?Exception)
 */
public func readByte(r: InputStream): (UInt8, ?Exception) {
    let b = Array<UInt8>(1, item: 0)
    let (_, e) = readFullCustom(r, b)
    (b[0], e)
}

/**
 * 数组比较
 *
 * @param a of Array<UInt8>
 * @param b of Array<UInt8>
 *
 * @return Type of Bool
 */
public func arrayEquals(a: Array<UInt8>, b: Array<UInt8>): Bool {
    let s = a.size
    if (s != b.size) {
        return false
    }
    if (s == 0 && b.size == 0) {
        return true
    }
    for (i in 0..((s / 2) + 1)) {
        if (a[i] != b[i] || a[s - i - 1] != b[s - i - 1]) {
            return false
        }
    }
    true
}

/* let member rev8tab type is Array<UInt8> */
let rev8tab: Array<UInt8> = [
    0x00,
    0x80,
    0x40,
    0xc0,
    0x20,
    0xa0,
    0x60,
    0xe0,
    0x10,
    0x90,
    0x50,
    0xd0,
    0x30,
    0xb0,
    0x70,
    0xf0,
    0x08,
    0x88,
    0x48,
    0xc8,
    0x28,
    0xa8,
    0x68,
    0xe8,
    0x18,
    0x98,
    0x58,
    0xd8,
    0x38,
    0xb8,
    0x78,
    0xf8,
    0x04,
    0x84,
    0x44,
    0xc4,
    0x24,
    0xa4,
    0x64,
    0xe4,
    0x14,
    0x94,
    0x54,
    0xd4,
    0x34,
    0xb4,
    0x74,
    0xf4,
    0x0c,
    0x8c,
    0x4c,
    0xcc,
    0x2c,
    0xac,
    0x6c,
    0xec,
    0x1c,
    0x9c,
    0x5c,
    0xdc,
    0x3c,
    0xbc,
    0x7c,
    0xfc,
    0x02,
    0x82,
    0x42,
    0xc2,
    0x22,
    0xa2,
    0x62,
    0xe2,
    0x12,
    0x92,
    0x52,
    0xd2,
    0x32,
    0xb2,
    0x72,
    0xf2,
    0x0a,
    0x8a,
    0x4a,
    0xca,
    0x2a,
    0xaa,
    0x6a,
    0xea,
    0x1a,
    0x9a,
    0x5a,
    0xda,
    0x3a,
    0xba,
    0x7a,
    0xfa,
    0x06,
    0x86,
    0x46,
    0xc6,
    0x26,
    0xa6,
    0x66,
    0xe6,
    0x16,
    0x96,
    0x56,
    0xd6,
    0x36,
    0xb6,
    0x76,
    0xf6,
    0x0e,
    0x8e,
    0x4e,
    0xce,
    0x2e,
    0xae,
    0x6e,
    0xee,
    0x1e,
    0x9e,
    0x5e,
    0xde,
    0x3e,
    0xbe,
    0x7e,
    0xfe,
    0x01,
    0x81,
    0x41,
    0xc1,
    0x21,
    0xa1,
    0x61,
    0xe1,
    0x11,
    0x91,
    0x51,
    0xd1,
    0x31,
    0xb1,
    0x71,
    0xf1,
    0x09,
    0x89,
    0x49,
    0xc9,
    0x29,
    0xa9,
    0x69,
    0xe9,
    0x19,
    0x99,
    0x59,
    0xd9,
    0x39,
    0xb9,
    0x79,
    0xf9,
    0x05,
    0x85,
    0x45,
    0xc5,
    0x25,
    0xa5,
    0x65,
    0xe5,
    0x15,
    0x95,
    0x55,
    0xd5,
    0x35,
    0xb5,
    0x75,
    0xf5,
    0x0d,
    0x8d,
    0x4d,
    0xcd,
    0x2d,
    0xad,
    0x6d,
    0xed,
    0x1d,
    0x9d,
    0x5d,
    0xdd,
    0x3d,
    0xbd,
    0x7d,
    0xfd,
    0x03,
    0x83,
    0x43,
    0xc3,
    0x23,
    0xa3,
    0x63,
    0xe3,
    0x13,
    0x93,
    0x53,
    0xd3,
    0x33,
    0xb3,
    0x73,
    0xf3,
    0x0b,
    0x8b,
    0x4b,
    0xcb,
    0x2b,
    0xab,
    0x6b,
    0xeb,
    0x1b,
    0x9b,
    0x5b,
    0xdb,
    0x3b,
    0xbb,
    0x7b,
    0xfb,
    0x07,
    0x87,
    0x47,
    0xc7,
    0x27,
    0xa7,
    0x67,
    0xe7,
    0x17,
    0x97,
    0x57,
    0xd7,
    0x37,
    0xb7,
    0x77,
    0xf7,
    0x0f,
    0x8f,
    0x4f,
    0xcf,
    0x2f,
    0xaf,
    0x6f,
    0xef,
    0x1f,
    0x9f,
    0x5f,
    0xdf,
    0x3f,
    0xbf,
    0x7f,
    0xff
]

/**
 * The Function is bitsReverse8
 *
 * @param x of UInt8
 *
 * @return Type of UInt8
 */
public func bitsReverse8(x: UInt8): UInt8 {
    rev8tab[Int64(x)]
}

/**
 * The Function is bitsReverse16
 *
 * @param x of UInt16
 *
 * @return Type of UInt16
 */
public func bitsReverse16(x: UInt16): UInt16 {
    UInt16(rev8tab[Int64(x >> 8)]) | (UInt16(rev8tab[Int64(x & 0xff)]) << 8)
}
