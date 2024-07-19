/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417.decoder

import QRCode4cj.pdf417.common.*
import std.format.*

open class DetectionResult <: ToString {
    private static let ADJUST_ROW_NUMBER_SKIP: Int64 = 2

    private let barcodeMetadata: BarcodeMetadata
    private let detectionResultColumns: Array<DetectionResultColumn>
    private var boundingBox: BoundingBox
    private let barcodeColumnCount: Int64

    init(barcodeMetadata: BarcodeMetadata, boundingBox: BoundingBox) {
        this.barcodeMetadata = barcodeMetadata
        this.barcodeColumnCount = barcodeMetadata.getColumnCount()
        this.boundingBox = boundingBox
        this.detectionResultColumns = Array<DetectionResultColumn>(barcodeColumnCount + 2, item: DetectionResultColumn()
        )
    }

    func getDetectionResultColumns(): Array<DetectionResultColumn> {
        adjustIndicatorColumnRowNumbers(detectionResultColumns[0]);
        adjustIndicatorColumnRowNumbers(detectionResultColumns[barcodeColumnCount + 1]);
        var unadjustedCodewordCount: Int64 = PDF417Common.MAX_CODEWORDS_IN_BARCODE;
        var previousUnadjustedCount: Int64
        do {
            previousUnadjustedCount = unadjustedCodewordCount
            unadjustedCodewordCount = adjustRowNumbers()
        } while (unadjustedCodewordCount > 0 && unadjustedCodewordCount < previousUnadjustedCount)
        return detectionResultColumns
    }

    private func adjustIndicatorColumnRowNumbers(detectionResultColumn: DetectionResultColumn) {
        if (detectionResultColumn.flag) {
            (detectionResultColumn as DetectionResultRowIndicatorColumn).getOrThrow().
                adjustCompleteIndicatorColumnRowNumbers(barcodeMetadata);
        }
    }

    // TODO ensure that no detected codewords with unknown row number are left
    // we should be able to estimate the row height and use it as a hint for the row number
    // we should also fill the rows top to bottom and bottom to top
    /**
     * @return number of codewords which don't have a valid row number. Note that the count is not accurate as codewords will
     * be counted several times. It just serves as an indicator to see when we can stop adjusting row numbers
     */
    private func adjustRowNumbers(): Int64 {
        var unadjustedCount: Int64 = adjustRowNumbersByRow();
        if (unadjustedCount == 0) {
            return 0
        }
        for (barcodeColumn in 1..barcodeColumnCount + 1) {
            var codewords: Array<Codeword> = detectionResultColumns[barcodeColumn].getCodewords()
            for (codewordsRow in 0..codewords.size) {
                if (codewords[codewordsRow].flag) {
                    if (!codewords[codewordsRow].hasValidRowNumber()) {
                        adjustRowNumbers(barcodeColumn, codewordsRow, codewords);
                    }
                }
            }
        }
        return unadjustedCount
    }

    private func adjustRowNumbersByRow(): Int64 {
        adjustRowNumbersFromBothRI();

        // TODO we should only do full row adjustments if row numbers of left and right row indicator column match.
        // Maybe it's even better to calculated the height (in codeword rows) and divide it by the number of barcode rows.
        // This, together with the LRI and RRI row numbers should allow us to get a good estimate where a row
        // number starts and ends.
        var unadjustedCount: Int64 = adjustRowNumbersFromLRI();
        return unadjustedCount + adjustRowNumbersFromRRI()
    }

