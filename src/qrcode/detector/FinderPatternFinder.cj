/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.qrcode.detector

import std.time.*
import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.math.*

/**
 * This class attempts to find finder patterns in a QR Code. Finder patterns are the square
 * markers at three corners of a QR Code.
 *
 * This class is thread-safe but not reentrant. Each thread must allocate its own object.
 *
 */
public open class FinderPatternFinder {
    private static let CENTER_QUORUM: Int64 = 2;
    private static let moduleComparator: EstimatedModuleComparator = EstimatedModuleComparator();
    protected static let MIN_SKIP: Int64 = 3; // 1 pixel/module times 3 modules/center
    protected static let MAX_MODULES: Int64 = 97; // support up to version 20 for mobile clients

    private var image: BitMatrix
    private var possibleCenters: ArrayList<FinderPattern>
    private var hasSkipped: Bool = false;
    private var crossCheckStateCount: Array<Int64>
    private var resultPointCallback: ?ResultPointCallback

    /**
     * Creates a finder that will search the image for three finder patterns.
     *
     * @param image image to search
     */
    public init(image: BitMatrix) {
        this(image, None);
    }

    public init(image: BitMatrix, resultPointCallback: ?ResultPointCallback) {
        this.image = image
        this.possibleCenters = ArrayList<FinderPattern>()
        this.crossCheckStateCount = Array<Int64>(5, repeat: 0)
        this.resultPointCallback = resultPointCallback
    }

    protected func getImage(): BitMatrix {
        return image
    }

    protected func getPossibleCenters(): ArrayList<FinderPattern> {
        return possibleCenters
    }

    func find(hints: HashMap<DecodeHintType, Any>): FinderPatternInfo {
        let tryHarder: Bool = hints.size != 0 && hints.contains(DecodeHintType.TRY_HARDER)
        let maxI: Int64 = image.getHeight();
        let maxJ: Int64 = image.getWidth();

        // We are looking for black/white/black/white/black modules in
        // 1:1:3:1:1 ratio; this tracks the number of such modules seen so far

        // Let's assume that the maximum version QR Code we support takes up 1/4 the height of the image,
        // and then account for the center being 3 modules in size. This gives the smallest
        // number of pixels the center could be, so skip this often. When trying harder, look for all
        // QR versions regardless of how dense they are.
        var iSkip: Int64 = exfind4(maxI, tryHarder)

        var done: Bool = false;
        var stateCount: Array<Int64> = Array<Int64>(5, repeat: 0);
        var i: Int64 = iSkip - 1
        while (i < maxI && !done) {

            // Get a row of black/white values
            doClearCounts(stateCount);
            var currentState: Int64 = 0;

            var j: Int64 = 0;
            while (j < maxJ) {
                currentState = exfind3(currentState, i, j, stateCount)
                if (!image.get(j, i)) { // White pixel
                    if ((currentState & 1) == 0) { // Counting black pixels
                        if (currentState == 4) { // A winner?
                            if (foundPatternCross(stateCount)) { // Yes
                                if (handlePossibleCenter(stateCount, i, j)) {
                                    (iSkip, i, j, done) = exfind(iSkip, done, i, j, stateCount, maxJ)
                                } else {
                                    doShiftCounts2(stateCount);
                                    currentState = 3

                                    j++
                                    continue
                                }

                                // Clear state to start looking again
                                currentState = 0
                                doClearCounts(stateCount);
                            } else { // No, shift counts back by two
                                doShiftCounts2(stateCount);
                                currentState = 3
                            }
                        } else {
                            currentState++
                            stateCount[Int64(currentState)] += 1
                        }
                    } else { // Counting white pixels
                        stateCount[Int64(currentState)] += 1
                    }
                }

                j++
            }
            (iSkip, done) = exfind2(iSkip, done, i, stateCount, maxJ)

            i += iSkip
        }

        let patternInfo: Array<FinderPattern> = selectBestPatterns();
        var resultPointArray: Array<ResultPoint> = changeFinderPatternArray(patternInfo);
        exfind5(resultPointArray, patternInfo)

        return FinderPatternInfo(patternInfo);
    }

