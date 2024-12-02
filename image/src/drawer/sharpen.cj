package image.drawer

import std.collection.*
import std.fs.*
import std.math.*
import image.color as color
import image.image as image
import image.internals.model.*
import image.internals.imageutil.*
/**
 * 锐化处理滤波器
 * @author changeden
 */
public type SharpenFilter = Array<Array<Int32>> // 锐化滤波器尺寸应为n×m，且n和m大于1，且皆为单数，如3×3

/**
 * 3×3高斯滤波器
 * @author changeden
 */
public let DefaultSharpenFilter: SharpenFilter = [[1, 2, 1], [2, 4, 2], [1, 2, 1]]

@OverflowWrapping
func getPixColor(src: ImageI, x: Int64, y: Int64): (Int32, Int32, Int32, Int32) {
    let (r, g, b, a) = src.at(x, y).rgba()
    (Int32(r >> 8), Int32(g >> 8), Int32(b >> 8), Int32(a >> 8))
}

@OverflowWrapping
func fixColor(c: Int32): UInt8 {
    if (c > 255) {
        return 255
    }
    if (c < 0) {
        return 0
    }
    return UInt8(c)
}

func checkSharpenFilter(filter: SharpenFilter, imageWidth: Int64, imageHeight: Int64) {
    if (filter.size < 2) {
        throw Exception("锐化滤波器尺寸应为n×m，且n和m大于1，且皆为单数，如3×3")
    }
    var m = filter[0].size
    if (m % 2 == 0) {
        throw Exception("锐化滤波器尺寸应为n×m，且n和m大于1，且皆为单数，如3×3")
    }
    for (i in 1..filter.size) {
        if (m != filter[i].size) {
            throw Exception("锐化滤波器尺寸应为n×m，且n和m大于1，且皆为单数，如3×3")
        }
    }
    if (filter.size > imageHeight) {
        throw Exception("锐化滤波器高度不能大于图片高度")
    }
    if (filter[0].size > imageWidth) {
        throw Exception("锐化滤波器宽度不能大于图片宽度")
    }
}

@OverflowWrapping
func laplacianSharpen(
    channel: SharpenFilter,
    filter: SharpenFilter,
    sharpen: UInt32,
    threshold: UInt32,
    filterWidth: Int64,
    filterHeight: Int64,
    filterHalfHeight: Int64,
    filterHalfWidth: Int64
): Int32 {
    var sum: Int32 = 0
    for (y in 0..filterHeight) {
        for (x in 0..filterWidth) {
            sum += channel[y][x] * filter[y][x]
        }
    }
    let src = channel[filterHalfHeight][filterHalfWidth]
    let texture = Int32(fixColor(src + Int32(UInt8(sum >> 4))))
    if (texture > Int32(threshold)) {
        return Int32(fixColor(src + (texture * Int32(sharpen)) >> 5))
    }
    src
}

/*
 * 锐化处理
 *
 * 参数 src - 原始图片
 * 参数 sharpenValue - 锐化处理值
 * 参数 sharpenThreshold - 锐化处理阈值，默认为15
 * 参数 filter - 锐化处理滤波器，默认使用3×3高斯滤波器
 *
 * 返回值 Image - 返回处理结果
 */
@OverflowWrapping
public func sharpen(
    src: ImageI,
    sharpenValue: UInt32,
    sharpenThreshold!: UInt32 = 15,
    filter!: SharpenFilter = DefaultSharpenFilter
): ImageI {
    if (sharpenValue < 1 || sharpenThreshold < 1) {
        return src
    }

    let bounds = src.bounds()
    let width = bounds.dx()
    let height = bounds.dy()

    checkSharpenFilter(filter, width, height) // 检测滤波器是否有效

    let dst = image.RGBA(bounds)

    let filterHeight = filter.size
    let filterHalfHeight = filterHeight / 2
    let filterWidth = filter[0].size
    let filterHalfWidth = filterWidth / 2
    let startY = filterHalfHeight - 1
    let startX = filterHalfWidth - 1
    let maxHeight = height - filterHalfHeight
    let maxWidth = width - filterHalfWidth
    for (y in 0..height) {
        for (x in 0..width) {
            let (r0, g0, b0, a) = getPixColor(src, x, y)
            var r = r0
            var g = g0
            var b = b0
            if (y > startY && y < maxHeight && x > startX && x < maxWidth) {
                let rChannel: SharpenFilter = Array<Array<Int32>>(filterHeight, {_ => Array<Int32>(filterWidth, item: 0)}
                )
                let gChannel: SharpenFilter = Array<Array<Int32>>(filterHeight, {_ => Array<Int32>(filterWidth, item: 0)}
                )
                let bChannel: SharpenFilter = Array<Array<Int32>>(filterHeight, {_ => Array<Int32>(filterWidth, item: 0)}
                )

                for (y0 in (y - filterHalfHeight)..(y + filterHalfHeight)) {
                    for (x0 in (x - filterHalfWidth)..(x + filterHalfWidth)) {
                        let (r1, g1, b1, _) = getPixColor(src, x0, y0)
                        let y1 = y0 - y + filterHalfHeight
                        let x1 = x0 - x + filterHalfWidth
                        rChannel[y1][x1] = r1
                        gChannel[y1][x1] = g1
                        bChannel[y1][x1] = b1
                    }
                }

                r = laplacianSharpen(
                    rChannel,
                    filter,
                    sharpenValue,
                    sharpenThreshold,
                    filterWidth,
                    filterHeight,
                    filterHalfWidth,
                    filterHalfHeight,
                )
                g = laplacianSharpen(
                    gChannel,
                    filter,
                    sharpenValue,
                    sharpenThreshold,
                    filterWidth,
                    filterHeight,
                    filterHalfWidth,
                    filterHalfHeight,
                )
                b = laplacianSharpen(
                    bChannel,
                    filter,
                    sharpenValue,
                    sharpenThreshold,
                    filterWidth,
                    filterHeight,
                    filterHalfWidth,
                    filterHalfHeight,
                )
            }

            dst.setRGBA(x, y, color.RGBAC(fixColor(r), fixColor(g), fixColor(b), UInt8(a)))
        }
    }

    dst
}
