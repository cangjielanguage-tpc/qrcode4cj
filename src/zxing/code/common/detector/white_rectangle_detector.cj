/*
 * Copyright 2010 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package zxing.code.common.detector

import zxing.code.common.*

/**
 * <p>
 * Detects a candidate barcode-like rectangular region within an image. It
 * starts around the center of the image, increases the size of the candidate
 * region until it finds a white rectangular region. By keeping track of the
 * last black points it encountered, it determines the corners of the barcode.
 * </p>
 *
 * @author David Olivier
 */
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
                throw NotFoundException.getNotFoundInstance()
            }
        } catch (e: Exception) {
            throw NotFoundException.getNotFoundInstance()
        }
    }

    /**
     * @param image barcode image to find a rectangle in
     * @param initSize initial size of search area around center
     * @param x x position of search center
     * @param y y position of search center
     * @throws NotFoundException if image is too small to accommodate {@code initSize}
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
                throw NotFoundException.getNotFoundInstance()
            }
        } catch (e: Exception) {
            throw NotFoundException.getNotFoundInstance()
        }
    }

    /**
     * <p>
     * Detects a candidate barcode-like rectangular region within an image. It
     * starts around the center of the image, increases the size of the candidate
     * region until it finds a white rectangular region.
     * </p>
     *
     * @return {@link ResultPoint}[] describing the corners of the rectangular
     * region. The first and last points are opposed on the diagonal, as
     * are the second and third. The first point will be the topmost
     * point and the last, the bottommost. The second point will be
     * leftmost and the third, the rightmost
     * @throws NotFoundException if no Data Matrix Code can be found
     */
    public func detect(): Array<ResultPoint> {
        var left = leftInit
        var right = rightInit
        var up = upInit
        var down = downInit
        var sizeExceeded = false
        var aBlackPointFoundOnBorder = true

        var atLeastOneBlackPointFoundOnRight = false
        var atLeastOneBlackPointFoundOnBottom = false
        var atLeastOneBlackPointFoundOnLeft = false
        var atLeastOneBlackPointFoundOnTop = false

        while (aBlackPointFoundOnBorder) {
            aBlackPointFoundOnBorder = false

            // .....
            // .   |
            // .....
            var rightBorderNotWhite = true
            while ((rightBorderNotWhite || !atLeastOneBlackPointFoundOnRight) && right < width) {
                rightBorderNotWhite = containsBlackPoint(up, down, right, false)
                if (rightBorderNotWhite) {
                    right++
                    aBlackPointFoundOnBorder = true
                    atLeastOneBlackPointFoundOnRight = true
                } else if (!atLeastOneBlackPointFoundOnRight) {
                    right++
                }
            }

            if (right >= width) {
                sizeExceeded = true
                break
            }

            // .....
            // .   .
            // .___.
            var bottomBorderNotWhite = true
            while ((bottomBorderNotWhite || !atLeastOneBlackPointFoundOnBottom) && down < height) {
                bottomBorderNotWhite = containsBlackPoint(left, right, down, true)
                if (bottomBorderNotWhite) {
                    down++
                    aBlackPointFoundOnBorder = true
                    atLeastOneBlackPointFoundOnBottom = true
                } else if (!atLeastOneBlackPointFoundOnBottom) {
                    down++
                }
            }

            if (down >= height) {
                sizeExceeded = true
                break
            }

            // .....
            // |   .
            // .....
            var leftBorderNotWhite = true
            while ((leftBorderNotWhite || !atLeastOneBlackPointFoundOnLeft) && left >= 0) {
                leftBorderNotWhite = containsBlackPoint(up, down, left, false)
                if (leftBorderNotWhite) {
                    left--
                    aBlackPointFoundOnBorder = true
                    atLeastOneBlackPointFoundOnLeft = true
                } else if (!atLeastOneBlackPointFoundOnLeft) {
                    left--
                }
            }

            if (left < 0) {
                sizeExceeded = true
                break
            }

            // .___.
            // .   .
            // .....
            var topBorderNotWhite = true
            while ((topBorderNotWhite || !atLeastOneBlackPointFoundOnTop) && up >= 0) {
                topBorderNotWhite = containsBlackPoint(left, right, up, true)
                if (topBorderNotWhite) {
                    up--
                    aBlackPointFoundOnBorder = true
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
            let maxSize = right - left

            var z: ResultPoint = ResultPoint()
            var i = 1;
            while (i < maxSize && z.flag == false) {
                z = getBlackPointOnSegment(Float32(left), Float32(down - i), Float32(left + i), Float32(down))
                i++
            }

            if (z.flag == false) {
                throw NotFoundException.getNotFoundInstance()
            }

            var t: ResultPoint = ResultPoint()

            //go down right
            i = 1
            while (i < maxSize && t.flag == false) {
                t = getBlackPointOnSegment(Float32(left), Float32(up + i), Float32(left + i), Float32(up))
                i++
            }

            if (t.flag == false) {
                throw NotFoundException.getNotFoundInstance()
            }

            var x: ResultPoint = ResultPoint()

            //go down left
            i = 1
            while (i < maxSize && x.flag == false) {
                x = getBlackPointOnSegment(Float32(right), Float32(up + i), Float32(right - i), Float32(up))
                i++
            }

            if (x.flag == false) {
                throw NotFoundException.getNotFoundInstance()
            }

            var y: ResultPoint = ResultPoint()

            //go up left
            i = 1
            while (i < maxSize && y.flag == false) {
                y = getBlackPointOnSegment(Float32(right), Float32(down - i), Float32(right - i), Float32(down))
                i++
            }

            if (y.flag == false) {
                throw NotFoundException.getNotFoundInstance()
            }

            return centerEdges(y, z, x, t)
        } else {
            throw NotFoundException.getNotFoundInstance()
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
     * recenters the points of a constant distance towards the center
     *
     * @param y bottom most point
     * @param z left most point
     * @param x right most point
     * @param t top most point
     * @return {@link ResultPoint}[] describing the corners of the rectangular
     * region. The first and last points are opposed on the diagonal, as
     * are the second and third. The first point will be the topmost
     * point and the last, the bottommost. The second point will be
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
     * Determines whether a segment contains a black point
     *
     * @param a          min value of the scanned coordinate
     * @param b          max value of the scanned coordinate
     * @param fixed      value of fixed coordinate
     * @param horizontal set to true if scan must be horizontal, false if vertical
     * @return true if a black point has been found, else false.
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
