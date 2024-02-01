/*
 * Copyright 2013 ZXing authors
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

package zxing.code.pdf417.decoder

import zxing.code.pdf417.common.PDF417Common
from std import collection.*

/**
 * @author Guenther Grau
 */
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

        values.put(value, confidenceNum);
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
                result.append(entryk);
            } else if (entryv == maxConfidence) {
                result.append(entryk);
            }
        }
        return result.toArray();
    }

    func getConfidence(value: Int64): Int64 {
        return values[value]
    }
}
