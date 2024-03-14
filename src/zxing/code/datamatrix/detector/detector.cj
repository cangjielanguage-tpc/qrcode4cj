/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.datamatrix.detector

from std import math.*
import zxing.code.common.NotFoundException
import zxing.code.common.ResultPoint
import zxing.code.common.BitMatrix
import zxing.code.common.DetectorResult
import zxing.code.common.GridSampler
import zxing.code.common.detector.WhiteRectangleDetector

/**
 * <p>Encapsulates logic that can detect a Data Matrix Code in an image, even if the Data Matrix Code
 * is rotated or skewed, or partially obscured.</p>
 *
 * @author Sean Owen
 */
public class Detector {
    private let image: BitMatrix
    private let rectangleDetector: WhiteRectangleDetector

    public init(image: BitMatrix) {
        this.image = image
        rectangleDetector = WhiteRectangleDetector(image)
    }

    /**
     * <p>Detects a Data Matrix Code in an image.</p>
     *
     * @return {@link DetectorResult} encapsulating results of detecting a Data Matrix Code
     * @throws NotFoundException if no Data Matrix Code can be found
     */
    public func detect(): DetectorResult {
        let cornerPoints: Array<ResultPoint> = rectangleDetector.detect();

        var points: Array<ResultPoint> = detectSolid1(cornerPoints);
        points = detectSolid2(points)
        points[3] = correctTopRight(points)
        let v: Option<ResultPoint> = points[3]
        if (let Some(a) <- v) {
            if (!a.flag) {
                throw NotFoundException.getNotFoundInstance();
            }
        } else {
            throw NotFoundException.getNotFoundInstance();
        }
        points = shiftToModuleCenter(points)

        var topLeft: ResultPoint = points[0]
        var bottomLeft: ResultPoint = points[1]
        var bottomRight: ResultPoint = points[2]
        var topRight: ResultPoint = points[3]

        var dimensionTop = transitionsBetween(topLeft, topRight) + 1
        var dimensionRight = transitionsBetween(bottomRight, topRight) + 1
        if ((dimensionTop & 0x01) == 1) {
            dimensionTop += 1
        }
        if ((dimensionRight & 0x01) == 1) {
            dimensionRight += 1
        }

        if (4 * dimensionTop < 6 * dimensionRight && 4 * dimensionRight < 6 * dimensionTop) {
            // The matrix is square
            dimensionRight = math.max(dimensionTop, dimensionRight)
            dimensionTop = dimensionRight
        }

        let bits: BitMatrix = sampleGrid(
            image,
            topLeft,
            bottomLeft,
            bottomRight,
            topRight,
            dimensionTop,
            dimensionRight
        );

        return DetectorResult(bits, [topLeft, bottomLeft, bottomRight, topRight]);
    }

    private static func shiftPoint(point: ResultPoint, to: ResultPoint, div: Int64): ResultPoint {
        var x: Float32 = (to.getX() - point.getX()) / Float32((div + 1))
        var y: Float32 = (to.getY() - point.getY()) / Float32((div + 1))
        return ResultPoint(point.getX() + x, point.getY() + y);
    }

    private static func moveAway(point: ResultPoint, fromX: Float32, fromY: Float32): ResultPoint {
        var x: Float32 = point.getX();
        var y: Float32 = point.getY();

        if (x < fromX) {
            x -= 1.0
        } else {
            x += 1.0
        }

        if (y < fromY) {
            y -= 1.0
        } else {
            y += 1.0
        }

        return ResultPoint(x, y);
    }

    /**
     * Detect a solid side which has minimum transition.
     */
    private func detectSolid1(cornerPoints: Array<ResultPoint>): Array<ResultPoint> {

        // 0  2
        // 1  3
        var pointA: ResultPoint = cornerPoints[0]
        var pointB: ResultPoint = cornerPoints[1]
        var pointC: ResultPoint = cornerPoints[3]
        var pointD: ResultPoint = cornerPoints[2]

        var trAB: Int64 = transitionsBetween(pointA, pointB);
        var trBC: Int64 = transitionsBetween(pointB, pointC);
        var trCD: Int64 = transitionsBetween(pointC, pointD);
        var trDA: Int64 = transitionsBetween(pointD, pointA);

        // 0..3
        // :  :
        // 1--2
        var min: Int64 = trAB
        var points = [pointD, pointA, pointB, pointC]
        if (min > trBC) {
            min = trBC
            points[0] = pointA
            points[1] = pointB
            points[2] = pointC
            points[3] = pointD
        }
        if (min > trCD) {
            min = trCD
            points[0] = pointB
            points[1] = pointC
            points[2] = pointD
            points[3] = pointA
        }
        if (min > trDA) {
            points[0] = pointC
            points[1] = pointD
            points[2] = pointA
            points[3] = pointB
        }

        return points
    }

