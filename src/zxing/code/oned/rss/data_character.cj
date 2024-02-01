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

import zxing.code.common.*

/**
 * Encapsulates a since character value in an RSS barcode, including its checksum information.
 */
public open class DataCharacter {
    private var value: Int64 = 0
    private var checksumPortion: Int64 = 0
    private var flag: Bool = false
    public init() {}
    public init(value: Int64, checksumPortion: Int64) {
        this.value = value
        this.checksumPortion = checksumPortion
        this.flag = true
    }

    public func getValue(): Int64 {
        return value
    }

    public func getChecksumPortion(): Int64 {
        return checksumPortion
    }

    public func toString(): String {
        return "${value} ( ${checksumPortion} )"
    }

    public func equals(o: Object): Bool {
        if (!(o is DataCharacter)) {
            return false;
        }
        var that: DataCharacter = (o as DataCharacter).getOrThrow();
        return value == that.value && checksumPortion == that.checksumPortion
    }

    public func hashCode(): Int64 {
        return value ^ checksumPortion
    }
}
