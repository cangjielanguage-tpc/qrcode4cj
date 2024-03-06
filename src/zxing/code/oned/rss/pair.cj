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
