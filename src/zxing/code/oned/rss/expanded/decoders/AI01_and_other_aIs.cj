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

from charset import charset.tools.UTF32String

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