    private func exfind(iSkip: Int64, done: Bool, i: Int64, j: Int64, stateCount: Array<Int64>, maxJ: Int64): (Int64, 
        Int64, Int64, Bool) {
        // Start examining every other line. Checking each line turned out to be too
        // expensive and didn't improve performance.
        var iSkip_p = iSkip
        var i_p = i
        var j_p = j
        var done_p = done
        iSkip_p = 2
        if (hasSkipped) {
            done_p = haveMultiplyConfirmedCenters()
        } else {
            let rowSkip: Int64 = findRowSkip();
            if (rowSkip > stateCount[2]) {
                // Skip rows between row of lower confirmed center
                // and top of presumed third confirmed center
                // but back up a bit to get a full chance of detecting it,
                // entire width of center of finder pattern

                // Skip by rowSkip, but back off by stateCount[2] (size of last center of
                // pattern we saw) to be conservative, and also back off by iSkip which
                // is about to be re-added
                i_p += rowSkip - stateCount[2] - iSkip_p
                j_p = maxJ - 1
            }
        }
        return (iSkip_p, i_p, j_p, done_p)
    }

    private func exfind2(iSkip: Int64, done: Bool, i: Int64, stateCount: Array<Int64>, maxJ: Int64): (Int64, Bool) {
        var iSkip_p = iSkip
        var done_p = done
        if (foundPatternCross(stateCount)) {
            let confirmed: Bool = handlePossibleCenter(stateCount, i, maxJ);
            if (confirmed) {
                iSkip_p = stateCount[0]
                if (hasSkipped) {
                    // Found a third one
                    done_p = haveMultiplyConfirmedCenters()
                }
            }
        }
        return (iSkip_p, done_p)
    }

    private func exfind3(currentState: Int64, i: Int64, j: Int64, stateCount: Array<Int64>): Int64 {
        var currentState_p = currentState
        if (image.get(j, i)) {
            // Black pixel
            if ((currentState_p & 1) == 1) { // Counting white pixels
                currentState_p++
            }
            stateCount[Int64(currentState_p)] += 1
        }
        return currentState_p
    }

    private func exfind4(maxI: Int64, tryHarder: Bool): Int64 {
        var iSkip: Int64 = (3 * maxI) / (4 * MAX_MODULES)
        if (iSkip < MIN_SKIP || tryHarder) {
            iSkip = MIN_SKIP
        }
        return iSkip
    }

    private func exfind5(resultPointArray: Array<ResultPoint>, patternInfo: Array<FinderPattern>) {
        ResultPoint.orderBestPatterns(resultPointArray);

        for (i in 0..resultPointArray.size) {
            patternInfo[i] = (resultPointArray[i] as FinderPattern).getOrThrow()
        }
    }

    public static func changeFinderPatternArray(arrayFinder: Array<FinderPattern>): Array<ResultPoint> {
        var result: ArrayList<ResultPoint> = ArrayList<ResultPoint>();
        for (i in 0..arrayFinder.size) {
            result.append(arrayFinder[i]);
        }
        return result.toArray();
    }

    /**
     * Given a count of black/white/black/white/black pixels just seen and an end position,
     * figures the location of the center of this run.
     */
    private static func centerFromEnd(stateCount: Array<Int64>, end: Int64): Float64 {
        return Float64(end - stateCount[4] - stateCount[3]) - Float64(stateCount[2]) / 2.0f64
    }

    /**
     * @param stateCount count of black/white/black/white/black pixels just read
     * @return true iff the proportions of the counts is close enough to the 1/1/3/1/1 ratios
     * used by finder patterns to be considered a match
     */
    protected static func foundPatternCross(stateCount: Array<Int64>): Bool {
        var totalModuleSize: Int64 = 0;
        for (i in 0..5) {
            let count: Int64 = stateCount[i]
            if (count == 0) {
                return false;
            }
            totalModuleSize += count
        }
        if (totalModuleSize < 7) {
            return false;
        }
        let moduleSize: Float64 = Float64(totalModuleSize) / 7.0f64
        let maxVariance: Float64 = moduleSize / 2.0f64

        // Allow less than 50% variance from 1-1-3-1-1 proportions
        return abs(moduleSize - Float64(stateCount[0])) < maxVariance && abs(moduleSize - Float64(stateCount[1])) <
            maxVariance && abs(3.0f64 * moduleSize - Float64(stateCount[2])) < 3.0f64 * maxVariance &&
            abs(moduleSize - Float64(stateCount[3])) < maxVariance && abs(moduleSize - Float64(stateCount[4])) <
            maxVariance
    }

