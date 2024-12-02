/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about picture color
 */
package image.color

import std.collection.*

/**
 * The interface is Color inherited from Hashable & ToString
 * @author changeden
 */
public interface Color <: Hashable & ToString {
    /*
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    func rgba(): (UInt32, UInt32, UInt32, UInt32)
}

/** let member nilColor */
public let nilColor = NilColor()

/**
 * The class is NilColor inherited from Color
 * @author changeden
 */
public class NilColor <: Color {
    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        (0, 0, 0, 255)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("NilColor".hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[r=0 g=0 b=0]"
    }
}

/**
 * The class is RGBAC inherited from Color & ToString
 * @author changeden
 */
public class RGBAC <: Color & ToString {
    /** var member r type is UInt8 */
    public var r: UInt8 = 0
    /** var member g type is UInt8 */
    public var g: UInt8 = 0
    /** var member b type is UInt8 */
    public var b: UInt8 = 0
    /** var member a type is UInt8 */
    public var a: UInt8 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param r of UInt8
     * @param g of UInt8
     * @param b of UInt8
     * @param a of UInt8
     */
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        this.r = r
        this.g = g
        this.b = b
        this.a = a
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var r = UInt32(this.r)
        r |= r << 8
        var g = UInt32(this.g)
        g |= g << 8
        var b = UInt32(this.b)
        b |= b << 8
        var a = UInt32(this.a)
        a |= a << 8
        return (r, g, b, a)
    }

    public func rgba_origin(): (UInt8, UInt8, UInt8, UInt8) {
        return(r,g,b,a)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("RGBA".hashCode())
        dfh.write(r.hashCode())
        dfh.write(g.hashCode())
        dfh.write(b.hashCode())
        dfh.write(a.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[r=${r} g=${g} b=${b} a=${a}]"
    }
}

/**
 * The class is RGBA64C inherited from Color
 * @author changeden
 */
public class RGBA64C <: Color {
    /** var member r type is UInt16 */
    public var r: UInt16 = 0
    /** var member g type is UInt16 */
    public var g: UInt16 = 0
    /** var member b type is UInt16 */
    public var b: UInt16 = 0
    /** var member a type is UInt16 */
    public var a: UInt16 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param r of UInt16
     * @param g of UInt16
     * @param b of UInt16
     * @param a of UInt16
     */
    public init(r: UInt16, g: UInt16, b: UInt16, a: UInt16) {
        this.r = r
        this.g = g
        this.b = b
        this.a = a
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var r = UInt32(this.r)
        var g = UInt32(this.g)
        var b = UInt32(this.b)
        var a = UInt32(this.a)
        return (r, g, b, a)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("RGBA64".hashCode())
        dfh.write(r.hashCode())
        dfh.write(g.hashCode())
        dfh.write(b.hashCode())
        dfh.write(a.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[r=${r} g=${g} b=${b} a=${a}]"
    }
}

/**
 * The class is NRGBAC inherited from Color
 * @author changeden
 */
public class NRGBAC <: Color {
    /** var member r type is UInt8 */
    public var r: UInt8 = 0
    /** var member g type is UInt8 */
    public var g: UInt8 = 0
    /** var member b type is UInt8 */
    public var b: UInt8 = 0
    /** var member a type is UInt8 */
    public var a: UInt8 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param r of UInt8
     * @param g of UInt8
     * @param b of UInt8
     * @param a of UInt8
     */
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        this.r = r
        this.g = g
        this.b = b
        this.a = a
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var a = UInt32(this.a)
        var r = UInt32(this.r)
        r |= r << 8
        r *= a
        r /= 0xff
        var g = UInt32(this.g)
        g |= g << 8
        g *= a
        g /= 0xff
        var b = UInt32(this.b)
        b |= b << 8
        b *= a
        b /= 0xff
        a |= a << 8
        return (r, g, b, a)
    }

