/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package pdf417.decoder

import common.Qrcoder4cjChecksumException
import pdf417.decoder.ec.ErrorCorrection
from std import time.*

/**
 * @author Guenther Grau
 */
public open class PDF417ScanningDecoder {
    private static let CODEWORD_SKEW_SIZE: Int64 = 2

    private static let MAX_ERRORS: Int64 = 3
    private static let MAX_EC_CODEWORDS: Int64 = 512
    private static let errorCorrection: ErrorCorrection = ErrorCorrection();

    private init() {}

    // TODO don't pass in minCodewordWidth and maxCodewordWidth, pass in barcode columns for start and stop pattern
    // columns. That way width can be deducted from the pattern column.
    // This approach also allows to detect more details about the barcode, e.g. if a bar type (white or black) is wider
    // than it should be. This can happen if the scanner used a bad blackpoint.
    public static func decode(
        image: BitMatrix,
        imageTopLeft: ResultPoint,
        imageBottomLeft: ResultPoint,
        imageTopRight: ResultPoint,
        imageBottomRight: ResultPoint,
        minCodewordWidth: Int64,
        maxCodewordWidth: Int64
    ): DecoderResult {
        var minCodewordWidth_ = minCodewordWidth
        var maxCodewordWidth_ = maxCodewordWidth
        var boundingBox: BoundingBox = BoundingBox(image, imageTopLeft, imageBottomLeft, imageTopRight, imageBottomRight
        );

        var leftRowIndicatorColumn: ?DetectionResultRowIndicatorColumn = None
        var rightRowIndicatorColumn: ?DetectionResultRowIndicatorColumn = None
        var detectionResult: ?DetectionResult = None
        var firstPass: Bool = true
        var flagt: Int64 = 0
        while (firstPass) {
            flagt++
            if (imageTopLeft.flag == true) {
                leftRowIndicatorColumn = getRowIndicatorColumn(
                    image,
                    boundingBox,
                    imageTopLeft,
                    true,
                    minCodewordWidth_,
                    maxCodewordWidth_
                )
            }
            if (imageTopRight.flag == true) {
                rightRowIndicatorColumn = getRowIndicatorColumn(
                    image,
                    boundingBox,
                    imageTopRight,
                    false,
                    minCodewordWidth_,
                    maxCodewordWidth_
                )
            }
            detectionResult = merge(leftRowIndicatorColumn, rightRowIndicatorColumn)

            if (let Some(d) <- detectionResult) {
                var resultBox: BoundingBox = d.getBoundingBox();
                if (resultBox.flag == true) {
                    if (flagt > 1) {
                        firstPass = false
                    }
                    if (firstPass && (resultBox.getMinY() < boundingBox.getMinY() || resultBox.getMaxY() >
                        boundingBox.getMaxY())) {
                        boundingBox = resultBox
                    } else {
                        break
                    }
                } else {
                    break
                }
                if (flagt > 1) {
                    firstPass = false
                }
            } else {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance();
            }
        }

        detectionResult.getOrThrow().setBoundingBox(boundingBox);
        var maxBarcodeColumn: Int64 = detectionResult.getOrThrow().getBarcodeColumnCount() + 1
        detectionResult.getOrThrow().setDetectionResultColumn(0, leftRowIndicatorColumn ?? DetectionResultColumn());
        detectionResult.getOrThrow().setDetectionResultColumn(
            maxBarcodeColumn,
            rightRowIndicatorColumn ?? DetectionResultColumn()
        );

        var leftToRight: Bool
        if (let Some(left) <- leftRowIndicatorColumn) {
            leftToRight = true
        } else {
            leftToRight = false
        }

        for (barcodeColumnCount in 1..=maxBarcodeColumn) {
            var barcodeColumn: Int64
            if (leftToRight) {
                barcodeColumn = barcodeColumnCount
            } else {
                barcodeColumn = maxBarcodeColumn - barcodeColumnCount
            }

            if (detectionResult.getOrThrow().getDetectionResultColumn(barcodeColumn).flag) {
                continue
            }
            var detectionResultColumn: DetectionResultColumn
            if (barcodeColumn == 0 || barcodeColumn == maxBarcodeColumn) {
                detectionResultColumn = DetectionResultRowIndicatorColumn(boundingBox, barcodeColumn == 0)
            } else {
                detectionResultColumn = DetectionResultColumn(boundingBox)
            }
            detectionResult.getOrThrow().setDetectionResultColumn(barcodeColumn, detectionResultColumn);
            var startColumn: Int64 = -1
            var previousStartColumn: Int64 = startColumn

            // TODO start at a row for which we know the start position, then detect upwards and downwards from there.
            for (imageRow in boundingBox.getMinY()..=boundingBox.getMaxY()) {
                startColumn = getStartColumn(detectionResult.getOrThrow(), barcodeColumn, imageRow, leftToRight)
                if (startColumn < 0 || startColumn > boundingBox.getMaxX()) {
                    if (previousStartColumn == -1) {
                        continue
                    }
                    startColumn = previousStartColumn
                }
                var codeword: Codeword = detectCodeword(
                    image,
                    boundingBox.getMinX(),
                    boundingBox.getMaxX(),
                    leftToRight,
                    startColumn,
                    imageRow,
                    minCodewordWidth_,
                    maxCodewordWidth_
                );
                if (codeword.flag) {
                    detectionResultColumn.setCodeword(imageRow, codeword);
                    previousStartColumn = startColumn
                    minCodewordWidth_ = min(minCodewordWidth_, codeword.getWidth())
                    maxCodewordWidth_ = max(maxCodewordWidth_, codeword.getWidth())
                }
            }
        }

        return createDecoderResult(detectionResult.getOrThrow());
    }

