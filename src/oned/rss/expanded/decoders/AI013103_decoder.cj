/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.common.*

class AI013103decoder <: AI013x0xDecoder {
    init(information: BitArray) {
        super(information);
    }

    protected func addWeightCode(buf: ArrayList<Rune>, _: Int64): Unit {
        buf.appendAll("(3103)".toRuneArray());
    }

    protected func checkWeight(weight: Int64): Int64 {
        return weight
    }
}
