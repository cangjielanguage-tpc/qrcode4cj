/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417.decoder

import QRCode4cj.pdf417.common.PDF417Common
import std.collection.*

open class BarcodeValue {
    private let values: HashMap<Int64, Int64> = HashMap<Int64, Int64>(1)

    /**
     * Add an occurrence of a value
     */
    func setValue(value: Int64) {
        var confidenceNum: Int64 = 0
        var confidence: Bool = values.contains(value)
        if (confidence) {
            confidenceNum = values[value]
        } else {
            confidenceNum = 0
        }
        confidenceNum++

        values.add(value, confidenceNum);
    }

    /**
     * Determines the maximum occurrence of a set value and returns all values which were set with this occurrence.
     * @return an array of int, containing the values with the highest occurrence, or null, if no value was set
     */
    func getValue(): Array<Int64> {
        var maxConfidence: Int64 = -1
        var result: ArrayList<Int64> = ArrayList<Int64>()
        for ((entryk, entryv) in values) {
            if (entryv > maxConfidence) {
                maxConfidence = entryv
                result.clear();
                result.add(entryk);
            } else if (entryv == maxConfidence) {
                result.add(entryk);
            }
        }
        return result.toArray();
    }

    func getConfidence(value: Int64): Int64 {
        return values[value]
    }
}
