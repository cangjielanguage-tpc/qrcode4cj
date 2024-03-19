/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.pdf417.decoder

import zxing.code.common.detector.MathUtils

open class PDF417CodewordDecoder {
    private static var RATIOS_TABLE: Array<Array<Float32>> = Array<Array<Float32>>()
    private init() {
    }

    static func getDecodedValue(moduleBitCount: Array<Int64>): Int64 {
        var decodedValue: Int64 = getDecodedCodewordValue(sampleBitCounts(moduleBitCount));
        if (decodedValue != -1) {
            return decodedValue
        }
        return getClosestDecodedValue(moduleBitCount);
    }

    private static func sampleBitCounts(moduleBitCount: Array<Int64>): Array<Int64> {
        var bitCountSum: Float32 = Float32(MathUtils.sum(moduleBitCount))
        var result: Array<Int64> = Array<Int64>(PDF417Common.BARS_IN_MODULE, item: 0)
        var bitCountIndex: Int64 = 0
        var sumPreviousBits: Int64 = 0
        for (i in 0..PDF417Common.MODULES_IN_CODEWORD) {
            var sampleIndex: Float32 = bitCountSum / Float32(2 * PDF417Common.MODULES_IN_CODEWORD) +
                (Float32(i) * bitCountSum) / Float32(PDF417Common.MODULES_IN_CODEWORD)
            if (Float32(sumPreviousBits + moduleBitCount[bitCountIndex]) <= sampleIndex) {
                sumPreviousBits += moduleBitCount[bitCountIndex]
                bitCountIndex++
            }
            result[bitCountIndex] = result[bitCountIndex] + 1
        }

        return result
    }

    private static func getDecodedCodewordValue(moduleBitCount: Array<Int64>): Int64 {
        var decodedValue: Int64 = getBitValue(moduleBitCount);

        if (PDF417Common.getCodeword(decodedValue) == -1) {
            return -1
        } else {
            return decodedValue
        }
    }

    private static func getBitValue(moduleBitCount: Array<Int64>): Int64 {
        var result: Int64 = 0

        for (i in 0..moduleBitCount.size) {
            for (bit in 0..moduleBitCount[i]) {
                var d: Int64 = 0
                if (i % 2 == 0) {
                    d = 1
                } else {
                    d = 0
                }
                result = (result << 1) | d
            }
        }
        return result
    }

    private static func getClosestDecodedValue(moduleBitCount: Array<Int64>): Int64 {
        if (RATIOS_TABLE.size == 0) {
            RATIOS_TABLE = Array<Array<Float32>>(
                PDF417Common.SYMBOL_TABLE.size,
                {int: Int64 => Array<Float32>(PDF417Common.BARS_IN_MODULE, item: 0.0)}
            )

            // Pre-computes the symbol ratio table.
            for (i in 0..PDF417Common.SYMBOL_TABLE.size) {
                var currentSymbol: Int64 = PDF417Common.SYMBOL_TABLE[i]
                var currentBit: Int64 = currentSymbol & 0x1

                for (j in 0..PDF417Common.BARS_IN_MODULE) {
                    var size: Float32 = 0.0
                    while ((currentSymbol & 0x1) == currentBit) {
                        size += 1.0
                        currentSymbol >>= 1
                    }
                    currentBit = currentSymbol & 0x1
                    RATIOS_TABLE[i][PDF417Common.BARS_IN_MODULE - j - 1] = size / Float32(PDF417Common.
                            MODULES_IN_CODEWORD)
                }
            }
        }

        var bitCountSum: Int64 = MathUtils.sum(moduleBitCount);
        var bitCountRatios: Array<Float32> = Array<Float32>(PDF417Common.BARS_IN_MODULE, item: 0.0)
        if (bitCountSum > 1) {
            for (i in 0..bitCountRatios.size) {
                bitCountRatios[i] = (Float32(moduleBitCount[i]) / Float32(bitCountSum))
            }
        }
        var bestMatchError: Float32 = Float32.Max;
        var bestMatch: Int64 = -1
        for (j in 0..RATIOS_TABLE.size) {
            var error: Float32 = 0.0
            var ratioTableRow: Array<Float32> = RATIOS_TABLE[j]
            for (k in 0..PDF417Common.BARS_IN_MODULE) {
                var diff: Float32 = ratioTableRow[k] - bitCountRatios[k]
                error += diff * diff
                if (error >= bestMatchError) {
                    break
                }
            }
            if (error < bestMatchError) {
                bestMatchError = error
                bestMatch = PDF417Common.SYMBOL_TABLE[j]
            }
        }

        return bestMatch
    }
}
