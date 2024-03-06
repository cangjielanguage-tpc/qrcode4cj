/*
 * Copyright 2008 ZXing authors
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

package zxing.code.oned.rss

from std import math.*

/**
 * Encapsulates functionality and implementation that is common to all families
 * of one-dimensional barcodes.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */
public abstract class OneDReader <: Reader {
    public open override func decode(image: BinaryBitmap): Result {
        return decode(image, HashMap<DecodeHintType, Any>())
    }

    // Note that we don't try rotation without the try harder flag, even if rotation was supported.
    public open override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        try {
            return doDecode(image, hints)
        } catch (nfe: NotFoundException) {
            var tryHarder: Bool = hints.size != 0 && hints.contains(DecodeHintType.TRY_HARDER)
            if (tryHarder && image.isRotateSupported()) {
                var rotatedImage: BinaryBitmap = image.rotateCounterClockwise()
                var result: Result = doDecode(rotatedImage, hints)

                // Record that we found it rotated 90 degrees CCW / 270 degrees CW
                var metadata: HashMap<ResultMetadataType, Any> = result.getResultMetadata()
                var orientation: Int64 = 270
                if (metadata.size > 0 && metadata.contains(ResultMetadataType.ORIENTATION)) {
                    // But if we found it reversed in doDecode(), add in that result here:
                    let getmetadata = metadata.get(ResultMetadataType.ORIENTATION).getOrThrow() as Int64

                    orientation = (orientation + getmetadata.getOrThrow()) % 360
                }
                result.putMetadata(ResultMetadataType.ORIENTATION, orientation)

                // Update result points
                var points: Array<ResultPoint> = result.getResultPoints()
                if (points.size != 0) {
                    var height: Int64 = rotatedImage.getHeight()

                    for (i in 0..points.size) {
                        points[i] = ResultPoint(Float32(height) - points[i].getY() - 1.0, points[i].getX())
                    }
                }
                return result
            } else {
                //throw nfe
                throw NotFoundException();
            }
        }
    }

    public open func reset() {
        // do nothing
    }

    /**
     * We're going to examine rows from the middle outward, searching alternately above and below the
     * middle, and farther out each time. rowStep is the number of rows between each successive
     * attempt above and below the middle. So we'd scan row middle, then middle - rowStep, then
     * middle + rowStep, then middle - (2 * rowStep), etc.
     * rowStep is bigger as the image is taller, but is always at least 1. We've somewhat arbitrarily
     * decided that moving up and down by about 1/16 of the image is pretty good we try more of the
     * image if "trying harder".
     *
     * @param image The image to decode
     * @param hints Any hints that were requested
     * @return The contents of the decoded barcode
     * @throws NotFoundException Any spontaneous errors which occur
     */
    private func doDecode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        var width: Int64 = image.getWidth()
        var height: Int64 = image.getHeight()
        var row: BitArray = BitArray(width)
        var hintsuse: HashMap<DecodeHintType, Any> = hints
        var tryHarder: Bool = hintsuse.size > 0 && hintsuse.contains(DecodeHintType.TRY_HARDER)

        var rowStep: Int64 = 0
        if (tryHarder) {
            rowStep = max(1, height >> (8))
        } else {
            rowStep = max(1, height >> (5))
        }

        var maxLines: Int64
        if (tryHarder) {
            maxLines = height
            // Look at the whole image, not just the center
        } else {
            maxLines = 15
            // 15 rows spaced 1/32 apart is roughly the middle half of the image
        }

        var middle: Int64 = height / 2

        for (x in 0..maxLines) {
            // Scanning from the middle out. Determine which row we're looking at next:
            var rowStepsAboveOrBelow: Int64 = (x + 1) / 2
            var isAbove: Bool = (x & 0x01) == 0

            // i.e. is x even?
            var rowNumber: Int64 = 0
            if (isAbove) {
                rowNumber = middle + rowStep * (rowStepsAboveOrBelow)
            } else {
                rowNumber = middle + rowStep * (-rowStepsAboveOrBelow)
            }
            if (rowNumber < 0 || rowNumber >= height) {
                break
            }

            // Estimate black point for this row and load it:
            try {
                row = image.getBlackRow(rowNumber, row)
            } catch (ignored: NotFoundException) {
                continue
            }

            // While we have the image data in a BitArray, it's fairly cheap to reverse it in place to
            // handle decoding upside down barcodes.
            for (attempt in 0..2) {
                if (attempt == 1) { // trying again?
                    row.reverse()

                    // reverse the row and continue
                    // This means we will only ever draw result points *once* in the life of this method
                    // since we want to avoid drawing the wrong points after flipping the row, and,
                    // don't want to clutter with noise from every single row scan -- just the scans
                    // that start on the center line.
                    if (hintsuse.size > 0 && hintsuse.contains(DecodeHintType.NEED_RESULT_POINT_CALLBACK)) {
                        var newHints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>()
                        newHints.putAll(hintsuse)
                        newHints.remove(DecodeHintType.NEED_RESULT_POINT_CALLBACK)
                        hintsuse = newHints
                    }
                }
                try {
                    // Look for a barcode
                    var result: Result = decodeRow(rowNumber, row, hintsuse)

                    // We found our barcode
                    if (attempt == 1) {
                        // But it was upside down, so note that
                        result.putMetadata(ResultMetadataType.ORIENTATION, 180)

                        // And remember to flip the result points horizontally.
                        var points: Array<ResultPoint> = result.getResultPoints()
                        if (points.size > 0) {
                            points[0] = ResultPoint(Float32(width) - points[0].getX() - 1.0, points[0].getY())
                            points[1] = ResultPoint(Float32(width) - points[1].getX() - 1.0, points[1].getY())
                        }
                    }

                    return result
                } catch (re: ReaderException) {
                    // continue -- just couldn't decode this row
                }
            }
        }

        throw NotFoundException.getNotFoundInstance()
    }

    /**
     * Records the size of successive runs of white and black pixels in a row, starting at a given point.
     * The values are recorded in the given array, and the number of runs recorded is equal to the size
     * of the array. If the row starts on a white pixel at the given start point, then the first count
     * recorded is the run of white pixels starting from that point likewise it is the count of a run
     * of black pixels if the row begin on a black pixels at that point.
     *
     * @param row row to count from
     * @param start offset into row to start at
     * @param counters array into which to record counts
     * @throws NotFoundException if counters cannot be filled entirely from row before running out
     * of pixels
     */
    protected static func recordPattern(row: BitArray, start: Int64, counters: Array<Int64>) {
        var numCounters: Int64 = counters.size

        var end: Int64 = row.getSize()

        for (i in 0..numCounters) {
            counters[i] = 0
        }

        if (start >= end) {
            throw NotFoundException.getNotFoundInstance()
        }
        var isWhite: Bool = !row.get(start)
        var counterPosition: Int64 = 0
        var i: Int64 = start
        while (i < end) {
            if (row.get(i) != isWhite) {
                counters[counterPosition] = counters[counterPosition] + 1
            } else {
                counterPosition++
                if (counterPosition == numCounters) {
                    break
                } else {
                    counters[counterPosition] = 1
                    isWhite = !isWhite
                }
            }
            i++
        }

        // If we read fully the last section of pixels and filled up our counters -- or filled
        // the last counter but ran off the side of the image, OK. Otherwise, a problem.
        if (!(counterPosition == numCounters || (counterPosition == numCounters - 1 && i == end))) {
            throw NotFoundException.getNotFoundInstance()
        }
    }

    protected static func recordPatternInReverse(row: BitArray, start: Int64, counters: Array<Int64>) {
        // This could be more efficient I guess

        var numTransitionsLeft: Int64 = counters.size
        var last: Bool = row.get(start)
        var startuse: Int64 = start
        while (startuse > 0 && numTransitionsLeft >= 0) {
            startuse--
            if (row.get(startuse) != last) {
                numTransitionsLeft--
                last = !last
            }
        }
        if (numTransitionsLeft >= 0) {
            throw NotFoundException.getNotFoundInstance()
        }
        recordPattern(row, startuse + 1, counters)
    }

    /**
     * Determines how closely a set of observed counts of runs of black/white values matches a given
     * target pattern. This is reported as the ratio of the total variance from the expected pattern
     * proportions across all pattern elements, to the length of the pattern.
     *
     * @param counters observed counters
     * @param pattern expected pattern
     * @param maxIndividualVariance The most any counter can differ before we give up
     * @return ratio of total variance between counters and pattern compared to total pattern size
     */
    protected static func patternMatchVariance(
        counters: Array<Int64>,
        pattern: Array<Int64>,
        maxIndividualVariance: Float32
    ): Float32 {
        var maxIndividualVarianceuse: Float32 = maxIndividualVariance
        var numCounters: Int64 = counters.size
        var total: Int64 = 0
        var patternLength: Int64 = 0

        for (i in 0..numCounters) {
            total += counters[i]
            patternLength += pattern[i]
        }
        if (total < patternLength) {
            // If we don't even have one pixel per unit of bar width, assume this is too small
            // to reliably match, so fail:
            // return Float.POSITIVE_INFINITY
            return 1.0 / 0.0
        }

        var unitBarWidth: Float32 = Float32(total) / Float32(patternLength)
        maxIndividualVarianceuse = unitBarWidth * maxIndividualVarianceuse

        var totalVariance: Float32 = 0.0

        for (x in 0..numCounters) {
            var counter: Float32 = Float32(counters[x])
            var scaledPattern: Float32 = Float32(pattern[x]) * unitBarWidth

            var variance: Float32
            if (counter > scaledPattern) {
                variance = counter - scaledPattern
            } else {
                variance = scaledPattern - counter
            }

            if (variance > maxIndividualVarianceuse) {
                // return Float.POSITIVE_INFINITY
                var return_data = 1.0 / 0.0
                return 1.0 / 0.0
            }
            totalVariance += variance
        }
        return totalVariance / Float32(total)
    }

    /**
     * <p>Attempts to decode a one-dimensional barcode format given a single row of
     * an image.</p>
     *
     * @param rowNumber row number from top of the row
     * @param row the black/white pixel data of the row
     * @param hints decode hints
     * @return {@link Result} containing encoded string and start/end of barcode
     * @throws NotFoundException if no potential barcode is found
     * @throws ChecksumException if a potential barcode is found but does not pass its checksum
     * @throws FormatException if a potential barcode is found but format is invalid
     */
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}