    public func rgba_origin(): (UInt8, UInt8, UInt8, UInt8) {
        return(r,g,b,a)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("NRGBA".hashCode())
        dfh.write(r.hashCode())
        dfh.write(g.hashCode())
        dfh.write(b.hashCode())
        dfh.write(a.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[r=${r} g=${g} b=${b} a=${a}]"
    }
}

/**
 * The class is NRGBA64C inherited from Color
 * @author changeden
 */
public class NRGBA64C <: Color {
    /** var member r type is UInt16 */
    public var r: UInt16 = 0
    /** var member g type is UInt16 */
    public var g: UInt16 = 0
    /** var member b type is UInt16 */
    public var b: UInt16 = 0
    /** var member a type is UInt16 */
    public var a: UInt16 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param r of UInt16
     * @param g of UInt16
     * @param b of UInt16
     * @param a of UInt16
     */
    public init(r: UInt16, g: UInt16, b: UInt16, a: UInt16) {
        this.r = r
        this.g = g
        this.b = b
        this.a = a
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var a = UInt32(this.a)
        var r = UInt32(this.r)
        r *= a
        r /= 0xff
        var g = UInt32(this.g)
        g *= a
        g /= 0xff
        var b = UInt32(this.b)
        b *= a
        b /= 0xff
        return (r, g, b, a)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("NRGBA64".hashCode())
        dfh.write(r.hashCode())
        dfh.write(g.hashCode())
        dfh.write(b.hashCode())
        dfh.write(a.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[r=${r} g=${g} b=${b} a=${a}]"
    }
}

/**
 * The class is AlphaC inherited from Color
 * @author changeden
 */
public class AlphaC <: Color {
    /** var member a type is UInt8 */
    public var a: UInt8 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param a of UInt8
     */
    public init(a: UInt8) {
        this.a = a
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var a = UInt32(a)
        a |= a << 8
        return (a, a, a, a)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("Alpha".hashCode())
        dfh.write(a.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[a=${a}]"
    }
}

/**
 * The class is Alpha16C inherited from Color
 * @author changeden
 */
public class Alpha16C <: Color {
    /** var member a type is UInt16 */
    public var a: UInt16 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param a of UInt16
     */
    public init(a: UInt16) {
        this.a = a
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var a = UInt32(a)
        return (a, a, a, a)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("Alpha16".hashCode())
        dfh.write(a.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[a=${a}]"
    }
}

/**
 * The class is GrayC inherited from Color
 * @author changeden
 */
public class GrayC <: Color {
    /** var member y type is UInt8 */
    public var y: UInt8 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param y of UInt8
     */
    public init(y: UInt8) {
        this.y = y
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var a = UInt32(y)
        a |= a << 8
        return (a, a, a, 0xffff)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("Gray".hashCode())
        dfh.write(y.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[y=${y}]"
    }
}

/**
 * The class is Gray16C inherited from Color
 * @author changeden
 */
public class Gray16C <: Color {
    /** var member y type is UInt16 */
    public var y: UInt16 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param y of UInt16
     */
    public init(y: UInt16) {
        this.y = y
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var a = UInt32(y)
        return (a, a, a, 0xffff)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("Gray16".hashCode())
        dfh.write(y.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[y=${y}]"
    }
}

/**
 * The interface is Model inherited from ToString
 * @author changeden
 */
public interface Model <: ToString {
    /*
     * The Function is convert
     *
     * @param c of Color
     *
     * @return Type of Color
     */
    func convert(c: Color): Color

    /*
     * The Function is ==
     *
     * @param m of Model
     *
     * @return Type of Bool
     */
    operator func ==(m: Model): Bool {
        toString() == m.toString()
    }
}

/**
 * The class is ModelFunc inherited from Model
 * @author changeden
 */
public class ModelFunc <: Model {
    /** var member modelName type is String */
    public var modelName: String = ""

    /** let member f type is (Color) -> Color */
    public let f: (Color) -> Color

    /**
     * The Function is init constructor
     *
     * @param f of (Color)->Color
     * @param modelName of String
     */
    public init(f: (Color) -> Color, modelName: String) {
        this.f = f
        this.modelName = modelName
    }

