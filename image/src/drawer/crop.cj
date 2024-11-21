package image.drawer

import std.fs.*
import std.math.*
import image.color as color
import image.image as image
import image.internals.model.*
import image.internals.imageutil.*

/*
 * 普通裁剪
 *
 * 参数 src - 原始图片
 * 参数 cropWidth - 裁剪宽度
 * 参数 cropHeight - 裁剪高度
 * 参数 cropX - 裁剪起始坐标X
 * 参数 cropY - 裁剪起始坐标Y
 *
 * 返回值 Image - 返回处理结果
 */
public func crop(src: ImageI, cropWidth: Int64, cropHeight: Int64, cropX!: Int64 = 0, cropY!: Int64 = 0): ImageI {
    if (cropWidth <= 0 || cropHeight <= 0) {
        return src
    }

    let dst: Image = if (src is ImageT) {
        (src as ImageT).getOrThrow().subImage(
            Rectangle(cropX, cropY, cropX + Int64(cropWidth), cropY + Int64(cropHeight))
        )
    } else {
        src
    }
    (dst as ImageI).getOrThrow()
}

class RoundedCorner <: Image {
    var width: Int64 = 0
    var height: Int64 = 0
    var radius: Int64 = 0

    init(width!: Int64 = 0, height!: Int64 = 0, radius!: Int64 = 0) {
        this.width = width
        this.height = height
        this.radius = radius
    }

    public func colorModel(): color.Model {
        color.AlphaModel
    }

    public func bounds(): Rectangle {
        Rectangle(0, 0, this.width, this.height)
    }

    public func at(x: Int64, y: Int64): color.Color {
        if (this.radius == 0) {
            return color.AlphaC(255)
        }
        let r = this.radius
        let rF = Float64(r * r)
        let w = this.width - 1
        let h = this.height - 1
        if (x < r && y < r && (rF < pow(Float64(r - x), 2) + pow(Float64(r - y), 2))) { // top left
            color.AlphaC(0)
        } else if (x > (w - r) && y < r && (rF < pow(Float64(w - r - x), 2) + pow(Float64(r - y), 2))) { // top right
            color.AlphaC(0)
        } else if (x < r && y > (h - r) && (rF < pow(Float64(r - x), 2) + pow(Float64(h - r - y), 2))) { // bottom left
            color.AlphaC(0)
        } else if (x > (w - r) && y > (h - r) && (rF < pow(Float64(w - r - x), 2) + pow(Float64(h - r - y), 2))) { // bottom right
            color.AlphaC(0)
        } else {
            color.AlphaC(255)
        }
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        // var dfh: DefaultHasher = DefaultHasher()
        // dfh.write("name=")
        // dfh.write("RoundedCorner")
        // dfh.write(width.hashCode())
        // dfh.write(height.hashCode())
        // dfh.write(radius.hashCode())
        // return dfh.finish()
        0
    }

    /**
     * The Function is eq
     *
     * @param i of Image
     *
     * @return Type of Bool
     */
    public func eq(i: Image): Bool {
        return this.hashCode() == i.hashCode()
    }
}

/*
 * 圆形裁剪
 *
 * 参数 src - 原始图片
 * 参数 cropRadius - 裁剪半径，默认为宽高一半的最小值
 * 参数 cropX - 裁剪原点坐标X，默认为宽度一半
 * 参数 cropY - 裁剪原点坐标Y，默认为高度一半
 *
 * 返回值 Image - 返回处理结果
 */
public func cropCircle(
    src: ImageI,
    cropRadius!: Int64 = min(src.bounds().dx() / 2, src.bounds().dy() / 2),
    cropX!: Int64 = src.bounds().dx() / 2,
    cropY!: Int64 = src.bounds().dy() / 2
): ImageI {
    if (cropRadius <= 0) {
        return src
    }

    let bounds = src.bounds()
    let width = bounds.dx()
    let height = bounds.dy()

    let radius = min(Int64(cropRadius), min(width, height) / 2)

    let w = radius * 2
    let tmp = crop(src, w, w, cropX: cropX, cropY: cropY)
    let dst = image.RGBA(Rectangle(0, 0, w, w))
    drawMask(dst, tmp.bounds(), tmp, Point(), RoundedCorner(width: w, height: w, radius: radius), Point(), Over)
    dst
}

/*
 * 圆角矩形裁剪
 *
 * 参数 src - 原始图片
 * 参数 cropRadius - 圆角半径
 *
 * 返回值 Image - 返回处理结果
 */
public func cropRoundedCorner(src: ImageI, cropRadius: Int64): ImageI {
    if (cropRadius <= 0) {
        return src
    }

    let bounds = src.bounds()
    let width = bounds.dx()
    let height = bounds.dy()
    let halfSize = min(width, height) / 2

    let radius = min(cropRadius, halfSize)
    let dst = image.RGBA(bounds)
    drawMask(dst, src.bounds(), src, Point(), RoundedCorner(width: width, height: height, radius: radius), Point(), Over
    )
    dst
}
