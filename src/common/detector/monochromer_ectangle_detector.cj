/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common.detector

import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.math.*

public class MonochromeRectangleDetector {
    private static let MAX_MODULES = 32

    private let image: BitMatrix

    public MonochromeRectangleDetector(image: BitMatrix) {
        this.image = image
    }

    public func detect(): Array<ResultPoint> {
        try {
            let height: Int64 = image.getHeight()
            let width: Int64 = image.getWidth()
            let halfHeight = Int64(height / 2)
            let halfWidth = Int64(width / 2)
            let deltaY = Int64(max(1, height / (MAX_MODULES * 8)))
            let deltaX = Int64(max(1, width / (MAX_MODULES * 8)))

            var top = 0
            var bottom = height
            var left = 0
            var right = width
            var pointA: ResultPoint = findCornerFromCenter(halfWidth, 0, left, right, halfHeight, -deltaY, top, bottom,
                halfWidth / 2)
            top = Int64(pointA.getY()) - 1
            let pointB: ResultPoint = findCornerFromCenter(halfWidth, -deltaX, left, right, halfHeight, 0, top, bottom,
                halfHeight / 2)
            left = Int64(pointB.getX()) - 1
            let pointC: ResultPoint = findCornerFromCenter(halfWidth, deltaX, left, right, halfHeight, 0, top, bottom,
                halfHeight / 2)
            right = Int64(pointC.getX()) + 1
            let pointD: ResultPoint = findCornerFromCenter(halfWidth, 0, left, right, halfHeight, deltaY, top, bottom,
                halfWidth / 2)
            bottom = Int64(pointD.getY()) + 1

            // Go try to find point A again with better information -- might have been off at first.
            pointA = findCornerFromCenter(
                halfWidth,
                0,
                left,
                right,
                halfHeight,
                -deltaY,
                top,
                bottom,
                halfWidth / 4
            )
            let tempArray: Array<ResultPoint> = [pointA, pointB, pointC, pointD]
            return tempArray
        } catch (e: Exception) {
            throw Qrcoder4cjNotFoundException()
        }
    }

    private func findCornerFromCenter(centerX: Int64, deltaX: Int64, left: Int64, right: Int64, centerY: Int64,
        deltaY: Int64, top: Int64, bottom: Int64, maxWhiteRun: Int64): ResultPoint {
        try {
            var lastRange: Array<Int64> = []
            var x: Int64 = centerX
            var y: Int64 = centerY

            while (y < bottom && y >= top && x < right && x >= left) {
                var range: Array<Int64>
                if (deltaX == 0) {
                    // horizontal slices, up and down
                    range = blackWhiteRange(y, maxWhiteRun, left, right, true)
                } else {
                    // vertical slices, left and right
                    range = blackWhiteRange(x, maxWhiteRun, top, bottom, false)
                }
                if (range == []) {
                    if (lastRange == []) {
                        throw Qrcoder4cjNotFoundException.getNotFoundInstance();
                    }

                    // lastRange was found
                    if (deltaX == 0) {
                        return exfindCornerFromCenter(y, deltaY, lastRange, centerX)
                    } else {
                        let lastX: Int64 = x - deltaX
                        if (lastRange[0] < centerY) {
                            if (lastRange[1] > centerY) {
                                var indext: Int64 = 0
                                if (deltaX > 0) {
                                    indext = 0
                                } else {
                                    indext = 1
                                }
                                return ResultPoint(Float32(lastX), Float32(lastRange[indext]))
                            }
                            return ResultPoint(Float32(lastX), Float32(lastRange[0]))
                        } else {
                            return ResultPoint(Float32(lastX), Float32(lastRange[1]))
                        }
                    }
                }
                lastRange = range

                y += deltaY
                x += deltaX
            }
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        } catch (e: Exception) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }
    }

    private func exfindCornerFromCenter(y: Int64, deltaY: Int64, lastRange: Array<Int64>, centerX: Int64): ResultPoint {
        let lastY: Int64 = y - deltaY
        if (lastRange[0] < centerX) {
            if (lastRange[1] > centerX) {
                // straddle, choose one or the other based on direction
                var indext: Int64 = 0
                if (deltaY > 0) {
                    indext = 0
                } else {
                    indext = 1
                }
                return ResultPoint(Float32(lastRange[indext]), Float32(lastY))
            }
            return ResultPoint(Float32(lastRange[0]), Float32(lastY))
        } else {
            return ResultPoint(Float32(lastRange[1]), Float32(lastY))
        }
    }

    private func blackWhiteRange(fixedDimension: Int64, maxWhiteRun: Int64, minDim: Int64, maxDim: Int64,
        horizontal: Bool): Array<Int64> {
        let center: Int64 = Int64((minDim + maxDim) / 2)

        // Scan left/up first
        var start: Int64 = center
        while (start >= minDim) {
            var tmpImageGet: Bool
            if (horizontal) {
                tmpImageGet = image.get(start, fixedDimension)
            } else {
                tmpImageGet = image.get(fixedDimension, start)
            }
            if (tmpImageGet) {
                start--
            } else {
                let whiteRunStart = start

                do {
                    start--
                } while (start >= minDim && !(tmpImageGet))
                let whiteRunSize = whiteRunStart - start
                if (start < minDim || whiteRunSize > maxWhiteRun) {
                    start = whiteRunStart
                    break
                }
            }
        }
        start++

        // Then try right/down
        var end: Int64 = center
        while (end < maxDim) {
            var tmpImageGet: Bool = exblackWhiteRange(horizontal, end, fixedDimension)
            if (tmpImageGet) {
                end++
            } else {
                let whiteRunStart = end
                do {
                    end++
                } while (end < maxDim && !(tmpImageGet))

                let whiteRunSize = end - whiteRunStart
                if (end >= maxDim || whiteRunSize > maxWhiteRun) {
                    end = whiteRunStart
                    break
                }
            }
        }
        end--
        let rt: Array<Int64>
        if (end > start) {
            return [start, end]
        } else {
            return []
        }
    }

    private func exblackWhiteRange(horizontal: Bool, end: Int64, fixedDimension: Int64): Bool {
        if (horizontal) {
            return image.get(end, fixedDimension)
        } else {
            return image.get(fixedDimension, end)
        }
    }
}
