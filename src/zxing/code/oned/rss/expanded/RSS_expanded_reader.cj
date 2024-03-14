/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned.rss.expanded

import zxing.code.oned.rss.expanded.decoders.*
from std import math.*

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
public class RSSExpandedReader <: AbstractRSSReader {
    private static var SYMBOL_WIDEST: Array<Int64> = [7, 5, 4, 3, 1]
    private static var EVEN_TOTAL_SUBSET: Array<Int64> = [4, 20, 52, 104, 204]
    private static var GSUM: Array<Int64> = [0, 348, 1388, 2948, 3988]

    private static var FINDER_PATTERNS: Array<Array<Int64>> = [
        [1, 8, 4, 1], // A
        [3, 6, 4, 1], // B
        [3, 4, 6, 1], // C
        [3, 2, 8, 1], // D
        [2, 6, 5, 1], // E
        [2, 2, 9, 1] // F
    ]

    private static var WEIGHTS: Array<Array<Int64>> = [
        [1, 3, 9, 27, 81, 32, 96, 77],
        [20, 60, 180, 118, 143, 7, 21, 63],
        [189, 145, 13, 39, 117, 140, 209, 205],
        [193, 157, 49, 147, 19, 57, 171, 91],
        [62, 186, 136, 197, 169, 85, 44, 132],
        [185, 133, 188, 142, 4, 12, 36, 108],
        [113, 128, 173, 97, 80, 29, 87, 50],
        [150, 28, 84, 41, 123, 158, 52, 156],
        [46, 138, 203, 187, 139, 206, 196, 166],
        [76, 17, 51, 153, 37, 111, 122, 155],
        [43, 129, 176, 106, 107, 110, 119, 146],
        [16, 48, 144, 10, 30, 90, 59, 177],
        [109, 116, 137, 200, 178, 112, 125, 164],
        [70, 210, 208, 202, 184, 130, 179, 115],
        [134, 191, 151, 31, 93, 68, 204, 190],
        [148, 22, 66, 198, 172, 94, 71, 2],
        [6, 18, 54, 162, 64, 192, 154, 40],
        [120, 149, 25, 75, 14, 42, 126, 167],
        [79, 26, 78, 23, 69, 207, 199, 175],
        [103, 98, 83, 38, 114, 131, 182, 124],
        [161, 61, 183, 127, 170, 88, 53, 159],
        [55, 165, 73, 8, 24, 72, 5, 15],
        [45, 135, 194, 160, 58, 174, 100, 89]
    ]

    private static let FINDER_PAT_A: Int64 = 0;
    private static let FINDER_PAT_B: Int64 = 1;
    private static let FINDER_PAT_C: Int64 = 2;
    private static let FINDER_PAT_D: Int64 = 3;
    private static let FINDER_PAT_E: Int64 = 4;
    private static let FINDER_PAT_F: Int64 = 5;

    private static var FINDER_PATTERN_SEQUENCES: Array<Array<Int64>> = [
        [FINDER_PAT_A, FINDER_PAT_A],
        [FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B],
        [FINDER_PAT_A, FINDER_PAT_C, FINDER_PAT_B, FINDER_PAT_D],
        [FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_C],
        [FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_D, FINDER_PAT_F],
        [FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_F, FINDER_PAT_F],
        [FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_D],
        [
            FINDER_PAT_A,
            FINDER_PAT_A,
            FINDER_PAT_B,
            FINDER_PAT_B,
            FINDER_PAT_C,
            FINDER_PAT_C,
            FINDER_PAT_D,
            FINDER_PAT_E,
            FINDER_PAT_E
        ],
        [
            FINDER_PAT_A,
            FINDER_PAT_A,
            FINDER_PAT_B,
            FINDER_PAT_B,
            FINDER_PAT_C,
            FINDER_PAT_C,
            FINDER_PAT_D,
            FINDER_PAT_E,
            FINDER_PAT_F,
            FINDER_PAT_F
        ],
        [
            FINDER_PAT_A,
            FINDER_PAT_A,
            FINDER_PAT_B,
            FINDER_PAT_B,
            FINDER_PAT_C,
            FINDER_PAT_D,
            FINDER_PAT_D,
            FINDER_PAT_E,
            FINDER_PAT_E,
            FINDER_PAT_F,
            FINDER_PAT_F
        ]
    ]

    private static let MAX_PAIRS: Int64 = 11;

