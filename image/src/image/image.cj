/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is baout: Picture type definition and operation core.
 */
package image.image

import std.collection.*
import image.*
import image.color.*
import image.color.CMYK as colorCMYK
import image.internals.model.*

/**
 * 图片信息
 * @author changeden
 */
public class Config <: ToString {
    /** 颜色模型 */
    public var colorModel: ?Model = None

    /** 图片宽度 */
    public var width: Int64 = 0

    /** v图片高度 */
    public var height: Int64 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param colorModel of Model 颜色模型
     * @param width of Int64 图片宽度
     * @param height of Int64 图片高度
     */
    public init(colorModel: Model, width: Int64, height: Int64) {
        this.colorModel = colorModel
        this.width = width
        this.height = height
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        let cm = if (let Some(r) <- colorModel) {
            r
        } else {
            "None"
        }
        "color-model: ${cm} width: ${width}, height: ${height}"
    }

    /**
     * The Function is ==
     *
     * @param r of Config
     *
     * @return Type of Bool
     */
    public operator func ==(r: Config): Bool {
        this.toString() == r.toString()
    }
}

/*
 * The Function is pixelBufferLength
 *
 * @param bytesPerPixel of Int64
 * @param r of Rectangle
 * @param imageTypeName of String
 *
 * @return Type of Int64
 */
func pixelBufferLength(bytesPerPixel: Int64, r: Rectangle, imageTypeName: String): Int64 {
    let totalLength = mul3NonNeg(bytesPerPixel, r.dx(), r.dy())
    if (totalLength < 0) {
        throw Exception("image: New ${imageTypeName} Rectangle has huge or negative dimensions")
    }
    return totalLength
}

/**
 * RGBA图片模型
 * @author changeden
 */
