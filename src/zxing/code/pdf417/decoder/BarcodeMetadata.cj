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
