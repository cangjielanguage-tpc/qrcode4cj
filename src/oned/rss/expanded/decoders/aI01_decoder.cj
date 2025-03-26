/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

import std.collection.*
import QRCode4cj.common.*

abstract class AI01decoder <: AbstractExpandedDecoder {
    static let GTIN_SIZE: Int64 = 40;

    init(information: BitArray) {
        super(information);
    }

    func encodeCompressedGtin(buf: ArrayList<Rune>, currentPos: Int64) {
        buf.add(all:"(01)".toRuneArray());
        var initialPosition: Int64 = buf.size;
        buf.add(r'9');

        encodeCompressedGtinWithoutAI(buf, currentPos, initialPosition);
    }

    func encodeCompressedGtinWithoutAI(buf: ArrayList<Rune>, currentPos: Int64, initialBufferPosition: Int64) {
        for (i in 0..4) {
            var currentBlock: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(currentPos + 10 * i, 10);
            if (currentBlock / 100 == 0) {
                buf.add(r'0');
            }
            if (currentBlock / 10 == 0) {
                buf.add(r'0');
            }
            buf.add(all:currentBlock.toString().toRuneArray());
        }

        appendCheckDigit(buf, initialBufferPosition);
    }

    private static func appendCheckDigit(buf: ArrayList<Rune>, currentPos: Int64) {
        var checkDigit: Int64 = 0;

        for (i in 0..13) {
            var digit: Int64 = buf[i + currentPos].hashCode() - r'0'.hashCode()
            checkDigit += if ((i & 0x01) == 0) {
                3 * digit
            } else {
                digit
            }
        }

        checkDigit = 10 - (checkDigit % 10)
        if (checkDigit == 10) {
            checkDigit = 0
        }

        buf.add(all:checkDigit.toString().toRuneArray());
    }
}
