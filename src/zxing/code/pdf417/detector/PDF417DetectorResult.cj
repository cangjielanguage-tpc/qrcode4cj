/*
 * Copyright 2007 ZXing authors
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

package zxing.code.pdf417.detector

import zxing.code.common.ResultPoint
import zxing.code.common.BitMatrix
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
