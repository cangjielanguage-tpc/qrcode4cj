/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded

/**
 * One row of an RSS Expanded Stacked symbol, consisting of 1+ expanded pairs.
 */
public class ExpandedRow {
    private var pairs: ArrayList<ExpandedPair> = ArrayList<ExpandedPair>();
    private var rowNumber: Int64 = 0

    init(pairs: ArrayList<ExpandedPair>, rowNumber: Int64) {
        this.pairs = ArrayList<ExpandedPair>(pairs)
        this.rowNumber = rowNumber
    }

    public func getPairs(): ArrayList<ExpandedPair> {
        return this.pairs;
    }

    public func getRowNumber(): Int64 {
        return this.rowNumber;
    }

    public func isEquivalent(otherPairs: ArrayList<ExpandedPair>): Bool {
        if (this.pairs.size != otherPairs.size) {
            return false
        }
        var i: Int64 = 0
        while (i < this.pairs.size) {
            if (!this.pairs[i].equals(otherPairs[i])) {
                return false
            }
            i++
        }
        return true
    }

    public func toString(): String {
        var str: String = ""
        for (i in 0..pairs.size) {
            str += "[ ${pairs[i].toString()} ]"
        }
        return "{ ${str} }"
    }

    /**
     * Two rows are equal if they contain the same pairs in the same order.
     */
    public func equals(o: Any): Bool {
        if (let None <- (o as ExpandedRow)) {
            return false;
        }
        var that: ?ExpandedRow = o as ExpandedRow

        if (this.pairs.size != (that?.pairs.size).getOrThrow()) {
            return false
        }
        var i: Int64 = 0
        while (i < this.pairs.size) {
            if (this.pairs[i].equals((that?.pairs[i]).getOrThrow())) {
                return false
            }
            i++
        }

        return true
    }

    public func hashCode(): Int64 {
        var hash = 0
        for (i in 0..pairs.size) {
            hash ^= pairs[i].hashCode()
        }
        return hash
    }
}
