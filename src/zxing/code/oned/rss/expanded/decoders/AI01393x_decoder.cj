/*
 * Copyright (C) 2010 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", led by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 * http://www.piramidepse.com/
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
            throw NotFoundException.getNotFoundInstance();
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