    /**
     * @param stateCount count of black/white/black/white/black pixels just read
     * @return true iff the proportions of the counts is close enough to the 1/1/3/1/1 ratios
     * used by finder patterns to be considered a match
     */
    protected static func foundPatternDiagonal(stateCount: Array<Int64>): Bool {
        var totalModuleSize: Int64 = 0;
        for (i in 0..5) {
            let count: Int64 = stateCount[i]
            if (count == 0) {
                return false;
            }
            totalModuleSize += count
        }
        if (totalModuleSize < 7) {
            return false;
        }
        let moduleSize: Float64 = Float64(totalModuleSize) / 7.0f64
        let maxVariance: Float64 = moduleSize / 1.333f64

        // Allow less than 75% variance from 1-1-3-1-1 proportions
        return abs(moduleSize - Float64(stateCount[0])) < maxVariance && abs(moduleSize - Float64(stateCount[1])) <
            maxVariance && abs(3.0f64 * moduleSize - Float64(stateCount[2])) < 3.0f64 * maxVariance &&
            abs(moduleSize - Float64(stateCount[3])) < maxVariance && abs(moduleSize - Float64(stateCount[4])) <
            maxVariance
    }

    private func getCrossCheckStateCount(): Array<Int64> {
        doClearCounts(crossCheckStateCount);
        return crossCheckStateCount
    }

    protected func clearCounts(counts: Array<Int64>) {
        doClearCounts(counts);
    }

    protected func shiftCounts2(stateCount: Array<Int64>) {
        doShiftCounts2(stateCount);
    }

    protected static func doClearCounts(counts: Array<Int64>) {
        let b: Range<Int64> = Range<Int64>(0, counts.size, 1, true, true, false);
        counts[b] = Array<Int64>(counts.size, repeat:0)
    }

    protected static func doShiftCounts2(stateCount: Array<Int64>) {
        stateCount[0] = stateCount[2]
        stateCount[1] = stateCount[3]
        stateCount[2] = stateCount[4]
        stateCount[3] = 1
        stateCount[4] = 0
    }

    /**
     * After a vertical and horizontal scan finds a potential finder pattern, this method
     * "cross-cross-cross-checks" by scanning down diagonally through the center of the possible
     * finder pattern to see if the same proportion is detected.
     *
     * @param centerI row where a finder pattern was detected
     * @param centerJ center of the section that appears to cross a finder pattern
     *
     * @return true if proportions are withing expected limits
     */
    private func crossCheckDiagonal(centerI: Int64, centerJ: Int64): Bool {
        var stateCount: Array<Int64> = getCrossCheckStateCount();

        // Start counting up, left from center finding black center mass
        var i: Int64 = 0;
        i = excrossCheckDiagonal1(i, centerI, centerJ, stateCount)

        if (stateCount[2] == 0) {
            return false;
        }

        // Continue up, left finding white space
        i = excrossCheckDiagonal2(i, centerI, centerJ, stateCount)
        if (stateCount[1] == 0) {
            return false;
        }

        // Continue up, left finding black border
        while (centerI >= i && centerJ >= i && image.get(centerJ - i, centerI - i)) {
            stateCount[0] += 1
            i++
        }
        if (stateCount[0] == 0) {
            return false;
        }

        let maxI: Int64 = image.getHeight();
        let maxJ: Int64 = image.getWidth();

        // Now also count down, right from center
        i = 1
        while (centerI + i < maxI && centerJ + i < maxJ && image.get(centerJ + i, centerI + i)) {
            stateCount[2] += 1
            i++
        }

        while (centerI + i < maxI && centerJ + i < maxJ && !image.get(centerJ + i, centerI + i)) {
            stateCount[3] += 1
            i++
        }
        if (stateCount[3] == 0) {
            return false;
        }

        while (centerI + i < maxI && centerJ + i < maxJ && image.get(centerJ + i, centerI + i)) {
            stateCount[4] += 1
            i++
        }
        if (stateCount[4] == 0) {
            return false;
        }

        return foundPatternDiagonal(stateCount);
    }

