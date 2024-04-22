/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss

import common.*

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
