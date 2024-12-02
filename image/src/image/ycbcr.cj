/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about: YCbCr type definition.
 */

package image.image
import image.*
import image.color.*
import image.color.NYCbCrA as colorNYCbCrA
import image.color.YCbCr as colorYCbCr
import image.internals.model.*

// 采样率
public enum YCbCrSubsampleRatio <: ToString & Hashable {
    | YCbCrSubsampleRatio444
    | YCbCrSubsampleRatio422
    | YCbCrSubsampleRatio420
    | YCbCrSubsampleRatio440
    | YCbCrSubsampleRatio411
    | YCbCrSubsampleRatio410

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        match (this) {
            case YCbCrSubsampleRatio444 => "YCbCrSubsampleRatio444"
            case YCbCrSubsampleRatio422 => "YCbCrSubsampleRatio422"
            case YCbCrSubsampleRatio420 => "YCbCrSubsampleRatio420"
            case YCbCrSubsampleRatio440 => "YCbCrSubsampleRatio440"
            case YCbCrSubsampleRatio411 => "YCbCrSubsampleRatio411"
            case YCbCrSubsampleRatio410 => "YCbCrSubsampleRatio410"
        }
        // "YCbCrSubsampleRatioUnknown"
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("YCbCrSubsampleRatio")
        dfh.write(this.toString().hashCode())
        return dfh.finish()
    }

    /**
     * The Function is ==
     *
     * @param c of YCbCrSubsampleRatio
     *
     * @return Type of Bool
     */
    public operator func ==(c: YCbCrSubsampleRatio): Bool {
        this.hashCode() == c.hashCode()
    }
}

/**
 * The class is YCbCr inherited from RGBA64Image & Image
 * @author changeden
 */
public open class YCbCr <: RGBA64Image & ImageT {
    /** y色通像素信息 */
    public var y: Array<UInt8>

    /** cb色通像素信息 */
    public var cb: Array<UInt8>

    /** cr色通像素信息 */
    public var cr: Array<UInt8>

    /** y色通像素信息位数 */
    public var yStride: Int64 = 0

    /** c色通像素信息位数 */
    public var cStride: Int64 = 0

