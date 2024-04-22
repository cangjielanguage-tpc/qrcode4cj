/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package common

/**
 * Simply encapsulates a width and height.
 */
public open class Dimension {
    private let width: Int64
    private let height: Int64

    public init(width: Int64, height: Int64) {
        if (width < 0 || height < 0) {
            throw IllegalArgumentException()
        }
        this.width = width
        this.height = height
    }

    public func getWidth(): Int64 {
        return width
    }

    public func getHeight(): Int64 {
        return height
    }

    public func equals(other: Any): Bool {
        if (other is Dimension) {
            let otherPoint: Dimension = (other as Dimension).getOrThrow();
            return width == otherPoint.width && height == otherPoint.height
        }

        return false
    }

    public func hashCode(): Int64 {
        return width * 32713 + height
    }

    public func toString(): String {
        return " ${width} x ${height}"
    }
}
