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

package zxing.code.oned.rss

from std import collection.*
from std import convert.*
from charset import charset.tools.UTF32String

/**
 * Decodes RSS-14, including truncated and stacked variants. See ISO/IEC 24724:2006.
 */
public class RSS14Reader <: AbstractRSSReader {
    private static var OUTSIDE_EVEN_TOTAL_SUBSET: Array<Int64> = [1, 10, 34, 70, 126]
    private static var INSIDE_ODD_TOTAL_SUBSET: Array<Int64> = [4, 20, 48, 81]
    private static var OUTSIDE_GSUM: Array<Int64> = [0, 161, 961, 2015, 2715]
    private static var INSIDE_GSUM: Array<Int64> = [0, 336, 1036, 1516]
    private static var OUTSIDE_ODD_WIDEST: Array<Int64> = [8, 6, 4, 3, 1]
    private static var INSIDE_ODD_WIDEST: Array<Int64> = [2, 4, 6, 8]

    private static var FINDER_PATTERNS: Array<Array<Int64>> = [
        [3, 8, 2, 1],
        [3, 5, 5, 1],
        [3, 3, 7, 1],
        [3, 1, 9, 1],
        [2, 7, 4, 1],
        [2, 5, 6, 1],
        [2, 3, 8, 1],
        [1, 5, 7, 1],
        [1, 3, 9, 1]
    ]

    private var possibleLeftPairs: ArrayList<Pair> = ArrayList<Pair>();
    private var possibleRightPairs: ArrayList<Pair> = ArrayList<Pair>();

    public init() {
        possibleLeftPairs = ArrayList<Pair>()
        possibleRightPairs = ArrayList<Pair>()
    }

    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        var leftPair: Pair
        if (let Some(left_data) <- decodePair(row, false, rowNumber, hints)) {
            leftPair = left_data
            addOrTally(possibleLeftPairs, leftPair);
        }
        row.reverse();

        var rightPair: Pair
        if (let Some(right_data) <- decodePair(row, true, rowNumber, hints)) {
            rightPair = right_data
            addOrTally(possibleRightPairs, rightPair)
        }

        row.reverse();

        for (left in possibleLeftPairs) {
            if (left.getCount() > 1) {
                for (right in possibleRightPairs) {
                    if (right.getCount() > 1 && checkChecksum(left, right)) {
                        var a = constructResult(left, right);

                        return a
                    }
                }
            }
        }

