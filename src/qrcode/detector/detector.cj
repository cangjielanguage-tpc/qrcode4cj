/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.qrcode.detector

import QRCode4cj.qrcode.decoder.*
import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import QRCode4cj.common.detector.*
import std.math.*

/**
 * Encapsulates logic that can detect a QR Code in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.
 */
public open class Detector {
    private var image: BitMatrix
    private var resultPointCallback: Option<ResultPointCallback> = None

    public init(image: BitMatrix) {
        this.image = image
    }

    protected func getImage(): BitMatrix {
        return image
    }

    protected func getResultPointCallback(): Option<ResultPointCallback> {
        return resultPointCallback
    }

    /**
     * <p>Detects a QR Code in an image.</p>
     *
     * @return {@link DetectorResult} encapsulating results of detecting a QR Code
     * @throws Qrcoder4cjNotFoundException if QR Code cannot be found
     * @throws Qrcoder4cjFormatException if a QR Code cannot be decoded
     */
    public func detect(): DetectorResult {
        return detect(HashMap<DecodeHintType, Any>());
    }

    /**
     * <p>Detects a QR Code in an image.</p>
     *
     * @param hints optional hints to detector
     * @return {@link DetectorResult} encapsulating results of detecting a QR Code
     * @throws Qrcoder4cjNotFoundException if QR Code cannot be found
     * @throws Qrcoder4cjFormatException if a QR Code cannot be decoded
     */
    public func detect(hints: HashMap<DecodeHintType, Any>): DetectorResult {
        resultPointCallback = hints.get(DecodeHintType.NEED_RESULT_POINT_CALLBACK) as ResultPointCallback
        var finder = FinderPatternFinder(image, resultPointCallback)
        var info = finder.find(hints)
        return processFinderPatternInfo(info)
    }

    protected func processFinderPatternInfo(info: FinderPatternInfo): DetectorResult {
        let topLeft: FinderPattern = info.getTopLeft();
        let topRight: FinderPattern = info.getTopRight();
        let bottomLeft: FinderPattern = info.getBottomLeft();

        let moduleSize: Float64 = calculateModuleSize(topLeft, topRight, bottomLeft);
        if (moduleSize < 1.0f64) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }
        let dimension: Int64 = computeDimension(topLeft, topRight, bottomLeft, moduleSize);
        let provisionalVersion: Version = Version.getProvisionalVersionForDimension(dimension);
        let modulesBetweenFPCenters: Int64 = provisionalVersion.getDimensionForVersion() - 7

        var alignmentPattern: AlignmentPattern = AlignmentPattern()

        // Anything above version 1 has an alignment pattern
        if (provisionalVersion.getAlignmentPatternCenters().size > 0) {
            // Guess where a "bottom right" finder pattern would have been
            let bottomRightX: Float64 = Float64(topRight.getX() - topLeft.getX() + bottomLeft.getX())
            let bottomRightY: Float64 = Float64(topRight.getY() - topLeft.getY() + bottomLeft.getY())

            // Estimate that alignment pattern is closer by 3 modules
            // from "bottom right" to known top left location
            let correctionToTopLeft: Float64 = 1.0f64 - 3.0f64 / Float64(modulesBetweenFPCenters)
            let estAlignmentX: Int64 = Int64(topLeft.getX() + Float32(correctionToTopLeft) * (Float32(bottomRightX) -
                    topLeft.getX()))
            let estAlignmentY: Int64 = Int64(topLeft.getY() + Float32(correctionToTopLeft) * (Float32(bottomRightY) -
                    topLeft.getY()))

            // Kind of arbitrary -- expand search radius before giving up
            var i: Int64 = 4;
            while (i <= 16) {
                try {
                    alignmentPattern = findAlignmentInRegion(
                        moduleSize,
                        estAlignmentX,
                        estAlignmentY,
                        Float64(i)
                    )
                    break
                } catch (re: Qrcoder4cjNotFoundException) {
                    // try next round
                }
                i <<= 1
            }
            // If we didn't find alignment pattern... well try anyway without it
        }

        let transform: PerspectiveTransform = createTransform(topLeft, topRight, bottomLeft, alignmentPattern, dimension
        );

