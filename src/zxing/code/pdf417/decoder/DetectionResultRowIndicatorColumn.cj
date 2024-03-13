/*
 * Copyright 2013 ZXing authors
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

package zxing.code.pdf417.decoder

/**
 * @author Guenther Grau
 */
open class DetectionResultRowIndicatorColumn <: DetectionResultColumn {
    private let isLeft_: Bool

    init(boundingBox: BoundingBox, isLeft_: Bool) {
        super(boundingBox);
        this.isLeft_ = isLeft_
    }

    private func setRowNumbers() {
        var words = getCodewords()
        for (i in 0..words.size) {
            if (words[i].flag) {
                words[i].setRowNumberAsRowIndicatorColumn();
            }
        }
    }

    // TODO implement properly
    // TODO maybe we should add missing codewords to store the correct row number to make
    // finding row numbers for other columns easier
    // use row height count to make detection of invalid row numbers more reliable
    func adjustCompleteIndicatorColumnRowNumbers(barcodeMetadata: BarcodeMetadata) {
        var codewords: Array<Codeword> = getCodewords();
        setRowNumbers();
        removeIncorrectCodewords(codewords, barcodeMetadata);
        var boundingBox: BoundingBox = getBoundingBox();

        var top: ResultPoint = boundingBox.getTopRight()
        if (isLeft_) {
            top = boundingBox.getTopLeft()
        }

        var bottom: ResultPoint = boundingBox.getBottomRight()
        if (isLeft_) {
            bottom = boundingBox.getBottomLeft()
        }

        var firstRow: Int64 = imageRowToCodewordIndex(Int64(top.getY()))
        var lastRow: Int64 = imageRowToCodewordIndex(Int64(bottom.getY()))

        // We need to be careful using the average row height. Barcode could be skewed so that we have smaller and
        // taller rows
        var barcodeRow: Int64 = -1
        var maxRowHeight: Int64 = 1
        var currentRowHeight: Int64 = 0
        for (codewordsRow in firstRow..lastRow) {
            if (codewords[codewordsRow].flag) {
                var rowDifference: Int64 = codewords[codewordsRow].getRowNumber() - barcodeRow

                // TODO improve handling with case where first row indicator doesn't start with 0
                if (rowDifference == 0) {
                    currentRowHeight++
                } else if (rowDifference == 1) {
                    maxRowHeight = max(maxRowHeight, currentRowHeight)
                    currentRowHeight = 1
                    barcodeRow = codewords[codewordsRow].getRowNumber()
                } else if (rowDifference < 0 || codewords[codewordsRow].getRowNumber() >= barcodeMetadata.getRowCount() ||
                    rowDifference > codewordsRow) {
                    codewords[codewordsRow] = Codeword()
                } else {
                    var checkedRows: Int64
                    if (maxRowHeight > 2) {
                        checkedRows = (maxRowHeight - 2) * rowDifference
                    } else {
                        checkedRows = rowDifference
                    }
                    var closePreviousCodewordFound: Bool = checkedRows >= codewordsRow
                    var i = 1;
                    while (i < checkedRows && !closePreviousCodewordFound) {
                        if (codewords[codewordsRow - i].flag) {
                            closePreviousCodewordFound = true
                        } else {
                            closePreviousCodewordFound = false
                        }
                        i++
                    }
                    if (closePreviousCodewordFound) {
                        codewords[codewordsRow] = Codeword()
                    } else {
                        barcodeRow = codewords[codewordsRow].getRowNumber()
                        currentRowHeight = 1
                    }
                }
            } else {
                continue
            }
        }
    }

    func getRowHeights(): Array<Int64> {
        var barcodeMetadata: ?BarcodeMetadata = getBarcodeMetadata();
        if (let Some(b) <- barcodeMetadata) {
            adjustIncompleteIndicatorColumnRowNumbers(b);
            var result: Array<Int64> = Array<Int64>(b.getRowCount(), item: 0)
            var words = getCodewords()
            for (i in 0..words.size) {
                if (words[i].flag) {
                    var rowNumber: Int64 = words[i].getRowNumber();
                    if (rowNumber >= result.size) {
                        continue
                    }
                    result[rowNumber] = result[rowNumber] + 1
                }
            }
            return result
        } else {
            return Array<Int64>()
        }
    }

