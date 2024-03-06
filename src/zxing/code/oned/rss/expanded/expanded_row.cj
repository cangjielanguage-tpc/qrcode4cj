/*
 * Copyright (C) 2010 ZXing authors
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

package zxing.code.oned.rss.expanded

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
