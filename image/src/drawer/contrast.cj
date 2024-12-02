package image.drawer

import std.fs.*
import image.color as color
import image.image as image
import image.internals.model.*
import image.internals.imageutil.*

func computeContrast(col: Int32, contrast: Int32, threshold: UInt32): Int32 {
    col + (col - Int32(threshold)) * contrast / 255
}

/*
 * 对比度调节
 *
 * 参数 src - 原始图片
 * 参数 contrastValue - 对比度调整值
 * 参数 thresholdValue - 对比度调整阈值，默认为128
 *
 * 返回值 Image - 返回处理结果
 */
public func contrast(src: ImageI, contrastValue: Int32, thresholdValue!: UInt32 = 128): ImageI {
    if (contrastValue == 0) {
        return src
    }

    let bounds = src.bounds()

    let dst = image.RGBA(bounds)

    for (y in 0..bounds.dy()) {
        for (x in 0..bounds.dx()) {
            let (r, g, b, a) = src.at(x, y).rgba()
            dst.setRGBA(
                x,
                y,
                color.RGBAC(
                    fixColor(computeContrast(Int32(r >> 8), contrastValue, thresholdValue)),
                    fixColor(computeContrast(Int32(g >> 8), contrastValue, thresholdValue)),
                    fixColor(computeContrast(Int32(b >> 8), contrastValue, thresholdValue)),
                    fixColor(Int32(a))
                )
            )
        }
    }

    dst
}
