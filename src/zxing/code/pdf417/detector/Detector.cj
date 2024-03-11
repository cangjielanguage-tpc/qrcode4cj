/*
 * Copyright 2009 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

package zxing.code.pdf417.detector

import zxing.code.common.BinaryBitmap
import zxing.code.common.DecodeHintType
import zxing.code.common.NotFoundException
import zxing.code.common.EncodeHintType
import zxing.code.tools.System
from std import math.*

/**
 * <p>Encapsulates logic that can detect a PDF417 Code in an image, even if the
 * PDF417 Code is rotated or skewed, or partially obscured.</p>
 *
 * @author SITA Lab (kevin.osullivan@sita.aero)
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Guenther Grau
 */
public open class Detector {
    private static let INDEXES_START_PATTERN: Array<Int64> = [0, 4, 1, 5]
    private static let INDEXES_STOP_PATTERN: Array<Int64> = [6, 2, 7, 3]
    private static let MAX_AVG_VARIANCE: Float32 = 0.42

    private static let MAX_INDIVIDUAL_VARIANCE: Float32 = 0.8

    // B S B S B S B S Bar/Space pattern
    // 11111111 0 1 0 1 0 1 000
    private static let START_PATTERN: Array<Int64> = [8, 1, 1, 1, 1, 1, 1, 3]

    // 1111111 0 1 000 1 0 1 00 1
    private static let STOP_PATTERN: Array<Int64> = [7, 1, 1, 3, 1, 1, 1, 2, 1]
    private static let MAX_PIXEL_DRIFT: Int64 = 3
    private static let MAX_PATTERN_DRIFT: Int64 = 5

    // if we set the value too low, then we don't detect the correct height of the bar if the start patterns are damaged.
    // if we set the value too high, then we might detect the start pattern from a neighbor barcode.
    private static let SKIPPED_ROW_COUNT_MAX: Int64 = 25

    // A PDF471 barcode should have at least 3 rows, with each row being >= 3 times the module width.
    // Therefore it should be at least 9 pixels tall. To be conservative, we use about half the size to
    // ensure we don't miss it.
    private static let ROW_STEP: Int64 = 8
    private static let BARCODE_MIN_HEIGHT: Int64 = 10
    private static let ROTATIONS: Array<Int64> = [0, 180, 90, 270]

    private init() {}

    /**
     * <p>Detects a PDF417 Code in an image. Checks 0, 90, 180, and 270 degree rotations.</p>
     *
     * @param image barcode image to decode
     * @param hints optional hints to detector
     * @param multiple if true, then the image is searched for multiple codes. If false, then at most one code will
     * be found and returned
     * @return {@link PDF417DetectorResult} encapsulating results of detecting a PDF417 code
     * @throws NotFoundException if no PDF417 Code can be found
     */
    public static func detect(
        image: BinaryBitmap,
        hints: HashMap<DecodeHintType, Any>,
        multiple: Bool,
        flagReadSecond: Int64
    ): PDF417DetectorResult {
        var originalMatrix: BitMatrix = image.getBlackMatrix()
        var bitMatrix: BitMatrix = BitMatrix();
        for (i in 0..ROTATIONS.size) {
            match (ROTATIONS[i]) {
                case 0 => bitMatrix = originalMatrix
                case 180 => bitMatrix = applyRotation(originalMatrix, ROTATIONS[i])
                case 90 => bitMatrix = applyRotation(originalMatrix, ROTATIONS[i])
                case 270 => bitMatrix = applyRotation(bitMatrix, 180)
                case _ => ()
            }

            var barcodeCoordinates: ArrayList<Array<ResultPoint>> = detect(multiple, bitMatrix, flagReadSecond)
            if (!barcodeCoordinates.isEmpty()) {
                return PDF417DetectorResult(bitMatrix, barcodeCoordinates, ROTATIONS[i])
            }
        }

        return PDF417DetectorResult(originalMatrix, ArrayList<Array<ResultPoint>>(), 0)
    }

    /**
     * Applies a rotation to the supplied BitMatrix.
     * @param matrix bit matrix to apply rotation to
     * @param rotation the degrees of rotation to apply
     * @return BitMatrix with applied rotation
     */
    private static func applyRotation(matrix: BitMatrix, rotation: Int64): BitMatrix {
        if (rotation % 360 == 0) {
            return matrix
        }

        var newMatrix: BitMatrix = matrix.clone()

        newMatrix.rotate(rotation)

        return newMatrix
    }

