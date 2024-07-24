/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common

public abstract class Binarizer {
    private var source: LuminanceSource
    public var flag: Bool = false
    protected init(source: LuminanceSource) {
        this.source = source
        this.flag = true
    }

    public func getLuminanceSource(): LuminanceSource {
        return source
    }

    public func getBlackRow(y: Int64, row: BitArray): BitArray

    public func getBlackMatrix(): BitMatrix

    @OverflowThrowing
    public func createBinarizer(source: LuminanceSource): Binarizer

    public func getWidth(): Int64 {
        return source.getWidth()
    }

    public func getHeight(): Int64 {
        return source.getHeight()
    }
}
