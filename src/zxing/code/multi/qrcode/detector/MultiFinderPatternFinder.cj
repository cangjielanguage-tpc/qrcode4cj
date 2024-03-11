package zxing.code.multi.qrcode.detector

import zxing.code.common.DecodeHintType
import zxing.code.common.NotFoundException
import zxing.code.common.ResultPoint
import zxing.code.common.ResultPointCallback
import zxing.code.common.BitMatrix
import zxing.code.qrcode.detector.FinderPattern
import zxing.code.qrcode.detector.FinderPatternFinder
import zxing.code.qrcode.detector.FinderPatternInfo
from std import math.*
from std import collection.*

/**
 * <p>This class attempts to find finder patterns in a QR Code. Finder patterns are the square
 * markers at three corners of a QR Code.</p>
 *
 * <p>This class is thread-safe but not reentrant. Each thread must allocate its own object.
 *
 * <p>In contrast to {@link FinderPatternFinder}, this class will return an array of all possible
 * QR code locations in the image.</p>
 *
 * <p>Use the TRY_HARDER hint to ask for a more thorough detection.</p>
 *
 * @author Sean Owen
 * @author Hannes Erven
 */
public class MultiFinderPatternFinder <: FinderPatternFinder {
    // TODO MIN_MODULE_COUNT and MAX_MODULE_COUNT would be great hints to ask the user for
    // since it limits the number of regions to decode

    // max. legal count of modules per QR code edge (177)
    private static var MAX_MODULE_COUNT_PER_EDGE: Float32 = 180.0

    // min. legal count per modules per QR code edge (11)
    private static var MIN_MODULE_COUNT_PER_EDGE: Float32 = 9.0

    /**
     * More or less arbitrary cutoff point for determining if two finder patterns might belong
     * to the same code if they differ less than DIFF_MODSIZE_CUTOFF_PERCENT percent in their
     * estimated modules sizes.
     */
    private static var DIFF_MODSIZE_CUTOFF_PERCENT: Float32 = 0.05f32

    /**
     * More or less arbitrary cutoff point for determining if two finder patterns might belong
     * to the same code if they differ less than DIFF_MODSIZE_CUTOFF pixels/module in their
     * estimated modules sizes.
     */
    private static var DIFF_MODSIZE_CUTOFF: Float32 = 0.5f32

    /**
     * A comparator that orders FinderPatterns by their estimated module size.
     */
    private func ModuleSizeComparator(center1: FinderPattern, center2: FinderPattern): Ordering {
        var value: Float32 = center2.getEstimatedModuleSize() - center1.getEstimatedModuleSize()
        if (value < 0.0) {
            return Ordering.LT
        } else if (value > 0.0) {
            return Ordering.GT
        }
        return Ordering.EQ
    }

    init(image: BitMatrix, resultPointCallback: ?ResultPointCallback) {
        super(image, resultPointCallback)
    }

