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
abstract class AI01weightDecoder <: AI01decoder {
    init(information: BitArray) {
        super(information);
    }

    func encodeCompressedWeight(buf: ArrayList<Char>, currentPos: Int64, weightSize: Int64) {
        var originalWeightNumeric: Int64 = this.getGeneralDecoder().extractNumericValueFromBitArray(
            currentPos,
            weightSize
        );
        addWeightCode(buf, originalWeightNumeric);

        var weightNumeric: Int64 = checkWeight(originalWeightNumeric);

        var currentDivisor: Int64 = 100000;

        for (i in 0..5) {
            if (weightNumeric / currentDivisor == 0) {
                buf.append('0');
            }
            currentDivisor /= 10
        }
        buf.appendAll(weightNumeric.toString().toRuneArray());
    }

    protected func addWeightCode(buf: ArrayList<Char>, weight: Int64): Unit

    protected func checkWeight(weight: Int64): Int64
}
