/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package pdf417.decoder

open class BarcodeMetadata {
    private let columnCount: Int64
    private let errorCorrectionLevel: Int64
    private let rowCountUpperPart: Int64
    private let rowCountLowerPart: Int64
    private let rowCount: Int64

    init(columnCount: Int64, rowCountUpperPart: Int64, rowCountLowerPart: Int64, errorCorrectionLevel: Int64) {
        this.columnCount = columnCount
        this.errorCorrectionLevel = errorCorrectionLevel
        this.rowCountUpperPart = rowCountUpperPart
        this.rowCountLowerPart = rowCountLowerPart
        this.rowCount = rowCountUpperPart + rowCountLowerPart
    }

    func getColumnCount(): Int64 {
        return columnCount
    }

    func getErrorCorrectionLevel(): Int64 {
        return errorCorrectionLevel
    }

    func getRowCount(): Int64 {
        return rowCount
    }

    func getRowCountUpperPart(): Int64 {
        return rowCountUpperPart
    }

    func getRowCountLowerPart(): Int64 {
        return rowCountLowerPart
    }
}
