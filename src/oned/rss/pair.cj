/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss

open class Pair <: DataCharacter {
    private var finderPattern: FinderPattern = FinderPattern()
    private var count: Int64 = 0

    init(value: Int64, checksumPortion: Int64, finderPattern: FinderPattern) {
        super(value, checksumPortion);
        this.finderPattern = finderPattern
    }

    public func getFinderPattern(): FinderPattern {
        return finderPattern
    }

    func getCount(): Int64 {
        return count
    }

    func incrementCount() {
        count++
    }
}
