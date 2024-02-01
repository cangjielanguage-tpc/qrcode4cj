/*
 * Copyright 2009 ZXing authors
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

package zxing.code.common

/**
 * This class implements a local thresholding algorithm, which while slower than the
 * GlobalHistogramBinarizer, is fairly efficient for what it does. It is designed for
 * high frequency images of barcodes with black data on white backgrounds. For this application,
 * it does a much better job than a global blackpoint with severe shadows and gradients.
 * However it tends to produce artifacts on lower frequency images and is therefore not
 * a good general purpose binarizer for uses outside ZXing.
 *
 * This class extends GlobalHistogramBinarizer, using the older histogram approach for 1D readers,
 * and the newer local approach for 2D readers. 1D decoding using a per-row histogram is already
 * inherently local, and only fails for horizontal gradients. We can revisit that problem later,
 * but for now it was not a win to use local blocks for 1D.
 *
 * This Binarizer is the default for the unit tests and the recommended class for library users.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public class HybridBinarizer <: GlobalHistogramBinarizer {
    static let BLOCK_SIZE_POWER = 3
    static let BLOCK_SIZE = 1 << BLOCK_SIZE_POWER
    static let BLOCK_SIZE_MASK = BLOCK_SIZE - 1
    static let MINIMUM_DIMENSION = BLOCK_SIZE * 5
    static let MIN_DYNAMIC_RANGE = 24

    public var matrix: BitMatrix = BitMatrix()

    public init(source: LuminanceSource) {
        super(source)
    }

    /**
     * Calculates the final BitMatrix once for all requests. This could be called once from the
     * constructor instead, but there are some advantages to doing it lazily, such as making
     * profiling easier, and not doing heavy lifting when callers don't expect it.
     */
    public override func getBlackMatrix(): BitMatrix {
        if (this.matrix.flag) {
            return this.matrix
        }
        let source: LuminanceSource = getLuminanceSource()

        let (width, height) = (source.getWidth(), source.getHeight())
        if (width >= MINIMUM_DIMENSION && height >= MINIMUM_DIMENSION) {
            let luminances = source.getMatrix()

            var subWidth = width >> BLOCK_SIZE_POWER
            if ((width & BLOCK_SIZE_MASK) != 0) {
                subWidth++
            }
            var subHeight = height >> BLOCK_SIZE_POWER
            if ((height & BLOCK_SIZE_MASK) != 0) {
                subHeight++
            }

            let blackPoints: Array<Array<Int64>> = calculateBlackPoints(luminances, subWidth, subHeight, width, height)

            let newMatrix = BitMatrix(width, height)
            calculateThresholdForBlock(luminances, subWidth, subHeight, width, height, blackPoints, newMatrix)
            this.matrix = newMatrix
        } else {
            this.matrix = super.getBlackMatrix()
        }
        return this.matrix
    }

    public override func createBinarizer(source: LuminanceSource): Binarizer {
        HybridBinarizer(source)
    }

    /**
     * For each block in the image, calculate the average black point using a 5x5 grid
     * of the blocks around it. Also handles the corner cases (fractional blocks are computed based
     * on the last pixels in the row/column which are also used in the previous block).
     */
    static func calculateThresholdForBlock(
        luminances: Array<UInt8>,
        subWidth: Int64,
        subHeight: Int64,
        width: Int64,
        height: Int64,
        blackPoints: Array<Array<Int64>>,
        matrix: BitMatrix
    ) {
        let maxYOffset = height - BLOCK_SIZE
        let maxXOffset = width - BLOCK_SIZE

        for (y in 0..subHeight) {
            var yoffset = y << BLOCK_SIZE_POWER
            if (yoffset > maxYOffset) {
                yoffset = maxYOffset
            }
            let top = cap(y, subHeight - 3)
            for (x in 0..subWidth) {
                var xoffset = x << BLOCK_SIZE_POWER
                if (xoffset > maxXOffset) {
                    xoffset = maxXOffset
                }
                let left = cap(x, subWidth - 3)
                var sum = 0
                for (z in -2..=2) {
                    let blackRow = blackPoints[top + z]
                    sum += blackRow[left - 2] + blackRow[left - 1] + blackRow[left] + blackRow[left + 1] + blackRow[left +
                            2]
                }
                let average = sum / 25
                thresholdBlock(luminances, xoffset, yoffset, average, width, matrix)
            }
        }
    }

    static func cap(value: Int64, max: Int64): Int64 {
        if (value < 2) {
            2
        } else {
            math.min(value, max)
        }
    }

    /**
     * Applies a single threshold to a block of pixels.
     */
    static func thresholdBlock(
        luminances: Array<UInt8>,
        xoffset: Int64,
        yoffset: Int64,
        threshold: Int64,
        stride: Int64,
        matrix: BitMatrix
    ) {
        var offset = yoffset * stride + xoffset
        for (y in 0..BLOCK_SIZE) {
            for (x in 0..BLOCK_SIZE) {
                if (Int64(luminances[offset + x] & 0xFF) <= threshold) {
                    matrix.set(xoffset + x, yoffset + y)
                }
            }
            offset += stride
        }
    }

    /**
     * Calculates a single black point for each block of pixels and saves it away.
     * See the following thread for a discussion of this algorithm:
     * http://groups.google.com/group/zxing/browse_thread/thread/d06efa2c35a7ddc0
     */
    static func calculateBlackPoints(
        luminances: Array<UInt8>,
        subWidth: Int64,
        subHeight: Int64,
        width: Int64,
        height: Int64
    ): Array<Array<Int64>> {
        let maxYOffset = height - BLOCK_SIZE
        let maxXOffset = width - BLOCK_SIZE
        let blackPoints = Array<Array<Int64>>(subHeight, {n: Int64 => Array<Int64>(subWidth, item: 0)})
        for (y in 0..subHeight) {
            var yoffset = y << BLOCK_SIZE_POWER
            if (yoffset > maxYOffset) {
                yoffset = maxYOffset
            }
            for (x in 0..subWidth) {
                var xoffset = x << BLOCK_SIZE_POWER
                if (xoffset > maxXOffset) {
                    xoffset = maxXOffset
                }
                var sum = 0
                var min = 0xFF
                var max = 0
                var offset = yoffset * width + xoffset
                var yy = 0
                while (yy < BLOCK_SIZE) {
                    for (xx in 0..BLOCK_SIZE) {
                        let pixel = Int64(luminances[offset + xx] & 0xFF)
                        sum += pixel

                        if (pixel < min) {
                            min = pixel
                        }
                        if (pixel > max) {
                            max = pixel
                        }
                    }
                    if (max - min > MIN_DYNAMIC_RANGE) {
                        yy++
                        offset += width
                        while (yy < BLOCK_SIZE) {
                            for (xx in 0..BLOCK_SIZE) {
                                sum += Int64(luminances[offset + xx] & 0xFF)
                            }
                            yy++
                            offset += width
                        }
                    }
                    yy++
                    offset += width
                }

                var average = sum >> (BLOCK_SIZE_POWER * 2)
                if (max - min <= MIN_DYNAMIC_RANGE) {
                    average = min / 2

                    if (y > 0 && x > 0) {
                        let averageNeighborBlackPoint = (blackPoints[y - 1][x] + (2 * blackPoints[y][x - 1]) +
                            blackPoints[y - 1][x - 1]) / 4
                        if (min < averageNeighborBlackPoint) {
                            average = averageNeighborBlackPoint
                        }
                    }
                }
                blackPoints[y][x] = average
            }
        }

        blackPoints
    }
}