    /**
     * Detects PDF417 codes in an image. Only checks 0 degree rotation
     * @param multiple if true, then the image is searched for multiple codes. If false, then at most one code will
     * be found and returned
     * @param bitMatrix bit matrix to detect barcodes in
     * @return List of ResultPoint arrays containing the coordinates of found barcodes
     */
    private static func detect(multiple: Bool, bitMatrix: BitMatrix, flagReadSecond: Int64): ArrayList<Array<ResultPoint>> {
        var barcodeCoordinates: ArrayList<Array<ResultPoint>> = ArrayList<Array<ResultPoint>>()
        var row: Int64 = 0
        var column: Int64 = 0
        var foundBarcodeInRow: Bool = false
        while (row < bitMatrix.getHeight()) {
            var vertices: Array<ResultPoint> = findVertices(bitMatrix, row, column, flagReadSecond)

            if (vertices[0].flag == false && vertices[3].flag == false) {
                if (!foundBarcodeInRow) {
                    break
                }

                // we didn't find a barcode starting at the given column and row. Try again from the first column and slightly
                // below the lowest barcode we found so far.
                foundBarcodeInRow = false
                column = 0
                for (i in 0..barcodeCoordinates.size) {
                    if (barcodeCoordinates[i][1].flag) {
                        row = max(row, Int64(barcodeCoordinates[i][1].getY()))
                    }
                    if (barcodeCoordinates[i][3].flag) {
                        row = max(row, Int64(barcodeCoordinates[i][3].getY()))
                    }
                }
                row += ROW_STEP
                continue
            }
            foundBarcodeInRow = true
            barcodeCoordinates.append(vertices)
            if (!multiple) {
                break
            }

            // if we didn't find a right row indicator column, then continue the search for the next barcode after the
            // start pattern of the barcode just found.
            if (vertices[2].flag) {
                column = Int64(vertices[2].getX())
                row = Int64(vertices[2].getY())
            } else {
                column = Int64(vertices[4].getX())
                row = Int64(vertices[4].getY())
            }
        }

        return barcodeCoordinates
    }

    /**
     * Locate the vertices and the codewords area of a black blob using the Start
     * and Stop patterns as locators.
     *
     * @param matrix the scanned barcode image.
     * @return an array containing the vertices:
     * vertices[0] x, y top left barcode
     * vertices[1] x, y bottom left barcode
     * vertices[2] x, y top right barcode
     * vertices[3] x, y bottom right barcode
     * vertices[4] x, y top left codeword area
     * vertices[5] x, y bottom left codeword area
     * vertices[6] x, y top right codeword area
     * vertices[7] x, y bottom right codeword area
     */
    private static func findVertices(matrix: BitMatrix, startRow: Int64, startColumn: Int64, flagReadSecond: Int64): Array<ResultPoint> {
        var height: Int64 = matrix.getHeight()
        var width: Int64 = matrix.getWidth()
        var startColumn_ = startColumn
        var startRow_ = startRow

        var result: Array<ResultPoint> = Array<ResultPoint>(8, item: ResultPoint())
        copyToResult(
            result,
            findRowsWithPattern(matrix, height, width, startRow_, startColumn_, START_PATTERN),
            INDEXES_START_PATTERN
        )

        if (result[4].flag) {
            startColumn_ = Int64(result[4].getX())
            startRow_ = Int64(result[4].getY())
            if (flagReadSecond == 0) {
                copyToResult(
                    result,
                    findRowsWithPattern(matrix, height, width, startRow_, startColumn_, STOP_PATTERN),
                    INDEXES_STOP_PATTERN
                )
            }
        }

        if (flagReadSecond > 0) {
            copyToResult(
                result,
                findRowsWithPattern(matrix, height, width, startRow_, startColumn_, STOP_PATTERN),
                INDEXES_STOP_PATTERN
            )
        }

        return result
    }

    private static func copyToResult(
        result: Array<ResultPoint>,
        tmpResult: Array<ResultPoint>,
        destinationIndexes: Array<Int64>
    ) {
        for (i in 0..destinationIndexes.size) {
            result[destinationIndexes[i]] = tmpResult[i]
        }
    }

