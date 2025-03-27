/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.common.*

class AI013x0x1xDecoder <: AI01weightDecoder {
    private static var HEADER_SIZE: Int64 = 7 + 1
    private static var WEIGHT_SIZE: Int64 = 20;
    private static var DATE_SIZE: Int64 = 16;

    private var dateCode: String
    private var firstAIdigits: String

    init(information: BitArray, firstAIdigits: String, dateCode: String) {
        super(information);
        this.dateCode = dateCode
        this.firstAIdigits = firstAIdigits
    }

    public func parseInformation(): String {
        if (this.getInformation().getSize() != HEADER_SIZE + GTIN_SIZE + WEIGHT_SIZE + DATE_SIZE) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var buf: ArrayList<Rune> = ArrayList<Rune>();

        encodeCompressedGtin(buf, HEADER_SIZE);
        encodeCompressedWeight(buf, HEADER_SIZE + GTIN_SIZE, WEIGHT_SIZE);
        encodeCompressedDate(buf, HEADER_SIZE + GTIN_SIZE + WEIGHT_SIZE);

        return String(buf);
    }

    private func encodeCompressedDate(buf: ArrayList<Rune>, currentPos: Int64) {
        var numericDate: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(currentPos, DATE_SIZE);
        if (numericDate == 38400) {
            return;
        }

        buf.add(r'(');
        buf.add(all:this.dateCode.toRuneArray());
        buf.add(r')');

        var day: Int64 = numericDate % 32
        numericDate /= 32
        var month: Int64 = numericDate % 12 + 1
        numericDate /= 12
        var year: Int64 = numericDate

        if (year / 10 == 0) {
            buf.add(r'0');
        }
        buf.add(all:year.toString().toRuneArray());
        if (month / 10 == 0) {
            buf.add(r'0');
        }
        buf.add(all:month.toString().toRuneArray());
        if (day / 10 == 0) {
            buf.add(r'0');
        }
        buf.add(all:day.toString().toRuneArray());
    }

    //@Override
    protected func addWeightCode(bufin: ArrayList<Rune>, weight: Int64): Unit {
        bufin.add(r'(');
        bufin.add(all:this.firstAIdigits.toString().toRuneArray());
        bufin.add(all:(weight / 100000).toString().toRuneArray());
        bufin.add(r')');
    }

    //@Override
    protected func checkWeight(weight: Int64): Int64 {
        return weight % 100000
    }
}