    private func excrossCheckDiagonal1(i_p: Int64, centerI: Int64, centerJ: Int64, stateCount: Array<Int64>): Int64 {
        var i = i_p
        while (centerI >= i && centerJ >= i && image.get(centerJ - i, centerI - i)) {
            stateCount[2] += 1
            i++
        }
        return i
    }

    private func excrossCheckDiagonal2(i_p: Int64, centerI: Int64, centerJ: Int64, stateCount: Array<Int64>): Int64 {
        var i = i_p
        while (centerI >= i && centerJ >= i && !image.get(centerJ - i, centerI - i)) {
            stateCount[1] += 1
            i++
        }
        return i
    }

    /**
     * After a horizontal scan finds a potential finder pattern, this method
     * "cross-checks" by scanning down vertically through the center of the possible
     * finder pattern to see if the same proportion is detected.
     *
     * @param startI row where a finder pattern was detected
     * @param centerJ center of the section that appears to cross a finder pattern
     * @param maxCount maximum reasonable number of modules that should be observed in any reading state, 
     * based on the results of the horizontal scan
     *
     * @return vertical center of finder pattern
     */
    private func crossCheckVertical(startI: Int64, centerJ: Int64, maxCount: Int64, originalStateCountTotal: Int64): Float64 {
        let image: BitMatrix = this.image;

        let maxI: Int64 = image.getHeight();
        var stateCount: Array<Int64> = getCrossCheckStateCount();

        // Start counting up from center
        var i: Int64 = excrossCheckVertical(startI, centerJ, stateCount)

        if (i < 0) {
            return Float64.NaN;
        }
        i = excrossCheckVertica3(i, maxCount, centerJ, stateCount)

        // If already too many modules in this state or ran off the edge:
        if (i < 0 || stateCount[1] > maxCount) {
            return Float64.NaN;
        }
        i = excrossCheckVertica4(i, maxCount, centerJ, stateCount)
        if (stateCount[0] > maxCount) {
            return Float64.NaN;
        }

        // Now also count down from center
        i = startI + 1
        while (i < maxI && image.get(centerJ, i)) {
            stateCount[2] += 1
            i++
        }
        if (i == maxI) {
            return Float64.NaN;
        }
        while (i < maxI && !image.get(centerJ, i) && stateCount[3] < maxCount) {
            stateCount[3] += 1
            i++
        }
        if (i == maxI || stateCount[3] >= maxCount) {
            return Float64.NaN;
        }
        while (i < maxI && image.get(centerJ, i) && stateCount[4] < maxCount) {
            stateCount[4] += 1
            i++
        }
        if (stateCount[4] >= maxCount) {
            return Float64.NaN;
        }

        // If we found a finder-pattern-like section, but its size is more than 40% different than
        // the original, assume it's a false positive
        let stateCountTotal: Int64 = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4]
        if (5 * abs(stateCountTotal - originalStateCountTotal) >= 2 * originalStateCountTotal) {
            return Float64.NaN;
        }

