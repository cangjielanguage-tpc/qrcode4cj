/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned.rss.expanded.decoders

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
class AI013103decoder <: AI013x0xDecoder {
    init(information: BitArray) {
        super(information);
    }

    protected func addWeightCode(buf: ArrayList<Char>, weight: Int64): Unit {
        buf.appendAll("(3103)".toRuneArray());
    }

    protected func checkWeight(weight: Int64): Int64 {
        return weight
    }
}
