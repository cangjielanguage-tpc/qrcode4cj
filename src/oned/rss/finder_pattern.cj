/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss

import QRCode4cj.common.*

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
