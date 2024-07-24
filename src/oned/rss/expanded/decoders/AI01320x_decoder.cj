/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.common.*

class AI01320xDecoder <: AI013x0xDecoder {
    init(information: BitArray) {
        super(information);
    }

    protected func addWeightCode(buf: ArrayList<Rune>, weight: Int64): Unit {
        if (weight < 10000) {
            buf.appendAll("(3202)".toRuneArray());
        } else {
            buf.appendAll("(3203)".toRuneArray());
        }
    }

    //@Override
    protected func checkWeight(weight: Int64): Int64 {
        if (weight < 10000) {
            return weight
        }
        return weight - 10000
    }
}
