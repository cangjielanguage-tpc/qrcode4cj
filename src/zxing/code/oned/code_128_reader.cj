/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * Decodes Code 128 barcodes.
 */
public open class Code128Reader <: OneDReader {
    static let CODE_PATTERNS: Array<Array<Int64>> = [
        [2, 1, 2, 2, 2, 2], // 0
        [2, 2, 2, 1, 2, 2],
        [2, 2, 2, 2, 2, 1],
        [1, 2, 1, 2, 2, 3],
        [1, 2, 1, 3, 2, 2],
        [1, 3, 1, 2, 2, 2], // 5
        [1, 2, 2, 2, 1, 3],
        [1, 2, 2, 3, 1, 2],
        [1, 3, 2, 2, 1, 2],
        [2, 2, 1, 2, 1, 3],
        [2, 2, 1, 3, 1, 2], // 10
        [2, 3, 1, 2, 1, 2],
        [1, 1, 2, 2, 3, 2],
        [1, 2, 2, 1, 3, 2],
        [1, 2, 2, 2, 3, 1],
        [1, 1, 3, 2, 2, 2], // 15
        [1, 2, 3, 1, 2, 2],
        [1, 2, 3, 2, 2, 1],
        [2, 2, 3, 2, 1, 1],
        [2, 2, 1, 1, 3, 2],
        [2, 2, 1, 2, 3, 1], // 20
        [2, 1, 3, 2, 1, 2],
        [2, 2, 3, 1, 1, 2],
        [3, 1, 2, 1, 3, 1],
        [3, 1, 1, 2, 2, 2],
        [3, 2, 1, 1, 2, 2], // 25
        [3, 2, 1, 2, 2, 1],
        [3, 1, 2, 2, 1, 2],
        [3, 2, 2, 1, 1, 2],
        [3, 2, 2, 2, 1, 1],
        [2, 1, 2, 1, 2, 3], // 30
        [2, 1, 2, 3, 2, 1],
        [2, 3, 2, 1, 2, 1],
        [1, 1, 1, 3, 2, 3],
        [1, 3, 1, 1, 2, 3],
        [1, 3, 1, 3, 2, 1], // 35
        [1, 1, 2, 3, 1, 3],
        [1, 3, 2, 1, 1, 3],
        [1, 3, 2, 3, 1, 1],
        [2, 1, 1, 3, 1, 3],
        [2, 3, 1, 1, 1, 3], // 40
        [2, 3, 1, 3, 1, 1],
        [1, 1, 2, 1, 3, 3],
        [1, 1, 2, 3, 3, 1],
        [1, 3, 2, 1, 3, 1],
        [1, 1, 3, 1, 2, 3], // 45
        [1, 1, 3, 3, 2, 1],
        [1, 3, 3, 1, 2, 1],
        [3, 1, 3, 1, 2, 1],
        [2, 1, 1, 3, 3, 1],
        [2, 3, 1, 1, 3, 1], // 50
        [2, 1, 3, 1, 1, 3],
        [2, 1, 3, 3, 1, 1],
        [2, 1, 3, 1, 3, 1],
        [3, 1, 1, 1, 2, 3],
        [3, 1, 1, 3, 2, 1], // 55
        [3, 3, 1, 1, 2, 1],
        [3, 1, 2, 1, 1, 3],
        [3, 1, 2, 3, 1, 1],
        [3, 3, 2, 1, 1, 1],
        [3, 1, 4, 1, 1, 1], // 60
        [2, 2, 1, 4, 1, 1],
        [4, 3, 1, 1, 1, 1],
        [1, 1, 1, 2, 2, 4],
        [1, 1, 1, 4, 2, 2],
        [1, 2, 1, 1, 2, 4], // 65
        [1, 2, 1, 4, 2, 1],
        [1, 4, 1, 1, 2, 2],
        [1, 4, 1, 2, 2, 1],
        [1, 1, 2, 2, 1, 4],
        [1, 1, 2, 4, 1, 2], // 70
        [1, 2, 2, 1, 1, 4],
        [1, 2, 2, 4, 1, 1],
        [1, 4, 2, 1, 1, 2],
        [1, 4, 2, 2, 1, 1],
        [2, 4, 1, 2, 1, 1], // 75
        [2, 2, 1, 1, 1, 4],
        [4, 1, 3, 1, 1, 1],
        [2, 4, 1, 1, 1, 2],
        [1, 3, 4, 1, 1, 1],
        [1, 1, 1, 2, 4, 2], // 80
        [1, 2, 1, 1, 4, 2],
        [1, 2, 1, 2, 4, 1],
        [1, 1, 4, 2, 1, 2],
        [1, 2, 4, 1, 1, 2],
        [1, 2, 4, 2, 1, 1], // 85
        [4, 1, 1, 2, 1, 2],
        [4, 2, 1, 1, 1, 2],
        [4, 2, 1, 2, 1, 1],
        [2, 1, 2, 1, 4, 1],
        [2, 1, 4, 1, 2, 1], // 90
        [4, 1, 2, 1, 2, 1],
        [1, 1, 1, 1, 4, 3],
        [1, 1, 1, 3, 4, 1],
        [1, 3, 1, 1, 4, 1],
        [1, 1, 4, 1, 1, 3], // 95
        [1, 1, 4, 3, 1, 1],
        [4, 1, 1, 1, 1, 3],
        [4, 1, 1, 3, 1, 1],
        [1, 1, 3, 1, 4, 1],
        [1, 1, 4, 1, 3, 1], // 100
        [3, 1, 1, 1, 4, 1],
        [4, 1, 1, 1, 3, 1],
        [2, 1, 1, 4, 1, 2],
        [2, 1, 1, 2, 1, 4],
        [2, 1, 1, 2, 3, 2], // 105
        [2, 3, 3, 1, 1, 1, 2]
    ]