        return returncrossCheckVertical(stateCount, i)
    }

    private func excrossCheckVertica4(i_p: Int64, maxCount: Int64, centerJ: Int64, stateCount: Array<Int64>): Int64 {
        var i = i_p
        while (i >= 0 && image.get(centerJ, i) && stateCount[0] <= maxCount) {
            stateCount[0] += 1
            i--
        }
        return i
    }

    private func excrossCheckVertica3(i_p: Int64, maxCount: Int64, centerJ: Int64, stateCount: Array<Int64>): Int64 {
        var i = i_p
        while (i >= 0 && !image.get(centerJ, i) && stateCount[1] <= maxCount) {
            stateCount[1] += 1
            i--
        }
        return i
    }

    private func excrossCheckVertical(startI: Int64, centerJ: Int64, stateCount: Array<Int64>): Int64 {
        var i = startI
        while (i >= 0 && image.get(centerJ, i)) {
            stateCount[2] += 1
            i--
        }
        return i
    }

    private func returncrossCheckVertical(stateCount: Array<Int64>, i: Int64): Float64 {
        if (foundPatternCross(stateCount)) {
            centerFromEnd(stateCount, i)
        } else {
            return Float64.NaN
        }
    }

    /**
     * Like {@link #crossCheckVertical(int, int, int, int)}, and in fact is basically identical,
     * except it reads horizontally instead of vertically. This is used to cross-cross
     * check a vertical cross check and locate the real center of the alignment pattern.
     */
    private func crossCheckHorizontal(startJ: Int64, centerI: Int64, maxCount: Int64, originalStateCountTotal: Int64): Float64 {
        let image: BitMatrix = this.image;

        let maxJ: Int64 = image.getWidth();
        var stateCount: Array<Int64> = getCrossCheckStateCount();

        var j: Int64 = excrossCheckHorizontal(startJ, centerI, stateCount)
        if (j < 0) {
            return Float64.NaN;
        }
        j = excrossCheckHorizontal2(j, maxCount, centerI, stateCount)
        if (j < 0 || stateCount[1] > maxCount) {
            return Float64.NaN;
        }
        j = excrossCheckHorizontal3(j, maxCount, centerI, stateCount)

        if (stateCount[0] > maxCount) {
            return Float64.NaN;
        }

        j = startJ + 1
        while (j < maxJ && image.get(j, centerI)) {
            stateCount[2] += 1
            j++
        }
        if (j == maxJ) {
            return Float64.NaN;
        }
        while (j < maxJ && !image.get(j, centerI) && stateCount[3] < maxCount) {
            stateCount[3] += 1
            j++
        }
        if (j == maxJ || stateCount[3] >= maxCount) {
            return Float64.NaN;
        }
        while (j < maxJ && image.get(j, centerI) && stateCount[4] < maxCount) {
            stateCount[4] += 1
            j++
        }
        if (stateCount[4] >= maxCount) {
            return Float64.NaN;
        }

        // If we found a finder-pattern-like section, but its size is significantly different than
        // the original, assume it's a false positive
        let stateCountTotal: Int64 = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4]
        if (5 * abs(stateCountTotal - originalStateCountTotal) >= originalStateCountTotal) {
            return Float64.NaN;
        }

        return returncrossCheckHorizontal(stateCount, j)
    }

    private func excrossCheckHorizontal3(j_p: Int64, maxCount: Int64, centerI: Int64, stateCount: Array<Int64>): Int64 {
        var j = j_p
        while (j >= 0 && image.get(j, centerI) && stateCount[0] <= maxCount) {
            stateCount[0] += 1
            j--
        }
        return j
    }

    private func excrossCheckHorizontal2(j_p: Int64, maxCount: Int64, centerI: Int64, stateCount: Array<Int64>): Int64 {
        var j = j_p
        while (j >= 0 && !image.get(j, centerI) && stateCount[1] <= maxCount) {
            stateCount[1] += 1
            j--
        }
        return j
    }

    private func excrossCheckHorizontal(startJ: Int64, centerI: Int64, stateCount: Array<Int64>): Int64 {
        var j = startJ
        while (j >= 0 && image.get(j, centerI)) {
            stateCount[2] += 1
            j--
        }
        return j
    }

    private func returncrossCheckHorizontal(stateCount: Array<Int64>, j: Int64): Float64 {
        if (foundPatternCross(stateCount)) {
            return centerFromEnd(stateCount, j)
        } else {
            return Float64.NaN
        }
    }

    /**
     * @param stateCount reading state module counts from horizontal scan
     * @param i row where finder pattern may be found
     * @param j end of possible finder pattern in row
     * @param pureBarcode ignored
     *
     * @return true if a finder pattern candidate was found this time
     *
     * @deprecated only exists for backwards compatibility
     * @see #handlePossibleCenter(int[], int, int)
     */
    protected func handlePossibleCenter(stateCount: Array<Int64>, i: Int64, j: Int64, _: Bool): Bool {
        return handlePossibleCenter(stateCount, i, j);
    }

    protected func handlePossibleCenter(stateCount: Array<Int64>, i: Int64, j: Int64): Bool {
        let stateCountTotal: Int64 = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4]
        var centerJ: Float64 = centerFromEnd(stateCount, j);
        var centerI: Float64 = crossCheckVertical(i, Int64(centerJ), stateCount[2], stateCountTotal)
        if (!centerI.isNaN()) {
            // Re-cross check
            centerJ = crossCheckHorizontal(Int64(centerJ), Int64(centerI), stateCount[2], stateCountTotal)
            if (!centerJ.isNaN() && crossCheckDiagonal(Int64(centerI), Int64(centerJ))) {
                let estimatedModuleSize: Float64 = Float64(stateCountTotal) / 7.0f64
                var found: Bool = false;
                for (index in 0..possibleCenters.size) {
                    let center: FinderPattern = possibleCenters[index]

                    // Look for about the same center and module size:
                    if (center.aboutEquals(Float32(estimatedModuleSize), Float32(centerI), Float32(centerJ))) {
                        let centerItem: FinderPattern = center.combineEstimate(
                            Float32(centerI),
                            Float32(centerJ),
                            Float32(estimatedModuleSize)
                        );
                        possibleCenters.set(index, centerItem);
                        found = true
                        break
                    }
                }
                if (!found) {
                    var point = FinderPattern(Float32(centerJ), Float32(centerI), Float32(estimatedModuleSize))
                    possibleCenters.append(point)
                    resultPointCallback?.foundPossibleResultPoint(point)
                }
                return true;
            }
        }
        return false;
    }

    /**
     * @return number of rows we could safely skip during scanning, based on the first
     * two finder patterns that have been located. In some cases their position will
     * allow us to infer that the third pattern must lie below a certain point farther
     * down in the image.
     */
    private func findRowSkip(): Int64 {
        let max: Int64 = possibleCenters.size;
        if (max <= 1) {
            return 0;
        }
        var firstConfirmedCenter: ResultPoint = ResultPoint();
        for (i in 0..possibleCenters.size) {
            if (possibleCenters[i].getCount() >= CENTER_QUORUM) {
                if (firstConfirmedCenter.equals(ResultPoint())) {
                    firstConfirmedCenter = possibleCenters[i]
                } else {
                    // We have two confirmed centers
                    // How far down can we skip before resuming looking for the next pattern?
                    // In the worst case, only the difference between the
                    // difference in the x / y coordinates of the two centers.
                    // This is the case where you find top left last.
                    hasSkipped = true
                    return Int64(abs(firstConfirmedCenter.getX() - possibleCenters[i].getX()) - abs(
                            firstConfirmedCenter.getY() - possibleCenters[i].getY())) / 2
                }
            }
        }
        return 0;
    }

    /**
     * @return true iff we have found at least 3 finder patterns that have been detected
     * at least CENTER_QUORUM times each, and, the estimated module size of the
     * candidates is "pretty similar"
     */
    private func haveMultiplyConfirmedCenters(): Bool {
        var confirmedCount: Int64 = 0;
        var totalModuleSize: Float32 = 0.0f32;
        let max: Int64 = possibleCenters.size;
        for (i in 0..possibleCenters.size) {
            if (possibleCenters[i].getCount() >= CENTER_QUORUM) {
                confirmedCount++
                totalModuleSize += possibleCenters[i].getEstimatedModuleSize()
            }
        }
        if (confirmedCount < 3) {
            return false;
        }

        // OK, we have at least 3 confirmed centers, but, it's possible that one is a "false positive"
        // and that we need to keep looking. We detect this by asking if the estimated module sizes vary too much.
        // We arbitrarily say that when the total deviation from average exceeds
        // 5% of the total module size estimates, it's too much.
        let average: Float32 = totalModuleSize / Float32(max)
        var totalDeviation: Float32 = 0.0f32;
        for (i in 0..possibleCenters.size) {
            totalDeviation += abs(possibleCenters[i].getEstimatedModuleSize() - average)
        }
        return totalDeviation <= 0.05f32 * totalModuleSize
    }

    /**
     * Get square of distance between a and b.
     */
    private static func squaredDistance(a: FinderPattern, b: FinderPattern): Float32 {
        let x: Float32 = a.getX() - b.getX()
        let y: Float32 = a.getY() - b.getY()
        return x * x + y * y
    }

    /**
     * @return the 3 best FinderPattern from our list of candidates. The "best" are
     * those have similar module size and form a shape closer to a isosceles right triangle.
     * @throws Qrcoder4cjNotFoundException if 3 such finder patterns do not exist
     */
    func moduleSizeComparator(p1: FinderPattern, p2: FinderPattern): Ordering {
        if (p1.estimatedModuleSize < p2.estimatedModuleSize) {
            return Ordering.LT
        } else if (p1.estimatedModuleSize > p2.estimatedModuleSize) {
            return Ordering.GT
        } else {
            return Ordering.EQ
        }
    }

    private func selectBestPatterns(): Array<FinderPattern> {
        let startSize: Int64 = possibleCenters.size;
        if (startSize < 3) {
            // Couldn't find enough finder patterns
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var itemnum: Int64 = 0;
        var it = 0;
        while (it < possibleCenters.size) {
            if (possibleCenters[it].getCount() < CENTER_QUORUM) {
                possibleCenters.remove(itemnum);
                continue
            }
            it++
            itemnum++
        }

        possibleCenters.sortBy(stable: true, comparator: moduleSizeComparator)
        var distortion: Float32 = Float32.Max;
        var bestPatterns: Array<FinderPattern> = Array<FinderPattern>(3, repeat: FinderPattern(0.0, 0.0, 0.0));

        for (i in 0..possibleCenters.size - 2) {
            let fpi: FinderPattern = possibleCenters[i]
            let minModuleSize: Float32 = fpi.getEstimatedModuleSize();

            for (j in i + 1..possibleCenters.size - 1) {
                let fpj: FinderPattern = possibleCenters[j]
                let squares0: Float32 = squaredDistance(fpi, fpj);
                distortion = exselectBestPatterns(j, minModuleSize, squares0, fpj, fpi, distortion, bestPatterns)
            }
        }

        if (distortion == Float32.Max) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        return bestPatterns
    }

    private func exselectBestPatterns(j: Int64, minModuleSize: Float32, squares0: Float32, fpj: FinderPattern,
        fpi: FinderPattern, distortion: Float32, bestPatterns: Array<FinderPattern>): Float32 {
        var distortion_P = distortion
        for (k in j + 1..possibleCenters.size) {
            let fpk: FinderPattern = possibleCenters[k]
            let maxModuleSize: Float32 = fpk.getEstimatedModuleSize();
            if (maxModuleSize > minModuleSize * 1.4f32) {
                continue
            }

            var (a, b, c): (Float32, Float32, Float32) = (squares0, squaredDistance(fpj, fpk), squaredDistance(fpi, fpk))

            // sorts ascending - inlined
            if (a < b) {
                if (b > c) {
                    if (a < c) {
                        var temp: Float32 = b
                        b = c
                        c = temp
                    } else {
                        var temp: Float32 = a
                        a = c
                        c = b
                        b = temp
                    }
                }
            } else {
                if (b < c) {
                    if (a < c) {
                        var temp: Float32 = a
                        a = b
                        b = temp
                    } else {
                        var temp: Float32 = a
                        a = b
                        b = c
                        c = temp
                    }
                } else {
                    var temp: Float32 = a
                    a = c
                    c = temp
                }
            }
            let d: Float32 = abs(c - 2.0f32 * b) + abs(c - 2.0f32 * a)
            if (d < distortion_P) {
                distortion_P = d
                (bestPatterns[0], bestPatterns[1], bestPatterns[2]) = (fpi, fpj, fpk)
            }
        }
        return distortion_P
    }
}

/**
 * Orders by FinderPattern#getEstimatedModuleSize()
 */
class EstimatedModuleComparator {
    func compare(center1: FinderPattern, center2: FinderPattern): Int64 {
        // 比较 center1 和 center2 中的 estimatedModuleSize 属性，并返回对应的结果
        if (center1.getEstimatedModuleSize() < center2.getEstimatedModuleSize()) {
            return -1
        } else if (center1.getEstimatedModuleSize() > center2.getEstimatedModuleSize()) {
            return 1
        } else {
            return 0
        }
    }
}
