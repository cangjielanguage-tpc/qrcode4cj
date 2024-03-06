package zxing.code.aztec.detector

import zxing.code.common.NotFoundException
import zxing.code.common.ResultPoint
import zxing.code.aztec.common.AztecDetectorResult
import zxing.code.common.BitMatrix
import zxing.code.common.GridSampler
import zxing.code.common.detector.MathUtils
import zxing.code.common.detector.WhiteRectangleDetector
import zxing.code.common.reedsolomon.GenericGF
import zxing.code.common.reedsolomon.ReedSolomonDecoder
import zxing.code.common.reedsolomon.ReedSolomonException
from std import math.*

/**
 * Encapsulates logic that can detect an Aztec Code in an image, even if the Aztec Code
 * is rotated or skewed, or partially obscured.
 *
 * @author David Olivier
 * @author Frank Yellin
 */
public class Point <: ToString {
    private var x: Int64 = 0
    private var y: Int64 = 0

    func toResultPoint(): ResultPoint {
        return ResultPoint(Float32(x), Float32(y))
    }

    public init(x: Int64, y: Int64) {
        this.x = x
        this.y = y
    }

    public func setXY(x: Int64, y: Int64) {
        this.x = x
        this.y = y
    }

    public func getX(): Int64 {
        return x
    }

    public func getY(): Int64 {
        return y
    }

    public func toString(): String {
        return "<${x} ${y}>"
    }
}

public class Detector {
    private static var EXPECTED_CORNER_BITS: Array<Int64> = [
        0xee0, // 07340  XXX .XX X.. ...
        0x1dc, // 00734  ... XXX .XX X..
        0x83b, // 04073  X.. ... XXX .XX
        0x707 // 03407 .XX X.. ... XXX
    ]

    private var image: BitMatrix

    private var compact: Bool = false;
    private var nbLayers: Int64 = Int64.Max;
    private var nbDataBlocks: Int64 = Int64.Max;
    private var nbCenterLayers: Int64 = Int64.Max;
    private var shift: Int64 = Int64.Max;

    public init(image: BitMatrix) {
        this.image = image
    }

    public func detect(): AztecDetectorResult {
        return detect(false)
    }

    /**
     * Detects an Aztec Code in an image.
     *
     * @param isMirror if true, image is a mirror-image of original
     * @return {@link AztecDetectorResult} encapsulating results of detecting an Aztec Code
     * @throws NotFoundException if no Aztec Code can be found
     */
    public func detect(isMirror: Bool): AztecDetectorResult {

        // 1. Get the center of the aztec matrix
        var pCenter: Point = getMatrixCenter()

        // 2. Get the center points of the four diagonal points just outside the bull's eye
        //  [topRight, bottomRight, bottomLeft, topLeft]
        var bullsEyeCorners: Array<ResultPoint> = getBullsEyeCorners(pCenter)

        if (isMirror) {
            var temp: ResultPoint = bullsEyeCorners[0]
            bullsEyeCorners[0] = bullsEyeCorners[2]
            bullsEyeCorners[2] = temp
        }

        // 3. Get the size of the matrix and other parameters from the bull's eye
        extractParameters(bullsEyeCorners)

        // 4. Sample the grid
        var bits: BitMatrix = sampleGrid(
            image,
            bullsEyeCorners[shift % 4],
            bullsEyeCorners[(shift + 1) % 4],
            bullsEyeCorners[(shift + 2) % 4],
            bullsEyeCorners[(shift + 3) % 4]
        )

        // 5. Get the corners of the matrix.
        var corners: Array<ResultPoint> = getMatrixCornerPoints(bullsEyeCorners)

        return AztecDetectorResult(bits, corners, compact, nbDataBlocks, nbLayers)
    }

