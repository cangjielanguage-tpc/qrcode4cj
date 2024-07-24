/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common.detector

import std.math.*

/**
 * General math-related and numeric utility functions.
 */
public class MathUtils {
    private MathUtils() {}

    /**
     * Ends up being a bit faster than {@link Math#round(float)}. This merely rounds its
     * argument to the nearest int, where x.5 rounds up to x+1. Semantics of this shortcut
     * differ slightly from {@link Math#round(float)} in that half rounds down for negative
     * values. -2.5 rounds to -3, not -2. For purposes here it makes no difference.
     *
     * @param d real value to round
     * @return nearest {@code int}
     */
    public static func round(d: Float32): Int64 {
        if (d - Float32(Int64.Max) > -0.001) {
            return Int64.Max;
        } else if (d - Float32(Int64.Min) < 0.001) {
            return Int64.Min;
        } else if (d.isNaN()) {
            return 0;
        }
        var dd = 0.0f32
        if (d < 0.0f32) {
            dd = d - 0.5f32
        } else {
            dd = d + 0.5f32
        }
        return Int64(dd)
    }

    /**
     * @param aX point A x coordinate
     * @param aY point A y coordinate
     * @param bX point B x coordinate
     * @param bY point B y coordinate
     * @return Euclidean distance between points A and B
     */
    public static func distance(aX: Float32, aY: Float32, bX: Float32, bY: Float32): Float32 {
        let (xDiff, yDiff) = (aX - bX, aY - bY)
        return sqrt(xDiff * xDiff + yDiff * yDiff)
    }

    /**
     * @param aX point A x coordinate
     * @param aY point A y coordinate
     * @param bX point B x coordinate
     * @param bY point B y coordinate
     * @return Euclidean distance between points A and B
     */
    public static func distance(aX: Int64, aY: Int64, bX: Int64, bY: Int64): Float32 {
        let (xDiff, yDiff) = (aX - bX, aY - bY)
        return sqrt(Float32(xDiff * xDiff + yDiff * yDiff))
    }

    /**
     * @param array values to sum
     * @return sum of values in array
     */
    public static func sum(array: Array<Int64>): Int64 {
        var count = 0
        for (a in 0..array.size) {
            count += array[a]
        }
        return count
    }
}