public open class RGBA <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(4, r, "RGBA"), {_ => 0}), 4 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return RGBAModel
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
    public func at(x: Int64, y: Int64): Color {
        rgbaAt(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    @OverflowWrapping
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        if (!Point(x, y).isIn(rect)) {
            return RGBA64C()
        }
        let i = pixOffset(x, y)
        let r = UInt16(pix[i])
        let g = UInt16(pix[i + 1])
        let b = UInt16(pix[i + 2])
        let a = UInt16(pix[i + 3])
        let rgba = RGBA64C()
        rgba.r = (r << 8) | r
        rgba.g = (g << 8) | g
        rgba.b = (b << 8) | b
        rgba.a = (a << 8) | a
        rgba
    }

    /**
     * 获取某坐标像素RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Color
     */
    public func rgbaAt(x: Int64, y: Int64): Color {
        if (!Point(x, y).isIn(rect)) {
            return RGBAC()
        }
        let i = pixOffset(x, y)
        let rgba = RGBAC()
        rgba.r = pix[i]
        rgba.g = pix[i + 1]
        rgba.b = pix[i + 2]
        rgba.a = pix[i + 3]
        rgba
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 4
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        let c1 = (RGBAModel.convert(c) as RGBAC).getOrThrow()
        pix[i] = c1.r
        pix[i + 1] = c1.g
        pix[i + 2] = c1.b
        pix[i + 3] = c1.a
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(c.r >> 8)
        pix[i + 1] = UInt8(c.g >> 8)
        pix[i + 2] = UInt8(c.b >> 8)
        pix[i + 3] = UInt8(c.a >> 8)
    }

    /**
     * 设置某坐标像素RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBAC
     */
    @OverflowWrapping
    public func setRGBA(x: Int64, y: Int64, c: RGBAC) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = c.r
        pix[i + 1] = c.g
        pix[i + 2] = c.b
        pix[i + 3] = c.a
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle 区域边界
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return RGBA()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        RGBA(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        if (rect.empty()) {
            return true
        }
        var i0 = 3
        var i1 = rect.dx() * 4
        for (y in rect.min.y..rect.max.y) {
            for (i in i0..i1 : 4) {
                if (pix[i] != 0xff) {
                    return false
                }
            }
            i0 += stride
            i1 += stride
        }
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
        dfh.write("RGBA")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/** 用于表示无效图片 */
public let nilImage: NilImage = NilImage()

/**
 * 无效图片
 * @author changeden
 */
public class NilImage <: RGBA64ImageI & ImageT {
    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return RGBAModel
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
    public func at(x: Int64, y: Int64): Color {
        rgbaAt(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        RGBA64C()
    }

    /**
     * 获取某坐标像素RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Color
     */
    public func rgbaAt(x: Int64, y: Int64): Color {
        GrayC()
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        0
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    public func set(x: Int64, y: Int64, c: Color) {}

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {}

    /**
     * 设置某坐标像素RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBAC
     */
    public func setRGBA(x: Int64, y: Int64, c: RGBAC) {}

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        this
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        false
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("NilImage")
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
}

/**
 * The class is RGBA64 inherited from RGBA64ImageI & ImageT
 * @author changeden
 */
public class RGBA64 <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(8, r, "RGBA64"), {_ => 0}), 8 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return RGBA64Model
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
    public func at(x: Int64, y: Int64): Color {
        rgba64At(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        if (!Point(x, y).isIn(rect)) {
            return RGBA64C()
        }
        let i = pixOffset(x, y)
        let rgba = RGBA64C()
        rgba.r = (UInt16(pix[i]) << 8) | UInt16(pix[i + 1])
        rgba.g = (UInt16(pix[i + 2]) << 8) | UInt16(pix[i + 3])
        rgba.b = (UInt16(pix[i + 4]) << 8) | UInt16(pix[i + 5])
        rgba.a = (UInt16(pix[i + 6]) << 8) | UInt16(pix[i + 7])
        rgba
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    @OverflowWrapping
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 8
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        let c1 = (RGBA64Model.convert(c) as RGBA64C).getOrThrow()
        pix[i] = UInt8(c1.r >> 8)
        pix[i + 1] = UInt8(c1.r)
        pix[i + 2] = UInt8(c1.g >> 8)
        pix[i + 3] = UInt8(c1.g)
        pix[i + 4] = UInt8(c1.b >> 8)
        pix[i + 5] = UInt8(c1.b)
        pix[i + 6] = UInt8(c1.a >> 8)
        pix[i + 7] = UInt8(c1.a)
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(c.r >> 8)
        pix[i + 1] = UInt8(c.r)
        pix[i + 2] = UInt8(c.g >> 8)
        pix[i + 3] = UInt8(c.g)
        pix[i + 4] = UInt8(c.b >> 8)
        pix[i + 5] = UInt8(c.b)
        pix[i + 6] = UInt8(c.a >> 8)
        pix[i + 7] = UInt8(c.a)
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return RGBA64()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        RGBA64(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        if (rect.empty()) {
            return true
        }
        var i0 = 6
        var i1 = rect.dx() * 8
        for (y in rect.min.y..rect.max.y) {
            for (i in i0..i1 : 8) {
                if (pix[i] != 0xff || pix[i + 1] != 0xff) {
                    return false
                }
            }
            i0 += stride
            i1 += stride
        }
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("RGBA64")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/**
 * The class is NRGBA inherited from RGBA64ImageI & ImageT
 * @author changeden
 */
public class NRGBA <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(4, r, "NRGBA"), {_ => 0}), 4 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return NRGBAModel
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
    public func at(x: Int64, y: Int64): Color {
        nrgbaAt(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        let (r, g, b, a) = nrgbaAt(x, y).rgba()
        RGBA64C(UInt16(r), UInt16(g), UInt16(b), UInt16(a))
    }

    /**
     * 获取某坐标像素NRGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of NRGBAC
     */
    public func nrgbaAt(x: Int64, y: Int64): NRGBAC {
        if (!Point(x, y).isIn(rect)) {
            return NRGBAC()
        }
        let i = pixOffset(x, y)
        NRGBAC(pix[i], pix[i + 1], pix[i + 2], pix[i + 3])
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 4
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        let c1 = (NRGBAModel.convert(c) as NRGBAC).getOrThrow()
        pix[i] = c1.r
        pix[i + 1] = c1.g
        pix[i + 2] = c1.b
        pix[i + 3] = c1.a
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        var r = UInt32(c.r)
        var g = UInt32(c.g)
        var b = UInt32(c.b)
        var a = UInt32(c.a)
        if (a != 0 && a != 0xffff) {
            r = (r * 0xffff) / a
            g = (g * 0xffff) / a
            b = (b * 0xffff) / a
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(r >> 8)
        pix[i + 1] = UInt8(g >> 8)
        pix[i + 2] = UInt8(b >> 8)
        pix[i + 3] = UInt8(a >> 8)
    }

    /**
     * 设置某坐标像素NRGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of NRGBAC
     */
    @OverflowWrapping
    public func setNRGBA(x: Int64, y: Int64, c: NRGBAC) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = c.r
        pix[i + 1] = c.g
        pix[i + 2] = c.b
        pix[i + 3] = c.a
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return NRGBA()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        NRGBA(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        if (rect.empty()) {
            return true
        }
        var i0 = 3
        var i1 = rect.dx() * 4
        for (y in rect.min.y..rect.max.y) {
            for (i in i0..i1 : 4) {
                if (pix[i] != 0xff) {
                    return false
                }
            }
            i0 += stride
            i1 += stride
        }
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("NRGBA")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/**
 * The class is NRGBA64 inherited from RGBA64ImageI & ImageT
 * @author changeden
 */
public class NRGBA64 <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(8, r, "NRGBA64"), {_ => 0}), 8 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return NRGBAModel
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
    public func at(x: Int64, y: Int64): Color {
        nrgba64At(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        let (r, g, b, a) = nrgba64At(x, y).rgba()
        RGBA64C(UInt16(r), UInt16(g), UInt16(b), UInt16(a))
    }

    /**
     * 获取某坐标像素64位NRGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of NRGBA64C
     */
    public func nrgba64At(x: Int64, y: Int64): NRGBA64C {
        if (!Point(x, y).isIn(rect)) {
            return NRGBA64C()
        }
        let i = pixOffset(x, y)
        NRGBA64C(
            (UInt16(pix[i]) << 8) | UInt16(pix[i + 1]),
            (UInt16(pix[i + 2]) << 8) | UInt16(pix[i + 3]),
            (UInt16(pix[i + 4]) << 8) | UInt16(pix[i + 5]),
            (UInt16(pix[i + 6]) << 8) | UInt16(pix[i + 7])
        )
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 8
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        let c1 = (NRGBA64Model.convert(c) as NRGBA64C).getOrThrow()
        pix[i] = UInt8(c1.r >> 8)
        pix[i + 1] = UInt8(c1.r)
        pix[i + 2] = UInt8(c1.g >> 8)
        pix[i + 3] = UInt8(c1.g)
        pix[i + 4] = UInt8(c1.b >> 8)
        pix[i + 5] = UInt8(c1.b)
        pix[i + 6] = UInt8(c1.a >> 8)
        pix[i + 7] = UInt8(c1.a)
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        var r = UInt32(c.r)
        var g = UInt32(c.g)
        var b = UInt32(c.b)
        var a = UInt32(c.a)
        if (a != 0 && a != 0xffff) {
            r = (r * 0xffff) / a
            g = (g * 0xffff) / a
            b = (b * 0xffff) / a
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(r >> 8)
        pix[i + 1] = UInt8(r)
        pix[i + 2] = UInt8(g >> 8)
        pix[i + 3] = UInt8(g)
        pix[i + 4] = UInt8(b >> 8)
        pix[i + 5] = UInt8(b)
        pix[i + 6] = UInt8(a >> 8)
        pix[i + 7] = UInt8(a)
    }

    /**
     * 设置某坐标像素64位NRGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of NRGBA64C
     */
    @OverflowWrapping
    public func setNRGBA64(x: Int64, y: Int64, c: NRGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(c.r >> 8)
        pix[i + 1] = UInt8(c.r)
        pix[i + 2] = UInt8(c.g >> 8)
        pix[i + 3] = UInt8(c.g)
        pix[i + 4] = UInt8(c.b >> 8)
        pix[i + 5] = UInt8(c.b)
        pix[i + 6] = UInt8(c.a >> 8)
        pix[i + 7] = UInt8(c.a)
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return NRGBA64()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        NRGBA64(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        if (rect.empty()) {
            return true
        }
        var i0 = 6
        var i1 = rect.dx() * 8
        for (y in rect.min.y..rect.max.y) {
            for (i in i0..i1 : 8) {
                if (pix[i] != 0xff || pix[i + 1] != 0xff) {
                    return false
                }
            }
            i0 += stride
            i1 += stride
        }
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("NRGBA64")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/**
 * The class is Alpha inherited from RGBA64ImageI & ImageT
 * @author changeden
 */
public class Alpha <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(1, r, "Alpha"), {_ => 0}), 1 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return AlphaModel
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
    public func at(x: Int64, y: Int64): Color {
        alphaAt(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        var a = UInt16(alphaAt(x, y).a)
        a |= a << 8
        RGBA64C(a, a, a, a)
    }

    /**
     * 获取某坐标像素Alpha颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of AlphaC
     */
    public func alphaAt(x: Int64, y: Int64): AlphaC {
        if (!Point(x, y).isIn(rect)) {
            return AlphaC()
        }
        let i = pixOffset(x, y)
        AlphaC(pix[i])
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 1
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = (AlphaModel.convert(c) as AlphaC).getOrThrow().a
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(c.a >> 8)
    }

    /**
     * 设置某坐标像素Alpha颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of AlphaC
     */
    @OverflowWrapping
    public func setAlpha(x: Int64, y: Int64, c: AlphaC) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = c.a
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return Alpha()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        Alpha(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        if (rect.empty()) {
            return true
        }
        var i0 = 0
        var i1 = rect.dx()
        for (_ in rect.min.y..rect.max.y) {
            for (i in i0..i1) {
                if (pix[i] != 0xff) {
                    return false
                }
            }
            i0 += stride
            i1 += stride
        }
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Alpha")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/**
 * The class is Alpha16 inherited from RGBA64ImageI & ImageT
 * @author changeden
 */
public class Alpha16 <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(2, r, "Alpha16"), {_ => 0}), 2 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return Alpha16Model
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
    public func at(x: Int64, y: Int64): Color {
        alpha16At(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        var a = alpha16At(x, y).a
        RGBA64C(a, a, a, a)
    }

    /**
     * 获取某坐标像素16位Alpha颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Alpha16C
     */
    public func alpha16At(x: Int64, y: Int64): Alpha16C {
        if (!Point(x, y).isIn(rect)) {
            return Alpha16C()
        }
        let i = pixOffset(x, y)
        Alpha16C((UInt16(pix[i]) << 8) | UInt16(pix[i + 1]))
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 2
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        let c1 = (Alpha16Model.convert(c) as Alpha16C).getOrThrow()
        pix[i] = UInt8(c1.a >> 8)
        pix[i + 1] = UInt8(c1.a)
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(c.a >> 8)
        pix[i + 1] = UInt8(c.a)
    }

    /**
     * 设置某坐标像素16位ALPHA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Alpha16C
     */
    @OverflowWrapping
    public func setAlpha16(x: Int64, y: Int64, c: Alpha16C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(c.a >> 8)
        pix[i + 1] = UInt8(c.a)
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return Alpha16()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        Alpha16(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        if (rect.empty()) {
            return true
        }
        var i0 = 0
        var i1 = rect.dx() * 2
        for (_ in rect.min.y..rect.max.y) {
            for (i in i0..i1 : 2) {
                if (pix[i] != 0xff || pix[i + 1] != 0xff) {
                    return false
                }
            }
            i0 += stride
            i1 += stride
        }
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Alpha16")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/**
 * The class is Gray inherited from RGBA64ImageI & ImageT
 * @author changeden
 */
public class Gray <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(1, r, "Gray"), {_ => 0}), 1 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return GrayModel
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
    public func at(x: Int64, y: Int64): Color {
        grayAt(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        var a = UInt16(grayAt(x, y).y)
        a |= a << 8
        RGBA64C(a, a, a, 0xffff)
    }

    /**
     * 获取某坐标像素Gray颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of GrayC
     */
    public func grayAt(x: Int64, y: Int64): GrayC {
        if (!Point(x, y).isIn(rect)) {
            return GrayC()
        }
        let i = pixOffset(x, y)
        GrayC(pix[i])
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 1
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = (GrayModel.convert(c) as GrayC).getOrThrow().y
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let gray = (19595 * UInt32(c.r) + 38470 * UInt32(c.g) + 7471 * UInt32(c.b) + ((1 << 15)) >> 24)
        let i = pixOffset(x, y)
        pix[i] = UInt8(gray)
    }

    /**
     * 设置某坐标像素Gray颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of GrayC
     */
    @OverflowWrapping
    public func setGray(x: Int64, y: Int64, c: GrayC) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = c.y
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return Gray()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        Gray(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Gray")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/**
 * The class is Gray16 inherited from RGBA64ImageI & ImageT
 * @author changeden
 */
public class Gray16 <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(2, r, "Gray16"), {_ => 0}), 2 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return Gray16Model
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
    public func at(x: Int64, y: Int64): Color {
        gray16At(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        var a = gray16At(x, y).y
        RGBA64C(a, a, a, 0xffff)
    }

    /**
     * 获取某坐标像素16位Gray颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Gray16C
     */
    public func gray16At(x: Int64, y: Int64): Gray16C {
        if (!Point(x, y).isIn(rect)) {
            return Gray16C()
        }
        let i = pixOffset(x, y)
        Gray16C((UInt16(pix[i]) << 8) | UInt16(pix[i + 1]))
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 2
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        let c1 = (Gray16Model.convert(c) as Gray16C).getOrThrow()
        pix[i] = UInt8(c1.y >> 8)
        pix[i + 1] = UInt8(c1.y)
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(c.a >> 8)
        pix[i + 1] = UInt8(c.a)
    }

    /**
     * 设置某坐标像素16位Gray颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Gray16C
     */
    @OverflowWrapping
    public func setGray16(x: Int64, y: Int64, c: Gray16C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(c.y >> 8)
        pix[i + 1] = UInt8(c.y)
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return Gray16()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        Gray16(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Gray16")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/**
 * The class is CMYK inherited from RGBA64ImageI & ImageT
 * @author changeden
 */
public class CMYK <: RGBA64ImageI & ImageT {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     */
    public init(r: Rectangle) {
        this(Array<UInt8>(pixelBufferLength(8, r, "CMYK"), {_ => 0}), 8 * r.dx(), r)
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return CMYKModel
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
    public func at(x: Int64, y: Int64): Color {
        cmykAt(x, y)
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        let (r, g, b, a) = cmykAt(x, y).rgba()
        RGBA64C(UInt16(r), UInt16(g), UInt16(b), UInt16(a))
    }

    /**
     * 获取某坐标像素CMYK颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of CMYK
     */
    public func cmykAt(x: Int64, y: Int64): colorCMYK {
        if (!Point(x, y).isIn(rect)) {
            return colorCMYK()
        }
        let i = pixOffset(x, y)
        let rgba = colorCMYK()
        rgba.c = pix[i]
        rgba.m = pix[i + 1]
        rgba.y = pix[i + 2]
        rgba.k = pix[i + 3]
        rgba
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 4
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        let c1 = (CMYKModel.convert(c) as colorCMYK).getOrThrow()
        pix[i] = c1.c
        pix[i + 1] = c1.m
        pix[i + 2] = c1.y
        pix[i + 3] = c1.k
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let (cc, mm, yy, kk) = RGBToCMYK(UInt8(c.r >> 8), UInt8(c.g >> 8), UInt8(c.b >> 8))
        let i = pixOffset(x, y)
        pix[i] = cc
        pix[i + 1] = mm
        pix[i + 2] = yy
        pix[i + 3] = kk
    }

    /**
     * 设置某坐标像素CMYK颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of CMYK
     */
    @OverflowWrapping
    public func setCMYK(x: Int64, y: Int64, c: colorCMYK) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = c.c
        pix[i + 1] = c.m
        pix[i + 2] = c.y
        pix[i + 3] = c.k
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return CMYK()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        CMYK(pix[i..pix.size], stride, rect)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("CMYK")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}

/**
 * The class is Paletted inherited from RGBA64ImageI & ImageT & PalettedImage
 * @author changeden
 */
public class Paletted <: RGBA64ImageI & ImageT & PalettedImage {
    /** 像素信息 */
    public var pix: Array<UInt8>

    /** 每像素信息位数 */
    public var stride: Int64 = 0

    /** 图片尺寸边界 */
    public var rect: Rectangle = Rectangle()

    /** 调色器 */
    public var palette: Palette = Palette()

    /**
     * The Function is init constructor
     *
     */
    public init() {
        this.pix = []
    }

    /**
     * The Function is init constructor
     *
     * @param pix of Array<UInt8> 像素信息
     * @param stride of Int64 每像素信息位数
     * @param rect of Rectangle 图片尺寸边界
     * @param palette of Palette 调色器
     */
    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle, palette: Palette) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
        this.palette = palette
    }

    /**
     * The Function is init constructor
     *
     * @param r of Rectangle 图片尺寸边界
     * @param palette of Palette 调色器
     */
    public init(r: Rectangle, palette: Palette) {
        this(Array<UInt8>(pixelBufferLength(1, r, "Paletted"), {_ => 0}), 1 * r.dx(), r, palette)
    }

    /**
     * The Function is init constructor
     *
     * @param palette of Palette 调色器
     */
    public init(palette: Palette) {
        this.pix = []
        this.palette = palette
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return palette
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
    public func at(x: Int64, y: Int64): Color {
        if (palette.buf.size == 0) {
            return nilColor
        }
        if (!Point(x, y).isIn(rect)) {
            return palette.buf[0]
        }
        let i = pixOffset(x, y)
        palette.buf[Int64(pix[i])]
    }

    /**
     * 获取某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        if (palette.buf.size == 0) {
            return RGBA64C()
        }
        let c: Color = if (Point(x, y).isIn(rect)) {
            let i = pixOffset(x, y)
            palette.buf[Int64(pix[i])]
        } else {
            palette.buf[0]
        }
        let (r, g, b, a) = c.rgba()
        RGBA64C(UInt16(r), UInt16(g), UInt16(b), UInt16(a))
    }

    /**
     * 获取某坐标像素信息起始位
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Int64
     */
    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 1
    }

    /**
     * 设置某坐标像素颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of Color
     */
    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(palette.index(c))
    }

    /**
     * 设置某坐标像素64位RGBA颜色
     *
     * @param x of Int64
     * @param y of Int64
     * @param c of RGBA64C
     */
    @OverflowWrapping
    public func setRGBA64(x: Int64, y: Int64, c: RGBA64C) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = UInt8(palette.index(c))
    }

    /**
     * 获取某坐标像素字节码
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of UInt8
     */
    public func colorIndexAt(x: Int64, y: Int64): UInt8 {
        if (!Point(x, y).isIn(rect)) {
            return 0
        }
        let i = pixOffset(x, y)
        pix[i]
    }

    /**
     * 设置某坐标像素字节码
     *
     * @param x of Int64
     * @param y of Int64
     * @param index of UInt8
     */
    public func setColorIndex(x: Int64, y: Int64, index: UInt8) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = index
    }

    /**
     * 获取某区域边界的图片
     *
     * @param r of Rectangle
     *
     * @return Type of Image
     */
    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return Paletted(palette)
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        Paletted(pix[i..pix.size], stride, this.rect.intersect(rect), palette)
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        let present = Array<Bool>(256, repeat: false)
        var i0 = 0
        var i1 = rect.dx()
        for (_ in rect.min.y..rect.max.y) {
            for (c in pix[i0..i1]) {
                present[Int64(c)] = true
            }
            i0 += stride
            i1 += stride
        }
        for (i in 0..palette.buf.size) {
            let c = palette.buf[i]
            if (!present[i]) {
                continue
            }
            let (_, _, _, a) = c.rgba()
            if (a != 0xffff) {
                return false
            }
        }
        return true
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Paletted")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
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
}