    // TODO maybe we should add missing codewords to store the correct row number to make
    // finding row numbers for other columns easier
    // use row height count to make detection of invalid row numbers more reliable
    private func adjustIncompleteIndicatorColumnRowNumbers(barcodeMetadata: BarcodeMetadata) {
        var boundingBox: BoundingBox = getBoundingBox();

        var top: ResultPoint
        if (isLeft_) {
            top = boundingBox.getTopLeft()
        } else {
            top = boundingBox.getTopRight()
        }

        var bottom: ResultPoint
        if (isLeft_) {
            bottom = boundingBox.getBottomLeft()
        } else {
            bottom = boundingBox.getBottomRight()
        }

        var firstRow: Int64 = imageRowToCodewordIndex(Int64(top.getY()))
        var lastRow: Int64 = imageRowToCodewordIndex(Int64(bottom.getY()))

        var codewords: Array<Codeword> = getCodewords();
        var barcodeRow: Int64 = -1
        var maxRowHeight: Int64 = 1
        var currentRowHeight: Int64 = 0

        for (codewordsRow in firstRow..lastRow) {
            if (codewords[codewordsRow].flag) {
                codewords[codewordsRow].setRowNumberAsRowIndicatorColumn();

                var rowDifference: Int64 = codewords[codewordsRow].getRowNumber() - barcodeRow

                // TODO improve handling with case where first row indicator doesn't start with 0
                if (rowDifference == 0) {
                    currentRowHeight++
                } else if (rowDifference == 1) {
                    maxRowHeight = max(maxRowHeight, currentRowHeight)
                    currentRowHeight = 1
                    barcodeRow = codewords[codewordsRow].getRowNumber()
                } else if (codewords[codewordsRow].getRowNumber() >= barcodeMetadata.getRowCount()) {
                    codewords[codewordsRow].flag = false
                } else {
                    barcodeRow = codewords[codewordsRow].getRowNumber()
                    currentRowHeight = 1
                }
            } else {
                continue
            }
        }
    }

    func getBarcodeMetadata(): ?BarcodeMetadata {
        var codewords: Array<Codeword> = getCodewords();
        var barcodeColumnCount: BarcodeValue = BarcodeValue();
        var barcodeRowCountUpperPart: BarcodeValue = BarcodeValue();
        var barcodeRowCountLowerPart: BarcodeValue = BarcodeValue();
        var barcodeECLevel: BarcodeValue = BarcodeValue();

        for (i in 0..codewords.size) {
            if (codewords[i].flag) {
                codewords[i].setRowNumberAsRowIndicatorColumn();

                var rowIndicatorValue: Int64 = codewords[i].getValue() % 30
                var codewordRowNumber: Int64 = codewords[i].getRowNumber();
                if (!isLeft_) {
                    codewordRowNumber += 2
                }
                match (codewordRowNumber % 3) {
                    case 0 => barcodeRowCountUpperPart.setValue(rowIndicatorValue * 3 + 1);
                    case 1 =>
                        barcodeECLevel.setValue(rowIndicatorValue / 3);
                        barcodeRowCountLowerPart.setValue(rowIndicatorValue % 3);
                    case 2 => barcodeColumnCount.setValue(rowIndicatorValue + 1);
                    case _ => continue
                }
            } else {
                continue
            }
        }

        // Maybe we should check if we have ambiguous values?
        if ((barcodeColumnCount.getValue().size == 0) || (barcodeRowCountUpperPart.getValue().size == 0) || (barcodeRowCountLowerPart.
            getValue().size == 0) || (barcodeECLevel.getValue().size == 0) || barcodeColumnCount.getValue()[0] < 1 ||
            barcodeRowCountUpperPart.getValue()[0] + barcodeRowCountLowerPart.getValue()[0] < PDF417Common.
            MIN_ROWS_IN_BARCODE || barcodeRowCountUpperPart.getValue()[0] + barcodeRowCountLowerPart.getValue()[0] >
            PDF417Common.MAX_ROWS_IN_BARCODE) {
            return None
        }
        var barcodeMetadata: BarcodeMetadata = BarcodeMetadata(
            barcodeColumnCount.getValue()[0],
            barcodeRowCountUpperPart.getValue()[0],
            barcodeRowCountLowerPart.getValue()[0],
            barcodeECLevel.getValue()[0]
        );
        removeIncorrectCodewords(codewords, barcodeMetadata);
        return barcodeMetadata
    }

    private func removeIncorrectCodewords(codewords: Array<Codeword>, barcodeMetadata: BarcodeMetadata) {
        // Remove codewords which do not match the metadata
        // TODO Maybe we should keep the incorrect codewords for the start and end positions?
        for (codewordRow in 0..codewords.size) {
            if (codewords[codewordRow].flag) {
                var rowIndicatorValue: Int64 = codewords[codewordRow].getValue() % 30
                var codewordRowNumber: Int64 = codewords[codewordRow].getRowNumber();
                if (codewordRowNumber > barcodeMetadata.getRowCount()) {
                    codewords[codewordRow].flag = false
                    continue
                }
                if (!isLeft_) {
                    codewordRowNumber += 2
                }
                match (codewordRowNumber % 3) {
                    case 0 => if (rowIndicatorValue * 3 + 1 != barcodeMetadata.getRowCountUpperPart()) {
                        codewords[codewordRow].flag = false
                    }
                    case 1 => if (rowIndicatorValue / 3 != barcodeMetadata.getErrorCorrectionLevel() ||
                        rowIndicatorValue % 3 != barcodeMetadata.getRowCountLowerPart()) {
                        codewords[codewordRow].flag = false
                    }
                    case 2 => if (rowIndicatorValue + 1 != barcodeMetadata.getColumnCount()) {
                        codewords[codewordRow].flag = false
                    }
                    case _ => continue
                }
            } else {
                continue
            }
        }
    }

    func isLeft(): Bool {
        return isLeft_
    }

    public override func toString(): String {
        return "IsLeft: " + isLeft_.toString() + "\n" + super.toString()
    }
}
