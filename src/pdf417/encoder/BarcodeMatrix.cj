/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417.encoder

/**
 * Holds all of the information for a barcode in a format where it can be easily accessible
 */
public open class BarcodeMatrix {
    private var matrix: Array<BarcodeRow>
    private var currentRow: Int64
    private let height: Int64
    private let width: Int64

    /**
     * @param height the height of the matrix (Rows)
     * @param width  the width of the matrix (Cols)
     */
    init(height: Int64, width: Int64) {
        var itemrow: BarcodeRow = BarcodeRow(0)
        matrix = Array<BarcodeRow>(height, item: itemrow)

        //Initializes the array to the correct width
        let matrixLength: Int64 = matrix.size
        for (i in 0..matrixLength) {
            matrix[i] = BarcodeRow((width + 4) * 17 + 1)
        }
        this.width = width * 17
        this.height = height
        this.currentRow = -1
    }

    func set(x: Int64, y: Int64, value: UInt8) {
        matrix[y].set(x, value)
        return
    }

    func startRow() {
        currentRow++
    }

    func getCurrentRow(): BarcodeRow {
        return matrix[currentRow]
    }

    public func getMatrix(): Array<Array<UInt8>> {
        return getScaledMatrix(1, 1)
    }

    public func getScaledMatrix(xScale: Int64, yScale: Int64): Array<Array<UInt8>> {
        var matrixOut: Array<Array<UInt8>> = Array<Array<UInt8>>(
            height * yScale,
            {int: Int64 => Array<UInt8>(width * xScale, item: 0)}
        )
        let yMax: Int64 = height * yScale
        for (i in 0..yMax) {
            matrixOut[yMax - i - 1] = matrix[i / yScale].getScaledRow(xScale)
        }
        return matrixOut
    }
}
