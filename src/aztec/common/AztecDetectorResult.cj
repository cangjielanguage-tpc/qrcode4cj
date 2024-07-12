/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package aztec.common

from std import collection.*
import common.ResultPoint
import common.BitMatrix
import common.DetectorResult

public class AztecDetectorResult <: DetectorResult {
    private var compact: Bool
    private var nbDatablocks: Int64
    private var nbLayers: Int64

    public init(bits: BitMatrix, points: Array<ResultPoint>, compact: Bool, nbDatablocks: Int64, nbLayers: Int64) {
        super(bits, points)
        this.compact = compact
        this.nbDatablocks = nbDatablocks
        this.nbLayers = nbLayers
    }

    public func getNbLayers(): Int64 {
        return this.nbLayers
    }

    public func getNbDatablocks(): Int64 {
        return this.nbDatablocks
    }

    public func isCompact(): Bool {
        return this.compact
    }
}