    private var pairs: ArrayList<ExpandedPair> = ArrayList<ExpandedPair>(MAX_PAIRS);
    private var rows: ArrayList<ExpandedRow> = ArrayList<ExpandedRow>();
    private var startEnd: Array<Int64> = Array<Int64>(2, item: 0)
    private var startFromEven: Bool = false;

    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        // Rows can start with even pattern in case in prev rows there where odd number of patters.
        // So lets try twice
        this.pairs.clear();
        this.startFromEven = false
        try {
            return constructResult(decodeRow2pairs(rowNumber, row));
        } catch (e: NotFoundException) {
            // OK
        }
        this.pairs.clear();
        this.startFromEven = true
        return constructResult(decodeRow2pairs(rowNumber, row));
    }

    public func reset() {
        this.pairs.clear();
        this.rows.clear();
    }

    // Not private for testing
    public func decodeRow2pairs(rowNumber: Int64, row: BitArray): ArrayList<ExpandedPair> {
        var done: Bool = false;
        while (!done) {
            try {
                this.pairs.append(retrieveNextPair(row, this.pairs, rowNumber));
            } catch (nfe: Exception) {
                if (this.pairs.isEmpty()) {
                    throw nfe
                }

                // exit this loop when retrieveNextPair() fails and throws
                done = true
            }
        }

        // TODO: verify sequence of finder patterns as in checkPairSequence()
        if (checkChecksum()) {
            return this.pairs;
        }

        var tryStackedDecode: Bool = !this.rows.isEmpty()
        storeRow(rowNumber);

        // TODO: deal with reversed rows
        if (tryStackedDecode) {
            // When the image is 180-rotated, then rows are sorted in wrong direction.
            // Try twice with both the directions.
            var ps: ArrayList<ExpandedPair> = checkRows(false);
            if (!ps.isEmpty()) {
                return ps
            }
            ps = checkRows(true)
            if (!ps.isEmpty()) {
                return ps
            }
        }

        throw NotFoundException.getNotFoundInstance();
    }

    private func checkRows(reverse: Bool): ArrayList<ExpandedPair> {

        // Limit number of rows we are checking
        // We use recursive algorithm with pure complexity and don't want it to take forever
        // Stacked barcode can have up to 11 rows, so 25 seems reasonable enough
        if (this.rows.size > 25) {
            this.rows.clear();

            // We will never have a chance to get result, so clear it
            return ArrayList<ExpandedPair>();
        }

        this.pairs.clear();
        if (reverse) {
            this.rows.reverse();
        }

        var ps: ArrayList<ExpandedPair> = ArrayList<ExpandedPair>();
        try {
            ps = checkRows(ArrayList<ExpandedRow>(), 0)
        } catch (e: NotFoundException) {
            // OK
        }
        if (reverse) {
            this.rows.reverse();
        }

        return ps
    }

    // Try to construct a valid rows sequence
    // Recursion is used to implement backtracking
    private func checkRows(collectedRows: ArrayList<ExpandedRow>, currentRow: Int64): ArrayList<ExpandedPair> {
        for (i in currentRow..rows.size) {
            var row: ExpandedRow = rows.get(i).getOrThrow();
            this.pairs.clear();

            for (j in 0..collectedRows.size) {
                this.pairs.appendAll(collectedRows[j].getPairs());
            }
            this.pairs.appendAll(row.getPairs());

            if (isValidSequence(this.pairs)) {
                if (checkChecksum()) {
                    return this.pairs;
                }

                var rs: ArrayList<ExpandedRow> = ArrayList<ExpandedRow>(collectedRows);
                rs.append(row);
                try {
                    // Recursion: try to add more rows
                    return checkRows(rs, i + 1);
                } catch (e: NotFoundException) {
                    // We failed, try the next candidate
                }
            }
        }

        throw NotFoundException.getNotFoundInstance();
    }

    // Whether the pairs form a valid find pattern sequence,
    // either complete or a prefix
    private static func isValidSequence(pairs: ArrayList<ExpandedPair>): Bool {
        for (i in 0..FINDER_PATTERN_SEQUENCES.size) {
            if (pairs.size <= FINDER_PATTERN_SEQUENCES[i].size) {
                var stop: Bool = true;
                for (j in 0..pairs.size) {
                    if (pairs.get(j).getOrThrow().getFinderPattern().getOrThrow().getValue() != FINDER_PATTERN_SEQUENCES[i][j]) {
                        stop = false
                        break
                    }
                }
                if (stop) {
                    return true;
                }
            }
        }

        return false;
    }

    private func storeRow(rowNumber: Int64) {

        // Discard if duplicate above or below; otherwise insert in order by row number.
        var insertPos: Int64 = 0;
        var prevIsSame: Bool = false;
        var nextIsSame: Bool = false;
        while (insertPos < this.rows.size) {
            var erow: ExpandedRow = this.rows.get(insertPos).getOrThrow();
            if (erow.getRowNumber() > rowNumber) {
                nextIsSame = erow.isEquivalent(this.pairs)
                break
            }
            prevIsSame = erow.isEquivalent(this.pairs)
            insertPos++
        }
        if (nextIsSame || prevIsSame) {
            return;
        }

        // When the row was partially decoded (e.g. 2 pairs found instead of 3),
        // it will prevent us from detecting the barcode.
        // Try to merge partial rows

        // Check whether the row is part of an already detected row
        if (isPartialRow(this.pairs, this.rows)) {
            return;
        }

        this.rows.insert(insertPos, ExpandedRow(this.pairs, rowNumber));

        removePartialRows(this.pairs, this.rows);
    }
    static func paircontains(pairs: ArrayList<ExpandedPair>, p: ExpandedPair): Bool {
        for (i in 0..pairs.size) {
            if (p.equals(pairs[i])) {
                return true
            }
        }
        return false
    }

    // Remove all the rows that contains only specified pairs
    private static func removePartialRows(pairs: ArrayList<ExpandedPair>, rows: ArrayList<ExpandedRow>) {
        // var iterator: ArrayListIterator<ExpandedRow> = rows.iterator();
        var i = 0
        var iteratorall = rows.iterator()
        while (let Some(iterator) <- iteratorall.next()) {
            var i_count = iterator.getPairs().size
            var par_count = pairs.size
            if (iterator.getPairs().size != pairs.size) {
                var allFound: Bool = true;
                for (p in iterator.getPairs()) {
                    if (!paircontains(pairs, p)) {
                        allFound = false
                        break
                    }
                }
                if (allFound) {
                    // 'pairs' contains all the pairs from the row 'r'
                    rows.remove(i)
                    iteratorall = rows.iterator()
                }
            }
            i++
        }
    }

    // Returns true when one of the rows already contains all the pairs
    private static func isPartialRow(pairs: Iterable<ExpandedPair>, rows: Iterable<ExpandedRow>): Bool {
        for (r in rows) {
            var allFound: Bool = true;

            for (p in pairs) {
                var found: Bool = false;
                for (j in 0..r.getPairs().size) {
                    if (p.equals(r.getPairs()[j])) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    allFound = false
                    break
                }
            }
            if (allFound) {
                // the row 'r' contain all the pairs from 'pairs'
                return true;
            }
        }
        return false;
    }

    // Only used for unit testing
    public func getRows(): ArrayList<ExpandedRow> {
        var ret = this.rows
        return ret
    }

    // Not private for unit testing
    public static func constructResult(pairs: ArrayList<ExpandedPair>): Result {
        try {
            var binary: BitArray = BitArrayBuilder.buildBitArray(pairs);

            var decoder: AbstractExpandedDecoder = AbstractExpandedDecoder.createDecoder(binary);
            var resultingString: String = decoder.parseInformation();

            var firstPoints: Array<ResultPoint> = pairs.get(0).getOrThrow().getFinderPattern().getOrThrow().
                getResultPoints();
            var lastPoints: Array<ResultPoint> = pairs.get(pairs.size - 1).getOrThrow().getFinderPattern().getOrThrow().
                getResultPoints();

            var result: Result = Result(
                resultingString,
                Array<UInt8>(),
                [firstPoints[0], firstPoints[1], lastPoints[0], lastPoints[1]],
                BarcodeFormat.RSS_EXPANDED
            );
            result.putMetadata(ResultMetadataType.SYMBOLOGY_IDENTIFIER, "]e0");
            return result
        } catch (e: Exception) {
            throw e
        }
    }

    private func checkChecksum(): Bool {
        var firstPair: ExpandedPair = this.pairs.get(0).getOrThrow();
        var checkCharacter: DataCharacter = firstPair.getLeftChar().getOrThrow();

        if (let None <- firstPair.getRightChar()) {
            return false;
        }

        var firstCharacter: DataCharacter = firstPair.getRightChar().getOrThrow();

        var checksum: Int64 = firstCharacter.getChecksumPortion();
        var s: Int64 = 2;

        for (i in 1..this.pairs.size) {
            var currentPair: ExpandedPair = this.pairs.get(i).getOrThrow();
            checksum += currentPair.getLeftChar().getOrThrow().getChecksumPortion()
            s++
            var currentRightChar: ?DataCharacter = currentPair.getRightChar();
            if (let Some(a) <- currentRightChar) {
                checksum += a.getChecksumPortion()
                s++
            }
        }

        checksum %= 211

        var checkCharacterValue: Int64 = 211 * (s - 4) + checksum

        return checkCharacterValue == checkCharacter.getValue()
    }

    private static func getNextSecondBar(row: BitArray, initialPos: Int64): Int64 {
        var currentPos: Int64
        if (row.get(initialPos)) {
            currentPos = row.getNextUnset(initialPos)
            currentPos = row.getNextSet(currentPos)
        } else {
            currentPos = row.getNextSet(initialPos)
            currentPos = row.getNextUnset(currentPos)
        }
        return currentPos
    }

    // not private for testing
    public func retrieveNextPair(row: BitArray, previousPairs: ArrayList<ExpandedPair>, rowNumber: Int64): ExpandedPair {
        var isOddPattern: Bool = previousPairs.size % 2 == 0
        if (startFromEven) {
            isOddPattern = !isOddPattern
        }

        var pattern: ?FinderPattern = None

        var keepFinding: Bool = true;
        var forcedOffset: Int64 = -1;
        do {
            this.findNextPair(row, previousPairs, forcedOffset);
            pattern = parseFoundFinderPattern(row, rowNumber, isOddPattern)
            if (let None <- pattern) {
                forcedOffset = getNextSecondBar(row, this.startEnd[0])
            } else {
                keepFinding = false
            }
        } while (keepFinding)

        // When stacked symbol is split over multiple rows, there's no way to guess if this pair can be last or not.
        // boolean mayBeLast = checkPairSequence(previousPairs, pattern);
        var leftChar: DataCharacter = this.decodeDataCharacter(row, pattern.getOrThrow(), isOddPattern, true);

        if (!previousPairs.isEmpty() && previousPairs.get(previousPairs.size - 1).getOrThrow().mustBeLast()) {
            throw NotFoundException.getNotFoundInstance();
        }

        var rightChar: ?DataCharacter = None
        try {
            rightChar = this.decodeDataCharacter(row, pattern.getOrThrow(), isOddPattern, false)
        } catch (ignored: NotFoundException) {
            // rightChar = null;
        }
        return ExpandedPair(leftChar, rightChar, pattern);
    }

    private func findNextPair(row: BitArray, previousPairs: ArrayList<ExpandedPair>, forcedOffset: Int64) {
        var counters: Array<Int64> = this.getDecodeFinderCounters();
        counters[0] = 0
        counters[1] = 0
        counters[2] = 0
        counters[3] = 0

        var width: Int64 = row.getSize();

        var rowOffset: Int64 = exfindNextPair(forcedOffset, previousPairs)
        var searchingEvenPair: Bool = previousPairs.size % 2 != 0
        if (startFromEven) {
            searchingEvenPair = !searchingEvenPair
        }

        var isWhite: Bool = false;
        (rowOffset, isWhite) = exfindNextPair2(rowOffset, isWhite, width, row)

        var counterPosition: Int64 = 0;
        var patternStart: Int64 = rowOffset

        for (x in rowOffset..width) {
            if (row.get(x) != isWhite) {
                counters[counterPosition] = counters[counterPosition] + 1
            } else {
                if (counterPosition == 3) {
                    if (searchingEvenPair) {
                        reverseCounters(counters);
                    }

                    if (isFinderPattern(counters)) {
                        this.startEnd[0] = patternStart
                        this.startEnd[1] = x
                        return;
                    }

                    if (searchingEvenPair) {
                        reverseCounters(counters);
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

    private func exfindNextPair2(rowOffset: Int64, isWhite: Bool, width: Int64, row: BitArray): (Int64, Bool) {
        var rowOffset_p = rowOffset
        var isWhite_p = isWhite
        while (rowOffset_p < width) {
            isWhite_p = !row.get(rowOffset_p)
            if (!isWhite_p) {
                break
            }
            rowOffset_p++
        }
        return (rowOffset_p, isWhite_p)
    }

    private func exfindNextPair(forcedOffset: Int64, previousPairs: ArrayList<ExpandedPair>): Int64 {
        var rowOffset: Int64
        if (forcedOffset >= 0) {
            rowOffset = forcedOffset
        } else if (previousPairs.isEmpty()) {
            rowOffset = 0
        } else {
            var lastPair: ExpandedPair = previousPairs.get(previousPairs.size - 1).getOrThrow();
            rowOffset = lastPair.getFinderPattern().getOrThrow().getStartEnd()[1]
        }
        return rowOffset
    }

    private static func reverseCounters(counters: Array<Int64>) {
        var length: Int64 = counters.size;
        for (i in 0..length / 2) {
            var tmp: Int64 = counters[i]
            counters[i] = counters[length - i - 1]
            counters[length - i - 1] = tmp
        }
    }

    private func parseFoundFinderPattern(row: BitArray, rowNumber: Int64, oddPattern: Bool): ?FinderPattern {
        // Actually we found elements 2-5.
        var firstCounter: Int64
        var start: Int64
        var end: Int64

        if (oddPattern) {
            // If pattern number is odd, we need to locate element 1 *before* the current block.
            var firstElementStart: Int64 = this.startEnd[0] - 1

            // Locate element 1
            while (firstElementStart >= 0 && !row.get(firstElementStart)) {
                firstElementStart--
            }

            firstElementStart++
            firstCounter = this.startEnd[0] - firstElementStart
            start = firstElementStart
            end = this.startEnd[1]
        } else {
            // If pattern number is even, the pattern is reversed, so we need to locate element 1 *after* the current block.
            start = this.startEnd[0]

            end = row.getNextUnset(this.startEnd[1] + 1)
            firstCounter = end - this.startEnd[1]
        }

        // Make 'counters' hold 1-4
        var counters: Array<Int64> = this.getDecodeFinderCounters();
        counters.copyTo(counters, 0, 1, counters.size - 1);

        counters[0] = firstCounter
        var value: Int64
        try {
            value = parseFinderValue(counters, FINDER_PATTERNS)
        } catch (ignored: NotFoundException) {
            return None
        }
        return FinderPattern(value, [start, end], start, end, rowNumber);
    }

    public func decodeDataCharacter(row: BitArray, pattern: FinderPattern, isOddPattern: Bool, leftChar: Bool): DataCharacter {
        var counters: Array<Int64> = Array<Int64>(this.getDataCharacterCounters().size, item: 0);

        if (leftChar) {
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
        } //counters[] has the pixels of the module

        var numModules: Int64 = 17; //left and right data characters have all the same length

        var elementWidth: Float32 = Float32(GetArraySum(counters)) / Float32(numModules)

        // Sanity check: element width for pattern and the character should match
        var expectedElementWidth: Float32 = Float32(pattern.getStartEnd()[1] - pattern.getStartEnd()[0]) / 15.0f32
        if (abs(elementWidth - expectedElementWidth) / expectedElementWidth > 0.3f32) {
            throw NotFoundException.getNotFoundInstance();
        }

        var oddCounts: Array<Int64> = this.getOddCounts();
        var evenCounts: Array<Int64> = this.getEvenCounts();
        var oddRoundingErrors: Array<Float32> = this.getOddRoundingErrors();
        var evenRoundingErrors: Array<Float32> = this.getEvenRoundingErrors();

        for (i in 0..counters.size) {
            var value: Float32 = 1.0f32 * Float32(counters[i]) / elementWidth
            var count: Int64 = Int64(value + 0.5f32)

            // Round
            if (count < 1) {
                if (value < 0.3f32) {
                    throw NotFoundException.getNotFoundInstance();
                }
                count = 1
            } else if (count > 8) {
                if (value > 8.7f32) {
                    throw NotFoundException.getNotFoundInstance();
                }
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

        adjustOddEvenCounts(numModules);

        var weightRowNumber: Int64 = 4 * pattern.getValue() + (if (isOddPattern) {
            0
        } else {
            2
        }) + (if (leftChar) {
            0
        } else {
            1
        }) - 1

        var oddSum: Int64 = 0;
        var oddChecksumPortion: Int64 = 0;
        var j: Int64 = oddCounts.size - 1
        while (j >= 0) {
            if (isNotA1left(pattern, isOddPattern, leftChar)) {
                var weight: Int64 = WEIGHTS[weightRowNumber][2 * j]
                oddChecksumPortion += oddCounts[j] * weight
            }
            oddSum += oddCounts[j]
            j--
        }
        var evenChecksumPortion: Int64 = 0;
        var i: Int64 = evenCounts.size - 1
        while (i >= 0) {
            if (isNotA1left(pattern, isOddPattern, leftChar)) {
                var weight: Int64 = WEIGHTS[weightRowNumber][2 * i + 1]
                evenChecksumPortion += evenCounts[i] * weight
            }
            i--
        }
        var checksumPortion: Int64 = oddChecksumPortion + evenChecksumPortion

        if ((oddSum & 0x01) != 0 || oddSum > 13 || oddSum < 4) {
            throw NotFoundException.getNotFoundInstance();
        }

        var group: Int64 = (13 - oddSum) / 2
        var oddWidest: Int64 = SYMBOL_WIDEST[group]
        var evenWidest: Int64 = 9 - oddWidest
        var vOdd: Int64 = RSSUtils.getRSSvalue(oddCounts, oddWidest, true);
        var vEven: Int64 = RSSUtils.getRSSvalue(evenCounts, evenWidest, false);
        var tEven: Int64 = EVEN_TOTAL_SUBSET[group]
        var gSum: Int64 = GSUM[group]
        var value: Int64 = vOdd * tEven + vEven + gSum

        return DataCharacter(value, checksumPortion);
    }

    private static func isNotA1left(pattern: FinderPattern, isOddPattern: Bool, leftChar: Bool): Bool {
        // A1: pattern.getValue is 0 (A), and it's an oddPattern, and it is a left char
        return !(pattern.getValue() == 0 && isOddPattern && leftChar)
    }

    private func GetArraySum(counts: Array<Int64>): Int64 {
        var sum: Int64 = 0;
        for (i in 0..counts.size) {
            sum += counts[i]
        }
        return sum
    }

    private func adjustOddEvenCounts(numModules: Int64) {
        var oddSum: Int64 = GetArraySum(this.getOddCounts());
        var evenSum: Int64 = GetArraySum(this.getEvenCounts());

        var incrementOdd: Bool = false;
        var decrementOdd: Bool = false;

        if (oddSum > 13) {
            decrementOdd = true
        } else if (oddSum < 4) {
            incrementOdd = true
        }
        var incrementEven: Bool = false;
        var decrementEven: Bool = false;
        if (evenSum > 13) {
            decrementEven = true
        } else if (evenSum < 4) {
            incrementEven = true
        }

        (decrementOdd, decrementEven, incrementOdd, incrementEven) = exadjustOddEvenCounts(oddSum, evenSum, numModules,
            decrementOdd, decrementEven, incrementOdd, incrementEven)

        if (incrementOdd) {
            if (decrementOdd) {
                throw NotFoundException.getNotFoundInstance();
            }
            increment(this.getOddCounts(), this.getOddRoundingErrors());
        }
        if (decrementOdd) {
            decrement(this.getOddCounts(), this.getOddRoundingErrors());
        }
        if (incrementEven) {
            if (decrementEven) {
                throw NotFoundException.getNotFoundInstance();
            }
            increment(this.getEvenCounts(), this.getOddRoundingErrors());
        }
        if (decrementEven) {
            decrement(this.getEvenCounts(), this.getEvenRoundingErrors());
        }
    }

    private func exadjustOddEvenCounts(oddSum: Int64, evenSum: Int64, numModules: Int64, decrementOdd: Bool,
        decrementEven: Bool, incrementOdd: Bool, incrementEven: Bool) {
        var (decrementOdd_p, decrementEven_p, incrementOdd_p, incrementEven_p) = (decrementOdd, decrementEven,
            incrementOdd, incrementEven)
        var mismatch: Int64 = oddSum + evenSum - numModules
        var oddParityBad: Bool = (oddSum & 0x01) == 1
        var evenParityBad: Bool = (evenSum & 0x01) == 0
        match (mismatch) {
            case 1 => if (oddParityBad) {
                if (evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                decrementOdd_p = true
            } else {
                if (!evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                decrementEven_p = true
            }
            case -1 => if (oddParityBad) {
                if (evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                incrementOdd_p = true
            } else {
                if (!evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                incrementEven_p = true
            }
            case 0 => if (oddParityBad) {
                if (!evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }

                // Both bad
                if (oddSum < evenSum) {
                    incrementOdd_p = true
                    decrementEven_p = true
                } else {
                    decrementOdd_p = true
                    incrementEven_p = true
                }
            } else {
                if (evenParityBad) {
                    throw NotFoundException.getNotFoundInstance();
                }
                // Nothing to do!
            }
            case _ => throw NotFoundException.getNotFoundInstance();
        }
        return (decrementOdd_p, decrementEven_p, incrementOdd_p, incrementEven_p)
    }
}
