/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package common

public abstract class GridSampler {
    private static var gridSampler: GridSampler = DefaultGridSampler()

    public static func setGridSampler(newGridSampler: GridSampler): Unit {
        gridSampler = newGridSampler
    }

    /**
     * @return the current implementation of GridSampler
     */
    public static func getInstance(): GridSampler {
        return gridSampler
    }

    public func sampleGrid(
        image: BitMatrix,
        dimensionX: Int64,
        dimensionY: Int64,
        p1ToX: Float64,
        p1ToY: Float64,
        p2ToX: Float64,
        p2ToY: Float64,
        p3ToX: Float64,
        p3ToY: Float64,
        p4ToX: Float64,
        p4ToY: Float64,
        p1FromX: Float64,
        p1FromY: Float64,
        p2FromX: Float64,
        p2FromY: Float64,
        p3FromX: Float64,
        p3FromY: Float64,
        p4FromX: Float64,
        p4FromY: Float64
    ): BitMatrix

    public func sampleGrid(
        image: BitMatrix,
        dimensionX: Int64,
        dimensionY: Int64,
        transform: PerspectiveTransform
    ): BitMatrix

    protected static func checkAndNudgePoints(image: BitMatrix, points: Array<Float64>) {
        let (width, height) = (image.width, image.height)

        // Check and nudge points from start until we see some that are OK:
        var nudged = true
        var maxOffset = points.size - 1 // points.length must be even
        var offset = 0

        while (offset < maxOffset && nudged) {
            let (x, y) = excheckAndNudgePoints(points, offset, width, height)
            nudged = false
            if (x == -1) {
                points[offset] = 0.0
                nudged = true
            } else if (x == width) {
                points[offset] = Float64(width - 1)
                nudged = true
            }
            if (y == -1) {
                points[offset + 1] = 0.0
                nudged = true
            } else if (y == height) {
                points[offset + 1] = Float64(height - 1)
                nudged = true
            }
            offset += 2
        }

        // Check and nudge points from end:
        nudged = true
        offset = points.size - 2
        while (offset >= 0 && nudged) {
            let (x, y) = xY(points, offset)
            if (x < -1 || x > width || y < -1 || y > height) {
                throw Qrcoder4cjNotFoundException()
            }
            nudged = false
            if (x == -1) {
                points[offset] = 0.0
                nudged = true
            } else if (x == width) {
                points[offset] = Float64(width - 1)
                nudged = true
            }
            if (y == -1) {
                points[offset + 1] = 0.0
                nudged = true
            } else if (y == height) {
                points[offset + 1] = Float64(height - 1)
                nudged = true
            }
            offset -= 2
        }
    }

    private static func excheckAndNudgePoints(points: Array<Float64>, offset: Int64, width: Int64, height: Int64): (Int64, 
        Int64) {
        let x = Int64(points[offset])
        let y = Int64(points[offset + 1])
        if (x < -1 || x > width || y < -1 || y > height) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }
        return (x, y)
    }

    private static func xY(points: Array<Float64>, offset: Int64): (Int64, Int64) {
        return (Int64(points[offset]), Int64(points[offset + 1]))
    }
}
