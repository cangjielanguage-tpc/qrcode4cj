/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package common

public interface ECIInput <: ToString {
    func length(): Int64

    func charAt(index: Int64): Char

    func subSequence(start: Int64, end: Int64): UTF32String

    func isECI(index: Int64): Bool

    func getECIValue(index: Int64): Int64
    func haveNCharacters(index: Int64, n: Int64): Bool

    func toString(): String
}
