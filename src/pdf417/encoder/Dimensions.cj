/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417.encoder

/**
 * Data object to specify the minimum and maximum number of rows and columns for a PDF417 barcode.
 */
public open class Dimensions {
    private let minCols: Int64
    private let maxCols: Int64
    private let minRows: Int64
    private let maxRows: Int64

    public init(minCols: Int64, maxCols: Int64, minRows: Int64, maxRows: Int64) {
        this.minCols = minCols
        this.maxCols = maxCols
        this.minRows = minRows
        this.maxRows = maxRows
    }

    public func getMinCols(): Int64 {
        return minCols
    }

    public func getMaxCols(): Int64 {
        return maxCols
    }

    public func getMinRows(): Int64 {
        return minRows
    }

    public func getMaxRows(): Int64 {
        return maxRows
    }
}