    private static let MAX_AVG_VARIANCE: Float32 = 0.25
    private static let MAX_INDIVIDUAL_VARIANCE: Float32 = 0.7

    private static let CODE_SHIFT: Int64 = 98

    private static let CODE_CODE_C: Int64 = 99
    private static let CODE_CODE_B: Int64 = 100
    private static let CODE_CODE_A: Int64 = 101

    private static let CODE_FNC_1: Int64 = 102
    private static let CODE_FNC_2: Int64 = 97
    private static let CODE_FNC_3: Int64 = 96
    private static let CODE_FNC_4_A: Int64 = 101
    private static let CODE_FNC_4_B: Int64 = 100

    private static let CODE_START_A: Int64 = 103
    private static let CODE_START_B: Int64 = 104
    private static let CODE_START_C: Int64 = 105
    private static let CODE_STOP: Int64 = 106

    private static func findStartPattern(row: BitArray): Array<Int64> {
        var width: Int64 = row.getSize()
        var rowOffset: Int64 = row.getNextSet(0)

        var counterPosition: Int64 = 0
        var counters: Array<Int64> = Array<Int64>(6, item: 0)
        var patternStart: Int64 = rowOffset
        var isWhite: Bool = false
        var patternLength: Int64 = counters.size

        for (i in rowOffset..width) {
            if (row.get(i) != isWhite) {
                counters[counterPosition] = counters[counterPosition] + 1
            } else {
                if (counterPosition == patternLength - 1) {
                    var bestVariance: Float32 = MAX_AVG_VARIANCE
                    var bestMatch: Int64 = -1

                    for (startCode in CODE_START_A..CODE_START_C + 1) {
                        var variance: Float32 = patternMatchVariance(
                            counters,
                            CODE_PATTERNS[startCode],
                            MAX_INDIVIDUAL_VARIANCE
                        )
                        if (variance < bestVariance) {
                            bestVariance = variance
                            bestMatch = startCode
                        }
                    }

                    // Look for whitespace before start pattern, >= 50% of width of start pattern
                    if (bestMatch >= 0 && row.isRange(
                        max(0, patternStart - (i - patternStart) / 2),
                        patternStart,
                        false
                    )) {
                        return Array<Int64>([patternStart, i, bestMatch])
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
        }
        throw NotFoundException.getNotFoundInstance()
    }

    private static func decodeCode(row: BitArray, counters: Array<Int64>, rowOffset: Int64): Int64 {
        recordPattern(row, rowOffset, counters)
        var bestVariance: Float32 = MAX_AVG_VARIANCE

        // worst variance we'll accept
        var bestMatch: Int64 = -1

        for (d in 0..CODE_PATTERNS.size) {
            var pattern: Array<Int64> = CODE_PATTERNS[d]
            var variance: Float32 = patternMatchVariance(counters, pattern, MAX_INDIVIDUAL_VARIANCE)
            if (variance < bestVariance) {
                bestVariance = variance
                bestMatch = d
            }
        }

        // TODO We're overlooking the fact that the STOP pattern has 7 values, not 6.
        if (bestMatch >= 0) {
            return bestMatch
        } else {
            throw NotFoundException.getNotFoundInstance()
        }
    }

    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        var convertFNC1: Bool = hints.size != 0 && hints.contains(DecodeHintType.ASSUME_GS1)

        var symbologyModifier: Int64 = 0

        var startPatternInfo: Array<Int64> = findStartPattern(row)
        var startCode: Int64 = startPatternInfo[2]
        var rawCodes: ArrayList<UInt8> = ArrayList<UInt8>(20)
        rawCodes.append(UInt8(startCode))

        var codeSet: Int64
        if (startCode == CODE_START_A) {
            codeSet = CODE_CODE_A
        } else if (startCode == CODE_START_B) {
            codeSet = CODE_CODE_B
        } else if (startCode == CODE_START_C) {
            codeSet = CODE_CODE_C
        } else {
            throw FormatException.getFormatInstance()
        }

        var done: Bool = false
        var isNextShifted: Bool = false

        var result: ArrayList<Char> = ArrayList<Char>()

        var lastStart: Int64 = startPatternInfo[0]
        var nextStart: Int64 = startPatternInfo[1]
        var counters: Array<Int64> = Array<Int64>(6, item: 0)

        var lastCode: Int64 = 0
        var code: Int64 = 0
        var checksumTotal: Int64 = startCode
        var multiplier: Int64 = 0
        var lastCharacterWasPrintable: Bool = true
        var upperMode: Bool = false
        var shiftUpperMode: Bool = false

        while (!done) {
            var unshift: Bool = isNextShifted
            isNextShifted = false

            // Save off last code
            lastCode = code

            // Decode another code from image
            code = decodeCode(row, counters, nextStart)

            rawCodes.append(UInt8(code))

            // Remember whether the last code was printable or not (excluding CODE_STOP)
            if (code != CODE_STOP) {
                lastCharacterWasPrintable = true
            }

            // Add to checksum computation (if not CODE_STOP of course)
            if (code != CODE_STOP) {
                multiplier++
                checksumTotal += multiplier * code
            }

            // Advance to where the next code will to start
            lastStart = nextStart

            for (i in 0..counters.size) {
                nextStart += counters[i]
            }

            // Take care of illegal start codes
            if (code == CODE_START_A || code == CODE_START_B || code == CODE_START_C) {
                throw FormatException.getFormatInstance()
            }

            if (codeSet == CODE_CODE_A) {
                if (code < 64) {
                    if (shiftUpperMode == upperMode) {
                        result.append(Char(' '.hashCode() + code))
                    } else {
                        result.append(Char(' '.hashCode() + code + 128))
                    }
                    shiftUpperMode = false
                } else if (code < 96) {
                    if (shiftUpperMode == upperMode) {
                        result.append(Char(code - 64))
                    } else {
                        result.append(Char(code + 64))
                    }
                    shiftUpperMode = false
                } else {
                    // Don't let CODE_STOP, which always appears, affect whether whether we think the last code
                    // was printable or not.
                    if (code != CODE_STOP) {
                        lastCharacterWasPrintable = false
                    }

                    if (code == CODE_FNC_1) {
                        if (result.size == 0) { // FNC1 at first or second character determines the symbology
                            symbologyModifier = 1
                        } else if (result.size == 1) {
                            symbologyModifier = 2
                        }
                        if (convertFNC1) {
                            if (result.size == 0) {
                                // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code is
                                // FNC1 then this is GS1-128. We add the symbology identifier.
                                result.appendAll("]C1".toRuneArray())
                            } else {
                                // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                                result.append(Char(29))
                            }
                        }
                    } else if (code == CODE_FNC_2) {
                        symbologyModifier = 4
                    } else if (code == CODE_FNC_3) {}
                    else if (code == CODE_FNC_4_A) {
                        if (!upperMode && shiftUpperMode) {
                            upperMode = true
                            shiftUpperMode = false
                        } else if (upperMode && shiftUpperMode) {
                            upperMode = false
                            shiftUpperMode = false
                        } else {
                            shiftUpperMode = true
                        }
                    } else if (code == CODE_SHIFT) {
                        isNextShifted = true
                        codeSet = CODE_CODE_B
                    } else if (code == CODE_CODE_B) {
                        codeSet = CODE_CODE_B
                    } else if (code == CODE_CODE_C) {
                        codeSet = CODE_CODE_C
                    } else if (code == CODE_STOP) {
                        done = true
                    }
                }
            } else if (codeSet == CODE_CODE_B) {
                if (code < 96) {
                    if (shiftUpperMode == upperMode) {
                        result.append(Char(' '.hashCode() + code))
                    } else {
                        result.append(Char(' '.hashCode() + code + 128))
                    }
                    shiftUpperMode = false
                } else {
                    if (code != CODE_STOP) {
                        lastCharacterWasPrintable = false
                    }
                    if (code == CODE_FNC_1) {
                        if (result.size == 0) { // FNC1 at first or second character determines the symbology
                            symbologyModifier = 1
                        } else if (result.size == 1) {
                            symbologyModifier = 2
                        }
                        if (convertFNC1) {
                            if (result.size == 0) {
                                // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code
                                // is FNC1 then this is GS1-128. We add the symbology identifier.
                                result.appendAll("]C1".toRuneArray())
                            } else {
                                // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                                result.append(Char(29))
                            }
                        }
                    } else if (code == CODE_FNC_2) {
                        symbologyModifier = 4
                    } else if (code == CODE_FNC_3) {}
                    else if (code == CODE_FNC_4_B) {
                        if (!upperMode && shiftUpperMode) {
                            upperMode = true
                            shiftUpperMode = false
                        } else if (upperMode && shiftUpperMode) {
                            upperMode = false
                            shiftUpperMode = false
                        } else {
                            shiftUpperMode = true
                        }
                    } else if (code == CODE_SHIFT) {
                        isNextShifted = true
                        codeSet = CODE_CODE_A
                    } else if (code == CODE_CODE_A) {
                        codeSet = CODE_CODE_A
                    } else if (code == CODE_CODE_C) {
                        codeSet = CODE_CODE_C
                    } else if (code == CODE_STOP) {
                        done = true
                    }
                }
            } else if (codeSet == CODE_CODE_C) {
                if (code < 100) {
                    if (code < 10) {
                        result.append('0')
                    }
                    result.appendAll(code.toString().toRuneArray())
                } else {
                    if (code != CODE_STOP) {
                        lastCharacterWasPrintable = false
                    }

                    if (code == CODE_FNC_1) {
                        if (result.size == 0) { // FNC1 at first or second character determines the symbology
                            symbologyModifier = 1
                        } else if (result.size == 1) {
                            symbologyModifier = 2
                        }
                        if (convertFNC1) {
                            if (result.size == 0) {
                                // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code
                                // is FNC1 then this is GS1-128. We add the symbology identifier.
                                result.appendAll("]C1".toRuneArray())
                            } else {
                                // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                                result.append(Char(29))
                            }
                        }
                    } else if (code == CODE_CODE_A) {
                        codeSet = CODE_CODE_A
                    } else if (code == CODE_CODE_B) {
                        codeSet = CODE_CODE_B
                    } else if (code == CODE_STOP) {
                        done = true
                    }
                }
            }
            // Unshift back to another code set if we were shifted
            if (unshift) {
                if (codeSet == CODE_CODE_A) {
                    codeSet = CODE_CODE_B
                } else {
                    codeSet = CODE_CODE_A
                }
            }
        }

        var lastPatternSize: Int64 = nextStart - lastStart

        // Check for ample whitespace following pattern, but, to do this we first need to remember that we
        // fudged decoding CODE_STOP since it actually has 7 bars, not 6. There is a black bar left
        // to read off. Would be slightly better to properly read. Here we just skip it:
        nextStart = row.getNextUnset(nextStart)
        if (!row.isRange(
            nextStart,
            min(row.getSize(), nextStart + (nextStart - lastStart) / 2),
            false
        )) {
            throw NotFoundException.getNotFoundInstance()
        }

        // Pull out from sum the value of the penultimate check code
        checksumTotal -= multiplier * lastCode

        // lastCode is the checksum then:
        if (checksumTotal % 103 != lastCode) {
            throw ChecksumException.getChecksumInstance()
        }

        // Need to pull out the check digits from string
        var resultLength: Int64 = result.size
        if (resultLength == 0) {
            // false positive
            throw NotFoundException.getNotFoundInstance()
        }

        // Only bother if the result had at least one character, and if the checksum digit happened to be
        // a printable character. If it was just interpreted as a control code, nothing to remove.
        if (resultLength > 0 && lastCharacterWasPrintable) {
            if (codeSet == CODE_CODE_C) {
                let range = Range(resultLength - 2, resultLength - 1, 1, true, true, true)
                result.remove(range)
            } else {
                let range = Range(resultLength - 1, resultLength - 1, 1, true, true, true)
                result.remove(range)
            }
        }

        var left: Float32 = Float32(startPatternInfo[1] + startPatternInfo[0]) / 2.0
        var right: Float32 = Float32(lastStart + lastPatternSize) / 2.0

        var rawCodesSize: Int64 = rawCodes.size
        var rawBytes: Array<UInt8> = Array<UInt8>(rawCodesSize, item: 0)

        for (i in 0..rawCodesSize) {
            rawBytes[i] = rawCodes.get(i).getOrThrow()
        }
        var resultObject: Result = Result(
            String(result),
            rawBytes,
            Array<ResultPoint>(
                [
                    ResultPoint(left, Float32(rowNumber)),
                    ResultPoint(right, Float32(rowNumber))
                ]
            ),
            BarcodeFormat.CODE_128
        )
        resultObject.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]C${symbologyModifier}")

        return resultObject
    }
}
