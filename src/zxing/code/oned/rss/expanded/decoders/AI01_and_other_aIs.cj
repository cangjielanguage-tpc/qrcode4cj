/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.oned.rss.expanded.decoders

import zxing.code.tools.UTF32String

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
class AI01AndOtherAIs <: AI01decoder {
    private static var HEADER_SIZE: Int64 = 1 + 1 + 2

    //first bit encodes the linkage flag,
    //the second one is the encodation method, and the other two are for the variable length
    init(information: BitArray) {
        super(information);
    }

    public func parseInformation(): String {
        var buff: ArrayList<Char> = ArrayList<Char>();

        buff.appendAll("(01)".toRuneArray());
        var initialGtinPosition: Int64 = buff.size;
        var firstGtinDigit: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(HEADER_SIZE, 4);
        buff.appendAll(firstGtinDigit.toString().toRuneArray());

        this.encodeCompressedGtinWithoutAI(buff, HEADER_SIZE + 4, initialGtinPosition);
        var a = this.getGeneralDecoder().decodeAllCodes(buff, HEADER_SIZE + 44)

        return a;
    }
}
