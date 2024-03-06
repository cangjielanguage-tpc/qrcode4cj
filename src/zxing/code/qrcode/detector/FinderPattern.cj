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

/**
 * <p>Encapsulates a finder pattern, which are the three square patterns found in
 * the corners of QR Codes. It also encapsulates a count of similar finder patterns,
 * as a convenience to the finder's bookkeeping.</p>
 *
 * @author Sean Owen
 */
public open class FinderPattern <: ResultPoint {
    public var estimatedModuleSize: Float32
    private var count: Int64

    init(posX: Float32, posY: Float32, estimatedModuleSize: Float32) {
        this(posX, posY, estimatedModuleSize, 1);
    }

    private init(posX: Float32, posY: Float32, estimatedModuleSize: Float32, count: Int64) {
        super(posX, posY);
        this.estimatedModuleSize = estimatedModuleSize
        this.count = count
    }

    public func getEstimatedModuleSize(): Float32 {
        return estimatedModuleSize
    }

    public func getCount(): Int64 {
        return count
    }

    /**
     * <p>Determines if this finder pattern "about equals" a finder pattern at the stated
     * position and size -- meaning, it is at nearly the same center with nearly the same size.</p>
     */
    func aboutEquals(moduleSize: Float32, i: Float32, j: Float32): Bool {
        if (abs(i - getY()) <= moduleSize && abs(j - getX()) <= moduleSize) {
            let moduleSizeDiff: Float32 = abs(moduleSize - estimatedModuleSize);
            return moduleSizeDiff <= 1.0f32 || moduleSizeDiff <= estimatedModuleSize
        }
        return false;
    }

    /**
     * Combines this object's current estimate of a finder pattern position and module size
     * with a new estimate. It returns a new {@code FinderPattern} containing a weighted average
     * based on count.
     */
    func combineEstimate(i: Float32, j: Float32, newModuleSize: Float32): FinderPattern {
        let combinedCount: Int64 = count + 1
        let combinedX: Float32 = (Float32(count) * getX() + j) / Float32(combinedCount)
        let combinedY: Float32 = (Float32(count) * getY() + i) / Float32(combinedCount)
        let combinedModuleSize: Float32 = (Float32(count) * estimatedModuleSize + newModuleSize) / Float32(combinedCount)
        return FinderPattern(combinedX, combinedY, combinedModuleSize, combinedCount);
    }
}
