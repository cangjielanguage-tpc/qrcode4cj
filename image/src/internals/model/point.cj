/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about Point type definition.
 */
package image.internals.model

/** let member nilPoint type is Point */
public let nilPoint: Point = NilPoint()

/**
 * The class is Point inherited from ToString & Hashable
 * @author changeden
 */
public open class Point <: ToString & Hashable {
    /** var member x type is Int64 */
    public var x: Int64 = 0
    /** var member y type is Int64 */
    public var y: Int64 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param x of Int64
     * @param y of Int64
     */
    public init(x: Int64, y: Int64) {
        this.x = x
        this.y = y
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        "(${x}, ${y})"
    }

    /**
     * The Function is +
     *
     * @param q of Point
     *
     * @return Type of Point
     */
    public operator func +(q: Point): Point {
        Point(x + q.x, y + q.y)
    }

    /**
     * The Function is -
     *
     * @param q of Point
     *
     * @return Type of Point
     */
    public operator func -(q: Point): Point {
        Point(x - q.x, y - q.y)
    }

    /**
     * The Function is *
     *
     * @param q of Point
     *
     * @return Type of Point
     */
    public operator func *(q: Point): Point {
        Point(x * q.x, y * q.y)
    }

    /**
     * The Function is /
     *
     * @param q of Point
     *
     * @return Type of Point
     */
    public operator func /(q: Point): Point {
        Point(x / q.x, y / q.y)
    }

    /**
     * The Function is %
     *
     * @param r of Rectangle
     *
     * @return Type of Point
     */
    public operator func %(r: Rectangle): Point {
        let w = r.dx()
        let h = r.dy()
        let p = this - r.min
        p.x = p.x % w
        if (p.x < 0) {
            p.x += w
        }
        p.y = p.y % h
        if (p.y < 0) {
            p.y += h
        }
        p + r.min
    }

    /**
     * The Function is ==
     *
     * @param q of Point
     *
     * @return Type of Bool
     */
    public operator func ==(q: Point): Bool {
        x == q.x && y == q.y
    }

    /**
     * The Function is !=
     *
     * @param q of Point
     *
     * @return Type of Bool
     */
    public operator func !=(q: Point): Bool {
        !(x == q.x && y == q.y)
    }

    /**
     * The Function is isIn
     *
     * @param r of Rectangle
     *
     * @return Type of Bool
     */
    public func isIn(r: Rectangle): Bool {
        r.min.x <= x && x < r.max.x && r.min.y <= y && y < r.max.y
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public open func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Point")
        dfh.write(x.hashCode())
        dfh.write(y.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is clone
     *
     * @return Type of Point
     */
    public func clone(): Point {
        Point(x, y)
    }
}

/**
 * The class is NilPoint inherited from Point
 * @author changeden
 */
public class NilPoint <: Point {
    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public override func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("NilPoint")
        dfh.write(x.hashCode())
        dfh.write(y.hashCode())
        return dfh.finish()
    }
}
