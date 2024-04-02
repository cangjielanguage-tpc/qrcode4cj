/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned.rss

import zxing.code.common.detector.*

/**
 * Superclass of {@link OneDReader} implementations that read barcodes in the RSS family
 * of formats.
 */
public abstract class AbstractRSSReader <: OneDReader {
    private static let MAX_AVG_VARIANCE: Float32 = 0.2;
    private static let MAX_INDIVIDUAL_VARIANCE: Float32 = 0.45f32;

    private static var MIN_FINDER_PATTERN_RATIO: Float32 = 9.5f32 / 12.0f32
    private static var MAX_FINDER_PATTERN_RATIO: Float32 = 12.5f32 / 14.0f32

    private var decodeFinderCounters: Array<Int64> = Array<Int64>();
    private var dataCharacterCounters: Array<Int64> = Array<Int64>();
    private var oddRoundingErrors: Array<Float32> = Array<Float32>();
    private var evenRoundingErrors: Array<Float32> = Array<Float32>();
    private var oddCounts: Array<Int64> = Array<Int64>();
    private var evenCounts: Array<Int64> = Array<Int64>();

    protected init() {
        decodeFinderCounters = Array<Int64>(4, item: 0)
        dataCharacterCounters = Array<Int64>(8, item: 0)
        oddRoundingErrors = Array<Float32>(4, item: 0.0)
        evenRoundingErrors = Array<Float32>(4, item: 0.0)
        oddCounts = Array<Int64>(dataCharacterCounters.size / 2, item: 0)
        evenCounts = Array<Int64>(dataCharacterCounters.size / 2, item: 0)
    }

    protected func getDecodeFinderCounters(): Array<Int64> {
        return decodeFinderCounters
    }

    protected func getDataCharacterCounters(): Array<Int64> {
        return dataCharacterCounters
    }

    protected func getOddRoundingErrors(): Array<Float32> {
        return oddRoundingErrors
    }

    protected func getEvenRoundingErrors(): Array<Float32> {
        return evenRoundingErrors
    }

    protected func getOddCounts(): Array<Int64> {
        return oddCounts
    }

    protected func getEvenCounts(): Array<Int64> {
        return evenCounts
    }

    protected static func parseFinderValue(counters: Array<Int64>, finderPatterns: Array<Array<Int64>>): Int64 {
        for (value in 0..finderPatterns.size) {
            if (patternMatchVariance(counters, finderPatterns[value], MAX_INDIVIDUAL_VARIANCE) < MAX_AVG_VARIANCE) {
                return value
            }
        }
        throw Qrcoder4cjNotFoundException.getNotFoundInstance();
    }

    /**
     * @param array values to sum
     * @return sum of values
     * @deprecated call {@link MathUtils#sum(int[])}
     */
    // @Deprecated
    protected static func count(array: Array<Int64>): Int64 {
        return MathUtils.sum(array);
    }

    protected static func increment(arrayin: Array<Int64>, errors: Array<Float32>) {
        var array: Array<Int64> = arrayin
        var index: Int64 = 0;
        var biggestError: Float32 = errors[0]

        for (i in 1..array.size) {
            if (errors[i] > biggestError) {
                biggestError = errors[i]
                index = i
            }
        }
        array[index] = array[index] + 1
    }

    protected static func decrement(arrayin: Array<Int64>, errors: Array<Float32>) {
        var array: Array<Int64> = arrayin
        var index: Int64 = 0;
        var biggestError: Float32 = errors[0]

        for (i in 1..array.size) {
            if (errors[i] < biggestError) {
                biggestError = errors[i]
                index = i
            }
        }
        array[index] = array[index] - 1
    }

    protected static func isFinderPattern(counters: Array<Int64>): Bool {
        var firstTwoSum: Int64 = counters[0] + counters[1]
        var sum: Int64 = firstTwoSum + counters[2] + counters[3]
        var ratio: Float32 = Float32(firstTwoSum) / Float32(sum)
        if (ratio >= MIN_FINDER_PATTERN_RATIO && ratio <= MAX_FINDER_PATTERN_RATIO) {
            // passes ratio test in spec, but see if the counts are unreasonable
            var minCounter: Int32 = Int32.Max;
            var maxCounter: Int32 = -Int32.Max

            for (i in 0..counters.size) {
                if (counters[i] > Int64(maxCounter)) {
                    maxCounter = Int32(counters[i])
                }
                if (counters[i] < Int64(minCounter)) {
                    minCounter = Int32(counters[i])
                }
            }
            return maxCounter < 10 * minCounter
        }
        return false;
    }
    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result
}
