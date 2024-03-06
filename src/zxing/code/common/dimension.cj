/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

package zxing.code.common

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