    static func merge(
        leftRowIndicatorColumn: ?DetectionResultRowIndicatorColumn,
        rightRowIndicatorColumn: ?DetectionResultRowIndicatorColumn
    ): ?DetectionResult {
        if (let Some(left) <- leftRowIndicatorColumn) {}
        else {
            if (let Some(right) <- rightRowIndicatorColumn) {}
            else {
                return None
            }
        }

        var barcodeMetadata: ?BarcodeMetadata = getBarcodeMetadata(leftRowIndicatorColumn, rightRowIndicatorColumn);

        if (let Some(b) <- barcodeMetadata) {
            var boundingBox: BoundingBox = BoundingBox.merge(
                adjustBoundingBox(leftRowIndicatorColumn),
                adjustBoundingBox(rightRowIndicatorColumn)
            );
            return DetectionResult(b, boundingBox);
        } else {
            return None
        }
    }

    static func adjustBoundingBox(rowIndicatorColumn: ?DetectionResultRowIndicatorColumn): BoundingBox {
        if (let Some(rowIndicator) <- rowIndicatorColumn) {
            var rowHeights: Array<Int64> = rowIndicator.getRowHeights();
            if (rowHeights.size == 0) {
                return BoundingBox()
            }
            var maxRowHeight: Int64 = getMax(rowHeights);
            var missingStartRows: Int64 = 0

            for (i in 0..rowHeights.size) {
                missingStartRows += maxRowHeight - rowHeights[i]
                if (rowHeights[i] > 0) {
                    break
                }
            }
            var codewords: Array<Codeword> = rowIndicator.getCodewords();

            var row: Int64 = 0
            var flag: Bool = getFlag(codewords, row)

            while (missingStartRows > 0 && flag == false) {
                missingStartRows--
                row++

                flag = getFlag(codewords, row)
            }
            var missingEndRows: Int64 = 0
            for (row in rowHeights.size - 1..=0 : -1) {
                missingEndRows += maxRowHeight - rowHeights[row]
                if (rowHeights[row] > 0) {
                    break
                }
            }

            row = codewords.size - 1
            flag = getFlag(codewords, row)
            while (missingEndRows > 0 && flag == false) {
                missingEndRows--
                row--
                flag = getFlag(codewords, row)
            }
            return rowIndicator.getBoundingBox().addMissingRows(
                missingStartRows,
                missingEndRows,
                rowIndicator.isLeft()
            );
        } else {
            return BoundingBox()
        }
    }

