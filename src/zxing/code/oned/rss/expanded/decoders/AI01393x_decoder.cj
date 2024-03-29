/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned.rss.expanded.decoders

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
class AI01393xDecoder <: AI01decoder {
    private static var HEADER_SIZE: Int64 = 5 + 1 + 2
    private static var LAST_DIGIT_SIZE: Int64 = 2;
    private static var FIRST_THREE_DIGITS_SIZE: Int64 = 10;

    init(information: BitArray) {
        super(information);
    }

    public func parseInformation(): String {
        if (this.getInformation().getSize() < HEADER_SIZE + GTIN_SIZE) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var buf: ArrayList<Char> = ArrayList<Char>();

        encodeCompressedGtin(buf, HEADER_SIZE);

        var lastAIdigit: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(
            HEADER_SIZE + GTIN_SIZE,
            LAST_DIGIT_SIZE
        );

        buf.appendAll("(393".toRuneArray());
        buf.appendAll(lastAIdigit.toString().toRuneArray());
        buf.append(')');

        var firstThreeDigits: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(
            HEADER_SIZE + GTIN_SIZE + LAST_DIGIT_SIZE, FIRST_THREE_DIGITS_SIZE);
        if (firstThreeDigits / 100 == 0) {
            buf.append('0');
        }
        if (firstThreeDigits / 10 == 0) {
            buf.append('0');
        }
        buf.appendAll(firstThreeDigits.toString().toRuneArray());

        var generalInformation: DecodedInformation = this.getGeneralDecoder().decodeGeneralPurposeField(
            HEADER_SIZE + GTIN_SIZE + LAST_DIGIT_SIZE + FIRST_THREE_DIGITS_SIZE, "");
        buf.appendAll(generalInformation.getNewString().toRuneArray());

        return String(buf);
    }
}
