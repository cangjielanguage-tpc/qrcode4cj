/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417.decoder

open class Codeword {
    private static let BARCODE_ROW_UNKNOWN: Int64 = -1

    private let startX: Int64
    private let endX: Int64
    private let bucket: Int64
    private let value: Int64
    private var rowNumber: Int64 = BARCODE_ROW_UNKNOWN
    public var flag = false;

    init() {
        this.startX = 0
        this.endX = 0
        this.bucket = 0
        this.value = 0
    }

    init(startX: Int64, endX: Int64, bucket: Int64, value: Int64) {
        this.startX = startX
        this.endX = endX
        this.bucket = bucket
        this.value = value
        this.flag = true
    }

    func hasValidRowNumber(): Bool {
        return isValidRowNumber(rowNumber);
    }

    func isValidRowNumber(rowNumber: Int64): Bool {
        return rowNumber != BARCODE_ROW_UNKNOWN && bucket == (rowNumber % 3) * 3
    }

    func setRowNumberAsRowIndicatorColumn() {
        rowNumber = (value / 30) * 3 + bucket / 3
    }

    func getWidth(): Int64 {
        return endX - startX
    }

    func getStartX(): Int64 {
        return startX
    }

    func getEndX(): Int64 {
        return endX
    }

    func getBucket(): Int64 {
        return bucket
    }

    func getValue(): Int64 {
        return value
    }

    func getRowNumber(): Int64 {
        return rowNumber
    }

    func setRowNumber(rowNumber: Int64) {
        this.rowNumber = rowNumber
    }

    /*override*/ public func toString(): String {
        return "${rowNumber}|${value}"
    }
}
