/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package qrcode.detector

import common.ResultPoint
from std import math.*

/**
 * <p>Encapsulates an alignment pattern, which are the smaller square patterns found in
 * all but the simplest QR Codes.</p>
 *
 * @author Sean Owen
 */
class AlignmentPattern <: ResultPoint {
    public var estimatedModuleSize: Float32 = 0.0;

    public init() {}

    public init(posX: Float32, posY: Float32, estimatedModuleSize: Float32) {
        super(posX, posY);
        this.estimatedModuleSize = estimatedModuleSize
    }

    /**
     * <p>Determines if this alignment pattern "about equals" an alignment pattern at the stated
     * position and size -- meaning, it is at nearly the same center with nearly the same size.</p>
     */
    public func aboutEquals(moduleSize: Float32, i: Float32, j: Float32): Bool {
        if (abs(i - getY()) <= moduleSize && abs(j - getX()) <= moduleSize) {
            let moduleSizeDiff: Float32 = abs(moduleSize - estimatedModuleSize);
            return moduleSizeDiff <= 1.0f32 || moduleSizeDiff <= estimatedModuleSize
        }
        return false;
    }

    /**
     * Combines this object's current estimate of a finder pattern position and module size
     * with a new estimate. It returns a new {@code FinderPattern} containing an average of the two.
     */
    public func combineEstimate(i: Float32, j: Float32, newModuleSize: Float32): AlignmentPattern {
        let combinedX: Float32 = (getX() + j) / 2.0f32
        let combinedY: Float32 = (getY() + i) / 2.0f32
        let combinedModuleSize: Float32 = (estimatedModuleSize + newModuleSize) / 2.0f32
        return AlignmentPattern(combinedX, combinedY, combinedModuleSize);
    }
}