    /**
     * @return the 3 best {@link FinderPattern}s from our list of candidates. The "best" are
     * those that have been detected at least 2 times, and whose module
     * size differs from the average among those patterns the least
     * @throws NotFoundException if 3 such finder patterns do not exist
     */
    private func selectMultipleBestPatterns(): Array<Array<FinderPattern>> {
        var possibleCenters: ArrayList<FinderPattern> = ArrayList<FinderPattern>()
        var PossibleCentersGotten = getPossibleCenters()
        for (fpN in 0..PossibleCentersGotten.size) {
            var fp: FinderPattern = PossibleCentersGotten[fpN]
            if (fp.getCount() >= 2) {
                possibleCenters.append(fp)
            }
        }
        var size: Int64 = possibleCenters.size

        if (size < 3) {
            // Couldn't find enough finder patterns
            throw NotFoundException.getNotFoundInstance()
        }

        /*
         * Begin HE modifications to safely detect multiple codes of equal size
         */
        if (size == 3) {
            return [possibleCenters.toArray()]
        }

        // Sort by estimated module size to speed up the upcoming checks
        possibleCenters.sortBy(this.ModuleSizeComparator, stable: true);

        /*
         * Now lets start: build a list of tuples of three finder locations that
         * - feature similar module sizes
         * - are placed in a distance so the estimated module count is within the QR specification
         * - have similar distance between upper left/right and left top/bottom finder patterns
         * - form a triangle with 90° angle (checked by comparing top right/bottom left distance
         * with pythagoras)
         *
         * Note: we allow each point to be used for more than one code region: this might seem
         * counterintuitive at first, but the performance penalty is not that big. At this point,
         * we cannot make a good quality decision whether the three finders actually represent
         * a QR code, or are just by chance laid out so it looks like there might be a QR code there.
         * So, if the layout seems right, lets have the decoder try to decode.
         */
        var results: ArrayList<Array<FinderPattern>> = ArrayList<Array<FinderPattern>>();

        for (i1 in 0..(size - 2)) {
            var p1: FinderPattern = possibleCenters[i1]

            for (i2 in (i1 + 1)..(size - 1)) {
                var p2: FinderPattern = possibleCenters[i2]

                // Compare the expected module sizes; if they are really off, skip
                var vModSize12: Float32 = (p1.getEstimatedModuleSize() - p2.getEstimatedModuleSize()) / min(
                    p1.getEstimatedModuleSize(), p2.getEstimatedModuleSize())
                var vModSize12A: Float32 = abs(p1.getEstimatedModuleSize() - p2.getEstimatedModuleSize())
                if (vModSize12A > DIFF_MODSIZE_CUTOFF && vModSize12 >= DIFF_MODSIZE_CUTOFF_PERCENT) {
                    // break, since elements are ordered by the module size deviation there cannot be
                    // any more interesting elements for the given p1.
                    break
                }

                for (i3 in (i2 + 1)..size) {
                    var p3: FinderPattern = possibleCenters[i3]

                    // Compare the expected module sizes; if they are really off, skip
                    var vModSize23: Float32 = (p2.getEstimatedModuleSize() - p3.getEstimatedModuleSize()) / min(
                        p2.getEstimatedModuleSize(), p3.getEstimatedModuleSize())
                    var vModSize23A: Float32 = abs(p2.getEstimatedModuleSize() - p3.getEstimatedModuleSize())
                    if (vModSize23A > DIFF_MODSIZE_CUTOFF && vModSize23 >= DIFF_MODSIZE_CUTOFF_PERCENT) {
                        // break, since elements are ordered by the module size deviation there cannot be
                        // any more interesting elements for the given p1.
                        break
                    }

                    var test: Array<FinderPattern> = [p1, p2, p3]
                    var testResult = FinderPatternFinder.changeFinderPatternArray(test);
                    ResultPoint.orderBestPatterns(testResult)

                    for (item in 0..testResult.size) {
                        test[item] = (testResult[item] as FinderPattern).getOrThrow()
                    }

                    // Calculate the distances: a = topleft-bottomleft, b=topleft-topright, c = diagonal
                    var info: FinderPatternInfo = FinderPatternInfo(test)
                    var dA: Float32 = ResultPoint.distance(info.getTopLeft(), info.getBottomLeft())
                    var dC: Float32 = ResultPoint.distance(info.getTopRight(), info.getBottomLeft())
                    var dB: Float32 = ResultPoint.distance(info.getTopLeft(), info.getTopRight())

                    // Check the sizes
                    var estimatedModuleCount: Float32 = (dA + dB) / (p1.getEstimatedModuleSize() * 2.0f32)
                    if (estimatedModuleCount > MAX_MODULE_COUNT_PER_EDGE || estimatedModuleCount <
                        MIN_MODULE_COUNT_PER_EDGE) {
                        continue
                    }

                    // Calculate the difference of the edge lengths in percent
                    var vABBC: Float32 = abs((dA - dB) / min(dA, dB))
                    if (vABBC >= 0.1f32) {
                        continue
                    }

                    // Calculate the diagonal length by assuming a 90° angle at topleft
                    var dCpy: Float32 = Float32(sqrt(dA * dA + dB * dB))

                    // Compare to the real distance in %
                    var vPyC: Float32 = abs((dC - dCpy) / min(dC, dCpy))

                    if (vPyC >= 0.1f32) {
                        continue
                    }

                    // All tests passed!
                    results.append(test)
                }
            }
        }

        if (results.size > 0) {
            return results.toArray()
        }

        // Nothing found!
        throw NotFoundException.getNotFoundInstance()
    }