    /**
     * Extracts the number of data layers and data blocks from the layer around the bull's eye.
     *
     * @param bullsEyeCorners the array of bull's eye corners
     * @throws NotFoundException in case of too many errors or invalid parameters
     */
    private func extractParameters(bullsEyeCorners: Array<ResultPoint>) {
        if (!isValid(bullsEyeCorners[0]) || !isValid(bullsEyeCorners[1]) || !isValid(bullsEyeCorners[2]) ||
            !isValid(bullsEyeCorners[3])) {
            throw NotFoundException.getNotFoundInstance()
        }
        var length: Int64 = 2 * nbCenterLayers

        // Get the bits around the bull's eye
        var sides: Array<Int64> = [
            sampleLine(bullsEyeCorners[0], bullsEyeCorners[1], length), // Right side
            sampleLine(bullsEyeCorners[1], bullsEyeCorners[2], length), // Bottom
            sampleLine(bullsEyeCorners[2], bullsEyeCorners[3], length), // Left side
            sampleLine(bullsEyeCorners[3], bullsEyeCorners[0], length) // Top
        ]

        // bullsEyeCorners[shift] is the corner of the bulls'eye that has three
        // orientation marks.
        // sides[shift] is the row/column that goes from the corner with three
        // orientation marks to the corner with two.
        shift = getRotation(sides, length)

        // Flatten the parameter bits into a single 28- or 40-bit long
        var parameterData: Int64 = /*long*/ 0
        for (i in 0..4) {
            var side: Int64 = sides[(shift + i) % 4]
            if (compact) {
                // Each side of the form ..XXXXXXX. where Xs are parameter data
                parameterData <<= 7
                parameterData += (side >> 1) & 0x7F
            } else {
                // Each side of the form ..XXXXX.XXXXX. where Xs are parameter data
                parameterData <<= 10
                parameterData += ((side >> 2) & (0x1f << 5)) + ((side >> 1) & 0x1F)
            }
        }

        // Corrects parameter data using RS.  Returns just the data portion
        // without the error correction.
        var correctedData: Int64 = getCorrectedParameterData(parameterData, compact)

        if (compact) {
            // 8 bits:  2 bits layers and 6 bits data blocks
            nbLayers = (correctedData >> 6) + 1
            nbDataBlocks = (correctedData & 0x3F) + 1
        } else {
            // 16 bits:  5 bits layers and 11 bits data blocks
            nbLayers = (correctedData >> 11) + 1
            nbDataBlocks = (correctedData & 0x7FF) + 1
        }
    }

    private static func getRotation(sides: Array<Int64>, length: Int64): Int64 {
        // In a normal pattern, we expect to See
        //   **    .*             D       A
        //   *      *
        //
        //   .      *
        //   ..    ..             C       B
        //
        // Grab the 3 bits from each of the sides the form the locator pattern and concatenate
        // into a 12-bit integer.  Start with the bit at A
        var cornerBits: Int64 = 0
        for (side in 0..sides.size) {
            // XX......X where X's are orientation marks
            var t: Int64 = ((sides[side] >> (length - 2)) << 1) + (sides[side] & 1)
            cornerBits = (cornerBits << 3) + t
        }

        // Mov the bottom bit to the top, so that the three bits of the locator pattern at A are
        // together.  cornerBits is now:
        //  3 orientation bits at A || 3 orientation bits at B || ... || 3 orientation bits at D
        cornerBits = ((cornerBits & 1) << 11) + (cornerBits >> 1)

        // The result shift indicates which element of BullsEyeCorners[] goes into the top-left
        // corner. Since the four rotation values have a Hamming distance of 8, we
        // can easily tolerate two errors.
        for (shift in 0..4) {
            var a: Int8 = countOne(cornerBits ^ EXPECTED_CORNER_BITS[shift]);
            if (countOne(cornerBits ^ EXPECTED_CORNER_BITS[shift]) <= 2) {
                return shift
            }
        }
        throw NotFoundException.getNotFoundInstance()
    }

