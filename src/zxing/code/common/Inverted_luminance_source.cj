/*
 * Copyright 2013 ZXing authors
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
 * A wrapper implementation of {@link LuminanceSource} which inverts the luminances it returns -- black becomes
 * white and vice versa, and each value becomes (255-value).
 *
 * @author Sean Owen
 */
public open class InvertedLuminanceSource <: LuminanceSource {
    private let delegate: LuminanceSource

    public init(delegate: LuminanceSource) {
        super(delegate.getWidth(), delegate.getHeight())
        this.delegate = delegate
    }

    public override func getRow(y: Int64, row: Array<UInt8>): Array<UInt8> {
        var rowret: Array<UInt8> = delegate.getRow(y, row)
        let width: Int64 = getWidth()
        for (i in 0..width) {
            rowret[i] = UInt8(255 - (rowret[i] & 0xFF))
        }
        return rowret
    }

    public override func getMatrix(): Array<UInt8> {
        let matrix: Array<UInt8> = delegate.getMatrix()
        let length: Int64 = getWidth() * getHeight()
        var invertedMatrix: Array<UInt8> = Array<UInt8>(length, item: 0)
        for (i in 0..length) {
            invertedMatrix[i] = UInt8(255 - (matrix[i] & 0xFF))
        }
        return invertedMatrix
    }

    public override func isCropSupported(): Bool {
        return delegate.isCropSupported()
    }

    public override func crop(left: Int64, top: Int64, width: Int64, height: Int64): LuminanceSource {
        return InvertedLuminanceSource(delegate.crop(left, top, width, height))
    }

    public override func isRotateSupported(): Bool {
        return delegate.isRotateSupported()
    }

    /**
     * @return original delegate {@link LuminanceSource} since invert undoes itself
     */
    public override func invert(): LuminanceSource {
        return delegate
    }

    public override func rotateCounterClockwise(): LuminanceSource {
        return InvertedLuminanceSource(delegate.rotateCounterClockwise())
    }

    public override func rotateCounterClockwise45(): LuminanceSource {
        return InvertedLuminanceSource(delegate.rotateCounterClockwise45())
    }
}