    private func adjustRowNumbersFromBothRI() {
        if (detectionResultColumns[0].flag) {}
        else {
            return;
        }
        if (detectionResultColumns[barcodeColumnCount + 1].flag) {}
        else {
            return;
        }
        var LRIcodewords: Array<Codeword> = detectionResultColumns[0].getCodewords();
        var RRIcodewords: Array<Codeword> = detectionResultColumns[barcodeColumnCount + 1].getCodewords();
        for (codewordsRow in 0..LRIcodewords.size) {
            var LRIRow = LRIcodewords[codewordsRow]
            var RRIRow = RRIcodewords[codewordsRow]
            if (LRIRow.flag && RRIRow.flag) {
            } else {
                continue
            }

            if (LRIRow.getRowNumber() == RRIRow.getRowNumber()) {
                for (barcodeColumn in 1..barcodeColumnCount) {
                    var codeword: Codeword = detectionResultColumns[barcodeColumn].getCodewords()[codewordsRow]
                    if (codeword.flag) {
                        codeword.setRowNumber(LRIRow.getRowNumber());
                        if (!codeword.hasValidRowNumber()) {
                            detectionResultColumns[barcodeColumn].getCodewords()[codewordsRow].flag = false
                        }
                    } else {
                        continue
                    }
                }
            }
        }
    }

    private func adjustRowNumbersFromRRI(): Int64 {
        if (detectionResultColumns[barcodeColumnCount + 1].flag) {
            var unadjustedCount: Int64 = 0
            var codewords: Array<Codeword> = detectionResultColumns[barcodeColumnCount + 1].getCodewords();
            for (codewordsRow in 0..codewords.size) {
                if (codewords[codewordsRow].flag) {
                    var rowIndicatorRowNumber: Int64 = codewords[codewordsRow].getRowNumber();
                    var invalidRowCounts: Int64 = 0
                    for (barcodeColumn in (barcodeColumnCount + 1)..0 : -1 where invalidRowCounts <
                        ADJUST_ROW_NUMBER_SKIP) {
                        var codeword: Codeword = detectionResultColumns[barcodeColumn].getCodewords()[codewordsRow]
                        if (codeword.flag) {
                            invalidRowCounts = adjustRowNumberIfValid(rowIndicatorRowNumber, invalidRowCounts, codeword)
                            if (!codeword.hasValidRowNumber()) {
                                unadjustedCount++
                            }
                        }
                    }
                } else {
                    continue
                }
            }
            return unadjustedCount
        } else {
            return 0
        }
    }

    private func adjustRowNumbersFromLRI(): Int64 {
        if (detectionResultColumns[0].flag) {
            var unadjustedCount: Int64 = 0
            var codewords: Array<Codeword> = detectionResultColumns[0].getCodewords();
            for (codewordsRow in 0..codewords.size) {
                if (codewords[codewordsRow].flag) {
                    var rowIndicatorRowNumber: Int64 = codewords[codewordsRow].getRowNumber();
                    var invalidRowCounts: Int64 = 0
                    for (barcodeColumn in 1..barcodeColumnCount + 1 where invalidRowCounts < ADJUST_ROW_NUMBER_SKIP) {
                        var codeword: Codeword = detectionResultColumns[barcodeColumn].getCodewords()[codewordsRow]
                        if (codeword.flag) {
                            invalidRowCounts = adjustRowNumberIfValid(rowIndicatorRowNumber, invalidRowCounts, codeword)
                            if (!codeword.hasValidRowNumber()) {
                                unadjustedCount++
                            }
                        }
                    }
                } else {
                    continue
                }
            }
            return unadjustedCount
        } else {
            return 0;
        }
    }

    private static func adjustRowNumberIfValid(
        rowIndicatorRowNumber: Int64,
        invalidRowCounts: Int64,
        codeword: Codeword
    ): Int64 {
        var invalidRowCounts_ = invalidRowCounts
        if (codeword.flag) {
            if (!codeword.hasValidRowNumber()) {
                if (codeword.isValidRowNumber(rowIndicatorRowNumber)) {
                    codeword.setRowNumber(rowIndicatorRowNumber);
                    invalidRowCounts_ = 0
                } else {
                    invalidRowCounts_ = invalidRowCounts_ + 1
                }
            }
            return invalidRowCounts_
        } else {
            return invalidRowCounts_
        }
    }

