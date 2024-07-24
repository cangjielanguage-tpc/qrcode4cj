/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.common.*

abstract class AI01weightDecoder <: AI01decoder {
    init(information: BitArray) {
        super(information);
    }

    func encodeCompressedWeight(buf: ArrayList<Rune>, currentPos: Int64, weightSize: Int64) {
        var originalWeightNumeric: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(
            currentPos,
            weightSize
        );
        addWeightCode(buf, originalWeightNumeric);

        var weightNumeric: Int64 = checkWeight(originalWeightNumeric);

        var currentDivisor: Int64 = 100000;

        for (i in 0..5) {
            if (weightNumeric / currentDivisor == 0) {
                buf.append(r'0');
            }
            currentDivisor /= 10
        }
        buf.appendAll(weightNumeric.toString().toRuneArray());
    }

    protected func addWeightCode(buf: ArrayList<Rune>, weight: Int64): Unit

    protected func checkWeight(weight: Int64): Int64
}
