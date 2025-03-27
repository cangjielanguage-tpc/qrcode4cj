/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.common.*

class AI01392xDecoder <: AI01decoder {
    private static var HEADER_SIZE: Int64 = 5 + 1 + 2
    private static var LAST_DIGIT_SIZE: Int64 = 2;

    init(information: BitArray) {
        super(information);
    }

    public func parseInformation(): String {
        if (this.getInformation().getSize() < HEADER_SIZE + GTIN_SIZE) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var buf: ArrayList<Rune> = ArrayList<Rune>();

        encodeCompressedGtin(buf, HEADER_SIZE);

        var lastAIdigit: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(
            HEADER_SIZE + GTIN_SIZE,
            LAST_DIGIT_SIZE
        );
        buf.add(all:"(392".toRuneArray());
        buf.add(all:lastAIdigit.toString().toRuneArray());
        buf.add(r')');

        var decodedInformation: DecodedInformation = this.getGeneralDecoder().decodeGeneralPurposeField(
            HEADER_SIZE + GTIN_SIZE + LAST_DIGIT_SIZE, "");
        buf.add(all:decodedInformation.getNewString().toRuneArray());

        return String(buf);
    }
}