    public func findMulti(hints: HashMap<DecodeHintType, Any>): Array<FinderPatternInfo> {
        var tryHarder: Bool = false
        if (hints.size > 0 && hints.contains(DecodeHintType.TRY_HARDER)) {
            tryHarder = true
        }
        var image: BitMatrix = getImage()
        var maxI: Int64 = image.getHeight()
        var maxJ: Int64 = image.getWidth()

        // We are looking for black/white/black/white/black modules in
        // 1:1:3:1:1 ratio; this tracks the number of such modules seen so far

        // Let's assume that the maximum version QR Code we support takes up 1/4 the height of the
        // image, and then account for the center being 3 modules in size. This gives the smallest
        // number of pixels the center could be, so skip this often. When trying harder, look for all
        // QR versions regardless of how dense they are.
        var iSkip: Int64 = (3 * maxI) / (4 * MAX_MODULES)
        if (iSkip < MIN_SKIP || tryHarder) {
            iSkip = MIN_SKIP
        }

        var stateCount: Array<Int64> = Array<Int64>(5, item: 0)

        var i: Int64 = iSkip - 1
        while (i < maxI) {
            // Get a row of black/white values
            doClearCounts(stateCount)
            var currentState: Int64 = 0
            for (j in 0..maxJ) {
                if (image.get(j, i)) {
                    // Black pixel
                    if ((currentState & 1) == 1) { // Counting white pixels
                        currentState++
                    }
                    stateCount[currentState] = stateCount[currentState] + 1
                } else { // White pixel
                    if ((currentState & 1) == 0) { // Counting black pixels
                        if (currentState == 4) { // A winner?
                            if (foundPatternCross(stateCount) && handlePossibleCenter(stateCount, i, j)) { // Yes
                                // Clear state to start looking again
                                currentState = 0
                                doClearCounts(stateCount)
                            } else { // No, shift counts back by two
                                doShiftCounts2(stateCount)
                                currentState = 3
                            }
                        } else {
                            currentState++
                            stateCount[currentState] = stateCount[currentState] + 1
                        }
                    } else { // Counting white pixels
                        stateCount[currentState] = stateCount[currentState] + 1
                    }
                }
            } // for j=...

            if (foundPatternCross(stateCount)) {
                handlePossibleCenter(stateCount, i, maxJ)
            }
            i += iSkip
        } // for i=iSkip-1 ...

        return returnfindMulti()
    }

    private func returnfindMulti(): Array<FinderPatternInfo> {
        var patternInfo: Array<Array<FinderPattern>> = selectMultipleBestPatterns()
        var result: ArrayList<FinderPatternInfo> = ArrayList<FinderPatternInfo>()
        for (patternN in 0..patternInfo.size) {
            var pattern: Array<FinderPattern> = patternInfo[patternN]
            var patternResult = FinderPatternFinder.changeFinderPatternArray(pattern);
            ResultPoint.orderBestPatterns(patternResult)
            for (i in 0..patternResult.size) {
                pattern[i] = (patternResult[i] as FinderPattern).getOrThrow()
            }
            result.append(FinderPatternInfo(pattern))
        }
        return result.toArray()
    }
}
