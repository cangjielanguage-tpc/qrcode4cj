/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.tools.UTF32String
import QRCode4cj.common.*

class AI01AndOtherAIs <: AI01decoder {
    private static var HEADER_SIZE: Int64 = 1 + 1 + 2

    //first bit encodes the linkage flag,
    //the second one is the encodation method, and the other two are for the variable length
    init(information: BitArray) {
        super(information);
    }

    public func parseInformation(): String {
        var buff: ArrayList<Rune> = ArrayList<Rune>();

        buff.add(all:"(01)".toRuneArray());
        var initialGtinPosition: Int64 = buff.size;
        var firstGtinDigit: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(HEADER_SIZE, 4);
        buff.add(all:firstGtinDigit.toString().toRuneArray());

        this.encodeCompressedGtinWithoutAI(buff, HEADER_SIZE + 4, initialGtinPosition);
        var a = this.getGeneralDecoder().decodeAllCodes(buff, HEADER_SIZE + 44)

        return a;
    }
}
