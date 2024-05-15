/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package qrcode.detector

/**
 * Encapsulates a finder pattern, which are the three square patterns found in
 * the corners of QR Codes. It also encapsulates a count of similar finder patterns,
 * as a convenience to the finder's bookkeeping.
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
