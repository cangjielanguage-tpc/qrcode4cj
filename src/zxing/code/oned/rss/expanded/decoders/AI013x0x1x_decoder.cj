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
            throw NotFoundException.getNotFoundInstance();
        }

        var buf: ArrayList<Char> = ArrayList<Char>();

        encodeCompressedGtin(buf, HEADER_SIZE);
        encodeCompressedWeight(buf, HEADER_SIZE + GTIN_SIZE, WEIGHT_SIZE);
        encodeCompressedDate(buf, HEADER_SIZE + GTIN_SIZE + WEIGHT_SIZE);

        return String(buf);
    }

    private func encodeCompressedDate(buf: ArrayList<Char>, currentPos: Int64) {
        var numericDate: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(currentPos, DATE_SIZE);
        if (numericDate == 38400) {
            return;
        }

        buf.append('(');
        buf.appendAll(this.dateCode.toRuneArray());
        buf.append(')');

        var day: Int64 = numericDate % 32
        numericDate /= 32
        var month: Int64 = numericDate % 12 + 1
        numericDate /= 12
        var year: Int64 = numericDate

        if (year / 10 == 0) {
            buf.append('0');
        }
        buf.appendAll(year.toString().toRuneArray());
        if (month / 10 == 0) {
            buf.append('0');
        }
        buf.appendAll(month.toString().toRuneArray());
        if (day / 10 == 0) {
            buf.append('0');
        }
        buf.appendAll(day.toString().toRuneArray());
    }

    //@Override
    protected func addWeightCode(bufin: ArrayList<Char>, weight: Int64): Unit {
        bufin.append('(');
        bufin.appendAll(this.firstAIdigits.toString().toRuneArray());
        bufin.appendAll((weight / 100000).toString().toRuneArray());
        bufin.append(')');
    }

    //@Override
    protected func checkWeight(weight: Int64): Int64 {
        return weight % 100000
    }
}
