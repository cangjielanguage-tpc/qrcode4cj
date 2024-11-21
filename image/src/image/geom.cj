/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about: Numeric operation.
 */

package image.image

/*
 * The Function is mul64
 *
 * @param x of UInt64
 * @param y of UInt64
 *
 * @return Type of (UInt64,UInt64)
 */
func mul64(x: UInt64, y: UInt64): (UInt64, UInt64) {
    let mask32 = UInt64((1 << 32) - 1)
    let x0 = x & mask32
    let x1 = x >> 32
    let y0 = y & mask32
    let y1 = y >> 32
    let w0 = x0 * y0
    let t = x1 * y0 + (w0 >> 32)
    var w1 = t & mask32
    let w2 = t >> 32
    w1 += x0 * y1
    let hi = x1 * y1 + w2 + (w1 >> 32)
    let lo = x * y
    return (hi, lo)
}

/*
 * The Function is mul3NonNeg
 *
 * @param x of Int64
 * @param y of Int64
 * @param z of Int64
 *
 * @return Type of Int64
 */
func mul3NonNeg(x: Int64, y: Int64, z: Int64): Int64 {
    if ((x < 0) || (y < 0) || (z < 0)) {
        return -1
    }
    var (hi0, lo0) = mul64(UInt64(x), UInt64(y))
    if (hi0 != 0) {
        return -1
    }
    var (hi1, lo1) = mul64(lo0, UInt64(z))
    if (hi1 != 0) {
        return -1
    }
    let a = Int64(lo1)
    if ((a < 0) || (UInt64(a) != lo1)) {
        return -1
    }
    return a
}

/*
 * The Function is add2NonNeg
 *
 * @param x of Int64
 * @param y of Int64
 *
 * @return Type of Int64
 */
func add2NonNeg(x: Int64, y: Int64): Int64 {
    if ((x < 0) || (y < 0)) {
        return -1
    }
    let a = x + y
    if (a < 0) {
        return -1
    }
    return a
}
