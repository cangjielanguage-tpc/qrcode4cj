/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * JPEG格式模块
 */
package image.png

/* let member intSize */
let intSize = 32 << ((!UInt64(0)) >> 63)

/*
 * The Function is abs
 *
 * @param x of Int64
 *
 * @return Type of Int64
 */
func abs(x: Int64): Int64 {
    let m = x >> (intSize - 1)
    (x ^ m) - m
}

/*
 * The Function is paeth
 *
 * @param a of UInt8
 * @param b of UInt8
 * @param c of UInt8
 *
 * @return Type of UInt8
 */
func paeth(a: UInt8, b: UInt8, c: UInt8): UInt8 {
    var pc = Int64(c)
    var pa = Int64(b) - pc
    var pb = Int64(a) - pc
    pc = abs(pa + pb)
    pa = abs(pa)
    pb = abs(pb)
    if (pa <= pb && pa <= pc) {
        a
    } else if (pb <= pc) {
        b
    } else {
        c
    }
}

/*
 * The Function is filterPaeth
 *
 * @param cdat of Array<UInt8>
 * @param pdat of Array<UInt8>
 * @param bytesPerPixel of Int64
 *
 * @return Type of Unit
 */
func filterPaeth(cdat: Array<UInt8>, pdat: Array<UInt8>, bytesPerPixel: Int64): Unit {
    var a: Int64
    var b: Int64
    var c: Int64
    var pa: Int64
    var pb: Int64
    var pc: Int64
    for (i in 0..bytesPerPixel) {
        a = 0
        c = 0
        for (j in i..cdat.size : bytesPerPixel) {
            b = Int64(pdat[j])
            pa = b - c
            pb = a - c
            pc = abs(pa + pb)
            pa = abs(pa)
            pb = abs(pb)
            if (pa <= pb && pa <= pc) {
                // No-op.
            } else if (pb <= pc) {
                a = b
            } else {
                a = c
            }
            a += Int64(cdat[j])
            a &= 0xff
            cdat[j] = UInt8(a)
            c = b
        }
    }
}
