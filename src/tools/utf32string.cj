/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
 
package QRCode4cj.tools

import std.collection.*
import std.unicode.*

public open class UTF32String <: ToString & Hashable & Equatable<UTF32String> {
    private var wsize: Int64 = 0
    var wval: Array<Rune>

    public init() {
        wval = Array<Rune>()
        wsize = 0
    }
    public init(str: String) {
        wval = str.toRuneArray()
        wsize = wval.size
    }

    public init(str: Rune) {
        wval = [str]
        wsize = 1
    }

    public init(str: Collection<Rune>) {
        wval = str.toArray()
        wsize = str.size
    }

    public init(size: Int64) {
        wval = Array<Rune>(size, item: r' ')
        wsize = size
    }
    public func toRuneArray(): Array<Rune> {
        return Array<Rune>(wval)
    }
    public func toString(): String {
        return String(wval)
    }

    public prop size: Int64 {
        get() {
            return wsize
        }
    }
    public prop charSize: Int64 {
        get() {
            return wsize
        }
    }
    public func get(idx: Int64): Rune {
        return wval[idx]
    }

    public func isEmpty(): Bool {
        return wsize == 0
    }

    public func trim(): UTF32String {
        if (wval.size == 0) {
            return UTF32String()
        }

        var strstart = -1;
        var strend = -1;

        for (i in 0..wval.size) {
            if (!wval[i].isWhiteSpace()) {
                strstart = i
                break
            }
        }

        for (i in wval.size - 1..=0 : -1) {
            if (!wval[i].isWhiteSpace()) {
                strend = i
                break
            }
        }
        return UTF32String(wval[strstart..=strend])
    }

    public func indexOf(str: UTF32String, start!: Int64 = 0): Option<Int64> { //常规算法
        var subwArray = str.toRuneArray()
        var n = wval.size;
        var m = subwArray.size;

        for (i in start..n - m + 1) {
            var count: Int64 = 0
            for (j in 0..m) {
                if (wval[i + j] != subwArray[j]) {
                    break
                } else {
                    count++
                }
            }
            if (count == m) {
                return i
            }
        }
        return None;
    }

    public func indexOf(str: String, start!: Int64 = 0): Option<Int64> {
        indexOf(UTF32String(str), start: start);
    }

    private func indexOf(substr: UTF32String, begin: Int64, lps: Array<Int64>): Option<Int64> { //基于KMP算法
        var subwArray = substr.toRuneArray()
        var n: Int64 = wval.size
        var m: Int64 = subwArray.size

        var i = begin
        var j = 0
        while (i < n) {
            if (wval[i] == subwArray[j]) {
                i++
                j++

                if (j == m) {
                    return (i - j)
                }
            } else {
                if (j != 0) {
                    j = lps[j - 1]
                } else {
                    i++
                }
            }
        }
        return None;
    }

    public func contains(str: String): Bool { //基于KMP算法
        return contains(UTF32String(str))
    }

    public func contains(str: UTF32String): Bool { //常规算法
        var subwArray = str.toRuneArray()
        var n = wval.size;
        var m = subwArray.size;

        for (i in 0..n - m + 1) {
            var count: Int64 = 0
            for (j in 0..m) {
                if (wval[i + j] != subwArray[j]) {
                    break
                } else {
                    count++
                }
            }
            if (count == m) {
                return true
            }
        }
        return false
    }

    private static func computeLPS(subArray: Array<Rune>): Array<Int64> {
        var m: Int64 = subArray.size;
        var lps: Array<Int64> = Array<Int64>(m, item: 0)

        var len = 0;
        var i = 1;
        while (i < m) {
            if (subArray[i] == subArray[len]) {
                len++;
                lps[i] = len
                i++;
            } else {
                if (len != 0) {
                    len = lps[len - 1]
                } else {
                    lps[i] = 0
                    i++;
                }
            }
        }
        return lps;
    }
    public func substring(pos: Int64, length: Int64): UTF32String {
        var len: Int64
        if (wsize - pos > length) {
            len = length
        } else {
            len = wsize - pos
        }
        var result: UTF32String = UTF32String(len)
        for (i in 0..len) {
            result.wval[i] = wval[i + pos]
        }
        return result
    }
    public func substring(pos: Int64): UTF32String {
        var len: Int64 = wsize - pos

        var result: UTF32String = UTF32String(len)
        for (i in 0..len) {
            result.wval[i] = wval[i + pos]
        }
        return result
    }

    public func split(str: UTF32String, removeEmpty!: Bool = false): Array<UTF32String> {
        var result: ArrayList<UTF32String> = ArrayList<UTF32String>()
        var n = wval.size;
        var subwArray = str.toRuneArray()
        var subwArraySize = subwArray.size
        var i = 0
        var lastPos = 0
        var lps = computeLPS(subwArray)

        while (i < n) {
            var pos: Option<Int64> = indexOf(str, i, lps)
            if (pos == None) {
                break;
            }
            var posVal: Int64 = pos.getOrThrow()
            if (posVal > lastPos) {
                result.append(substring(lastPos, posVal - lastPos))
            } else if (posVal == lastPos && !removeEmpty) {
                result.append(UTF32String(""))
            }
            lastPos = posVal + subwArraySize
            i = lastPos
        }
        if (lastPos < n) {
            result.append(substring(lastPos, n - lastPos))
        }
        return result.toArray()
    }

