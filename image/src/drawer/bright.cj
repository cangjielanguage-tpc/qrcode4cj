package image.drawer

import std.fs.*
import image.color as color
import image.image as image
import image.internals.model.*
import image.internals.imageutil.*

/*
 * 亮度调节
 *
 * 参数 src - 原始图片
 * 参数 brightValue - 亮度调整值
 *
 * 返回值 Image - 返回处理结果
 */
public func bright(src: ImageI, brightValue: Int32): ImageI {
    if (brightValue == 0) {
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
                    fixColor(Int32(r >> 8) + brightValue),
                    fixColor(Int32(g >> 8) + brightValue),
                    fixColor(Int32(b >> 8) + brightValue),
                    fixColor(Int32(a))
                )
            )
        }
    }

    dst
}
