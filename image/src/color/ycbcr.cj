/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about YCbCr type picture color definition.
 */

package image.color

/**
 * The Function is RGBToYCbCr
 *
 * @param r of UInt8
 * @param g of UInt8
 * @param b of UInt8
 *
 * @return Type of (UInt8, UInt8, UInt8)
 */
@OverflowWrapping
public func RGBToYCbCr(r: UInt8, g: UInt8, b: UInt8): (UInt8, UInt8, UInt8) {
    let r1 = Int32(r)
    let g1 = Int32(g)
    let b1 = Int32(b)

    let yy = (19595 * r1 + 38470 * g1 + 7471 * b1 + (1 << 15)) >> 16

    var cb = -11056 * r1 - 21712 * g1 + 32768 * b1 + (257 << 15)
    if ((UInt32(cb) & 0xff000000) == 0) {
        cb = cb >> 16
    } else {
        cb = !(cb >> 31)
    }

    var cr = 32768 * r1 - 27440 * g1 - 5328 * b1 + (257 << 15)
    if ((UInt32(cr) & 0xff000000) == 0) {
        cr >>= 16
    } else {
        cr = !(cr >> 31)
    }

    (UInt8(yy), UInt8(cb), UInt8(cr))
}

/**
 * The Function is YCbCrToRGB
 *
 * @param y of UInt8
 * @param cb of UInt8
 * @param cr of UInt8
 *
 * @return Type of (UInt8, UInt8, UInt8)
 */
@OverflowWrapping
public func YCbCrToRGB(y: UInt8, cb: UInt8, cr: UInt8): (UInt8, UInt8, UInt8) {
    let yy1 = Int32(y) * 0x10101
    let cb1 = Int32(cb) - 128
    let cr1 = Int32(cr) - 128

    var r = yy1 + 91881 * cr1
    if ((UInt32(r) & 0xff000000) == 0) {
        r >>= 16
    } else {
        r = !(r >> 31)
    }

    var g = yy1 - 22554 * cb1 - 46802 * cr1
    if ((UInt32(g) & 0xff000000) == 0) {
        g >>= 16
    } else {
        g = !(g >> 31)
    }

    var b = yy1 + 116130 * cb1
    if ((UInt32(b) & 0xff000000) == 0) {
        b >>= 16
    } else {
        b = !(b >> 31)
    }

    (UInt8(r), UInt8(g), UInt8(b))
}

/**
 * The class is YCbCr inherited from Color
 * @author changeden
 */
public open class YCbCr <: Color {
    /** var member y type is UInt8 */
    public var y: UInt8 = 0

    /** var member cb type is UInt8 */
    public var cb: UInt8 = 0