        let bits: BitMatrix = sampleGrid(image, transform, dimension);

        var points: Array<ResultPoint>
        if (alignmentPattern.flag == true) {
            points = [bottomLeft, topLeft, topRight, alignmentPattern]
        } else {
            points = [bottomLeft, topLeft, topRight]
        }
        return DetectorResult(bits, points);
    }

    private static func createTransform(
        topLeft: ResultPoint,
        topRight: ResultPoint,
        bottomLeft: ResultPoint,
        alignmentPattern: ResultPoint,
        dimension: Int64
    ): PerspectiveTransform {
        let dimMinusThree: Float64 = Float64(dimension) - 3.5f64
        var bottomRightX: Float64
        var bottomRightY: Float64
        var sourceBottomRightX: Float64
        var sourceBottomRightY: Float64
        if (alignmentPattern.flag == true) {
            bottomRightX = Float64(alignmentPattern.getX())
            bottomRightY = Float64(alignmentPattern.getY())
            sourceBottomRightX = dimMinusThree - 3.0f64
            sourceBottomRightY = sourceBottomRightX
        } else {
            // Don't have an alignment pattern, just make up the bottom-right point
            bottomRightX = Float64((topRight.getX() - topLeft.getX()) + bottomLeft.getX())
            bottomRightY = Float64((topRight.getY() - topLeft.getY()) + bottomLeft.getY())
            sourceBottomRightX = dimMinusThree
            sourceBottomRightY = dimMinusThree
        }

        return PerspectiveTransform.quadrilateralToQuadrilateral(
            3.5f64,
            3.5f64,
            dimMinusThree,
            3.5f64,
            sourceBottomRightX,
            sourceBottomRightY,
            3.5f64,
            dimMinusThree,
            Float64(topLeft.getX()),
            Float64(topLeft.getY()),
            Float64(topRight.getX()),
            Float64(topRight.getY()),
            Float64(bottomRightX),
            Float64(bottomRightY),
            Float64(bottomLeft.getX()),
            Float64(bottomLeft.getY())
        );
    }

    private static func sampleGrid(
        image: BitMatrix,
        transform: PerspectiveTransform,
        dimension: Int64
    ): BitMatrix {
        let sampler: GridSampler = GridSampler.getInstance();
        return sampler.sampleGrid(image, dimension, dimension, transform);
    }

    /**
     * <p>Computes the dimension (number of modules on a size) of the QR Code based on the position
     * of the finder patterns and estimated module size.</p>
     */
    private static func computeDimension(
        topLeft: ResultPoint,
        topRight: ResultPoint,
        bottomLeft: ResultPoint,
        moduleSize: Float64
    ): Int64 {
        let tltrCentersDimension: Int64 = MathUtils.round(ResultPoint.distance(topLeft, topRight) / Float32(moduleSize));
        let tlblCentersDimension: Int64 = MathUtils.round(ResultPoint.distance(topLeft, bottomLeft) / Float32(moduleSize)
        );
        var dimension: Int64 = ((tltrCentersDimension + tlblCentersDimension) / 2) + 7
        match (dimension & 0x03) {
            // mod 4
            case 0 => dimension++

            // 1? do nothing
            case 2 => dimension--
            case 3 => throw Qrcoder4cjNotFoundException.getNotFoundInstance();
            case _ => ()
        }
        return dimension
    }

    /**
     * <p>Computes an average estimated module size based on estimated derived from the positions
     * of the three finder patterns.</p>
     *
     * @param topLeft detected top-left finder pattern center
     * @param topRight detected top-right finder pattern center
     * @param bottomLeft detected bottom-left finder pattern center
     * @return estimated module size
     */
    protected func calculateModuleSize(
        topLeft: ResultPoint,
        topRight: ResultPoint,
        bottomLeft: ResultPoint
    ): Float64 {
        // Take the average
        return (calculateModuleSizeOneWay(topLeft, topRight) + calculateModuleSizeOneWay(topLeft, bottomLeft)) / 2.0f64
    }

    /**
     * <p>Estimates module size based on two finder patterns -- it uses
     * {@link #sizeOfBlackWhiteBlackRunBothWays(int, int, int, int)} to figure the
     * width of each, measuring along the axis between their centers.</p>
     */
    private func calculateModuleSizeOneWay(pattern: ResultPoint, otherPattern: ResultPoint): Float64 {
        let moduleSizeEst1: Float64 = sizeOfBlackWhiteBlackRunBothWays(
            Int64(pattern.getX()),
            Int64(pattern.getY()),
            Int64(otherPattern.getX()),
            Int64(otherPattern.getY())
        );
        let moduleSizeEst2: Float64 = sizeOfBlackWhiteBlackRunBothWays(
            Int64(otherPattern.getX()),
            Int64(otherPattern.getY()),
            Int64(pattern.getX()),
            Int64(pattern.getY())
        );
        if (moduleSizeEst1.isNaN()) {
            return moduleSizeEst2 / 7.0f64
        }
        if (moduleSizeEst2.isNaN()) {
            return moduleSizeEst1 / 7.0f64
        }

        // Average them, and divide by 7 since we've counted the width of 3 black modules,
        // and 1 white and 1 black module on either side. Ergo, divide sum by 14.
        return (moduleSizeEst1 + moduleSizeEst2) / 14.0f64
    }

    /**
     * See {@link #sizeOfBlackWhiteBlackRun(int, int, int, int)}; computes the total width of
     * a finder pattern by looking for a black-white-black run from the center in the direction
     * of another point (another finder pattern center), and in the opposite direction too.
     */
    private func sizeOfBlackWhiteBlackRunBothWays(fromX: Int64, fromY: Int64, toX: Int64, toY: Int64): Float64 {
        var result: Float64 = sizeOfBlackWhiteBlackRun(fromX, fromY, toX, toY);

        // Now count other way -- don't run off image though of course
        var scale: Float64 = 1.0f64;
        var otherToX: Int64 = fromX - (toX - fromX)
        if (otherToX < 0) {
            scale = Float64(fromX) / Float64(fromX - otherToX)
            otherToX = 0
        } else if (otherToX >= image.getWidth()) {
            scale = Float64(image.getWidth() - 1 - fromX) / Float64(otherToX - fromX)
            otherToX = image.getWidth() - 1
        }
        var otherToY: Int64 = Int64(Float64(fromY) - Float64(toY - fromY) * scale)

        scale = 1.0f64
        if (otherToY < 0) {
            scale = Float64(fromY) / Float64(fromY - otherToY)
            otherToY = 0
        } else if (otherToY >= image.getHeight()) {
            scale = Float64(image.getHeight() - 1 - fromY) / Float64(otherToY - fromY)
            otherToY = image.getHeight() - 1
        }
        otherToX = Int64(Float64(fromX) + Float64(otherToX - fromX) * scale)

        result += sizeOfBlackWhiteBlackRun(fromX, fromY, otherToX, otherToY)

        // Middle pixel is double-counted this way; subtract 1
        return result - 1.0f64
    }

    /**
     * <p>This method traces a line from a point in the image, in the direction towards another point.
     * It begins in a black region, and keeps going until it finds white, then black, then white again.
     * It reports the distance from the start to this point.</p>
     *
     * <p>This is used when figuring out how wide a finder pattern is, when the finder pattern
     * may be skewed or rotated.</p>
     */
    private func sizeOfBlackWhiteBlackRun(fromX: Int64, fromY: Int64, toX: Int64, toY: Int64): Float64 {
        // Mild variant of Bresenham's algorithm;
        var fromX_: Int64 = fromX
        var fromY_: Int64 = fromY
        var toX_: Int64 = toX
        var toY_: Int64 = toY

        let steep: Bool = abs(toY_ - fromY_) > abs(toX_ - fromX_)

        if (steep) {
            var temp: Int64 = fromX_
            fromX_ = fromY_
            fromY_ = temp
            temp = toX_
            toX_ = toY_
            toY_ = temp
        }

        let dx: Int64 = abs(toX_ - fromX_);
        let dy: Int64 = abs(toY_ - fromY_);
        var error: Int64 = -dx / 2
        let xstep: Int64 = getxstep(fromX_, toX_)
        let ystep: Int64 = getystep(fromY_, toY_)

        // In black pixels, looking for white, first or second time.
        var state: Int64 = 0;

        // Loop up until x == toX_, but not beyond
        let xLimit: Int64 = toX_ + xstep
        var x: Int64 = fromX_
        var y: Int64 = fromY_
        while (x != xLimit) {
            let realX: Int64 = getrealX(steep, x, y)
            let realY: Int64 = getrealY(steep, x, y)

            // Does current pixel mean we have moved white to black or vice versa?
            // Scanning black in state 0,2 and white in state 1, so if we find the wrong
            // color, advance to next state or end if we are in state 2 already
            if ((state == 1) == image.get(realX, realY)) {
                if (state == 2) {
                    return Float64(MathUtils.distance(x, y, fromX_, fromY_))
                }
                state++
            }

            error += dy
            if (error > 0) {
                if (y == toY_) {
                    break
                }
                y += ystep
                error -= dx
            }

            x += xstep
        }

        // Found black-white-black; give the benefit of the doubt that the next pixel outside the image
        // is "white" so this last point at (toX+xStep,toY) is the right ending. This is really a
        // small approximation; (toX+xStep,toY+yStep) might be really correct. Ignore this.
        if (state == 2) {
            return Float64(MathUtils.distance(toX_ + xstep, toY_, fromX_, fromY_))
        }

        // else we didn't find even black-white-black; no estimate is really possible
        return Float64.NaN;
    }

    private func getxstep(fromX_: Int64, toX_: Int64): Int64 {
        if (fromX_ < toX_) {
            1
        } else {
            -1
        }
    }

    private func getystep(fromY_: Int64, toY_: Int64): Int64 {
        if (fromY_ < toY_) {
            1
        } else {
            -1
        }
    }

    private func getrealX(steep: Bool, x: Int64, y: Int64): Int64 {
        if (steep) {
            y
        } else {
            x
        }
    }

    private func getrealY(steep: Bool, x: Int64, y: Int64): Int64 {
        if (steep) {
            x
        } else {
            y
        }
    }

    /**
     * <p>Attempts to locate an alignment pattern in a limited region of the image, which is
     * guessed to contain it. This method uses {@link AlignmentPattern}.</p>
     *
     * @param overallEstModuleSize estimated module size so far
     * @param estAlignmentX x coordinate of center of area probably containing alignment pattern
     * @param estAlignmentY y coordinate of above
     * @param allowanceFactor number of pixels in all directions to search from the center
     * @return {@link AlignmentPattern} if found, or null otherwise
     * @throws Qrcoder4cjNotFoundException if an unexpected error occurs during detection
     */
    private func findAlignmentInRegion(
        overallEstModuleSize: Float64,
        estAlignmentX: Int64,
        estAlignmentY: Int64,
        allowanceFactor: Float64
    ): AlignmentPattern {
        // Look for an alignment pattern (3 modules in size) around where it
        // should be
        let allowance: Int64 = Int64(allowanceFactor * overallEstModuleSize)
        let alignmentAreaLeftX: Int64 = max(0, estAlignmentX - allowance);
        let alignmentAreaRightX: Int64 = min(image.getWidth() - 1, estAlignmentX + allowance);
        if (alignmentAreaRightX - alignmentAreaLeftX < Int64(overallEstModuleSize * 3.0f64)) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        let alignmentAreaTopY: Int64 = max(0, estAlignmentY - allowance);
        let alignmentAreaBottomY: Int64 = min(image.getHeight() - 1, estAlignmentY + allowance);
        if (alignmentAreaBottomY - alignmentAreaTopY < Int64(overallEstModuleSize * 3.0f64)) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }
        var alignmentFinder: AlignmentPatternFinder = AlignmentPatternFinder(
            image,
            alignmentAreaLeftX,
            alignmentAreaTopY,
            alignmentAreaRightX - alignmentAreaLeftX,
            alignmentAreaBottomY - alignmentAreaTopY,
            Float32(overallEstModuleSize),
            resultPointCallback
        )

        return alignmentFinder.find();
    }
}
