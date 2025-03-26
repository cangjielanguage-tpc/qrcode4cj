/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.common.*

abstract class AI013x0xDecoder <: AI01weightDecoder {
    private static var HEADER_SIZE: Int64 = 4 + 1
    private static var WEIGHT_SIZE: Int64 = 15;

    init(information: BitArray) {
        super(information);
    }

    public func parseInformation(): String {
        if (this.getInformation().getSize() != HEADER_SIZE + GTIN_SIZE + WEIGHT_SIZE) {
            throw Qrcoder4cjNotFoundException()
        }

        var buf: ArrayList<Rune> = ArrayList<Rune>();

        encodeCompressedGtin(buf, HEADER_SIZE);
        encodeCompressedWeight(buf, HEADER_SIZE + GTIN_SIZE, WEIGHT_SIZE);

        return String(buf);
    }
}
