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

package zxing.code.pdf417.encoder

/**
 * Data object to specify the minimum and maximum number of rows and columns for a PDF417 barcode.
 *
 * @author qwandor@google.com (Andrew Walbran)
 */
public open class Dimensions {
    private let minCols: Int64
    private let maxCols: Int64
    private let minRows: Int64
    private let maxRows: Int64

    public init(minCols: Int64, maxCols: Int64, minRows: Int64, maxRows: Int64) {
        this.minCols = minCols
        this.maxCols = maxCols
        this.minRows = minRows
        this.maxRows = maxRows
    }

    public func getMinCols(): Int64 {
        return minCols
    }

    public func getMaxCols(): Int64 {
        return maxCols
    }

    public func getMinRows(): Int64 {
        return minRows
    }

    public func getMaxRows(): Int64 {
        return maxRows
    }
}