    /**
     * Corrects the parameter bits using Reed-Solomon algorithm.
     *
     * @param parameterData parameter bits
     * @param compact true if this is a compact Aztec code
     * @throws NotFoundException if the array contains too many errors
     */
    private static func getCorrectedParameterData(parameterData: Int64, compact: Bool): Int64 {
        var parameterDataItem = parameterData

        var numCodewords: Int64
        var numDataCodewords: Int64

        if (compact) {
            numCodewords = 7
            numDataCodewords = 2
        } else {
            numCodewords = 10
            numDataCodewords = 4
        }

        var numECCodewords: Int64 = numCodewords - numDataCodewords
        var parameterWords: Array<Int64> = Array<Int64>(numCodewords, item: 0)
        var i: Int64 = numCodewords - 1
        while (i >= 0) {
            parameterWords[i] = Int64(parameterDataItem & 0xF)
            parameterDataItem >>= 4
            i--
        }
        try {
            var rsDecoder: ReedSolomonDecoder = ReedSolomonDecoder(GenericGF.AZTEC_PARAM)
            rsDecoder.decode(parameterWords, numECCodewords)
        } catch (ignored: ReedSolomonException) {
            throw NotFoundException.getNotFoundInstance()
        }

        // Toss the error correction.  Just return the data as an integer
        var result: Int64 = 0
        for (i in 0..numDataCodewords) {
            result = (result << 4) + parameterWords[i]
        }
        return result
    }

    /**
     * Finds the corners of a bull-eye centered on the passed point.
     * This returns the centers of the diagonal points just outside the bull's eye
     * Returns [topRight, bottomRight, bottomLeft, topLeft]
     *
     * @param pCenter Center point
     * @return The corners of the bull-eye
     * @throws NotFoundException If no valid bull-eye can be found
     */
    private func getBullsEyeCorners(pCenter: Point): Array<ResultPoint> {
        var pina: Point = pCenter
        var pinb: Point = pCenter
        var pinc: Point = pCenter
        var pind: Point = pCenter

        var color: Bool = true

        nbCenterLayers = 1
        while (nbCenterLayers < 9) {
            var pouta: Point = getFirstDifferent(pina, color, 1, -1)
            var poutb: Point = getFirstDifferent(pinb, color, 1, 1)
            var poutc: Point = getFirstDifferent(pinc, color, -1, 1)
            var poutd: Point = getFirstDifferent(pind, color, -1, -1)

            //d      a
            //
            //c      b
            if (nbCenterLayers > 2) {
                var q: Float32 = distance(poutd, pouta) * Float32(nbCenterLayers) / (distance(pind, pina) * Float32(nbCenterLayers +
                        2))
                if (q < 0.75 || q > 1.25 || !isWhiteOrBlackRectangle(pouta, poutb, poutc, poutd)) {
                    break
                }
            }

            pina = pouta
            pinb = poutb
            pinc = poutc
            pind = poutd

            color = !color
            nbCenterLayers++
        }

        if (nbCenterLayers != 5 && nbCenterLayers != 7) {
            throw NotFoundException.getNotFoundInstance()
        }

        compact = nbCenterLayers == 5

        // Expand the square by .5 pixel in each direction so that we're on the border
        // between the white square and the black square
        var pinax: ResultPoint = ResultPoint(Float32(pina.getX()) + 0.5f32, Float32(pina.getY()) - 0.5f32)
        var pinbx: ResultPoint = ResultPoint(Float32(pinb.getX()) + 0.5f32, Float32(pinb.getY()) + 0.5f32)
        var pincx: ResultPoint = ResultPoint(Float32(pinc.getX()) - 0.5f32, Float32(pinc.getY()) + 0.5f32)
        var pindx: ResultPoint = ResultPoint(Float32(pind.getX()) - 0.5f32, Float32(pind.getY()) - 0.5f32)

        // Expand the square so that its corners are the centers of the points
        // just outside the bull's eye.
        return expandSquare(
            [pinax, pinbx, pincx, pindx],
            2 * nbCenterLayers - 3,
            2 * nbCenterLayers
        )
    }

