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
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
abstract class AI01decoder <: AbstractExpandedDecoder {
    static let GTIN_SIZE: Int64 = 40;

    init(information: BitArray) {
        super(information);
    }

    func encodeCompressedGtin(buf: ArrayList<Char>, currentPos: Int64) {
        buf.appendAll("(01)".toRuneArray());
        var initialPosition: Int64 = buf.size;
        buf.append('9');

        encodeCompressedGtinWithoutAI(buf, currentPos, initialPosition);
    }

    func encodeCompressedGtinWithoutAI(buf: ArrayList<Char>, currentPos: Int64, initialBufferPosition: Int64) {
        for (i in 0..4) {
            var currentBlock: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(currentPos + 10 * i, 10);
            if (currentBlock / 100 == 0) {
                buf.append('0');
            }
            if (currentBlock / 10 == 0) {
                buf.append('0');
            }
            buf.appendAll(currentBlock.toString().toRuneArray());
        }

        appendCheckDigit(buf, initialBufferPosition);
    }

    private static func appendCheckDigit(buf: ArrayList<Char>, currentPos: Int64) {
        var checkDigit: Int64 = 0;

        for (i in 0..13) {
            var digit: Int64 = buf[i + currentPos].hashCode() - '0'.hashCode()
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

        buf.appendAll(checkDigit.toString().toRuneArray());
    }
}
