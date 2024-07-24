/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common

import std.fs.*

public open class GlobalHistogramBinarizer <: Binarizer {
    static let LUMINANCE_BITS: UInt8 = 5
    static let LUMINANCE_SHIFT: UInt8 = 8 - LUMINANCE_BITS
    static let LUMINANCE_BUCKETS = 1 << LUMINANCE_BITS
    static let EMPTY: Array<Byte> = []

    public var luminances: Array<UInt8>
    public var buckets: Array<Int64>

    public init(source: LuminanceSource) {
        super(source)
        luminances = EMPTY
        buckets = Array<Int64>(LUMINANCE_BUCKETS, item: 0)
    }

    // Applies simple sharpening to the row data to improve performance of the 1D Readers.
    public open func getBlackRow(y: Int64, r: BitArray): BitArray {
        let source: LuminanceSource = getLuminanceSource()
        let width = source.getWidth()
        var row: BitArray = BitArray()
        if (r.getSize() < width) {
            row = BitArray(width)
        } else {
            row = r
            row.clear()
        }

        initArrays(width)
        let localLuminances = source.getRow(y, luminances)
        var localBuckets = buckets
        for (x in 0..width) {
            localBuckets[Int64((localLuminances[x] & 0xff) >> LUMINANCE_SHIFT)] = localBuckets[Int64((localLuminances[x] &
                        0xff) >> LUMINANCE_SHIFT)] + 1
        }
        buckets = localBuckets
        let blackPoint = estimateBlackPoint(localBuckets)

        if (width < 3) {
            for (x in 0..width) {
                if (Int64(localLuminances[x] & 0xff) < blackPoint) {
                    row.set(x)
                }
            }
        } else {
            var left = localLuminances[0] & 0xff
            var center = localLuminances[1] & 0xff
            for (x in 1..(width - 1)) {
                let right = localLuminances[x + 1] & 0xff
                if ((Int64(center) * 4 - Int64(left) - Int64(right)) / 2 < blackPoint) {
                    row.set(x)
                }
                left = center
                center = right
            }
        }

        row
    }

    public open func getBlackMatrix(): BitMatrix {
        let source: LuminanceSource = getLuminanceSource()
        let width = source.getWidth()
        let height = source.getHeight()
        let matrix = BitMatrix(width, height)

        initArrays(width)
        let localBuckets = buckets
        for (y in 1..5) {
            let row = height * y / 5
            let localLuminances = source.getRow(row, luminances)
            let right = (width * 4) / 5
            for (x in (width / 5)..right) {
                let pixel = localLuminances[x] & 0xff
                localBuckets[Int64(pixel >> LUMINANCE_SHIFT)] += 1
            }
        }
        buckets = localBuckets
        let blackPoint = estimateBlackPoint(localBuckets)

        let localLuminances = source.getMatrix()
        for (y in 0..height) {
            let offset = y * width
            for (x in 0..width) {
                let pixel = Int64(localLuminances[offset + x] & 0xff)
                if (pixel < blackPoint) {
                    matrix.set(x, y)
                }
            }
        }

        matrix
    }

    public open func createBinarizer(source: LuminanceSource): Binarizer {
        GlobalHistogramBinarizer(source)
    }

    func initArrays(luminanceSize: Int64) {
        if (luminances.size < luminanceSize) {
            luminances = Array<UInt8>(luminanceSize, item: 0)
        }
        for (x in 0..LUMINANCE_BUCKETS) {
            buckets[x] = 0
        }
    }

    static func estimateBlackPoint(buckets_: Array<Int64>): Int64 {
        let numBuckets = buckets_.size
        var maxBucketCount = 0
        var firstPeak = 0
        var firstPeakSize = 0
        for (x in 0..numBuckets) {
            if (buckets_[x] > firstPeakSize) {
                firstPeak = x
                firstPeakSize = buckets_[x]
            }
            if (buckets_[x] > maxBucketCount) {
                maxBucketCount = buckets_[x]
            }
        }

        var secondPeak = 0
        var secondPeakScore_ = 0
        for (x in 0..numBuckets) {
            let distanceToBiggest = x - firstPeak
            let score = buckets_[x] * distanceToBiggest * distanceToBiggest
            if (score > secondPeakScore_) {
                secondPeak = x
                secondPeakScore_ = score
            }
        }

        if (firstPeak > secondPeak) {
            let temp = firstPeak
            firstPeak = secondPeak
            secondPeak = temp
        }

        if (secondPeak - firstPeak <= numBuckets / 16) {
            throw Qrcoder4cjNotFoundException()
        }

        var bestValley = secondPeak - 1
        var bestValleyScore = -1
        var x = secondPeak - 1
        while (x > firstPeak) {
            let fromFirst = x - firstPeak
            let score = fromFirst * fromFirst * (secondPeak - x) * (maxBucketCount - buckets_[x])
            if (score > bestValleyScore) {
                bestValley = x
                bestValleyScore = score
            }
            x = x - 1
        }

        bestValley << LUMINANCE_SHIFT
    }
}