    /**
     * Finds a candidate center point of an Aztec code from an image
     *
     * @return the center point
     */
    private func getMatrixCenter(): Point {
        var pointA: ResultPoint
        var pointB: ResultPoint
        var pointC: ResultPoint
        var pointD: ResultPoint

        //Get a white rectangle that can be the border of the matrix in center bull's eye or
        try {
            var cornerPoints: Array<ResultPoint> = WhiteRectangleDetector(image).detect()
            pointA = cornerPoints[0]
            pointB = cornerPoints[1]
            pointC = cornerPoints[2]
            pointD = cornerPoints[3]
        } catch (e: NotFoundException) {
            // This exception can be in case the initial rectangle is white
            // In that case, surely in the bull's eye, we try to expand the rectangle.
            var cx: Int64 = image.getWidth() / 2
            var cy: Int64 = image.getHeight() / 2
            pointA = getFirstDifferent(Point(cx + 7, cy - 7), false, 1, -1).toResultPoint()
            pointB = getFirstDifferent(Point(cx + 7, cy + 7), false, 1, 1).toResultPoint()
            pointC = getFirstDifferent(Point(cx - 7, cy + 7), false, -1, 1).toResultPoint()
            pointD = getFirstDifferent(Point(cx - 7, cy - 7), false, -1, -1).toResultPoint()
        }

        //Compute the center of the rectangle
        var pointx = Float32(pointA.getX() + pointD.getX() + pointB.getX() + pointC.getX()) / 4.0f32
        var pointy = Float32(pointA.getY() + pointD.getY() + pointB.getY() + pointC.getY()) / 4.0f32

        var pointx_o = round(pointx)
        var pointy_o = round(pointy)

        /*QHT - start: round IEEE-754 规则 与四舍五入 规则差异 补丁*/
        var pointx_d = Int64(pointx) % 2
        var pointx_f = pointx - Float32(Int64(pointx))
        if (pointx_d == 0 && pointx_f == 0.5) {
            pointx_o = pointx_o + 1.0
        }

        var pointy_d = Int64(pointy) % 2
        var pointy_f = pointy - Float32(Int64(pointy))
        if (pointy_d == 0 && pointy_f == 0.5) {
            pointy_o = pointy_o + 1.0
        }

        var cx: Int64 = Int64(pointx_o)
        var cy: Int64 = Int64(pointy_o)

        // Redetermine the white rectangle starting from previously computed center.
        // This will ensure that we end up with a white rectangle in center bull's eye
        // in order to compute a more accurate center.
        try {
            var cornerPoints: Array<ResultPoint> = WhiteRectangleDetector(image, 15, cx, cy).detect()
            pointA = cornerPoints[0]
            pointB = cornerPoints[1]
            pointC = cornerPoints[2]
            pointD = cornerPoints[3]
        } catch (e: NotFoundException) {
            // This exception can be in case the initial rectangle is white
            // In that case we try to expand the rectangle.
            pointA = getFirstDifferent(Point(cx + 7, cy - 7), false, 1, -1).toResultPoint()
            pointB = getFirstDifferent(Point(cx + 7, cy + 7), false, 1, 1).toResultPoint()
            pointC = getFirstDifferent(Point(cx - 7, cy + 7), false, -1, 1).toResultPoint()
            pointD = getFirstDifferent(Point(cx - 7, cy - 7), false, -1, -1).toResultPoint()
        }

        // Recompute the center of the rectangle
        cx = MathUtils.round(Float32((pointA.getX() + pointD.getX() + pointB.getX() + pointC.getX()) / 4.0f32))
        cy = MathUtils.round(Float32((pointA.getY() + pointD.getY() + pointB.getY() + pointC.getY()) / 4.0f32))

        return Point(cx, cy)
    }

    /**
     * Gets the Aztec code corners from the bull's eye corners and the parameters.
     *
     * @param bullsEyeCorners the array of bull's eye corners
     * @return the array of aztec code corners
     */
    private func getMatrixCornerPoints(bullsEyeCorners: Array<ResultPoint>): Array<ResultPoint> {
        return expandSquare(bullsEyeCorners, 2 * nbCenterLayers, getDimension());
    }

