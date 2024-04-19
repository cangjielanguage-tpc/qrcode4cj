/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded.decoders

class AI013103decoder <: AI013x0xDecoder {
    init(information: BitArray) {
        super(information);
    }

    protected func addWeightCode(buf: ArrayList<Char>, _: Int64): Unit {
        buf.appendAll("(3103)".toRuneArray());
    }

    protected func checkWeight(weight: Int64): Int64 {
        return weight
    }
}
