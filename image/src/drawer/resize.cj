package image.drawer

import image.resizer.*
import std.collection.*
import std.fs.*
import std.math.*
import image.color as color
import image.image as image
import image.internals.model.*
import image.internals.imageutil.*

/**
 * 缩放模式
 * @author changeden
 */
public enum ResizeMode {
    | Lfit // 等比缩放，缩放图限制为指定w与h的矩形内的最大图片
    | Mfit // 等比缩放，缩放图为延伸出指定w与h的矩形框外的最小图片
    | Fill // 将原图等比缩放为延伸出指定w与h的矩形框外的最小图片，然后将超出的部分进行居中裁剪
    | Pad(color.RGBAC) // 将原图缩放为指定w与h的矩形内的最大图片，然后使用指定颜色居中填充空白部分
    | Fixed // 固定宽高，强制缩放
}

/*
 * 缩放处理
 *
 * 参数 src - 原始图片
 * 参数 resizeWidth - 缩放目标宽度
 * 参数 resizeHeight - 缩放目标高度
 * 参数 resizeMode - 缩放模式
 *
 * 返回值 Image - 返回处理结果
 */
public func resize(src: ImageI, resizeWidth: Int64, resizeHeight: Int64, resizeMode: ResizeMode): ImageI {
    if (resizeWidth <= 0 || resizeHeight <= 0) {
        return src
    }

    let bounds = src.bounds()
    let sW = Float64(bounds.dx())
    let sH = Float64(bounds.dy())
    let rW = Float64(resizeWidth) / sW
    let rH = Float64(resizeHeight) / sH

    let dst: Image = match (resizeMode) {
        case Fixed => resize(src, resizeWidth, resizeHeight)

        case Lfit =>
            let ratio = min(rW, rH)
            resize(src, Int64(sW * ratio), Int64(sH * ratio))

        case Pad(padColor) =>
            let ratio = min(rW, rH)
            let w = Int64(sW * ratio)
            let h = Int64(sH * ratio)
            let imgSrc = resize(src, w, h)
            drawWrap(
                imgSrc,
                resizeWidth,
                resizeHeight,
                abs((resizeWidth - w) / 2),
                abs((resizeHeight - h) / 2),
                padColor
            )

        case Mfit =>
            let ratio = max(rW, rH)
            resize(src, Int64(sW * ratio), Int64(sH * ratio))

        case Fill =>
            let ratio = max(rW, rH)
            let w = Int64(sW * ratio)
            let h = Int64(sH * ratio)
            let imgSrc = (resize(src, w, h) as ImageI).getOrThrow()
            crop(
                imgSrc,
                resizeWidth,
                resizeHeight,
                cropX: abs((resizeWidth - w) / 2),
                cropY: abs((resizeHeight - h) / 2)
            )
    }
    (dst as ImageI).getOrThrow()
}

func drawWrap(src: Image, w: Int64, h: Int64, x: Int64, y: Int64, padColor: color.RGBAC): Image {
    let wrapImg = image.RGBA(Rectangle(0, 0, w, h))
    draw(wrapImg, wrapImg.bounds(), image.Uniform(padColor), Point(), Src)
    let bounds = src.bounds()
    draw(wrapImg, bounds + Point(x, y), src, bounds.min, Src)
    return wrapImg
}