    private func adjustRowNumbers(barcodeColumn: Int64, codewordsRow: Int64, codewords: Array<Codeword>) {
        var codeword: Codeword = codewords[codewordsRow]
        var previousColumnCodewords: Array<Codeword> = detectionResultColumns[barcodeColumn - 1].getCodewords();
        var nextColumnCodewords: Array<Codeword> = previousColumnCodewords
        if (detectionResultColumns[barcodeColumn + 1].flag) {
            nextColumnCodewords = detectionResultColumns[barcodeColumn + 1].getCodewords()
        }

        var otherCodewords_: Array<Codeword> = Array<Codeword>(14, item: Codeword())

        otherCodewords_[2] = previousColumnCodewords[codewordsRow]
        otherCodewords_[3] = nextColumnCodewords[codewordsRow]

        if (codewordsRow > 0) {
            otherCodewords_[0] = codewords[codewordsRow - 1]
            otherCodewords_[4] = previousColumnCodewords[codewordsRow - 1]
            otherCodewords_[5] = nextColumnCodewords[codewordsRow - 1]
        }
        if (codewordsRow > 1) {
            otherCodewords_[8] = codewords[codewordsRow - 2]
            otherCodewords_[10] = previousColumnCodewords[codewordsRow - 2]
            otherCodewords_[11] = nextColumnCodewords[codewordsRow - 2]
        }
        if (codewordsRow < codewords.size - 1) {
            otherCodewords_[1] = codewords[codewordsRow + 1]
            otherCodewords_[6] = previousColumnCodewords[codewordsRow + 1]
            otherCodewords_[7] = nextColumnCodewords[codewordsRow + 1]
        }
        if (codewordsRow < codewords.size - 2) {
            otherCodewords_[9] = codewords[codewordsRow + 2]
            otherCodewords_[12] = previousColumnCodewords[codewordsRow + 2]
            otherCodewords_[13] = nextColumnCodewords[codewordsRow + 2]
        }
        for (i in 0..otherCodewords_.size) {
            if (adjustRowNumber(codeword, otherCodewords_[i])) {
                return;
            }
        }
    }

    /**
     * @return true, if row number was adjusted, false otherwise
     */
    private static func adjustRowNumber(codeword: Codeword, otherCodeword: Codeword): Bool {
        if (otherCodeword.flag) {
            if (otherCodeword.hasValidRowNumber() && otherCodeword.getBucket() == codeword.getBucket()) {
                codeword.setRowNumber(otherCodeword.getRowNumber());
                return true
            }
        } else {
            return false
        }

        return false
    }

    func getBarcodeColumnCount(): Int64 {
        return barcodeColumnCount
    }

    func getBarcodeRowCount(): Int64 {
        return barcodeMetadata.getRowCount();
    }

    func getBarcodeECLevel(): Int64 {
        return barcodeMetadata.getErrorCorrectionLevel();
    }

    func setBoundingBox(boundingBox: BoundingBox) {
        this.boundingBox = boundingBox
    }

    func getBoundingBox(): BoundingBox {
        return boundingBox
    }

    func setDetectionResultColumn(barcodeColumn: Int64, detectionResultColumn: DetectionResultColumn) {
        detectionResultColumns[barcodeColumn] = detectionResultColumn
    }

    func getDetectionResultColumn(barcodeColumn: Int64): DetectionResultColumn {
        return detectionResultColumns[barcodeColumn]
    }

    public func toString(): String {
        var rowIndicatorColumn: DetectionResultColumn = detectionResultColumns[0]
        if (rowIndicatorColumn.flag) {}
        else {
            rowIndicatorColumn = detectionResultColumns[barcodeColumnCount + 1]
        }
        var result = String()
        for (codewordsRow in 0..rowIndicatorColumn.getCodewords().size) {
            result += "CW "
            result += codewordsRow.format("3")
            result += ":"
            for (barcodeColumn in 0..barcodeColumnCount + 2) {
                if (detectionResultColumns[barcodeColumn].flag) {
                    var codeword: Codeword = detectionResultColumns[barcodeColumn].getCodewords()[codewordsRow]
                    if (codeword.flag) {
                        result += " "
                        result += codeword.getRowNumber().format("3")
                        result += "|"
                        result += codeword.getValue().format("3")
                    } else {
                        result += "    |   "
                        continue
                    }
                } else {
                    result += "    |   "
                    continue
                }
            }
            result += "\n"
        }
        return result
    }
}
