/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package pdf417.detector

import common.ResultPoint
import common.BitMatrix
from std import collection.*

/**
 * @author Guenther Grau
 */
public open class PDF417DetectorResult {
    private var bits: BitMatrix
    private var points: ArrayList<Array<ResultPoint>>
    private var rotation: Int64

    public init(bits: BitMatrix, points: ArrayList<Array<ResultPoint>>, rotation: Int64) {
        this.bits = bits
        this.points = points
        this.rotation = rotation
    }

    public init(bits: BitMatrix, points: ArrayList<Array<ResultPoint>>) {
        this(bits, points, 0)
    }

    public func getBits(): BitMatrix {
        return bits
    }

    public func getPoints(): ArrayList<Array<ResultPoint>> {
        return points
    }

    public func getRotation(): Int64 {
        return rotation
    }
}