    /**
     * Creates a BitMatrix by sampling the provided image.
     * topLeft, topRight, bottomRight, and bottomLeft are the centers of the squares on the
     * diagonal just outside the bull's eye.
     */
    private func sampleGrid(
        image: BitMatrix,
        topLeft: ResultPoint,
        topRight: ResultPoint,
        bottomRight: ResultPoint,
        bottomLeft: ResultPoint
    ): BitMatrix {
        var sampler: GridSampler = GridSampler.getInstance()
        var dimension: Int64 = getDimension()

        var low: Float64 = Float64(dimension) / 2.0f64 - Float64(nbCenterLayers)
        var high: Float64 = Float64(dimension) / 2.0f64 + Float64(nbCenterLayers)

        return sampler.sampleGrid(
            image,
            dimension,
            dimension,
            low,
            low, // topleft
            high,
            low, // topright
            high,
            high, // bottomright
            low,
            high, // bottomleft
            Float64(topLeft.getX()),
            Float64(topLeft.getY()),
            Float64(topRight.getX()),
            Float64(topRight.getY()),
            Float64(bottomRight.getX()),
            Float64(bottomRight.getY()),
            Float64(bottomLeft.getX()),
            Float64(bottomLeft.getY())
        )
    }

    /**
     * Samples a line.
     *
     * @param p1   start point (inclusive)
     * @param p2   end point (exclusive)
     * @param size number of bits
     * @return the array of bits as an int (first bit is high-order bit of result)
     */
    private func sampleLine(p1: ResultPoint, p2: ResultPoint, size: Int64): Int64 {
        var result: Int64 = 0

        var d: Float32 = distance(p1, p2)
        var moduleSize: Float32 = d / Float32(size)
        var px: Float32 = p1.getX()
        var py: Float32 = p1.getY()
        var dx: Float32 = moduleSize * (p2.getX() - p1.getX()) / d
        var dy: Float32 = moduleSize * (p2.getY() - p1.getY()) / d
        for (i in 0..size) {
            if (image.get(MathUtils.round(px + Float32(i) * dx), MathUtils.round(py + Float32(i) * dy))) {
                result |= 1 << (size - i - 1)
            }
        }
        return result
    }

    /**
     * @return true if the border of the rectangle passed in parameter is compound of white points only
     * or black points only
     */
    private func isWhiteOrBlackRectangle(
        p1: Point,
        p2: Point,
        p3: Point,
        p4: Point
    ): Bool {
        var corr: Int64 = 3

        var p1_new = Point(max(0, p1.getX() - corr), min(image.getHeight() - 1, p1.getY() + corr));
        var p2_new = Point(max(0, p2.getX() - corr), max(0, p2.getY() - corr));
        var p3_new = Point(
            min(image.getWidth() - 1, p3.getX() + corr),
            max(0, min(image.getHeight() - 1, p3.getY() - corr))
        );
        var p4_new = Point(
            min(image.getWidth() - 1, p4.getX() + corr),
            min(image.getHeight() - 1, p4.getY() + corr)
        );

        var cInit: Int64 = getColor(p4_new, p1_new)

        if (cInit == 0) {
            return false
        }

        var c: Int64 = getColor(p1_new, p2_new)

        if (c != cInit) {
            return false
        }

        c = getColor(p2_new, p3_new)

        if (c != cInit) {
            return false
        }

        c = getColor(p3_new, p4_new)

        return c == cInit
    }

    /**
     * Gets the color of a segment
     *
     * @return 1 if segment more than 90% black, -1 if segment is more than 90% white, 0 else
     */
    private func getColor(p1: Point, p2: Point): Int64 {
        var d: Float32 = distance(p1, p2)
        if (d == 0.0f32) {
            return 0
        }
        var dx: Float32 = Float32(p2.getX() - p1.getX()) / d
        var dy: Float32 = Float32(p2.getY() - p1.getY()) / d
        var error: Int64 = 0

        var px: Float32 = Float32(p1.getX())
        var py: Float32 = Float32(p1.getY())

        var colorModel: Bool = image.get(p1.getX(), p1.getY())

        var iMax: Int64 = Int64(floor(d))
        for (i in 0..iMax) {
            if (image.get(MathUtils.round(px), MathUtils.round(py)) != colorModel) {
                error++
            }
            px += dx
            py += dy
        }

        var errRatio: Float32 = Float32(error) / d

        if (errRatio > 0.1f32 && errRatio < 0.9f32) {
            return 0
        }

        if ((errRatio <= 0.1f32) == colorModel) {
            return 1
        } else {
            return -1
        }
    }