    public func indexOfToList(str: UTF32String): ArrayList<Int64> {
        var n = wval.size;
        var strArray = str.toRuneArray()
        var strArraySize = strArray.size

        var posiList = ArrayList<Int64>()

        var i = 0
        var lps = computeLPS(strArray)
        while (i < n) {
            var pos: Option<Int64> = indexOf(str, i, lps)
            if (pos.isNone()) {
                break;
            }
            var posVal: Int64 = pos.getOrThrow()
            posiList.append(posVal)
            i = posVal + strArraySize
        }
        return posiList
    }

    public func replace(old: UTF32String, new: UTF32String): UTF32String {
        var rawStrSize = wval.size;
        var oldArray = old.toRuneArray()
        var oldArraySize = oldArray.size

        var newArray = new.toRuneArray()
        var newArraySize = newArray.size

        var posiList = indexOfToList(old)

        var posiSize = posiList.size
        if (posiSize == 0) {
            return this
        }
        var newSize = rawStrSize - (posiSize * oldArraySize) + (posiSize * newArraySize)

        var newStr: UTF32String = UTF32String(newSize)

        var posi = 0

        for (i in 0..posiList[0]) {
            newStr.wval[posi] = wval[i]
            posi++
        }
        for (i in 0..newArraySize) {
            newStr.wval[posi] = newArray[i]
            posi++
        }

        for (i in 1..posiSize) {
            for (j in posiList[i - 1] + oldArraySize..posiList[i]) {
                newStr.wval[posi] = wval[j]
                posi++
            }
            for (i in 0..newArraySize) {
                newStr.wval[posi] = newArray[i]
                posi++
            }
        }
        var i = 0
        while (posi < newSize) {
            newStr.wval[posi] = wval[posiList[posiSize - 1] + oldArraySize + i]
            posi++
            i++
        }
        return newStr
    }

    public func startsWith(str: UTF32String): Bool {
        if (str.size == 0) {
            return true
        }
        var rawStrSize = wval.size;
        var strArray = str.toRuneArray()
        var strArraySize = strArray.size
        if (strArraySize > rawStrSize) {
            return false
        }
        for (i in 0..strArraySize) {
            if (wval[i] != strArray[i]) {
                return false
            }
        }
        return true
    }
    public func endsWith(str: UTF32String): Bool {
        if (str.size == 0) {
            return true
        }
        var rawStrSize = wval.size;
        var strArray = str.toRuneArray()
        var strArraySize = strArray.size
        if (strArraySize > rawStrSize) {
            return false
        }
        var idx = 0
        for (i in rawStrSize - strArraySize..rawStrSize) {
            if (wval[i] != strArray[idx]) {
                return false
            }
            idx++
        }
        return true
    }

    public func toAsciiLower(): UTF32String {
        var newarr = this.wval.clone()
        for (i in 0..this.wsize) {
            newarr[i] = this.wval[i].toAsciiLowerCase()
        }

        return UTF32String(newarr)
    }

    @OverflowWrapping
    public func hashCode(): Int64 {
        var h: Int64 = 0;
        for (v in 0..wval.size) {
            h = 31 * h + Int64(UInt32(wval[v]))
        }
        return h;
    }

    public operator func [](arg1: Int64): Rune {
        return wval[arg1]
    }

    public operator func [](arg1: Range<Int64>): UTF32String {
        return UTF32String(wval[arg1])
    }

    public operator func ==(arg1: UTF32String): Bool {
        if (this.size != arg1.size) {
            return false
        }

        for (i in 0..this.size) {
            if (this[i] != arg1[i]) {
                return false
            }
        }
        return true
    }

    public operator func ==(arg1: String): Bool {
        let data = arg1.toRuneArray()
        if (this.size != data.size) {
            return false
        }

        for (i in 0..this.size) {
            if (this[i] != data[i]) {
                return false
            }
        }
        return true
    }

    public operator func !=(arg1: UTF32String): Bool {
        let data = arg1.toRuneArray()
        if (this.size != data.size) {
            return true
        }

        for (i in 0..this.size) {
            if (this[i] != data[i]) {
                return true
            }
        }
        return false
    }

    public operator func <(arg1: UTF32String): Bool {
        if (this.size < arg1.size) {
            return true
        }

        for (i in 0..this.size) {
            if (this[i] < arg1[i]) {
                return true
            }
        }
        return false
    }

    public operator func >(arg1: UTF32String): Bool {
        if (this.size > arg1.size) {
            return true
        }

        for (i in 0..this.size) {
            if (this[i] > arg1[i]) {
                return true
            }
        }
        return false
    }

    public operator func +(arg1: UTF32String): UTF32String {
        var data1 = this.toRuneArray()
        var data2 = arg1.toRuneArray()
        var newArray = Array<Rune>(data1.size + data2.size, item: r' ')

        data1.copyTo(newArray, 0, 0, data1.size)
        data2.copyTo(newArray, 0, data1.size, data2.size)
        return UTF32String(newArray);
    }
}