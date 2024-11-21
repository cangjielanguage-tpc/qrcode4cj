/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about: Base color definition.
 */

package image.image

import image.color.*
import image.*
import image.internals.model.*

/** let member Black */
public let Black = Uniform(Black)

/** let member White */
public let White = Uniform(White)

/** let member Transparent */
public let Transparent = Uniform(Transparent)

/** let member Opaque */
public let Opaque = Uniform(Opaque)

/**
 * 通用图片
 * @author changeden
 */
public class Uniform <: RGBA64Image & Image & Opaquer & Color & Model {
    /** 颜色 */
    public var c: Color

    /**
     * The Function is init constructor
     *
     * @param c of Color 颜色
     */
    public init(c: Color) {
        this.c = c
    }

    /**
     * 获取颜色的RGBA色通
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        c.rgba()
    }

    /**
     * 获取颜色模型
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        this
    }

    /**
     * 转换
     *
     * @param c of Color
     *
     * @return Type of Color
     */
    public func convert(c: Color): Color {
        c
    }

    /**
     * 获取图片尺寸边界
     *
     * @return Type of Rectangle
     */
    public func bounds(): Rectangle {
        Rectangle(-1000000000, -1000000000, 1000000000, 1000000000)
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
        return c
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
        let (r, g, b, a) = c.rgba()
        RGBA64C(UInt16(r), UInt16(g), UInt16(b), UInt16(a))
    }

    /**
     * 是否不透明
     *
     * @return Type of Bool
     */
    public func opaque(): Bool {
        let (_, _, _, a) = c.rgba()
        a == 0xffff
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        let (r, g, b, a) = c.rgba()
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Uniform")
        dfh.write(r.hashCode())
        dfh.write(g.hashCode())
        dfh.write(b.hashCode())
        dfh.write(a.hashCode())
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
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "Uniform"
    }
}