    static func getFlag(codewords: Array<Codeword>, row: Int64): Bool {
        if (codewords[row].flag) {
            return true
        } else {
            return false
        }
    }

    static func getMax(values: Array<Int64>): Int64 {
        var maxValue: Int64 = -1

        for (i in 0..values.size) {
            maxValue = max(maxValue, values[i])
        }
        return maxValue
    }

    static func getBarcodeMetadata(
        leftRowIndicatorColumn: ?DetectionResultRowIndicatorColumn,
        rightRowIndicatorColumn: ?DetectionResultRowIndicatorColumn
    ): ?BarcodeMetadata {
        var leftBarcodeMetadata: ?BarcodeMetadata = None
        var rightBarcodeMetadata: ?BarcodeMetadata = None
        var leftBarFlag = false;
        var rightBarFlag = false;
        var leftMetadataFlag = false;
        var rightMetadataFlag = false;
        if (let Some(left) <- leftRowIndicatorColumn) {
            leftBarFlag = true
            leftBarcodeMetadata = left.getBarcodeMetadata()

            if (let Some(leftMetadata) <- leftBarcodeMetadata) {
                leftMetadataFlag = true
            }
        }

        if (let Some(right) <- rightRowIndicatorColumn) {
            rightBarFlag = true
            rightBarcodeMetadata = right.getBarcodeMetadata()
            if (let Some(rightMetadata) <- rightBarcodeMetadata) {
                rightMetadataFlag = true
            }
        }

        if (leftBarFlag == false || leftMetadataFlag == false) {
            if (rightBarFlag) {
                return rightRowIndicatorColumn.getOrThrow().getBarcodeMetadata()
            } else {
                return None
            }
        }

        if (rightBarFlag == false || rightMetadataFlag == false) {
            return leftBarcodeMetadata
        }

        if (leftBarcodeMetadata.getOrThrow().getColumnCount() != rightBarcodeMetadata.getOrThrow().getColumnCount() &&
            leftBarcodeMetadata.getOrThrow().getErrorCorrectionLevel() !=
            rightBarcodeMetadata.getOrThrow().getErrorCorrectionLevel() &&
            leftBarcodeMetadata.getOrThrow().getRowCount() != rightBarcodeMetadata.getOrThrow().getRowCount()) {
            return None
        }
        return leftBarcodeMetadata
    }

    static func getRowIndicatorColumn(
        image: BitMatrix,
        boundingBox: BoundingBox,
        startPoint: ResultPoint,
        leftToRight: Bool,
        minCodewordWidth: Int64,
        maxCodewordWidth: Int64
    ): DetectionResultRowIndicatorColumn {
        var rowIndicatorColumn: DetectionResultRowIndicatorColumn = DetectionResultRowIndicatorColumn(
            boundingBox,
            leftToRight
        );

        for (i in 0..2) {
            var increment: Int64 = 0
            if (i == 0) {
                increment = 1
            } else {
                increment = -1
            }
            var startColumn: Int64 = Int64(startPoint.getX())
            var imageRow: Int64 = Int64(startPoint.getY())
            while (imageRow <= boundingBox.getMaxY() && imageRow >= boundingBox.getMinY()) {
                var codeword: Codeword = detectCodeword(
                    image,
                    0,
                    image.getWidth(),
                    leftToRight,
                    startColumn,
                    imageRow,
                    minCodewordWidth,
                    maxCodewordWidth
                );
                if (codeword.flag) {
                    rowIndicatorColumn.setCodeword(imageRow, codeword);
                    if (leftToRight) {
                        startColumn = codeword.getStartX()
                    } else {
                        startColumn = codeword.getEndX()
                    }
                }
                imageRow += increment
            }
        }
        return rowIndicatorColumn
    }

