/*
 * Copyright 2007 ZXing authors
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

package zxing.code.qrcode.detector

import zxing.code.common.ResultPoint
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
