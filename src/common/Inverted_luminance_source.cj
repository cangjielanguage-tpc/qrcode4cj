/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package common

public open class InvertedLuminanceSource <: LuminanceSource {
    private let delegate: LuminanceSource

    public init(delegate: LuminanceSource) {
        super(delegate.getWidth(), delegate.getHeight())
        this.delegate = delegate
    }

    public override func getRow(y: Int64, row: Array<UInt8>): Array<UInt8> {
        var rowret: Array<UInt8> = delegate.getRow(y, row)
        let width: Int64 = getWidth()
        for (i in 0..width) {
            rowret[i] = UInt8(255 - (rowret[i] & 0xFF))
        }
        return rowret
    }

    public override func getMatrix(): Array<UInt8> {
        let matrix: Array<UInt8> = delegate.getMatrix()
        let length: Int64 = getWidth() * getHeight()
        var invertedMatrix: Array<UInt8> = Array<UInt8>(length, item: 0)
        for (i in 0..length) {
            invertedMatrix[i] = UInt8(255 - (matrix[i] & 0xFF))
        }
        return invertedMatrix
    }

    public override func isCropSupported(): Bool {
        return delegate.isCropSupported()
    }

    public override func crop(left: Int64, top: Int64, width: Int64, height: Int64): LuminanceSource {
        return InvertedLuminanceSource(delegate.crop(left, top, width, height))
    }

    public override func isRotateSupported(): Bool {
        return delegate.isRotateSupported()
    }

    /**
     * @return original delegate {@link LuminanceSource} since invert undoes itself
     */
    public override func invert(): LuminanceSource {
        return delegate
    }

    public override func rotateCounterClockwise(): LuminanceSource {
        return InvertedLuminanceSource(delegate.rotateCounterClockwise())
    }

    public override func rotateCounterClockwise45(): LuminanceSource {
        return InvertedLuminanceSource(delegate.rotateCounterClockwise45())
    }
}