    /**
     * The Function is convert
     *
     * @param c of Color
     *
     * @return Type of Color
     */
    public func convert(c: Color): Color {
        return f(c)
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        modelName
    }
}

/** let member RGBAModel type is Model */
public let RGBAModel: Model = ModelFunc(rgbaModel, "RGBA")
/** let member RGBA64Model type is Model */
public let RGBA64Model: Model = ModelFunc(rgba64Model, "RGBA64")
/** let member NRGBAModel type is Model */
public let NRGBAModel: Model = ModelFunc(nrgbaModel, "NRGBA")
/** let member NRGBA64Model type is Model */
public let NRGBA64Model: Model = ModelFunc(nrgba64Model, "NRGBA64")
/** let member AlphaModel type is Model */
public let AlphaModel: Model = ModelFunc(alphaModel, "Alpha")
/** let member Alpha16Model type is Model */
public let Alpha16Model: Model = ModelFunc(alpha16Model, "Alpha16")
/** let member GrayModel type is Model */
public let GrayModel: Model = ModelFunc(grayModel, "Gray")
/** let member Gray16Model type is Model */
public let Gray16Model: Model = ModelFunc(gray16Model, "Gray16")

/**
 * The Function is rgbaModel
 *
 * @param c of Color
 *
 * @return Type of Color
 */
@OverflowWrapping
public func rgbaModel(c: Color): Color {
    if (c is RGBAC) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    RGBAC(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8), UInt8(a >> 8))
}

/**
 * The Function is rgba64Model
 *
 * @param c of Color
 *
 * @return Type of Color
 */
@OverflowWrapping
public func rgba64Model(c: Color): Color {
    if (c is RGBA64C) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    RGBA64C(UInt16(r), UInt16(g), UInt16(b), UInt16(a))
}

/**
 * The Function is nrgbaModel
 *
 * @param c of Color
 *
 * @return Type of Color
 */
@OverflowWrapping
public func nrgbaModel(c: Color): Color {
    if (c is NRGBAC) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    let rgba = NRGBAC()
    if (a == 0xffff) {
        rgba.r = UInt8(r >> 8)
        rgba.g = UInt8(g >> 8)
        rgba.b = UInt8(b >> 8)
        rgba.a = 0xff
        return rgba
    }
    if (a == 0) {
        return rgba
    }
    rgba.r = UInt8(((r * 0xffff) / a) >> 8)
    rgba.g = UInt8(((g * 0xffff) / a) >> 8)
    rgba.b = UInt8(((b * 0xffff) / a) >> 8)
    rgba.a = UInt8(a >> 8)
    rgba
}

/**
 * The Function is nrgba64Model
 *
 * @param c of Color
 *
 * @return Type of Color
 */
@OverflowWrapping
public func nrgba64Model(c: Color): Color {
    if (c is NRGBA64C) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    let rgba = NRGBA64C()
    if (a == 0xffff) {
        rgba.r = UInt16(r)
        rgba.g = UInt16(g)
        rgba.b = UInt16(b)
        rgba.a = 0xffff
        return rgba
    }
    if (a == 0) {
        return rgba
    }
    rgba.r = UInt16((r * 0xffff) / a)
    rgba.g = UInt16((g * 0xffff) / a)
    rgba.b = UInt16((b * 0xffff) / a)
    rgba.a = UInt16(a)
    rgba
}

/**
 * The Function is alphaModel
 *
 * @param c of Color
 *
 * @return Type of Color
 */
@OverflowWrapping
public func alphaModel(c: Color): Color {
    if (c is AlphaC) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    AlphaC(UInt8(a >> 8))
}

/**
 * The Function is alpha16Model
 *
 * @param c of Color
 *
 * @return Type of Color
 */
@OverflowWrapping
public func alpha16Model(c: Color): Color {
    if (c is Alpha16C) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    Alpha16C(UInt16(a))
}

/**
 * The Function is grayModel
 *
 * @param c of Color
 *
 * @return Type of Color
 */
@OverflowWrapping
public func grayModel(c: Color): Color {
    if (c is GrayC) {
        return c
    }
    var (r, g, b, _) = c.rgba()
    let y = (19595 * r + 38470 * g + 7471 * b + (1 << 15)) >> 24
    GrayC(UInt8(y))
}

/**
 * The Function is gray16Model
 *
 * @param c of Color
 *
 * @return Type of Color
 */
@OverflowWrapping
public func gray16Model(c: Color): Color {
    if (c is Gray16C) {
        return c
    }
    var (r, g, b, _) = c.rgba()
    let y = (19595 * r + 38470 * g + 7471 * b + (1 << 15)) >> 16
    Gray16C(UInt16(y))
}

/**
 * The class is Palette inherited from Model
 * @author changeden
 */
public class Palette <: Model {
    /** var member buf type is collection.ArrayList<Color> */
    public var buf: ArrayList<Color>