    /** 采样率 */
    public var subsampleRatio: YCbCrSubsampleRatio = YCbCrSubsampleRatio444

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.y = []
        this.cb = []
        this.cr = []
    }

    /**
     * The Function is init constructor
     *
     * @param subsampleRatio of YCbCrSubsampleRatio 采样率
     */
    public init(subsampleRatio: YCbCrSubsampleRatio) {
        this()
        this.subsampleRatio = subsampleRatio
    }

    /**
     * The Function is init constructor
     *
     * @param y of Array<UInt8> y色通像素信息
     * @param cb of Array<UInt8> cb色通像素信息
     * @param cr of Array<UInt8> cr色通像素信息
     * @param yStride of Int64 y色通像素信息位数
     * @param cStride of Int64 c色通像素信息位数
     * @param subsampleRatio of YCbCrSubsampleRatio 采样率
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(
        y: Array<UInt8>,
        cb: Array<UInt8>,
        cr: Array<UInt8>,
        yStride: Int64,
        cStride: Int64,
        subsampleRatio: YCbCrSubsampleRatio,
        rect: Rectangle
    ) {
        this.y = y
        this.cb = cb
        this.cr = cr
        this.yStride = yStride
        this.cStride = cStride
        this.subsampleRatio = subsampleRatio
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     * @param subsampleRatio of YCbCrSubsampleRatio 采样率
     */
    public init(r: Rectangle, subsampleRatio: YCbCrSubsampleRatio) {
        let (w, h, cw, ch) = yCbCrSize(r, subsampleRatio)
        let totalLength = add2NonNeg(mul3NonNeg(1, w, h), mul3NonNeg(2, cw, ch))
        if (totalLength < 0) {
            throw Exception("image: NewYCbCr Rectangle has huge or negative dimensions")
        }
        let i0 = w * h + 0 * cw * ch
        let i1 = w * h + 1 * cw * ch
        let i2 = w * h + 2 * cw * ch
        this.y = Array<UInt8>(i0, {_ => 0})
        this.cb = Array<UInt8>(i1 - i0, {_ => 0})
        this.cr = Array<UInt8>(i2 - i1, @OverflowSaturating{_ => 0})
        this.yStride = w
        this.cStride = cw
        this.subsampleRatio = subsampleRatio
        this.rect = r
    }

    /**
     * T获取颜色模型
     *
     * @return Type of Model
     */
    public open func colorModel(): Model {
        YCbCrModel
    }

    /**
     * 获取图片尺寸边界
     *
     * @return Type of Rectangle
     */
    public func bounds(): Rectangle {
        rect
    }

    /**
     * 获取某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Color
     */
    public open func at(x: Int64, y: Int64): Color {
        ycbcrAt(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public open func rgba64At(x: Int64, y: Int64): RGBA64C {
        let (r, g, b, a) = ycbcrAt(x, y).rgba()
        RGBA64C(UInt16(r), UInt16(g), UInt16(b), UInt16(a))
    }

    /**
     * 获取某坐标像素YCbCr颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of YCbCr
     */
    public func ycbcrAt(x: Int64, y: Int64): colorYCbCr {
        if (!Point(x, y).isIn(rect)) {
            return colorYCbCr()
        }
        let yi = yOffset(x, y)
        let ci = cOffset(x, y)
        colorYCbCr(this.y[yi], cb[ci], cr[ci])
    }

    /**
     * 获取某坐标像素y色通信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func yOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * yStride + (x - rect.min.x)
    }

    /**
     * 获取某坐标像素c色通信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func cOffset(x: Int64, y: Int64): Int64 {
        match (subsampleRatio) {
            case YCbCrSubsampleRatio422 => (y - rect.min.y) * cStride + (x / 2 - rect.min.x / 2)
            case YCbCrSubsampleRatio420 => (y / 2 - rect.min.y / 2) * cStride + (x / 2 - rect.min.x / 2)
            case YCbCrSubsampleRatio440 => (y / 2 - rect.min.y / 2) * cStride + (x - rect.min.x)
            case YCbCrSubsampleRatio411 => (y - rect.min.y) * cStride + (x / 4 - rect.min.x / 4)
            case YCbCrSubsampleRatio410 => (y / 2 - rect.min.y / 2) * cStride + (x / 4 - rect.min.x / 4)
            case _ => (y - rect.min.y) * cStride + (x - rect.min.x)
        }
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public open func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return YCbCr(subsampleRatio)
        }
        let yi = yOffset(rect.min.x, rect.min.y)
        let ci = cOffset(rect.min.x, rect.min.y)
        YCbCr(
            y[yi..y.size],
            cb[ci..cb.size],
            cr[ci..cr.size],
            yStride,
            cStride,
            subsampleRatio,
            rect
        )
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public open func opaque(): Bool {
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public open func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("YCbCr")
        dfh.write(y.size.hashCode())
        dfh.write(cb.size.hashCode())
        dfh.write(cr.size.hashCode())
        dfh.write(yStride.hashCode())
        dfh.write(cStride.hashCode())
        dfh.write(subsampleRatio.hashCode())
        dfh.write(rect.hashCode())
        return dfh.finish()
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

    /**
     * 获取YCbCr完整像素信息
     *
     * @return Type of Array<UInt8>
     */
    public func getYCbCr(): Array<UInt8> {
        let r = Array<UInt8>(y.size + cb.size + cr.size, {_ => 0})
        var index = 0
        for (i in y) {
            r[index] = i
            index++
        }
        for (i in cb) {
            r[index] = i
            index++
        }
        for (i in cr) {
            r[index] = i
            index++
        }
        r
    }

    public func set(x: Int64, y: Int64, c: Color) {
        throw Exception("不支持该操作")
    }
}

/*
 * 获取YCbCr尺寸信息
 *
 * @param r of Rectangle
 * @param subsampleRatio of YCbCrSubsampleRatio
 *
 * @return Type of (Int64,Int64,Int64,Int64)
 */
func yCbCrSize(r: Rectangle, subsampleRatio: YCbCrSubsampleRatio): (Int64, Int64, Int64, Int64) {
    let w = r.dx()
    let h = r.dy()
    var cw: Int64
    var ch: Int64
    match (subsampleRatio) {
        case YCbCrSubsampleRatio422 =>
            cw = (r.max.x + 1) / 2 - r.min.x / 2
            ch = h

        case YCbCrSubsampleRatio420 =>
            cw = (r.max.x + 1) / 2 - r.min.x / 2
            ch = (r.max.y + 1) / 2 - r.min.y / 2
        case YCbCrSubsampleRatio440 =>
            cw = w
            ch = (r.max.y + 1) / 2 - r.min.y / 2
        case YCbCrSubsampleRatio411 =>
            cw = (r.max.x + 3) / 4 - r.min.x / 4
            ch = h

        case YCbCrSubsampleRatio410 =>
            cw = (r.max.x + 3) / 4 - r.min.x / 4
            ch = (r.max.y + 1) / 2 - r.min.y / 2
        case _ =>
            cw = w
            ch = h
    }
    (w, h, cw, ch)
}

/**
 * The class is NYCbCrA inherited from YCbCr
 * @author changeden
 */
public class NYCbCrA <: YCbCr {
    /** a色通像素信息 */
    public var a: Array<UInt8> = Array<UInt8>()

    /** a色通像素信息位数 */
    public var aStride: Int64 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param subsampleRatio of YCbCrSubsampleRatio 采样率
     */
    public init(subsampleRatio: YCbCrSubsampleRatio) {
        this.subsampleRatio = subsampleRatio
    }

    /**
     * The Function is init constructor
     *
     * @param y of Array<UInt8> y色通像素信息
     * @param cb of Array<UInt8> cb色通像素信息
     * @param cr of Array<UInt8> cr色通像素信息
     * @param a of Array<UInt8> a色通像素信息
     * @param yStride of Int64 y色通像素信息位数
     * @param cStride of Int64 c色通像素信息位数
     * @param aStride of Int64 a色通像素信息位数
     * @param subsampleRatio of YCbCrSubsampleRatio 采样率
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(
        y: Array<UInt8>,
        cb: Array<UInt8>,
        cr: Array<UInt8>,
        a: Array<UInt8>,
        yStride: Int64,
        cStride: Int64,
        aStride: Int64,
        subsampleRatio: YCbCrSubsampleRatio,
        rect: Rectangle
    ) {
        super(y, cb, cr, yStride, cStride, subsampleRatio, rect)
        this.a = a
        this.aStride = aStride
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     * @param subsampleRatio of YCbCrSubsampleRatio 采样率
     */
    public init(r: Rectangle, subsampleRatio: YCbCrSubsampleRatio) {
        let (w, h, cw, ch) = yCbCrSize(r, subsampleRatio)
        let totalLength = add2NonNeg(mul3NonNeg(2, w, h), mul3NonNeg(2, cw, ch))
        if (totalLength < 0) {
            throw Exception("image: NewNYCbCrA Rectangle has huge or negative dimension")
        }
        let i0 = 1 * w * h + 0 * cw * ch
        let i1 = 1 * w * h + 1 * cw * ch
        let i2 = 1 * w * h + 2 * cw * ch
        let i3 = 2 * w * h + 2 * cw * ch
        this.y = Array<UInt8>(i0, {_ => 0})
        this.cb = Array<UInt8>(i1 - i0, {_ => 0})
        this.cr = Array<UInt8>(i2 - i1, {_ => 0})
        this.a = Array<UInt8>(i3 - i2, {_ => 0})
        this.yStride = w
        this.cStride = cw
        this.aStride = w
        this.subsampleRatio = subsampleRatio
        this.rect = r
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public override func colorModel(): Model {
        NYCbCrAModel
    }

    /**
     * 获取某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Color
     */
    public override func at(x: Int64, y: Int64): Color {
        nycbcrAt(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public override func rgba64At(x: Int64, y: Int64): RGBA64C {
        let (r, g, b, aa) = nycbcrAt(x, y).rgba()
        RGBA64C(UInt16(r), UInt16(g), UInt16(b), UInt16(aa))
    }

    /**
     * 获取某坐标像素NYCbCr颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of NYCbCrA
     */
    public func nycbcrAt(x: Int64, y: Int64): colorNYCbCrA {
        if (!Point(x, y).isIn(rect)) {
            return colorNYCbCrA()
        }
        let yi = yOffset(x, y)
        let ci = cOffset(x, y)
        let ai = aOffset(x, y)

        let ycbcr = colorYCbCr(this.y[yi], cb[ci], cr[ci])
        colorNYCbCrA(ycbcr, a[ai])
    }

    /**
     * 获取某坐标像素a色通信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func aOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * aStride + (x - rect.min.x)
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public override func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return NYCbCrA(subsampleRatio)
        }
        let yi = yOffset(rect.min.x, rect.min.y)
        let ci = cOffset(rect.min.x, rect.min.y)
        let ai = aOffset(rect.min.x, rect.min.y)
        NYCbCrA(
            y[yi..y.size],
            cb[ci..cb.size],
            cr[ci..cr.size],
            a[ai..a.size],
            yStride,
            cStride,
            aStride,
            subsampleRatio,
            rect
        )
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public override func opaque(): Bool {
        if (rect.empty()) {
            return true
        }
        var i0 = 0
        var i1 = rect.dx()
        for (i in rect.min.y..rect.max.y) {
            for (ai in i0..i1) {
                if (a[ai] != 0xff) {
                    return false
                }
            }
            i0 += aStride
            i1 += aStride
        }
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public override func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("NYCbCrA")
        dfh.write(y.size.hashCode())
        dfh.write(cb.size.hashCode())
        dfh.write(cr.size.hashCode())
        dfh.write(yStride.hashCode())
        dfh.write(cStride.hashCode())
        dfh.write(subsampleRatio.hashCode())
        dfh.write(rect.hashCode())
        return dfh.finish()
    }

    /**
     * T获取NYCbCr完整像素信息
     *
     * @return Type of Array<UInt8>
     */
    public func getNYCbCrA(): Array<UInt8> {
        let r = Array<UInt8>(y.size + cb.size + cr.size + a.size, {_ => 0})
        var index = 0
        for (i in y) {
            r[index] = i
            index++
        }
        for (i in cb) {
            r[index] = i
            index++
        }
        for (i in cr) {
            r[index] = i
            index++
        }
        for (i in a) {
            r[index] = i
            index++
        }
        r
    }
}
