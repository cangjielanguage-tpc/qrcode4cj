/*
 * Copyright 2009 ZXing authors
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

package zxing.code.oned.rss

/**
 * Encapsulates an RSS barcode finder pattern, including its start/end position and row.
 */
public class FinderPattern {
    private var value: Int64 = 0
    private var startEnd: Array<Int64> = Array<Int64>();
    private var resultPoints: Array<ResultPoint> = Array<ResultPoint>();
    public var flag = false
    public init() {}
    public init(value: Int64, startEnd: Array<Int64>, start: Int64, end: Int64, rowNumber: Int64) {
        this.value = value
        this.startEnd = startEnd
        this.resultPoints = [
            ResultPoint(Float32(start), Float32(rowNumber)),
            ResultPoint(Float32(end), Float32(rowNumber))
        ]
        this.flag = true
    }

    public func getValue(): Int64 {
        return value
    }

    public func getStartEnd(): Array<Int64> {
        return startEnd
    }

    public func getResultPoints(): Array<ResultPoint> {
        return resultPoints
    }

    public func equals(o: Object): Bool {
        if (!(o is FinderPattern)) {
            return false;
        }
        var that: FinderPattern = (o as FinderPattern).getOrThrow();
        return value == that.value
    }

    public func hashCode(): Int64 {
        return value
    }
}