    static func adjustCodewordCount(detectionResult: DetectionResult, barcodeMatrix: Array<Array<BarcodeValue>>) {
        var barcodeMatrix01: BarcodeValue = barcodeMatrix[0][1]
        var numberOfCodewords: Array<Int64> = barcodeMatrix01.getValue();
        var calculatedNumberOfCodewords: Int64 = detectionResult.getBarcodeColumnCount() *
            detectionResult.getBarcodeRowCount() - getNumberOfECCodeWords(detectionResult.getBarcodeECLevel())
        if (numberOfCodewords.size == 0) {
            if (calculatedNumberOfCodewords < 1 || calculatedNumberOfCodewords > PDF417Common.MAX_CODEWORDS_IN_BARCODE) {
                throw Qrcoder4cjNotFoundException.getNotFoundInstance();
            }
            barcodeMatrix01.setValue(calculatedNumberOfCodewords);
        } else if (numberOfCodewords[0] != calculatedNumberOfCodewords && calculatedNumberOfCodewords >= 1 &&
            calculatedNumberOfCodewords <= PDF417Common.MAX_CODEWORDS_IN_BARCODE) {
            // The calculated one is more reliable as it is derived from the row indicator columns
            barcodeMatrix01.setValue(calculatedNumberOfCodewords);
        }
    }

    static func createDecoderResult(detectionResult: DetectionResult): DecoderResult {
        var barcodeMatrix: Array<Array<BarcodeValue>> = createBarcodeMatrix(detectionResult);
        adjustCodewordCount(detectionResult, barcodeMatrix);
        var erasures: ArrayList<Int64> = ArrayList<Int64>()
        var codewords: Array<Int64> = Array<Int64>(
            detectionResult.getBarcodeRowCount() * detectionResult.getBarcodeColumnCount(), item: 0)
        var ambiguousIndexValuesList: ArrayList<Array<Int64>> = ArrayList<Array<Int64>>()
        var ambiguousIndexesList: ArrayList<Int64> = ArrayList<Int64>()
        for (row in 0..detectionResult.getBarcodeRowCount()) {
            for (column in 0..detectionResult.getBarcodeColumnCount()) {
                var values: Array<Int64> = barcodeMatrix[row][column + 1].getValue();
                var codewordIndex: Int64 = row * detectionResult.getBarcodeColumnCount() + column
                if (values.size == 0) {
                    erasures.append(codewordIndex);
                } else if (values.size == 1) {
                    codewords[codewordIndex] = values[0]
                } else {
                    ambiguousIndexesList.append(codewordIndex);
                    ambiguousIndexValuesList.append(values);
                }
            }
        }
        var ambiguousIndexValues: Array<Array<Int64>> = Array<Array<Int64>>(
            ambiguousIndexValuesList.size,
            {int: Int64 => Array<Int64>()}
        )

        for (i in 0..ambiguousIndexValues.size) {
            ambiguousIndexValues[i] = ambiguousIndexValuesList[i]
        }
        return createDecoderResultFromAmbiguousValues(
            detectionResult.getBarcodeECLevel(),
            codewords,
            erasures.toArray(),
            ambiguousIndexesList.toArray(),
            ambiguousIndexValues
        );
    }