        throw NotFoundException.getNotFoundInstance();
    }

    private static func addOrTally(possiblePairs: ArrayList<Pair>, pair: Pair) {
        var found: Bool = false;

        for (other in possiblePairs) {
            if (other.getValue() == pair.getValue()) {
                other.incrementCount();
                found = true
                break
            }
        }
        if (!found) {
            possiblePairs.append(pair);
        }
    }

    public func reset() {
        possibleLeftPairs.clear();
        possibleRightPairs.clear();
    }

    private static func constructResult(leftPair: Pair, rightPair: Pair): Result {
        var symbolValue: Int64 = 4537077i64 * leftPair.getValue() + rightPair.getValue()
        var text: UTF32String = UTF32String(symbolValue.toString());

        var buffer: ArrayList<Char> = ArrayList<Char>();
        var i: Int64 = 13 - text.charSize
        while (i > 0) {
            buffer.append('0');
            i--
        }
        buffer.appendAll(text.toRuneArray());

        var checkDigit: Int64 = 0;

        for (i in 0..13) {
            var digit: Int64 = Int64.tryParse(buffer.get(i).getOrThrow().toString()).getOrThrow()
            checkDigit += if ((i & 0x01) == 0) {
                3 * digit
            } else {
                digit
            }
        }
        checkDigit = 10 - (checkDigit % 10)
        if (checkDigit == 10) {
            checkDigit = 0
        }
        buffer.appendAll(checkDigit.toString().toRuneArray());

        var leftPoints: Array<ResultPoint> = leftPair.getFinderPattern().getResultPoints();
        var rightPoints: Array<ResultPoint> = rightPair.getFinderPattern().getResultPoints();

        var result: Result = Result(
            String(buffer),
            Array<UInt8>(),
            [leftPoints[0], leftPoints[1], rightPoints[0], rightPoints[1]],
            BarcodeFormat.RSS_14
        );
        result.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]e0");
        return result
    }

    private static func checkChecksum(leftPair: Pair, rightPair: Pair): Bool {
        var checkValue: Int64 = (leftPair.getChecksumPortion() + 16 * rightPair.getChecksumPortion()) % 79
        var targetCheckValue: Int64 = 9 * leftPair.getFinderPattern().getValue() +
            rightPair.getFinderPattern().getValue()
        if (targetCheckValue > 72) {
            targetCheckValue--
        }
        if (targetCheckValue > 8) {
            targetCheckValue--
        }
        return checkValue == targetCheckValue
    }

    private func decodePair(row: BitArray, right: Bool, rowNumber: Int64, hints: Map<DecodeHintType, Any>): ?Pair {
        try {
            var startEnd: Array<Int64> = findFinderPattern(row, right);
            var pattern: FinderPattern = parseFoundFinderPattern(row, rowNumber, right, startEnd);

            var resultPointCallback: ?ResultPointCallback = if (hints.isEmpty()) {
                None
            } else {
                hints.get(DecodeHintType.NEED_RESULT_POINT_CALLBACK) as ResultPointCallback
            }

            if (let Some(r) <- resultPointCallback) {
                startEnd = pattern.getStartEnd()
                var center: Float32 = Float32(startEnd[0] + startEnd[1] - 1) / 2.0f32
                if (right) {
                    // row is actually reversed
                    center = Float32(row.getSize() - 1) - center
                }

                /* != null*/
                r.foundPossibleResultPoint(ResultPoint(center, Float32(rowNumber)));
            }

            var outside: DataCharacter = decodeDataCharacter(row, pattern, true);
            var inside: DataCharacter = decodeDataCharacter(row, pattern, false);
            return Pair(
                1597 * outside.getValue() + inside.getValue(),
                outside.getChecksumPortion() + 4 * inside.getChecksumPortion(),
                pattern
            );
        } catch (ignored: NotFoundException) {
            return None
        }
    }

    private func decodeDataCharacter(row: BitArray, pattern: FinderPattern, outsideChar: Bool): DataCharacter {
        var counters: Array<Int64> = Array<Int64>(getDataCharacterCounters().size, item: 0);

        if (outsideChar) {
            recordPatternInReverse(row, pattern.getStartEnd()[0], counters);
        } else {
            recordPattern(row, pattern.getStartEnd()[1], counters);

            // reverse it
            var i: Int64 = 0;
            var j: Int64 = counters.size - 1
            while (i < j) {
                var temp: Int64 = counters[i]
                counters[i] = counters[j]
                counters[j] = temp
                i++
                j--
            }
        }

        var numModules: Int64 = if (outsideChar) {
            16
        } else {
            15
        }
        var elementWidth: Float32 = Float32(GetArraySum(counters)) / Float32(numModules)

        var oddCounts: Array<Int64> = this.getOddCounts();
        var evenCounts: Array<Int64> = this.getEvenCounts();
        var oddRoundingErrors: Array<Float32> = this.getOddRoundingErrors();
        var evenRoundingErrors: Array<Float32> = this.getEvenRoundingErrors();

        for (i in 0..counters.size) {
            var value: Float32 = Float32(counters[i]) / elementWidth
            var count: Int64 = Int64(value + 0.5f32)

            // Round
            if (count < 1) {
                count = 1
            } else if (count > 8) {
                count = 8
            }
            var offset: Int64 = i / 2
            if ((i & 0x01) == 0) {
                oddCounts[offset] = count
                oddRoundingErrors[offset] = value - Float32(count)
            } else {
                evenCounts[offset] = count
                evenRoundingErrors[offset] = value - Float32(count)
            }
        }

        adjustOddEvenCounts(outsideChar, numModules);

        var oddSum: Int64 = 0;
        var oddChecksumPortion: Int64 = 0;
        var i: Int64 = oddCounts.size - 1
        while (i >= 0) {
            oddChecksumPortion *= 9
            oddChecksumPortion += oddCounts[i]
            oddSum += oddCounts[i]
            i--
        }
        var evenChecksumPortion: Int64 = 0;
        var evenSum: Int64 = 0;
        var j: Int64 = evenCounts.size - 1
        while (j >= 0) {
            evenChecksumPortion *= 9
            evenChecksumPortion += evenCounts[j]
            evenSum += evenCounts[j]
            j--
        }
        var checksumPortion: Int64 = oddChecksumPortion + 3 * evenChecksumPortion

        if (outsideChar) {
            if ((oddSum & 0x01) != 0 || oddSum > 12 || oddSum < 4) {
                throw NotFoundException.getNotFoundInstance();
            }
            var group: Int64 = (12 - oddSum) / 2
            var oddWidest: Int64 = OUTSIDE_ODD_WIDEST[group]
            var evenWidest: Int64 = 9 - oddWidest
            var vOdd: Int64 = RSSUtils.getRSSvalue(oddCounts, oddWidest, false);
            var vEven: Int64 = RSSUtils.getRSSvalue(evenCounts, evenWidest, true);
            var tEven: Int64 = OUTSIDE_EVEN_TOTAL_SUBSET[group]
            var gSum: Int64 = OUTSIDE_GSUM[group]
            return DataCharacter(vOdd * tEven + vEven + gSum, checksumPortion);
        } else {
            if ((evenSum & 0x01) != 0 || evenSum > 10 || evenSum < 4) {
                throw NotFoundException.getNotFoundInstance();
            }
            var group: Int64 = (10 - evenSum) / 2
            var oddWidest: Int64 = INSIDE_ODD_WIDEST[group]
            var evenWidest: Int64 = 9 - oddWidest
            var vOdd: Int64 = RSSUtils.getRSSvalue(oddCounts, oddWidest, true);
            var vEven: Int64 = RSSUtils.getRSSvalue(evenCounts, evenWidest, false);
            var tOdd: Int64 = INSIDE_ODD_TOTAL_SUBSET[group]
            var gSum: Int64 = INSIDE_GSUM[group]
            return DataCharacter(vEven * tOdd + vOdd + gSum, checksumPortion);
        }
    }

    private func GetArraySum(counts: Array<Int64>): Int64 {
        var sum: Int64 = 0;
        for (i in 0..counts.size) {
            sum += counts[i]
        }
        return sum
    }

    private func findFinderPattern(row: BitArray, rightFinderPattern: Bool): Array<Int64> {
        var counters: Array<Int64> = getDecodeFinderCounters();
        counters[0] = 0
        counters[1] = 0
        counters[2] = 0
        counters[3] = 0

        var width: Int64 = row.getSize();
        var isWhite: Bool = false;
        var rowOffset: Int64 = 0;
        while (rowOffset < width) {
            isWhite = !row.get(rowOffset)
            if (rightFinderPattern == isWhite) {
                break
            }
            rowOffset++
        }

        var counterPosition: Int64 = 0;
        var patternStart: Int64 = rowOffset

        for (x in rowOffset..width) {
            if (row.get(x) != isWhite) {
                counters[counterPosition] += 1
            } else {
                if (counterPosition == 3) {
                    if (isFinderPattern(counters)) {
                        return [patternStart, x]
                    }
                    patternStart += counters[0] + counters[1]
                    counters[0] = counters[2]
                    counters[1] = counters[3]
                    counters[2] = 0
                    counters[3] = 0
                    counterPosition--
                } else {
                    counterPosition++
                }
                counters[counterPosition] = 1
                isWhite = !isWhite
            }
        }

        throw NotFoundException.getNotFoundInstance();
    }

    private func parseFoundFinderPattern(row: BitArray, rowNumber: Int64, right: Bool, startEnd: Array<Int64>): FinderPattern {
        // Actually we found elements 2-5
        var firstIsBlack: Bool = row.get(startEnd[0]);
        var firstElementStart: Int64 = startEnd[0] - 1

        // Locate element 1
        while (firstElementStart >= 0 && firstIsBlack != row.get(firstElementStart)) {
            firstElementStart--
        }
        firstElementStart++
        var firstCounter: Int64 = startEnd[0] - firstElementStart

        // Make 'counters' hold 1-4
        var counters: Array<Int64> = getDecodeFinderCounters();
        counters.copyTo(counters, 0, 1, counters.size - 1)
        counters[0] = firstCounter
        var value: Int64 = parseFinderValue(counters, FINDER_PATTERNS);
        var start: Int64 = firstElementStart
        var end: Int64 = startEnd[1]
        if (right) {
            // row is actually reversed
            start = row.getSize() - 1 - start
            end = row.getSize() - 1 - end
        }
        return FinderPattern(value, [firstElementStart, startEnd[1]], start, end, rowNumber);
    }

    private func adjustOddEvenCounts(outsideChar: Bool, numModules: Int64) {
        var oddSum: Int64 = GetArraySum(getOddCounts());
        var evenSum: Int64 = GetArraySum(getEvenCounts());

        var incrementOdd: Bool = false;
        var decrementOdd: Bool = false;
        var incrementEven: Bool = false;
        var decrementEven: Bool = false;

        if (outsideChar) {
            if (oddSum > 12) {
                decrementOdd = true
            } else if (oddSum < 4) {
                incrementOdd = true
            }
            if (evenSum > 12) {
                decrementEven = true
            } else if (evenSum < 4) {
                incrementEven = true
            }
        } else {
            if (oddSum > 11) {
                decrementOdd = true
            } else if (oddSum < 5) {
                incrementOdd = true
            }
            if (evenSum > 10) {
                decrementEven = true
            } else if (evenSum < 4) {
                incrementEven = true
            }
        }

        var mismatch: Int64 = oddSum + evenSum - numModules
        var oddParityBad: Bool = (oddSum & 0x01) == (if (outsideChar) {
            1
        } else {
            0
        })
        var evenParityBad: Bool = (evenSum & 0x01) == 1

        match (mismatch) {
            case 1 => if (oddParityBad) {
                if (evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                decrementOdd = true
            } else {
                if (!evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                decrementEven = true
            }
            case -1 => if (oddParityBad) {
                if (evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                incrementOdd = true
            } else {
                if (!evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                incrementEven = true
            }
            case 0 => if (oddParityBad) {
                if (!evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }

                // Both bad
                if (oddSum < evenSum) {
                    incrementOdd = true
                    decrementEven = true
                } else {
                    decrementOdd = true
                    incrementEven = true
                }
            } else {
                if (evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                // Nothing to do!
            }
            case _ => throw NotFoundException.getNotFoundInstance();
        }

        if (incrementOdd) {
            if (decrementOdd) {
                throw NotFoundException.getNotFoundInstance();
            }
            increment(getOddCounts(), getOddRoundingErrors());
        }
        if (decrementOdd) {
            decrement(getOddCounts(), getOddRoundingErrors());
        }
        if (incrementEven) {
            if (decrementEven) {
                throw NotFoundException.getNotFoundInstance();
            }
            increment(getEvenCounts(), getOddRoundingErrors());
        }
        if (decrementEven) {
            decrement(getEvenCounts(), getEvenRoundingErrors());
        }
    }
}