    private static func findRowsWithPattern(matrix: BitMatrix, height: Int64, width: Int64, startRow: Int64,
        startColumn: Int64, pattern: Array<Int64>): Array<ResultPoint> {
        var startRow_ = startRow
        var result: Array<ResultPoint> = Array<ResultPoint>(4, item: ResultPoint())
        var found: Bool = false
        var counters: Array<Int64> = Array<Int64>(pattern.size, item: 0)

        while (startRow_ < height) {
            var loc: Array<Int64> = findGuardPatternDetect(matrix, startColumn, startRow_, width, pattern, counters)
            if (loc.size != 0) {
                while (startRow_ > 0) {
                    startRow_--
                    var previousRowLoc: Array<Int64> = findGuardPattern(matrix, startColumn, startRow_, width, pattern,
                        counters)

                    if (previousRowLoc.size != 0) {
                        loc = previousRowLoc
                    } else {
                        startRow_++
                        break
                    }
                }
                result[0] = ResultPoint(Float32(loc[0]), Float32(startRow_))
                result[1] = ResultPoint(Float32(loc[1]), Float32(startRow_))
                found = true
                break
            }
            startRow_ += ROW_STEP
        }
        var stopRow: Int64 = startRow_ + 1

        // Last row of the current symbol that contains pattern
        if (found) {
            var skippedRowCount: Int64 = 0
            var previousRowLoc: Array<Int64> = [Int64(result[0].getX()), Int64(result[1].getX())]

            while (stopRow < height) {
                var loc: Array<Int64> = findGuardPattern(matrix, previousRowLoc[0], stopRow, width, pattern, counters)

                // a found pattern is only considered to belong to the same barcode if the start and end positions
                // don't differ too much. Pattern drift should be not bigger than two for consecutive rows. With
                // a higher number of skipped rows drift could be larger. To keep it simple for now, we allow a slightly
                // larger drift and don't check for skipped rows.
                if (loc.size != 0 && abs(previousRowLoc[0] - loc[0]) < MAX_PATTERN_DRIFT &&
                    abs(previousRowLoc[1] - loc[1]) < MAX_PATTERN_DRIFT) {
                    previousRowLoc = loc
                    skippedRowCount = 0
                } else {
                    if (skippedRowCount > SKIPPED_ROW_COUNT_MAX) {
                        break
                    } else {
                        skippedRowCount++
                    }
                }
                stopRow++
            }
            stopRow -= skippedRowCount + 1
            result[2] = ResultPoint(Float32(previousRowLoc[0]), Float32(stopRow))
            result[3] = ResultPoint(Float32(previousRowLoc[1]), Float32(stopRow))
        }
        if (stopRow - startRow_ < BARCODE_MIN_HEIGHT) {
            result = Array<ResultPoint>(4, item: ResultPoint())
        }
        return result
    }

    /**
     * @param matrix row of black/white values to search
     * @param column x position to start search
     * @param row y position to start search
     * @param width the number of pixels to search on this row
     * @param pattern pattern of counts of number of black and white pixels that are
     * being searched for as a pattern
     * @param counters array of counters, as long as pattern, to re-use
     * @return start/end horizontal offset of guard pattern, as an array of two ints.
     */
    private static func findGuardPattern(
        matrix: BitMatrix,
        column: Int64,
        row: Int64,
        width: Int64,
        pattern: Array<Int64>,
        counters: Array<Int64>
    ): Array<Int64> {
        for (i in 0..counters.size) {
            counters[i] = 0
        }
        var patternStart: Int64 = column
        var pixelDrift: Int64 = 0
        pixelDrift++
        // if there are black pixels left of the current pixel shift to the left, but only for MAX_PIXEL_DRIFT pixels
        while (matrix.get(patternStart, row) && patternStart > 0 && pixelDrift < MAX_PIXEL_DRIFT + 1) {
            pixelDrift++
            patternStart--
        }

        var x: Int64 = patternStart
        var counterPosition: Int64 = 0
        var patternLength: Int64 = pattern.size
        var isWhite: Bool = false
        while (x < width) {
            let pixel: Bool = matrix.get(x, row)
            if (pixel != isWhite) {
                counters[counterPosition] += 1
            } else {
                if (counterPosition == patternLength - 1) {
                    if (patternMatchVariance(counters, pattern) < MAX_AVG_VARIANCE) {
                        return [patternStart, x]
                    }

                    patternStart += counters[0] + counters[1]
                    System.arraycopy(counters, 2, counters, 0, counterPosition - 1)

                    counters[counterPosition - 1] = 0
                    counters[counterPosition] = 0
                    counterPosition--
                } else {
                    counterPosition++
                }
                counters[counterPosition] = 1
                isWhite = !isWhite
            }
            x++;
        }
        if (counterPosition == patternLength - 1 && patternMatchVariance(counters, pattern) < MAX_AVG_VARIANCE) {
            return [patternStart, x - 1]
        }
        return Array<Int64>()
    }

    //////////////////////////////////////////////////////////////////////