    /**
     * This method deals with the fact, that the decoding process doesn't always yield a single most likely value. The
     * current error correction implementation doesn't deal with erasures very well, so it's better to provide a value
     * for these ambiguous codewords instead of treating it as an erasure. The problem is that we don't know which of
     * the ambiguous values to choose. We try decode using the first value, and if that fails, we use another of the
     * ambiguous values and try to decode again. This usually only happens on very hard to read and decode barcodes,
     * so decoding the normal barcodes is not affected by this.
     *
     * @param erasureArray contains the indexes of erasures
     * @param ambiguousIndexes array with the indexes that have more than one most likely value
     * @param ambiguousIndexValues two dimensional array that contains the ambiguous values. The first dimension must
     * be the same length as the ambiguousIndexes array
     */
    static func createDecoderResultFromAmbiguousValues(
        ecLevel: Int64,
        codewords: Array<Int64>,
        erasureArray: Array<Int64>,
        ambiguousIndexes: Array<Int64>,
        ambiguousIndexValues: Array<Array<Int64>>
    ): DecoderResult {
        var ambiguousIndexCount: Array<Int64> = Array<Int64>(ambiguousIndexes.size, item: 0)

        var tries: Int64 = 100
        tries--
        while (tries > 0) {
            for (i in 0..ambiguousIndexCount.size) {
                codewords[ambiguousIndexes[i]] = ambiguousIndexValues[i][ambiguousIndexCount[i]]
            }
            try {
                return decodeCodewords(codewords, ecLevel, erasureArray);
            } catch (ignored: Qrcoder4cjChecksumException) {
                //
            }
            if (ambiguousIndexCount.size == 0) {
                throw Qrcoder4cjChecksumException.getChecksumInstance();
            }

            for (i in 0..ambiguousIndexCount.size) {
                if (ambiguousIndexCount[i] < ambiguousIndexValues[i].size - 1) {
                    ambiguousIndexCount[i] = ambiguousIndexCount[i] + 1
                    break
                } else {
                    ambiguousIndexCount[i] = 0
                    if (i == ambiguousIndexCount.size - 1) {
                        throw Qrcoder4cjChecksumException.getChecksumInstance();
                    }
                }
            }
            tries--
        }
        throw Qrcoder4cjChecksumException.getChecksumInstance();
    }

    static func createBarcodeMatrix(detectionResult: DetectionResult): Array<Array<BarcodeValue>> {
        var barcodeMatrix: Array<Array<BarcodeValue>> = Array<Array<BarcodeValue>>(
            detectionResult.getBarcodeRowCount(),
            {
                int: Int64 => Array<BarcodeValue>(
                    detectionResult.getBarcodeColumnCount() + 2,
                    item: BarcodeValue()
                )
            }
        )

        for (row in 0..barcodeMatrix.size) {
            for (column in 0..barcodeMatrix[row].size) {
                barcodeMatrix[row][column] = BarcodeValue()
            }
        }

        var column: Int64 = 0
        var Columns = detectionResult.getDetectionResultColumns()
        for (i in 0..Columns.size) {
            if (Columns[i].flag) {
                var words = Columns[i].getCodewords()
                for (j in 0..words.size) {
                    if (words[j].flag) {
                        var rowNumber: Int64 = words[j].getRowNumber();
                        if (rowNumber >= 0) {
                            if (rowNumber >= barcodeMatrix.size) {
                                continue
                            }
                            barcodeMatrix[rowNumber][column].setValue(words[j].getValue());
                        }
                    }
                }
            }
            column++
        }
        return barcodeMatrix
    }

    static func isValidBarcodeColumn(detectionResult: DetectionResult, barcodeColumn: Int64): Bool {
        return barcodeColumn >= 0 && barcodeColumn <= detectionResult.getBarcodeColumnCount() + 1
    }

