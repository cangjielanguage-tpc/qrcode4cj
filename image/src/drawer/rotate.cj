package image.drawer

import image.resizer.*
import std.collection.*
import std.fs.*
import std.math.*
import image.color as color
import image.image as image
import image.internals.model.*
import image.internals.imageutil.*
/*
 * 中心旋转
 *
 * 参数 src - 原始图片
 * 参数 rotateAngle - 中心旋转角度
 *
 * 返回值 Image - 返回处理结果
 */
@OverflowWrapping
public func rotate(src: ImageI, rotateAngle: Int64): ImageI {
    if (rotateAngle % 360 == 0) {
        return src
    }

    let bounds = src.bounds()
    let sW = bounds.dx()
    let sH = bounds.dy()

    let hW = Float64(sW) * 0.5
    let hH = Float64(sH) * 0.5

    let angle = Float64(rotateAngle) * Float64.PI / 180.0
    let sin = sin(angle)
    let cos = cos(angle)

    let (ltX, ltY) = computeRotatePosition(-hW, hH, sin, cos)
    let (rtX, rtY) = computeRotatePosition(hW, hH, sin, cos)
    let (lbX, lbY) = computeRotatePosition(-hW, -hH, sin, cos)
    let (rbX, rbY) = computeRotatePosition(hW, -hH, sin, cos)

    let maxWidth = Int64(max(abs(rbX - ltX), abs(rtX - lbX)))
    let maxHeight = Int64(max(abs(rbY - ltY), abs(rtY - lbY)))

    let dst = image.RGBA(Rectangle(0, 0, maxWidth, maxHeight))

    let halfWidth = Float64(maxWidth) * 0.5
    let halfHeight = Float64(maxHeight) * 0.5
    let subAngle = Float64(360 - rotateAngle % 360) * Float64.PI / 180.0
    let sinR = sinh(subAngle)
    let cosR = cosh(subAngle)

    for (y in 0..maxHeight) {
        for (x in 0..maxWidth) {
            let tXF = (Float64(x) - halfWidth) * cosR + (-Float64(y) + halfHeight) * sinR
            let tYF = -(Float64(x) - halfWidth) * sinR + (-Float64(y) + halfHeight) * cosR
            // let tX = Int64(tXF)
            // let tY = Int64(tYF)
            let colour = if (!(tXF > hW || tXF < -hW || tYF > hH || tYF < -hH)) {
                let tXN = Int64(tXF + hW)
                let tYN = Int64(abs(tYF - hH))
                let (r, g, b, a) = src.at(tXN, tYN).rgba()
                color.RGBAC(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8), UInt8(a))
            } else {
                color.RGBAC(255, 255, 255, 255)
            }
            dst.setRGBA(x, y, colour)
        }
    }
    dst
}

func computeRotatePosition(x: Float64, y: Float64, sin: Float64, cos: Float64): (Float64, Float64) {
    (x * cos + y * sin, -x * sin + y * cos)
}