    private static func findGuardPatternDetect(
        matrix: BitMatrix,
        column: Int64,
        row: Int64,
        width: Int64,
        pattern: Array<Int64>,
        counters: Array<Int64>
    ): Array<Int64> {
        for (i in 0..counters.size) {
            counters[i] = 0
        }
        var patternStart: Int64 = column
        var pixelDrift: Int64 = 0
        pixelDrift++
        // if there are black pixels left of the current pixel shift to the left, but only for MAX_PIXEL_DRIFT pixels
        while (matrix.get(patternStart, row) && patternStart > 0 && pixelDrift < MAX_PIXEL_DRIFT + 1) {
            pixelDrift++
            patternStart--
        }

        var x: Int64 = patternStart
        var counterPosition: Int64 = 0
        var patternLength: Int64 = pattern.size
        var isWhite: Bool = false
        var threshold = 2
        var tflag = 0
        if (pattern[0] == 8) {
            threshold = 3
        } else {
            threshold = 2
        }
        while (x < width) {
            let pixel: Bool = matrix.get(x, row)
            if (pixel != isWhite) {
                counters[counterPosition] += 1
            } else {
                if (counters[0] > 0 && counters[1] > 0 && counters[2] > 0 && (counters[0]) / (counters[1] + counters[2]) <
                    threshold) {
                    if (counterPosition > 2) {
                        for (i in 0..counterPosition - 2) {
                            if (counters[i] > 0 && counters[i + 1] > 0 && counters[i + 2] > 0 &&
                                (counters[i]) / (counters[i + 1] + counters[i + 2]) < threshold) {
                            } else {
                                tflag = i
                                break
                            }
                        }
                        if (tflag > 0) {
                            System.arraycopy(counters, tflag, counters, 0, counterPosition - tflag + 1)
                            counterPosition = counterPosition - tflag
                        } else {
                            counters[0] = counters[counterPosition - 2]
                            counters[1] = counters[counterPosition - 1]
                            counters[2] = counters[counterPosition]
                            counterPosition = 2
                        }

                        tflag = 0
                    } else {
                        counters[0] = counters[1]
                        counters[1] = counters[2]
                        counters[2] = 1
                        counterPosition = 2
                    }
                } else {
                    if (counterPosition == patternLength - 1) {
                        if (patternMatchVariance(counters, pattern) < MAX_AVG_VARIANCE) {
                            return [patternStart, x]
                        }

                        patternStart += counters[0] + counters[1]
                        System.arraycopy(counters, 2, counters, 0, counterPosition - 1)

                        counters[counterPosition - 1] = 0
                        counters[counterPosition] = 0
                        counterPosition--
                    } else {
                        counterPosition++
                    }
                    counters[counterPosition] = 1
                }

                isWhite = !isWhite
            }
            x++;
        }
        if (counterPosition == patternLength - 1 && patternMatchVariance(counters, pattern) < MAX_AVG_VARIANCE) {
            return [patternStart, x - 1]
        }
        return Array<Int64>()
    }

    /**
     * Determines how closely a set of observed counts of runs of black/white
     * values matches a given target pattern. This is reported as the ratio of
     * the total variance from the expected pattern proportions across all
     * pattern elements, to the size of the pattern.
     *
     * @param counters observed counters
     * @param pattern expected pattern
     * @return ratio of total variance between counters and pattern compared to total pattern size
     */
    private static func patternMatchVariance(counters: Array<Int64>, pattern: Array<Int64>): Float32 {
        let numCounters: Int64 = counters.size
        var total: Int64 = 0
        var patternLength: Int64 = 0
        for (i in 0..numCounters) {
            total += counters[i]
            patternLength += pattern[i]
        }
        if (total < patternLength) {
            // If we don't even have one pixel per unit of bar width, assume this
            // is too small to reliably match, so fail:
            return Float32.NaN
        }

        // We're going to fake floating-point math in integers. We just need to use more bits.
        // Scale up patternLength so that intermediate values below like scaledCounter will have
        // more "significant digits".
        let unitBarWidth: Float32 = (Float32(total) / Float32(patternLength))
        let maxIndividualVariance: Float32 = MAX_INDIVIDUAL_VARIANCE * unitBarWidth

        var totalVariance: Float32 = 0.0
        for (x in 0..numCounters) {
            var counter: Int64 = counters[x]
            var scaledPattern: Float32 = Float32(pattern[x]) * unitBarWidth
            var variance: Float32 = 0.0
            if (Float32(counter) > scaledPattern) {
                variance = Float32(counter) - scaledPattern
            } else {
                variance = Float32(scaledPattern) - Float32(counter)
            }

            if (variance > maxIndividualVariance) {
                return Float32.NaN
            }
            totalVariance += variance
        }
        return totalVariance / Float32(total)
    }
}
