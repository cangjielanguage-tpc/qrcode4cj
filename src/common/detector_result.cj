/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.common

public open class DetectorResult {
    private let bits: BitMatrix
    private let points: Array<ResultPoint>

    public init(bits: BitMatrix, points: Array<ResultPoint>) {
        this.bits = bits
        this.points = points
    }

    public func getBits(): BitMatrix {
        return bits
    }

    public func getPoints(): Array<ResultPoint> {
        return points
    }
}
