/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package common.detector

import common.*

public class WhiteRectangleDetector {
    private static let INIT_SIZE = 10
    private static let CORR = 1

    private let image: BitMatrix
    private let height: Int64
    private let width: Int64
    private let leftInit: Int64
    private let rightInit: Int64
    private let downInit: Int64
    private let upInit: Int64

    public init(image: BitMatrix) {
        let xx = image.getWidth() / 2
        let yy = image.getHeight() / 2
        try {
            this.image = image
            height = image.getHeight()
            width = image.getWidth()
            let halfsize: Int64 = INIT_SIZE / 2
            leftInit = xx - halfsize
            rightInit = xx + halfsize
            upInit = yy - halfsize
            downInit = yy + halfsize
            if (upInit < 0 || leftInit < 0 || downInit >= height || rightInit >= width) {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance()
            }
        } catch (e: Exception) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }
    }

    /**
     * @param image the barcode image to find a rectangle in
     * @param initSize initial size of search area around center
     * @param x x position value of search center
     * @param y y position value of search center
     *
     * @throws Qrcoder4cjNotFoundException if image is too small to accommodate {@code initSize}
     */
    public init(image: BitMatrix, initSize: Int64, x: Int64, y: Int64) {
        try {
            this.image = image
            height = image.getHeight()
            width = image.getWidth()
            let halfsize: Int64 = Int64(initSize / 2)
            leftInit = x - halfsize
            rightInit = x + halfsize
            upInit = y - halfsize
            downInit = y + halfsize
            if (upInit < 0 || leftInit < 0 || downInit >= height || rightInit >= width) {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance()
            }
        } catch (e: Exception) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }
    }

    /**
     * Detects a candidate barcode-like rectangular region within an image. It
     * starts around the center of the image, increases the size of the candidate
     * region until it finds a white rectangular region.
     *
     * @return ResultPoint[] describing the corners of the rectangular
     * region. The first and last points are opposed on the diagonal, as
     * are the second and third. The first point will be the topmost point
     * and the last, the bottommost. The second point will be
     * leftmost and the third, the rightmost
     * @throws Qrcoder4cjNotFoundException if no Data Matrix Code can be found
     */
    public func detect(): Array<ResultPoint> {
        var left_ = leftInit
        var right_ = rightInit
        var up = upInit
        var down_ = downInit
        var sizeExceeded = false
        var aBlackPointFoundOnBorder_ = true

        var atLeastOneBlackPointFoundOnRight_ = false
        var atLeastOneBlackPointFoundOnBottom = false
        var atLeastOneBlackPointFoundOnLeft = false
        var atLeastOneBlackPointFoundOnTop = false

        while (aBlackPointFoundOnBorder_) {
            aBlackPointFoundOnBorder_ = false

            // .....
            // .   |
            // .....
            var rightBorderNotWhite = true
            while ((rightBorderNotWhite || !atLeastOneBlackPointFoundOnRight_) && right_ < width) {
                rightBorderNotWhite = containsBlackPoint(up, down_, right_, false)
                if (rightBorderNotWhite) {
                    right_++
                    aBlackPointFoundOnBorder_ = true
                    atLeastOneBlackPointFoundOnRight_ = true
                } else if (!atLeastOneBlackPointFoundOnRight_) {
                    right_++
                }
            }

            if (right_ >= width) {
                sizeExceeded = true
                break
            }

            /*
             * .....
             * .   .
             * .___.
             */ 
            var bottomBorderNotWhite = true
            while ((bottomBorderNotWhite || !atLeastOneBlackPointFoundOnBottom) && down_ < height) {
                bottomBorderNotWhite = containsBlackPoint(left_, right_, down_, true)
                if (bottomBorderNotWhite) {
                    down_++
                    aBlackPointFoundOnBorder_ = true
                    atLeastOneBlackPointFoundOnBottom = true
                } else if (!atLeastOneBlackPointFoundOnBottom) {
                    down_++
                }
            }

            if (down_ >= height) {
                sizeExceeded = true
                break
            }

            /*
             * .....
             * |   .
             * .___.
             */ 
            var leftBorderNotWhite_ = true
            while ((leftBorderNotWhite_ || !atLeastOneBlackPointFoundOnLeft) && left_ >= 0) {
                leftBorderNotWhite_ = containsBlackPoint(up, down_, left_, false)
                if (leftBorderNotWhite_) {
                    left_--
                    aBlackPointFoundOnBorder_ = true
                    atLeastOneBlackPointFoundOnLeft = true
                } else if (!atLeastOneBlackPointFoundOnLeft) {
                    left_--
                }
            }

            if (left_ < 0) {
                sizeExceeded = true
                break
            }

            /*
             * .....
             * .   .
             * .....
             */ 
            var topBorderNotWhite = true
            while ((topBorderNotWhite || !atLeastOneBlackPointFoundOnTop) && up >= 0) {
                topBorderNotWhite = containsBlackPoint(left_, right_, up, true)
                if (topBorderNotWhite) {
                    up--
                    aBlackPointFoundOnBorder_ = true
                    atLeastOneBlackPointFoundOnTop = true
                } else if (!atLeastOneBlackPointFoundOnTop) {
                    up--
                }
            }

            if (up < 0) {
                sizeExceeded = true
                break
            }
        }

        if (!sizeExceeded) {
            let maxSize = right_ - left_

            var z: ResultPoint = ResultPoint()
            var i = 1;
            while (i < maxSize && z.flag == false) {
                z = getBlackPointOnSegment(Float32(left_), Float32(down_ - i), Float32(left_ + i), Float32(down_))
                i++
            }

            if (z.flag == false) {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance()
            }

            var t: ResultPoint = ResultPoint()

            //go down_ right_
            i = 1
            while (i < maxSize && t.flag == false) {
                t = getBlackPointOnSegment(Float32(left_), Float32(up + i), Float32(left_ + i), Float32(up))
                i++
            }

            if (t.flag == false) {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance()
            }

            var x: ResultPoint = ResultPoint()

            //go down_ left_
            i = 1
            while (i < maxSize && x.flag == false) {
                x = getBlackPointOnSegment(Float32(right_), Float32(up + i), Float32(right_ - i), Float32(up))
                i++
            }

            if (x.flag == false) {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance()
            }

            var y: ResultPoint = ResultPoint()

            //go up left_
            i = 1
            while (i < maxSize && y.flag == false) {
                y = getBlackPointOnSegment(Float32(right_), Float32(down_ - i), Float32(right_ - i), Float32(down_))
                i++
            }

            if (y.flag == false) {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance()
            }

            return centerEdges(y, z, x, t)
        } else {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }
    }

    private func getBlackPointOnSegment(aX: Float32, aY: Float32, bX: Float32, bY: Float32): ResultPoint {
        let dist = MathUtils.round(MathUtils.distance(aX, aY, bX, bY))
        let xStep = (bX - aX) / Float32(dist)
        let yStep = (bY - aY) / Float32(dist)
        for (i in 0..dist) {
            let x = MathUtils.round(aX + Float32(i) * xStep)
            let y = MathUtils.round(aY + Float32(i) * yStep)
            if (image.get(x, y)) {
                return ResultPoint(Float32(x), Float32(y))
            }
        }
        var r: ResultPoint = ResultPoint()
        return r
    }

    /**
     * recenters the points value of a constant distance towards the center
     *
     * @param y bottom most point value
     * @param z left most point value
     * @param x right most point value
     * @param t top most point value
     *
     * @return ResultPoint[] describing the corners of the rectangular
     * region. The first and last points are opposed on the diagonal, as
     * are the second and third. The first point will be the topmost point
     * and the last, the bottommost. The second point will be
     * leftmost and the third, the rightmost
     */
    private func centerEdges(
        y: ResultPoint,
        z: ResultPoint,
        x: ResultPoint,
        t: ResultPoint
    ): Array<ResultPoint> {
        //
        //       t            t
        //  z                      x
        //        x    OR    z
        //   y                    y
        //
        let yi = y.getX();
        let yj = y.getY();
        let zi = z.getX();
        let zj = z.getY();
        let xi = x.getX();
        let xj = x.getY();
        let ti = t.getX();
        let tj = t.getY();

        if (yi < Float32(width / 2)) {
            return [
                ResultPoint(ti - Float32(CORR), tj + Float32(CORR)),
                ResultPoint(zi + Float32(CORR), zj + Float32(CORR)),
                ResultPoint(xi - Float32(CORR), xj - Float32(CORR)),
                ResultPoint(yi + Float32(CORR), yj - Float32(CORR))
            ]
        } else {
            return [
                ResultPoint(ti + Float32(CORR), tj + Float32(CORR)),
                ResultPoint(zi + Float32(CORR), zj - Float32(CORR)),
                ResultPoint(xi - Float32(CORR), xj + Float32(CORR)),
                ResultPoint(yi - Float32(CORR), yj - Float32(CORR))
            ]
        }
    }

    /**
     * Determines whether a segment contains a black point value
     *
     * @param a          min value of the scanned coordinate
     * @param b          max value of the scanned coordinate
     * @param fixed      value of the fixed coordinate
     * @param horizontal set to true if scan must be horizontal, false if vertical
     *
     * @return true if a black point value has been found, else false.
     */
    private func containsBlackPoint(a: Int64, b: Int64, fixed: Int64, horizontal: Bool): Bool {
        if (horizontal) {
            for (x in a..=b) {
                if (image.get(x, fixed)) {
                    return true
                }
            }
        } else {
            for (y in a..=b) {
                if (image.get(fixed, y)) {
                    return true
                }
            }
        }

        return false
    }
}
