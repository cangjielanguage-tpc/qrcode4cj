/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.tools

import std.time.*

public class System {
    public static func arraycopy<T>(src: Array<T>, srcPos: Int64, dest: Array<T>, destPos: Int64, length: Int64): Array<T> {
        var returndata: Array<T> = dest

        for (i in 0..length) {
            returndata[destPos + i] = src[i + srcPos]
        }
        return returndata
    }

    public static func currentTimeMillis(): Int64 {
        var zero = DateTime.of(year: 1970, month: 1, dayOfMonth: 1)
        var now = DateTime.now()
        var new: Duration = now - zero

        return new.toMilliseconds()
    }

    @OverflowWrapping
    public static func unsignedShiftRight(c: Int32, num: Int64) {
        Int32(UInt32(c) >> num)
    }
}
