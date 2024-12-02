/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about Reactangle type definition.
 */
package image.internals.model
import image.color.*

/**
 * The class is Rectangle inherited from ToString & Hashable
 * @author changeden
 */
public class Rectangle <: ToString & Hashable {
    /** var member min type is Point */
    public var min: Point = Point()

    /** var member max type is Point */
    public var max: Point = Point()

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param min of Point
     * @param max of Point
     */
    public init(min: Point, max: Point) {
        this.min = min
        this.max = max
    }

    /**
     * The Function is init constructor
     *
     * @param x0 of Int64
     * @param y0 of Int64
     * @param x1 of Int64
     * @param y1 of Int64
     */
    public init(x0: Int64, y0: Int64, x1: Int64, y1: Int64) {
        var x2 = x0
        var x3 = x1
        if (x0 > x1) {
            x2 = x1
            x3 = x0
        }
        var y2 = y0
        var y3 = y1
        if (y0 > y1) {
            y2 = y1
            y3 = y0
        }
        min = Point(x2, y2)
        max = Point(x3, y3)
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        min.toString() + " - " + max.toString()
    }

    /**
     * The Function is dx
     *
     * @return Type of Int64
     */
    public func dx(): Int64 {
        max.x - min.x
    }

    /**
     * The Function is dy
     *
     * @return Type of Int64
     */
    public func dy(): Int64 {
        max.y - min.y
    }

    /**
     * The Function is size
     *
     * @return Type of Point
     */
    public func size(): Point {
        Point(max.x - min.x, max.y - min.y)
    }

    /**
     * The Function is +
     *
     * @param p of Point
     *
     * @return Type of Rectangle
     */
    public operator func +(p: Point): Rectangle {
        Rectangle(Point(min.x + p.x, min.y + p.y), Point(max.x + p.x, max.y + p.y))
    }

    /**
     * The Function is -
     *
     * @param p of Point
     *
     * @return Type of Rectangle
     */
    public operator func -(p: Point): Rectangle {
        Rectangle(Point(min.x - p.x, min.y - p.y), Point(max.x - p.x, max.y - p.y))
    }

    /**
     * The Function is ==
     *
     * @param s of Rectangle
     *
     * @return Type of Bool
     */
    public operator func ==(s: Rectangle): Bool {
        (min == s.min && max == s.max) || empty() && s.empty()
    }

    /**
     * The Function is inset
     *
     * @param n of Int64
     *
     * @return Type of Rectangle
     */
    public func inset(n: Int64): Rectangle {
        if (dx() < (2 * n)) {
            min.x = (min.x + max.x) / 2
            max.x = min.x
        } else {
            min.x += n
            max.x -= n
        }
        if (dy() < (2 * n)) {
            min.y = (min.y + max.y) / 2
            max.y = min.y
        } else {
            min.y += n
            max.y -= n
        }
        this
    }

    /**
     * The Function is intersect
     *
     * @param s of Rectangle
     *
     * @return Type of Rectangle
     */
    public func intersect(s: Rectangle): Rectangle {
        if (min.x < s.min.x) {
            min.x = s.min.x
        }
        if (min.y < s.min.y) {
            min.y = s.min.y
        }
        if (max.x > s.max.x) {
            max.x = s.max.x
        }
        if (max.y > s.max.y) {
            max.y = s.max.y
        }
        if (empty()) {
            return Rectangle()
        }
        this
    }

    /**
     * The Function is union
     *
     * @param s of Rectangle
     *
     * @return Type of Rectangle
     */
    public func union(s: Rectangle): Rectangle {
        if (empty()) {
            return s
        }
        if (s.empty()) {
            return this
        }
        if (min.x > s.min.x) {
            min.x = s.min.x
        }
        if (min.y > s.min.y) {
            min.y = s.min.y
        }
        if (max.x < s.max.x) {
            max.x = s.max.x
        }
        if (max.y < s.max.y) {
            max.y = s.max.y
        }
        this
    }

    /**
     * The Function is empty
     *
     * @return Type of Bool
     */
    public func empty(): Bool {
        min.x >= max.x || min.y >= max.y
    }

    /**
     * The Function is overlaps
     *
     * @param s of Rectangle
     *
     * @return Type of Bool
     */
    public func overlaps(s: Rectangle): Bool {
        !empty() && !s.empty() && min.x < s.max.x && s.min.x < max.x && min.y < s.max.y && s.min.y < max.y
    }

    /**
     * The Function is isIn
     *
     * @param s of Rectangle
     *
     * @return Type of Bool
     */
    public func isIn(s: Rectangle): Bool {
        if (empty()) {
            return true
        }
        s.min.x <= min.x && max.x <= s.max.x && s.min.y <= min.y && max.y <= s.max.y
    }

    /**
     * The Function is canon
     *
     * @return Type of Rectangle
     */
    public func canon(): Rectangle {
        if (max.x < min.x) {
            let t = min.x
            min.x = max.x
            max.x = t
        }
        if (max.y < min.y) {
            let t = min.y
            min.y = max.y
            max.y = t
        }
        this
    }

    /**
     * The Function is at
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of Color
     */
    public func at(x: Int64, y: Int64): Color {
        if (Point(x, y).isIn(this)) {
            return Opaque
        }
        return Transparent
    }

    /**
     * The Function is rgba64At
     *
     * @param x of Int64
     * @param y of Int64
     *
     * @return Type of color.RGBA64C
     */
    public func rgba64At(x: Int64, y: Int64): RGBA64C {
        if (Point(x, y).isIn(this)) {
            return RGBA64C(0xffff, 0xffff, 0xffff, 0xffff)
        }
        return RGBA64C()
    }

    /**
     * The Function is bounds
     *
     * @return Type of Rectangle
     */
    public func bounds(): Rectangle {
        this
    }

    /**
     * The Function is colorModel
     *
     * @return Type of Model
     */
    public func colorModel(): Model {
        return Alpha16Model
    }

    /**
     * The Function is hashCode
     *
     * @return Type of Int64
     */
    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Rectangle")
        dfh.write(min.hashCode())
        dfh.write(max.hashCode())
        return dfh.finish()
    }

    /**
     * The Function is clone
     *
     * @return Type of Rectangle
     */
    public func clone(): Rectangle {
        Rectangle(min.x, min.y, max.x, max.y)
    }
}