    /** var member cr type is UInt8 */
    public var cr: UInt8 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param y of UInt8
     * @param cb of UInt8
     * @param cr of UInt8
     */
    public init(y: UInt8, cb: UInt8, cr: UInt8) {
        this.y = y
        this.cb = cb
        this.cr = cr
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    @OverflowWrapping
    public open func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        let yy1 = Int32(y) * 0x10101
        let cb1 = Int32(cb) - 128
        let cr1 = Int32(cr) - 128

        var r = yy1 + 91881 * cr1
        if ((UInt32(r) & 0xff000000) == 0) {
            r >>= 8
        } else {
            r = (!(r >> 31)) & 0xffff
        }

        var g = yy1 - 22554 * cb1 - 46802 * cr1
        if ((UInt32(g) & 0xff000000) == 0) {
            g >>= 8
        } else {
            g = (!(g >> 31)) & 0xffff
        }

        var b = yy1 + 116130 * cb1
        if ((UInt32(b) & 0xff000000) == 0) {
            b >>= 8
        } else {
            b = (!(b >> 31)) & 0xffff
        }

        (UInt32(r), UInt32(g), UInt32(b), 0xffff)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public open func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("YCbCr".hashCode())
        dfh.write(y.hashCode())
        dfh.write(cb.hashCode())
        dfh.write(cr.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public open func toString(): String {
        "[y=${y} cb=${cb} cr=${cr}]"
    }
}

/** let member YCbCrModel type is Model */
public let YCbCrModel: Model = ModelFunc(yCbCrModel, "YcbCr")

/*
 * The Function is yCbCrModel
 *
 * @param c of Color
 *
 * @return Type of Color
 */
func yCbCrModel(c: Color): Color {
    if (c is YCbCr) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    var (y, u, v) = RGBToYCbCr(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8))
    let rgba = YCbCr()
    rgba.y = UInt8(r >> 8)
    rgba.cb = UInt8(g >> 8)
    rgba.cr = UInt8(b >> 8)
    rgba
}

/**
 * The class is NYCbCrA inherited from YCbCr
 * @author changeden
 */
public class NYCbCrA <: YCbCr {
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
     * @param c of YCbCr
     * @param a of UInt8
     */
    public init(c: YCbCr, a: UInt8) {
        this.y = c.y
        this.cb = c.cb
        this.cr = c.cr
        this.a = a
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    @OverflowWrapping
    public override func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        let yy1 = Int32(y) * 0x10101
        let cb1 = Int32(cb) - 128
        let cr1 = Int32(cr) - 128

        var r = yy1 + 91881 * cr1
        if ((UInt32(r) & 0xff000000) == 0) {
            r >>= 8
        } else {
            r = (!(r >> 31)) & 0xffff
        }

        var g = yy1 - 22554 * cb1 - 46802 * cr1
        if ((UInt32(g) & 0xff000000) == 0) {
            g >>= 8
        } else {
            g = (!(g >> 31)) & 0xffff
        }

        var b = yy1 + 116130 * cb1
        if ((UInt32(b) & 0xff000000) == 0) {
            b >>= 8
        } else {
            b = (!(b >> 31)) & 0xffff
        }

        var a = UInt32(a) * 0x101

        (UInt32(r) * a / 0xffff, UInt32(g) * a / 0xffff, UInt32(b) * a / 0xffff, a)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public override func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("NYCbCrA".hashCode())
        dfh.write(y.hashCode())
        dfh.write(cb.hashCode())
        dfh.write(cr.hashCode())
        dfh.write(a.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[y=${y} cb=${cb} cr=${cr} a=${a}]"
    }
}

/** let member NYCbCrAModel type is Model */
public let NYCbCrAModel: Model = ModelFunc(nYCbCrAModel, "NYCbCr")

/**
 * The Function is nYCbCrAModel
 *
 * @param c of Color
 *
 * @return Type of Color
 */
public func nYCbCrAModel(c: Color): Color {
    if (c is NYCbCrA) {
        return c
    } else if (c is YCbCr) {
        return NYCbCrA((c as YCbCr).getOrThrow(), 0xff)
    }
    var (r, g, b, a) = c.rgba()

    if (a != 0) {
        r = (r * 0xffff) / a
        g = (g * 0xffff) / a
        b = (b * 0xffff) / a
    }

    var (y, u, v) = RGBToYCbCr(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8))
    var rgba = YCbCr()
    rgba.y = y
    rgba.cb = u
    rgba.cr = v
    return NYCbCrA(rgba, UInt8(a >> 8))
}

/**
 * The Function is RGBToCMYK
 *
 * @param r of UInt8
 * @param g of UInt8
 * @param b of UInt8
 *
 * @return Type of (UInt8, UInt8, UInt8, UInt8)
 */
public func RGBToCMYK(r: UInt8, g: UInt8, b: UInt8): (UInt8, UInt8, UInt8, UInt8) {
    let rr = UInt32(r)
    let gg = UInt32(g)
    let bb = UInt32(b)
    var w = rr
    if (w < gg) {
        w = gg
    }
    if (w < bb) {
        w = bb
    }
    if (w == 0) {
        return (0, 0, 0, 0xff)
    }
    let c = (w - rr) * 0xff / w
    let m = (w - gg) * 0xff / w
    let y = (w - bb) * 0xff / w
    return (UInt8(c), UInt8(m), UInt8(y), UInt8(0xff - w))
}

/**
 * The Function is CMYKToRGB
 *
 * @param c of UInt8
 * @param m of UInt8
 * @param y of UInt8
 * @param k of UInt8
 *
 * @return Type of (UInt8, UInt8, UInt8)
 */
public func CMYKToRGB(c: UInt8, m: UInt8, y: UInt8, k: UInt8): (UInt8, UInt8, UInt8) {
    let w = 0xffff - UInt32(k) * 0x101
    let r = (0xffff - UInt32(c) * 0x101) * w / 0xffff
    let g = (0xffff - UInt32(m) * 0x101) * w / 0xffff
    let b = (0xffff - UInt32(y) * 0x101) * w / 0xffff
    return (UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8))
}

/**
 * The class is CMYK inherited from Color
 * @author changeden
 */
public class CMYK <: Color {
    /** var member c type is UInt8 */
    public var c: UInt8 = 0

    /** var member m type is UInt8 */
    public var m: UInt8 = 0

    /** var member y type is UInt8 */
    public var y: UInt8 = 0

    /** var member k type is UInt8 */
    public var k: UInt8 = 0

    public init() {}

    public init(c: UInt8, m: UInt8, y: UInt8, k: UInt8) {
        this.c = c
        this.m = m
        this.y = y
        this.k = k
    }

    /**
     * The Function is rgba
     *
     * @return Type of (UInt32, UInt32, UInt32, UInt32)
     */
    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        let w = 0xffff - UInt32(k) * 0x101
        let r = (0xffff - UInt32(c) * 0x101) * w / 0xffff
        let g = (0xffff - UInt32(m) * 0x101) * w / 0xffff
        let b = (0xffff - UInt32(y) * 0x101) * w / 0xffff
        return (r, g, b, 0xffff)
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("CMYK".hashCode())
        dfh.write(c.hashCode())
        dfh.write(m.hashCode())
        dfh.write(y.hashCode())
        dfh.write(k.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "[c=${c} m=${m} y=${y} k=${k}]"
    }
}

/** let member CMYKModel type is Model */
public let CMYKModel: Model = ModelFunc(cmykModel, "CMYK")

/*
 * The Function is cmykModel
 *
 * @param c of Color
 *
 * @return Type of Color
 */
func cmykModel(c: Color): Color {
    if (c is CMYK) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    var (cc, mm, yy, kk) = RGBToCMYK(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8))
    let rgba = CMYK()
    rgba.c = cc
    rgba.m = mm
    rgba.y = yy
    rgba.k = kk
    rgba
}