    static func getStartColumn(detectionResult: DetectionResult, barcodeColumn: Int64, imageRow: Int64,
        leftToRight: Bool): Int64 {
        var barcodeColumn_ = barcodeColumn
        var offset: Int64
        if (leftToRight) {
            offset = 1
        } else {
            offset = -1
        }

        var codeword: Codeword = Codeword()
        if (isValidBarcodeColumn(detectionResult, barcodeColumn_ - offset)) {
            codeword = detectionResult.getDetectionResultColumn(barcodeColumn_ - offset).getCodeword(imageRow)
        }
        if (codeword.flag) {
            return getStartColumn(leftToRight, codeword)
        }
        codeword = detectionResult.getDetectionResultColumn(barcodeColumn_).getCodewordNearby(imageRow)
        if (codeword.flag) {
            if (leftToRight) {
                return codeword.getStartX()
            } else {
                return codeword.getEndX()
            }
        }
        if (isValidBarcodeColumn(detectionResult, barcodeColumn_ - offset)) {
            codeword = detectionResult.getDetectionResultColumn(barcodeColumn_ - offset).getCodewordNearby(imageRow)
        }
        if (codeword.flag) {
            return getStartColumn(leftToRight, codeword)
        }
        var skippedColumns: Int64 = 0

        while (isValidBarcodeColumn(detectionResult, barcodeColumn_ - offset)) {
            barcodeColumn_ -= offset
            for (previousRowCodeword in detectionResult.getDetectionResultColumn(barcodeColumn_).getCodewords()) {
                if (previousRowCodeword.flag) {
                    if (leftToRight) {
                        return previousRowCodeword.getEndX() + offset * skippedColumns * (previousRowCodeword.getEndX() -
                            previousRowCodeword.getStartX())
                    } else {
                        return previousRowCodeword.getStartX() + offset * skippedColumns * (previousRowCodeword.getEndX(
                        ) - previousRowCodeword.getStartX())
                    }
                }
            }
            skippedColumns++
        }
        if (leftToRight) {
            return detectionResult.getBoundingBox().getMinX()
        } else {
            return detectionResult.getBoundingBox().getMaxX()
        }
    }

    private static func getStartColumn(leftToRight: Bool, codeword: Codeword) {
        if (leftToRight) {
            return codeword.getEndX()
        } else {
            return codeword.getStartX()
        }
    }

    static func detectCodeword(
        image: BitMatrix,
        minColumn: Int64,
        maxColumn: Int64,
        leftToRight: Bool,
        startColumn: Int64,
        imageRow: Int64,
        minCodewordWidth: Int64,
        maxCodewordWidth: Int64
    ): Codeword {
        var startColumn_ = startColumn
        startColumn_ = adjustCodewordStartColumn(image, minColumn, maxColumn, leftToRight, startColumn_, imageRow)

        // we usually know fairly exact now how long a codeword is. We should provide minimum and maximum expected length
        // and try to adjust the read pixels, e.g. remove single pixel errors or try to cut off exceeding pixels.
        // min and maxCodewordWidth should not be used as they are calculated for the whole barcode an can be inaccurate
        // for the current position
        var moduleBitCount: Array<Int64> = getModuleBitCount(
            image,
            minColumn,
            maxColumn,
            leftToRight,
            startColumn_,
            imageRow
        );

        if (moduleBitCount.size == 0) {
            return Codeword()
        }
        var endColumn: Int64
        var codewordBitCount: Int64 = MathUtils.sum(moduleBitCount);
        if (leftToRight) {
            endColumn = startColumn_ + codewordBitCount
        } else {
            for (i in 0..moduleBitCount.size / 2) {
                var tmpCount: Int64 = moduleBitCount[i]
                moduleBitCount[i] = moduleBitCount[moduleBitCount.size - 1 - i]
                moduleBitCount[moduleBitCount.size - 1 - i] = tmpCount
            }
            endColumn = startColumn_
            startColumn_ = endColumn - codewordBitCount
        }

        // We could also use the width of surrounding codewords for more accurate results, but this seems
        // sufficient for now
        if (!checkCodewordSkew(codewordBitCount, minCodewordWidth, maxCodewordWidth)) {
            // We could try to use the startX and endX position of the codeword in the same column in the previous row,
            // create the bit count from it and normalize it to 8. This would help with single pixel errors.
            return Codeword()
        }

        var decodedValue: Int64 = PDF417CodewordDecoder.getDecodedValue(moduleBitCount);
        var codeword: Int64 = PDF417Common.getCodeword(decodedValue);
        if (codeword == -1) {
            return Codeword()
        }

        return Codeword(startColumn_, endColumn, getCodewordBucketNumber(decodedValue), codeword);
    }