    /**
     * Detect a second solid side next to first solid side.
     */
    private func detectSolid2(points: Array<ResultPoint>): Array<ResultPoint> {

        // A..D
        // :  :
        // B--C
        var pointA: ResultPoint = points[0]
        var pointB: ResultPoint = points[1]
        var pointC: ResultPoint = points[2]
        var pointD: ResultPoint = points[3]

        // Transition detection on the edge is not stable.
        // To safely detect, shift the points to the module center.
        var tr: Int64 = transitionsBetween(pointA, pointD);
        let pointBs = shiftPoint(pointB, pointC, (tr + 1) * 4);
        let pointCs = shiftPoint(pointC, pointB, (tr + 1) * 4);
        var trBA: Int64 = transitionsBetween(pointBs, pointA);
        var trCD: Int64 = transitionsBetween(pointCs, pointD);

        // 0..3
        // |  :
        // 1--2
        if (trBA < trCD) {
            // solid sides: A-B-C
            points[0] = pointA
            points[1] = pointB
            points[2] = pointC
            points[3] = pointD
        } else {
            // solid sides: B-C-D
            points[0] = pointB
            points[1] = pointC
            points[2] = pointD
            points[3] = pointA
        }

        return points
    }

    /**
     * Calculates the corner position of the white top right module.
     */
    private func correctTopRight(points: Array<ResultPoint>): ResultPoint {

        // A..D
        // |  :
        // B--C
        var pointA: ResultPoint = points[0]
        var pointB: ResultPoint = points[1]
        var pointC: ResultPoint = points[2]
        var pointD: ResultPoint = points[3]

        // shift points for safe transition detection.
        var trTop: Int64 = transitionsBetween(pointA, pointD);
        var trRight: Int64 = transitionsBetween(pointB, pointD);
        let pointAs = shiftPoint(pointA, pointB, (trRight + 1) * 4);
        let pointCs = shiftPoint(pointC, pointB, (trTop + 1) * 4);

        trTop = transitionsBetween(pointAs, pointD)
        trRight = transitionsBetween(pointCs, pointD)

        let candidate1 = ResultPoint(
            pointD.getX() + (pointC.getX() - pointB.getX()) / Float32((trTop + 1)),
            pointD.getY() + (pointC.getY() - pointB.getY()) / Float32((trTop + 1))
        )
        let candidate2 = ResultPoint(
            pointD.getX() + (pointA.getX() - pointB.getX()) / Float32((trRight + 1)),
            pointD.getY() + (pointA.getY() - pointB.getY()) / Float32((trRight + 1))
        )

        if (!isValid(candidate1)) {
            if (isValid(candidate2)) {
                return candidate2
            }

            //let t:?ResultPoint=None

            return ResultPoint()
        }
        if (!isValid(candidate2)) {
            return candidate1
        }

        let sumc1 = transitionsBetween(pointAs, candidate1) + transitionsBetween(pointCs, candidate1)
        let sumc2 = transitionsBetween(pointAs, candidate2) + transitionsBetween(pointCs, candidate2)

        if (sumc1 > sumc2) {
            return candidate1
        } else {
            return candidate2
        }
    }

    /**
     * Shift the edge points to the module center.
     */
    private func shiftToModuleCenter(points: Array<ResultPoint>): Array<ResultPoint> {
        // A..D
        // |  :
        // B--C

        var pointA: ResultPoint = points[0]
        var pointB: ResultPoint = points[1]
        var pointC: ResultPoint = points[2]
        var pointD: ResultPoint = points[3]

        // calculate pseudo dimensions
        var dimH = transitionsBetween(pointA, pointD) + 1
        var dimV = transitionsBetween(pointC, pointD) + 1

        // shift points for safe dimension detection
        var pointAs: ResultPoint = shiftPoint(pointA, pointB, dimV * 4);
        var pointCs: ResultPoint = shiftPoint(pointC, pointB, dimH * 4);

        //  calculate more precise dimensions
        dimH = transitionsBetween(pointAs, pointD) + 1
        dimV = transitionsBetween(pointCs, pointD) + 1
        if ((dimH & 0x01) == 1) {
            dimH += 1
        }
        if ((dimV & 0x01) == 1) {
            dimV += 1
        }

        // WhiteRectangleDetector returns points inside of the rectangle.
        // I want points on the edges.
        let centerX: Float32 = (pointA.getX() + pointB.getX() + pointC.getX() + pointD.getX()) / 4.0
        let centerY: Float32 = (pointA.getY() + pointB.getY() + pointC.getY() + pointD.getY()) / 4.0
        pointA = moveAway(pointA, centerX, centerY)
        pointB = moveAway(pointB, centerX, centerY)
        pointC = moveAway(pointC, centerX, centerY)
        pointD = moveAway(pointD, centerX, centerY)

        var pointBs: ResultPoint
        var pointDs: ResultPoint

        // shift points to the center of each modules
        pointAs = shiftPoint(pointA, pointB, dimV * 4)
        pointAs = shiftPoint(pointAs, pointD, dimH * 4)
        pointBs = shiftPoint(pointB, pointA, dimV * 4)
        pointBs = shiftPoint(pointBs, pointC, dimH * 4)
        pointCs = shiftPoint(pointC, pointD, dimV * 4)
        pointCs = shiftPoint(pointCs, pointB, dimH * 4)
        pointDs = shiftPoint(pointD, pointC, dimV * 4)
        pointDs = shiftPoint(pointDs, pointA, dimH * 4)

        return [pointAs, pointBs, pointCs, pointDs]
    }

