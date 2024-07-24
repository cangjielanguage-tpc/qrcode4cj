/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.common

import QRCode4cj.tools.floatToIntBits
import std.math.*

/**
 * <p>Encapsulates a point of interest in an image containing a barcode. Typically, this
 * would be the location of a finder pattern or the corner of the barcode, for example.</p>
 */
public open class ResultPoint {
    private var x: Float32 = 0.0
    private var y: Float32 = 0.0
    public var flag: Bool = false
    public init() {}
    public init(x: Float32, y: Float32) {
        this.x = x
        this.y = y
        this.flag = true
    }

    public func getX(): Float32 {
        return x
    }

    public func getY(): Float32 {
        return y
    }

    public func equals(other: ResultPoint): Bool {
        return x == other.x && y == other.y
    }

    public func hashCode(): Int64 {
        return 31 * floatToIntBits(x) + floatToIntBits(y)
    }

    public func toString(): String {
        return "(${x},${y})"
    }

    /**
     * Orders an array of three ResultPoints in an order [A,B,C] such that AB is less than AC
     * and BC is less than AC, and the angle between BC and BA is less than 180 degrees.
     *
     * @param patterns array of three {@code ResultPoint} to order
     */
    public static func orderBestPatterns(patterns: Array<ResultPoint>) {

        // Find distances between pattern centers
        let zeroOneDistance: Float32 = distance(patterns[0], patterns[1]);
        let oneTwoDistance: Float32 = distance(patterns[1], patterns[2]);
        let zeroTwoDistance: Float32 = distance(patterns[0], patterns[2]);

        var pointA: ResultPoint
        var pointB: ResultPoint
        var pointC: ResultPoint

        // Assume one closest to other two is B; A and C will just be guesses at first
        if (oneTwoDistance >= zeroOneDistance && oneTwoDistance >= zeroTwoDistance) {
            pointB = patterns[0]
            pointA = patterns[1]
            pointC = patterns[2]
        } else if (zeroTwoDistance >= oneTwoDistance && zeroTwoDistance >= zeroOneDistance) {
            pointB = patterns[1]
            pointA = patterns[0]
            pointC = patterns[2]
        } else {
            pointB = patterns[2]
            pointA = patterns[0]
            pointC = patterns[1]
        }

        // Use cross product to figure out whether A and C are correct or flipped.
        // This asks whether BC x BA has a positive z component, which is the arrangement
        // we want for A, B, C. If it's negative, then we've got it flipped around and
        // should swap A and C.
        if (crossProductZ(pointA, pointB, pointC) < 0.0) {
            let temp: ResultPoint = pointA
            pointA = pointC
            pointC = temp
        }

        patterns[0] = pointA
        patterns[1] = pointB
        patterns[2] = pointC
    }

    /**
     * @param pattern1 first pattern
     * @param pattern2 second pattern
     * @return distance between two points
     */
    public static func distance(pattern1: ResultPoint, pattern2: ResultPoint): Float32 {
        let (xDiff, yDiff) = (pattern1.x - pattern2.x, pattern1.y - pattern2.y)
        var num = sqrt(Float32(xDiff * xDiff + yDiff * yDiff))
        return num
    }

    /**
     * Returns the z component of the cross product between vectors BC and BA.
     */
    private static func crossProductZ(
        pointA: ResultPoint,
        pointB: ResultPoint,
        pointC: ResultPoint
    ): Float32 {
        let bX: Float32 = pointB.x;
        let bY: Float32 = pointB.y;
        var num = ((pointC.x - bX) * (pointA.y - bY)) - ((pointC.y - bY) * (pointA.x - bX))
        return num
    }
}