    static func getModuleBitCount(
        image: BitMatrix,
        minColumn: Int64,
        maxColumn: Int64,
        leftToRight: Bool,
        startColumn: Int64,
        imageRow: Int64
    ): Array<Int64> {
        var imageColumn: Int64 = startColumn
        var moduleBitCount: Array<Int64> = Array<Int64>(8, item: 0)
        var size = moduleBitCount.size
        var moduleNumber: Int64 = 0

        var increment: Int64
        if (leftToRight) {
            increment = 1
        } else {
            increment = -1
        }

        var previousPixelValue: Bool = leftToRight
        var whileflag: Bool = false
        if (leftToRight) {
            whileflag = imageColumn < maxColumn
        } else {
            whileflag = imageColumn >= minColumn
        }

        var number = 0;
        while (whileflag && moduleNumber < size) {
            if (image.get(imageColumn, imageRow) == previousPixelValue) {
                number++
                imageColumn += increment
            } else {
                moduleBitCount[moduleNumber] = number
                number = 0
                moduleNumber++
                previousPixelValue = !previousPixelValue
            }

            if (leftToRight) {
                whileflag = imageColumn < maxColumn
            } else {
                whileflag = imageColumn >= minColumn
            }
        }
        var columnif: Int64 = 0
        if (leftToRight) {
            columnif = maxColumn
        } else {
            columnif = minColumn
        }
        if (moduleNumber == moduleBitCount.size || (imageColumn == columnif && moduleNumber == moduleBitCount.size - 1)) {
            return moduleBitCount
        }
        return Array<Int64>()
    }

    static func getNumberOfECCodeWords(barcodeECLevel: Int64): Int64 {
        return 2 << barcodeECLevel
    }

    static func adjustCodewordStartColumn(
        image: BitMatrix,
        minColumn: Int64,
        maxColumn: Int64,
        leftToRight: Bool,
        codewordStartColumn: Int64,
        imageRow: Int64
    ): Int64 {
        var correctedStartColumn: Int64 = codewordStartColumn
        var leftToRight_ = leftToRight

        var increment: Int64
        if (leftToRight_) {
            increment = -1
        } else {
            increment = 1
        }

        // there should be no black pixels before the start column. If there are, then we need to start earlier.
        for (i in 0..2) {
            var whileflag: Bool = false
            if (leftToRight_) {
                whileflag = correctedStartColumn >= minColumn
            } else {
                whileflag = correctedStartColumn < maxColumn
            }
            while (whileflag && leftToRight_ == image.get(correctedStartColumn, imageRow)) {
                if (abs(codewordStartColumn - correctedStartColumn) > CODEWORD_SKEW_SIZE) {
                    return codewordStartColumn
                }
                correctedStartColumn += increment
            }
            increment = -increment
            leftToRight_ = !leftToRight_
        }
        return correctedStartColumn
    }

    static func checkCodewordSkew(codewordSize: Int64, minCodewordWidth: Int64, maxCodewordWidth: Int64): Bool {
        return minCodewordWidth - CODEWORD_SKEW_SIZE <= codewordSize && codewordSize <= maxCodewordWidth +
            CODEWORD_SKEW_SIZE
    }

    static func decodeCodewords(codewords: Array<Int64>, ecLevel: Int64, erasures: Array<Int64>): DecoderResult {
        if (codewords.size == 0) {
            throw Qrcoder4cjFormatException.getFormatInstance();
        }

        var numECCodewords: Int64 = 1 << (ecLevel + 1)
        var correctedErrorsCount: Int64 = correctErrors(codewords, erasures, numECCodewords);
        verifyCodewordCount(codewords, numECCodewords);

        // Decode the codewords
        var decoderResult: DecoderResult = DecodedBitStreamParser.decode(codewords, ecLevel.toString());
        decoderResult.setErrorsCorrected(correctedErrorsCount);
        decoderResult.setErasures(erasures.size);
        return decoderResult
    }

