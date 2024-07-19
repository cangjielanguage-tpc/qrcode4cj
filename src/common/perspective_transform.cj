/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.common

/**
 * This class implements a perspective transform in two dimensions. Given four source and four
 * destination points, it will compute the transformation implied between them. The code is based
 * directly upon section 3.4.2 of George Wolberg's "Digital Image Warping"; see pages 54-56.
 */
public class PerspectiveTransform {
    public let a11: Float64
    public let a12: Float64
    public let a13: Float64
    public let a21: Float64
    public let a22: Float64
    public let a23: Float64
    public let a31: Float64
    public let a32: Float64
    public let a33: Float64

    init(
        a11: Float64,
        a21: Float64,
        a31: Float64,
        a12: Float64,
        a22: Float64,
        a32: Float64,
        a13: Float64,
        a23: Float64,
        a33: Float64
    ) {
        this.a11 = a11
        this.a12 = a12
        this.a13 = a13
        this.a21 = a21
        this.a22 = a22
        this.a23 = a23
        this.a31 = a31
        this.a32 = a32
        this.a33 = a33
    }

    public static func quadrilateralToQuadrilateral(
        x0: Float64,
        y0: Float64,
        x1: Float64,
        y1: Float64,
        x2: Float64,
        y2: Float64,
        x3: Float64,
        y3: Float64,
        x0p: Float64,
        y0p: Float64,
        x1p: Float64,
        y1p: Float64,
        x2p: Float64,
        y2p: Float64,
        x3p: Float64,
        y3p: Float64
    ): PerspectiveTransform {
        let qToS = quadrilateralToSquare(x0, y0, x1, y1, x2, y2, x3, y3)
        let sToQ = squareToQuadrilateral(x0p, y0p, x1p, y1p, x2p, y2p, x3p, y3p)

        return sToQ.times(qToS)
    }

    public func transformPoints(points: Array<Float64>) {
        for (i in 0..points.size : 2) {
            let x = points[i]
            let y = points[i + 1]
            let denominator = a13 * x + a23 * y + a33
            points[i] = (a11 * x + a21 * y + a31) / denominator
            points[i + 1] = (a12 * x + a22 * y + a32) / denominator
        }
    }

    public static func squareToQuadrilateral(
        x0: Float64,
        y0: Float64,
        x1: Float64,
        y1: Float64,
        x2: Float64,
        y2: Float64,
        x3: Float64,
        y3: Float64
    ): PerspectiveTransform {
        let dx3 = x0 - x1 + x2 - x3
        let dy3 = y0 - y1 + y2 - y3
        if (dx3 == 0.0 && dy3 == 0.0) {
            PerspectiveTransform(
                x1 - x0,
                x2 - x1,
                x0,
                y1 - y0,
                y2 - y1,
                y0,
                0.0,
                0.0,
                1.0
            )
        } else {
            let dx1 = x1 - x2
            let dx2 = x3 - x2
            let dy1 = y1 - y2
            let dy2 = y3 - y2
            let denominator = dx1 * dy2 - dx2 * dy1
            let a13 = (dx3 * dy2 - dx2 * dy3) / denominator
            let a23 = (dx1 * dy3 - dx3 * dy1) / denominator

            PerspectiveTransform(
                x1 - x0 + a13 * x1,
                x3 - x0 + a23 * x3,
                x0,
                y1 - y0 + a13 * y1,
                y3 - y0 + a23 * y3,
                y0,
                a13,
                a23,
                1.0
            )
        }
    }

    public static func quadrilateralToSquare(
        x0: Float64,
        y0: Float64,
        x1: Float64,
        y1: Float64,
        x2: Float64,
        y2: Float64,
        x3: Float64,
        y3: Float64
    ): PerspectiveTransform {
        squareToQuadrilateral(x0, y0, x1, y1, x2, y2, x3, y3).buildAdjoint()
    }

    func buildAdjoint(): PerspectiveTransform {
        PerspectiveTransform(
            a22 * a33 - a23 * a32,
            a23 * a31 - a21 * a33,
            a21 * a32 - a22 * a31,
            a13 * a32 - a12 * a33,
            a11 * a33 - a13 * a31,
            a12 * a31 - a11 * a32,
            a12 * a23 - a13 * a22,
            a13 * a21 - a11 * a23,
            a11 * a22 - a12 * a21
        )
    }

    func times(other: PerspectiveTransform): PerspectiveTransform {
        PerspectiveTransform(
            a11 * other.a11 + a21 * other.a12 + a31 * other.a13,
            a11 * other.a21 + a21 * other.a22 + a31 * other.a23,
            a11 * other.a31 + a21 * other.a32 + a31 * other.a33,
            a12 * other.a11 + a22 * other.a12 + a32 * other.a13,
            a12 * other.a21 + a22 * other.a22 + a32 * other.a23,
            a12 * other.a31 + a22 * other.a32 + a32 * other.a33,
            a13 * other.a11 + a23 * other.a12 + a33 * other.a13,
            a13 * other.a21 + a23 * other.a22 + a33 * other.a23,
            a13 * other.a31 + a23 * other.a32 + a33 * other.a33
        )
    }
}
