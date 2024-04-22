/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package pdf417.decoder

import common.Qrcoder4cjNotFoundException
import common.ResultPoint
import common.BitMatrix
from std import math.*

open class BoundingBox {
    private var image: BitMatrix = BitMatrix()
    private var topLeft: ResultPoint = ResultPoint();
    private var bottomLeft: ResultPoint = ResultPoint();
    private var topRight: ResultPoint = ResultPoint();
    private var bottomRight: ResultPoint = ResultPoint();
    private var minX: Int64 = 0
    private var maxX: Int64 = 0
    private var minY: Int64 = 0
    private var maxY: Int64 = 0
    public var flag: Bool = false;
    init() {}

    init(
        image: BitMatrix,
        topLeft: ResultPoint,
        bottomLeft: ResultPoint,
        topRight: ResultPoint,
        bottomRight: ResultPoint
    ) {
        var topLeft_: ResultPoint = topLeft
        var bottomLeft_: ResultPoint = bottomLeft
        var topRight_: ResultPoint = topRight
        var bottomRight_: ResultPoint = bottomRight

        var leftUnspecified: Bool = !topLeft_.flag || !bottomLeft_.flag
        var rightUnspecified: Bool = !topRight_.flag || !bottomRight_.flag
        if (leftUnspecified && rightUnspecified) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }
        if (leftUnspecified) {
            topLeft_ = ResultPoint(0.0, topRight.getY())
            bottomLeft_ = ResultPoint(0.0, bottomRight.getY())
        } else if (rightUnspecified) {
            topRight_ = ResultPoint(Float32(image.getWidth() - 1), topLeft.getY())
            bottomRight_ = ResultPoint(Float32(image.getWidth() - 1), bottomLeft.getY())
        }
        this.image = image
        this.topLeft = topLeft_
        this.bottomLeft = bottomLeft_
        this.topRight = topRight_
        this.bottomRight = bottomRight_
        this.minX = Int64(min(topLeft_.getX(), bottomLeft_.getX()))
        this.maxX = Int64(max(topRight_.getX(), bottomRight_.getX()))
        this.minY = Int64(min(topLeft_.getY(), topRight_.getY()))
        this.maxY = Int64(max(bottomLeft_.getY(), bottomRight_.getY()))
        this.flag = true
    }

    init(boundingBox_: BoundingBox) {
        this.image = boundingBox_.image
        this.topLeft = boundingBox_.topLeft
        this.bottomLeft = boundingBox_.bottomLeft
        this.topRight = boundingBox_.topRight
        this.bottomRight = boundingBox_.bottomRight
        this.minX = boundingBox_.minX
        this.maxX = boundingBox_.maxX
        this.minY = boundingBox_.minY
        this.maxY = boundingBox_.maxY
        this.flag = boundingBox_.flag
    }

    static func merge(leftBox: BoundingBox, rightBox: BoundingBox): BoundingBox {
        if (leftBox.flag == false) {
            return rightBox
        }
        if (rightBox.flag == false) {
            return leftBox
        }
        return BoundingBox(leftBox.image, leftBox.topLeft, leftBox.bottomLeft, rightBox.topRight, rightBox.bottomRight);
    }

    func addMissingRows(missingStartRows: Int64, missingEndRows: Int64, isLeft: Bool): BoundingBox {
        var newTopLeft: ResultPoint = topLeft
        var newBottomLeft: ResultPoint = bottomLeft
        var newTopRight: ResultPoint = topRight
        var newBottomRight: ResultPoint = bottomRight

        if (missingStartRows > 0) {
            var top: ResultPoint
            if (isLeft) {
                top = topLeft
            } else {
                top = topRight
            }
            var newMinY: Int64 = Int64(top.getY()) - missingStartRows
            if (newMinY < 0) {
                newMinY = 0
            }
            var newTop: ResultPoint = ResultPoint(top.getX(), Float32(newMinY));
            if (isLeft) {
                newTopLeft = newTop
            } else {
                newTopRight = newTop
            }
        }

        if (missingEndRows > 0) {
            var bottom: ResultPoint
            if (isLeft) {
                bottom = bottomLeft
            } else {
                bottom = bottomRight
            }
            var newMaxY: Int64 = Int64(bottom.getY()) + missingEndRows
            if (newMaxY >= image.getHeight()) {
                newMaxY = image.getHeight() - 1
            }
            var newBottom: ResultPoint = ResultPoint(bottom.getX(), Float32(newMaxY));
            if (isLeft) {
                newBottomLeft = newBottom
            } else {
                newBottomRight = newBottom
            }
        }

        return BoundingBox(image, newTopLeft, newBottomLeft, newTopRight, newBottomRight);
    }

    func getMinX(): Int64 {
        return minX
    }

    func getMaxX(): Int64 {
        return maxX
    }

    func getMinY(): Int64 {
        return minY
    }

    func getMaxY(): Int64 {
        return maxY
    }

    func getTopLeft(): ResultPoint {
        return topLeft
    }

    func getTopRight(): ResultPoint {
        return topRight
    }

    func getBottomLeft(): ResultPoint {
        return bottomLeft
    }

    func getBottomRight(): ResultPoint {
        return bottomRight
    }
}
