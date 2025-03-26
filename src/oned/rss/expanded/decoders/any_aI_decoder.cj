/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.common.*

class AnyAIDecoder <: AbstractExpandedDecoder {
    private static var HEADER_SIZE: Int64 = 2 + 1 + 2

    init(information: BitArray) {
        super(information);
    }

    public func parseInformation(): String {
        var buf: ArrayList<Rune> = ArrayList<Rune>();
        return this.getGeneralDecoder().decodeAllCodes(buf, HEADER_SIZE);
    }
}