    /**
     * The Function is init constructor
     */
    public init() {
        this.buf = ArrayList<Color>()
    }

    /**
     * The Function is init constructor
     *
     * @param size of Int64
     */
    public init(size: Int64) {
        this(size, {_ => NilColor()})
    }

    /**
     * The Function is init constructor
     *
     * @param size of Int64
     * @param defColor of (Int64)->Color
     */
    public init(size: Int64, defColor: (Int64) -> Color) {
        this.buf = ArrayList<Color>(size, defColor)
    }

    /**
     * The Function is init constructor
     *
     * @param list of Array<color.Color>
     */
    public init(list: Array<Color>) {
        this.buf = ArrayList<Color>(list)
    }

    /**
     * The Function is index
     *
     * @param c of Color
     *
     * @return Type of Int64
     */
    public func index(c: Color): Int64 {
        var (cr, cg, cb, ca) = c.rgba()
        var ret = 0
        var bestSum = UInt32((1 << 32) - 1)
        for (i in 0..buf.size) {
            var v = buf[i]
            var (vr, vg, vb, va) = v.rgba()
            let sum = sqDiff(cr, vr) + sqDiff(cg, vg) + sqDiff(cb, vb) + sqDiff(ca, va)
            if (sum < bestSum) {
                if (sum == 0) {
                    return i
                }
                ret = i
                bestSum = sum
            }
        }
        ret
    }

    /**
     * The Function is convert
     *
     * @param c of Color
     *
     * @return Type of Color
     */
    public func convert(c: Color): Color {
        if (buf.size == 0) {
            return nilColor
        }
        buf[index(c)]
    }

    /**
     * The Function is size
     *
     * @return Type of Int64
     */
    public func size(): Int64 {
        this.buf.size
    }

    /**
     * The Function is []
     *
     * @param index of Int64
     *
     * @return Type of Color
     */
    public operator func [](index: Int64): Color {
        buf[index]
    }

    /**
     * The Function is []
     *
     * @param index of Int64
     * @param value of Color
     *
     * @return Type of Unit
     */
    public operator func [](index: Int64, value!: Color): Unit {
        this.buf[index] = value
    }

    /**
     * The Function is []
     *
     * @param range of Range<Int64>
     *
     * @return Type of Palette
     */
    public operator func [](range: Range<Int64>): Palette {
        let p = Palette()
        for (i in range) {
            p.buf.append(this[i])
        }
        p
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "Palette"
    }

    /**
     * The Function is append
     *
     * @param e of Color
     */
    public func append(e: Color) {
        buf.append(e)
    }

    /**
     * The Function is appendAll
     *
     * @param e of Collection<Color>
     */
    public func appendAll(e: Collection<Color>) {
        buf.appendAll(e)
    }
}

/*
 * The Function is sqDiff
 *
 * @param x of UInt32
 * @param y of UInt32
 *
 * @return Type of UInt32
 */
@OverflowWrapping
func sqDiff(x: UInt32, y: UInt32): UInt32 {
    let d = x - y
    return (d * d) >> 2
}

/** let member Black */
public let Black = Gray16C()
/** let member White */
public let White = Gray16C(0xffff)
/** let member Transparent */
public let Transparent = Alpha16C()
/** let member Opaque */
public let Opaque = Alpha16C(0xffff)