    /**
     * Gets the coordinate of the first point with a different color in the given direction
     */
    private func getFirstDifferent(initPoint: Point, color: Bool, dx: Int64, dy: Int64): Point {
        var x: Int64 = initPoint.getX() + dx
        var y: Int64 = initPoint.getY() + dy

        while (isValid(x, y) && image.get(x, y) == color) {
            x += dx
            y += dy
        }

        x -= dx
        y -= dy

        while (isValid(x, y) && image.get(x, y) == color) {
            x += dx
        }
        x -= dx

        while (isValid(x, y) && image.get(x, y) == color) {
            y += dy
        }
        y -= dy

        return Point(x, y)
    }

    /**
     * Expand the square represented by the corner points by pushing out equally in all directions
     *
     * @param cornerPoints the corners of the square, which has the bull's eye at its center
     * @param oldSide the original length of the side of the square in the target bit matrix
     * @param newSide the length of the size of the square in the target bit matrix
     * @return the corners of the expanded square
     */
    private static func expandSquare(cornerPoints: Array<ResultPoint>, oldSide: Int64, newSide: Int64): Array<ResultPoint> {
        var ratio: Float32 = Float32(newSide) / (2.0f32 * Float32(oldSide))
        var dx: Float32 = cornerPoints[0].getX() - cornerPoints[2].getX()
        var dy: Float32 = cornerPoints[0].getY() - cornerPoints[2].getY()
        var centerx: Float32 = (cornerPoints[0].getX() + cornerPoints[2].getX()) / 2.0f32
        var centery: Float32 = (cornerPoints[0].getY() + cornerPoints[2].getY()) / 2.0f32

        var result0: ResultPoint = ResultPoint(centerx + ratio * dx, centery + ratio * dy)
        var result2: ResultPoint = ResultPoint(centerx - ratio * dx, centery - ratio * dy)

        dx = cornerPoints[1].getX() - cornerPoints[3].getX()
        dy = cornerPoints[1].getY() - cornerPoints[3].getY()
        centerx = (cornerPoints[1].getX() + cornerPoints[3].getX()) / 2.0f32
        centery = (cornerPoints[1].getY() + cornerPoints[3].getY()) / 2.0f32
        var result1: ResultPoint = ResultPoint(centerx + ratio * dx, centery + ratio * dy)
        var result3: ResultPoint = ResultPoint(centerx - ratio * dx, centery - ratio * dy)

        return [result0, result1, result2, result3]
    }

    private func isValid(x: Int64, y: Int64): Bool {
        return x >= 0 && x < image.getWidth() && y >= 0 && y < image.getHeight()
    }

    private func isValid(point: ResultPoint): Bool {
        var x: Int64 = MathUtils.round(Float32(point.getX()))
        var y: Int64 = MathUtils.round(Float32(point.getY()))
        return isValid(x, y)
    }

    private static func distance(a: Point, b: Point): Float32 {
        return MathUtils.distance(Float32(a.getX()), Float32(a.getY()), Float32(b.getX()), Float32(b.getY()))
    }

    private static func distance(a: ResultPoint, b: ResultPoint): Float32 {
        return MathUtils.distance(a.getX(), a.getY(), b.getX(), b.getY())
    }

    private func getDimension(): Int64 {
        if (compact) {
            return 4 * nbLayers + 11
        }
        return 4 * nbLayers + 2 * ((2 * nbLayers + 6) / 15) + 15
    }
}
