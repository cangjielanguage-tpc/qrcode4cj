/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * THis file is about Implementation of YCbCr type picture rendering.
 */
package image.internals.imageutil

import image.internals.model.*
import image.image.*

/**
 * 画图
 *
 * @param dst of image.RGBA 结果图片
 * @param r of Rectangle  画图范围矩形
 * @param src of image.YCbCr 原始图片
 * @param sp of Point 原始图片起始坐标
 *
 * @return Type of Bool
 */
@OverflowWrapping
public func drawYCbCr(dst: RGBA, r: Rectangle, src: YCbCr, sp: Point): Bool {
    let x0 = (r.min.x - dst.rect.min.x) * 4
    let x1 = (r.max.x - dst.rect.min.x) * 4
    let y0 = r.min.y - dst.rect.min.y
    let y1 = r.max.y - dst.rect.min.y

    match (src.subsampleRatio) {
        case YCbCrSubsampleRatio444 =>
            var y = y0
            var sy = sp.y
            while (y != y1) {
                let dpixS = y * dst.stride
                var yi = (sy - src.rect.min.y) * src.yStride + (sp.x - src.rect.min.x)
                var ci = (sy - src.rect.min.y) * src.cStride + (sp.x - src.rect.min.x)
                var x = x0
                while (x != x1) {
                    let yy1 = Int32(src.y[yi]) * 0x10101
                    let cb1 = Int32(src.cb[ci]) - 128
                    let cr1 = Int32(src.cr[ci]) - 128
                    var r = yy1 + 91881 * cr1

                    if ((UInt32(r) & 0xff000000) == 0) {
                        r >>= 16
                    } else {
                        r = !(r >> 31)
                    }

                    var g = yy1 - 22554 * cb1 - 46802 * cr1
                    if ((UInt32(g) & 0xff000000) == 0) {
                        g >>= 16
                    } else {
                        g = !(g >> 31)
                    }

                    var b = yy1 + 116130 * cb1
                    if ((UInt32(b) & 0xff000000) == 0) {
                        b >>= 16
                    } else {
                        b = !(b >> 31)
                    }
                    dst.pix[dpixS] = UInt8(r)
                    dst.pix[dpixS + 1] = UInt8(g)
                    dst.pix[dpixS + 2] = UInt8(b)
                    dst.pix[dpixS + 3] = 255
                    x += 4
                    yi++
                    ci++
                }
                y++
                sy++
            }
            true
        case YCbCrSubsampleRatio422 =>
            var y = y0
            var sy = sp.y
            while (y != y1) {
                let dpixS = y * dst.stride
                var yi = (sy - src.rect.min.y) * src.yStride + (sp.x - src.rect.min.x)
                var ciBase = (sy - src.rect.min.y) * src.cStride - src.rect.min.x / 2
                var x = x0
                var sx = sp.x
                while (x != x1) {
                    var ci = ciBase + sx / 2
                    let yy1 = Int32(src.y[yi]) * 0x10101
                    let cb1 = Int32(src.cb[ci]) - 128
                    let cr1 = Int32(src.cr[ci]) - 128
                    var r = yy1 + 91881 * cr1

                    if ((UInt32(r) & 0xff000000) == 0) {
                        r >>= 16
                    } else {
                        r = !(r >> 31)
                    }

                    var g = yy1 - 22554 * cb1 - 46802 * cr1
                    if ((UInt32(g) & 0xff000000) == 0) {
                        g >>= 16
                    } else {
                        g = !(g >> 31)
                    }

                    var b = yy1 + 116130 * cb1
                    if ((UInt32(b) & 0xff000000) == 0) {
                        b >>= 16
                    } else {
                        b = !(b >> 31)
                    }
                    dst.pix[dpixS] = UInt8(r)
                    dst.pix[dpixS + 1] = UInt8(g)
                    dst.pix[dpixS + 2] = UInt8(b)
                    dst.pix[dpixS + 3] = 255
                    x += 4
                    sx++
                    yi++
                }
                y++
                sy++
            }
            true
        case YCbCrSubsampleRatio420 =>
            var y = y0
            var sy = sp.y
            while (y != y1) {
                let dpixS = y * dst.stride
                var yi = (sy - src.rect.min.y) * src.yStride + (sp.x - src.rect.min.x)
                var ciBase = (sy / 2 - src.rect.min.y / 2) * src.cStride - src.rect.min.x / 2
                var x = x0
                var sx = sp.x
                while (x != x1) {
                    var ci = ciBase + sx / 2
                    let yy1 = Int32(src.y[yi]) * 0x10101
                    let cb1 = Int32(src.cb[ci]) - 128
                    let cr1 = Int32(src.cr[ci]) - 128
                    var r = yy1 + 91881 * cr1

                    if ((UInt32(r) & 0xff000000) == 0) {
                        r >>= 16
                    } else {
                        r = !(r >> 31)
                    }

                    var g = yy1 - 22554 * cb1 - 46802 * cr1
                    if ((UInt32(g) & 0xff000000) == 0) {
                        g >>= 16
                    } else {
                        g = !(g >> 31)
                    }

                    var b = yy1 + 116130 * cb1
                    if ((UInt32(b) & 0xff000000) == 0) {
                        b >>= 16
                    } else {
                        b = !(b >> 31)
                    }
                    dst.pix[dpixS] = UInt8(r)
                    dst.pix[dpixS + 1] = UInt8(g)
                    dst.pix[dpixS + 2] = UInt8(b)
                    dst.pix[dpixS + 3] = 255
                    x += 4
                    sx++
                    yi++
                }
                y++
                sy++
            }
            true
        case YCbCrSubsampleRatio440 =>
            var y = y0
            var sy = sp.y
            while (y != y1) {
                let dpixS = y * dst.stride
                var yi = (sy - src.rect.min.y) * src.yStride + (sp.x - src.rect.min.x)
                var ci = (sy / 2 - src.rect.min.y / 2) * src.cStride + (sp.x - src.rect.min.x)
                var x = x0
                while (x != x1) {
                    let yy1 = Int32(src.y[yi]) * 0x10101
                    let cb1 = Int32(src.cb[ci]) - 128
                    let cr1 = Int32(src.cr[ci]) - 128
                    var r = yy1 + 91881 * cr1

                    if ((UInt32(r) & 0xff000000) == 0) {
                        r >>= 16
                    } else {
                        r = !(r >> 31)
                    }

                    var g = yy1 - 22554 * cb1 - 46802 * cr1
                    if ((UInt32(g) & 0xff000000) == 0) {
                        g >>= 16
                    } else {
                        g = !(g >> 31)
                    }

                    var b = yy1 + 116130 * cb1
                    if ((UInt32(b) & 0xff000000) == 0) {
                        b >>= 16
                    } else {
                        b = !(b >> 31)
                    }
                    dst.pix[dpixS] = UInt8(r)
                    dst.pix[dpixS + 1] = UInt8(g)
                    dst.pix[dpixS + 2] = UInt8(b)
                    dst.pix[dpixS + 3] = 255
                    x += 4
                    yi++
                    ci++
                }
                y++
                sy++
            }
            true
        case _ => false
    }
}