    private func isValid(p: ResultPoint): Bool {
        if (p.getX() >= 0.0 && p.getX() <= Float32(image.getWidth() - 1) && p.getY() > 0.0 && p.getY() <= Float32(image.
                getHeight() - 1)) {
            return true
        } else {
            return false
        }
    }

    private static func sampleGrid(
        image: BitMatrix,
        topLeft: ResultPoint,
        bottomLeft: ResultPoint,
        bottomRight: ResultPoint,
        topRight: ResultPoint,
        dimensionX: Int64,
        dimensionY: Int64
    ): BitMatrix {
        var sampler: GridSampler = GridSampler.getInstance();

        return sampler.sampleGrid(
            image,
            dimensionX,
            dimensionY,
            0.5,
            0.5,
            Float64(dimensionX) - 0.5,
            0.5,
            Float64(dimensionX) - 0.5,
            Float64(dimensionY) - 0.5,
            0.5,
            Float64(dimensionY) - 0.5,
            Float64(topLeft.getX()),
            Float64(topLeft.getY()),
            Float64(topRight.getX()),
            Float64(topRight.getY()),
            Float64(bottomRight.getX()),
            Float64(bottomRight.getY()),
            Float64(bottomLeft.getX()),
            Float64(bottomLeft.getY())
        );
    }

    /**
     * Counts the number of black/white transitions between two points, using something like Bresenham's algorithm.
     */
    private func transitionsBetween(fromr: ResultPoint, to: ResultPoint): Int64 {

        // See QR Code Detector, sizeOfBlackWhiteBlackRun()

        var fromX: Int64 = Int64(fromr.getX())
        var fromY: Int64 = Int64(fromr.getY())
        var toX: Int64 = Int64(to.getX())
        var toY: Int64 = math.min(image.getHeight() - 1, Int64(to.getY()))

        var steep: Bool = math.abs(toY - fromY) > math.abs(toX - fromX)
        if (steep) {
            var temp: Int64 = fromX
            fromX = fromY
            fromY = temp
            temp = toX
            toX = toY
            toY = temp
        }

        let dx: Int64 = math.abs(toX - fromX);
        let dy: Int64 = math.abs(toY - fromY);
        var error = -dx / 2
        let ystep = if (fromY < toY) {
            1
        } else {
            -1
        }
        let xstep = if (fromX < toX) {
            1
        } else {
            -1
        }
        var transitions = 0;
        let t1: Int64
        let t2: Int64
        if (steep) {
            t1 = fromY
            t2 = fromX
        } else {
            t1 = fromX
            t2 = fromY
        }
        transitions = extransitionsBetween(fromX, fromY, toX, steep, transitions, error, dy, toY, dx, xstep, ystep)

        return transitions
    }

    private func extransitionsBetween(fromX: Int64, fromY: Int64, toX: Int64, steep: Bool, transitions: Int64,
        error: Int64, dy: Int64, toY: Int64, dx: Int64, xstep: Int64, ystep: Int64) {
        var transitions_p = transitions
        var error_p = error
        var inBlack = image.get(
            if (steep) {
                fromY
            } else {
                fromX
            },
            if (steep) {
                fromX
            } else {
                fromY
            }
        );
        var x: Int64 = fromX
        var y: Int64 = fromY
        while (x != toX) {
            let isBlack = image.get(
                if (steep) {
                    y
                } else {
                    x
                },
                if (steep) {
                    x
                } else {
                    y
                }
            );
            if (isBlack != inBlack) {
                transitions_p++
                inBlack = isBlack
            }
            error_p += dy
            if (error_p > 0) {
                if (y == toY) {
                    break
                }
                y += ystep
                error_p -= dx
            }

            x += xstep
        }
        return transitions_p
    }
}