    /**
     * <p>Given data and error-correction codewords received, possibly corrupted by errors, attempts to
     * correct the errors in-place.</p>
     *
     * @param codewords   data and error correction codewords
     * @param erasures positions of any known erasures
     * @param numECCodewords number of error correction codewords that are available in codewords
     * @throws Qrcoder4cjChecksumException if error correction fails
     */
    static func correctErrors(codewords: Array<Int64>, erasures: Array<Int64>, numECCodewords: Int64): Int64 {
        if (erasures.size > numECCodewords / 2 + MAX_ERRORS || numECCodewords < 0 || numECCodewords > MAX_EC_CODEWORDS) {
            // Too many errors or EC Codewords is corrupted
            throw Qrcoder4cjChecksumException.getChecksumInstance();
        }
        return errorCorrection.decode(codewords, numECCodewords, erasures);
    }

    /**
     * Verify that all is OK with the codeword array.
     */
    static func verifyCodewordCount(codewords: Array<Int64>, numECCodewords: Int64) {
        if (codewords.size < 4) {
            // Codeword array size should be at least 4 allowing for
            // Count CW, At least one Data CW, Error Correction CW, Error Correction CW
            throw Qrcoder4cjFormatException.getFormatInstance();
        }

        // The first codeword, the Symbol Length Descriptor, shall always encode the total number of data
        // codewords in the symbol, including the Symbol Length Descriptor itself, data codewords and pad
        // codewords, but excluding the number of error correction codewords.
        var numberOfCodewords: Int64 = codewords[0]
        if (numberOfCodewords > codewords.size) {
            throw Qrcoder4cjFormatException.getFormatInstance();
        }
        if (numberOfCodewords == 0) {
            // Reset to the length of the array - 8 (Allow for at least level 3 Error Correction (8 Error Codewords)
            if (numECCodewords < codewords.size) {
                codewords[0] = codewords.size - numECCodewords
            } else {
                throw Qrcoder4cjFormatException.getFormatInstance();
            }
        }
    }

    static func getBitCountForCodeword(codeword: Int64): Array<Int64> {
        var codeword_ = codeword
        var result: Array<Int64> = Array<Int64>(8, item: 0)
        var previousValue: Int64 = 0
        var i: Int64 = result.size - 1
        var number = 0;
        while (true) {
            if ((codeword_ & 0x1) != previousValue) {
                previousValue = codeword_ & 0x1
                result[i] = number
                number = 0
                i--
                if (i < 0) {
                    break
                }
            }
            number++
            codeword_ >>= 1
        }
        return result
    }

    static func getCodewordBucketNumber(codeword: Int64): Int64 {
        return getCodewordBucketNumber(getBitCountForCodeword(codeword));
    }

    static func getCodewordBucketNumber(moduleBitCount: Array<Int64>): Int64 {
        return (moduleBitCount[0] - moduleBitCount[2] + moduleBitCount[4] - moduleBitCount[6] + 9) % 9
    }

    func toString(barcodeMatrix: Array<Array<BarcodeValue>>): String {
        var result = String();
        for (row in 0..barcodeMatrix.size) {
            result += "Row "
            result += row.format("2")
            result += ": "
            let barcodeMatrix_row = barcodeMatrix[row]
            for (column in 0..barcodeMatrix_row.size) {
                var barcodeValue: BarcodeValue = barcodeMatrix_row[column]
                if (barcodeValue.getValue().size == 0) {
                    result += "        "
                } else {
                    result += barcodeValue.getValue()[0].format("4")
                    result += "("
                    result += barcodeValue.getConfidence(barcodeValue.getValue()[0]).format("2")
                    result += ")"
                }
            }
            result += "\n"
        }
        return result
    }
}
