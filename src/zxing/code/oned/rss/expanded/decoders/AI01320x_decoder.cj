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
class AI01320xDecoder <: AI013x0xDecoder {
    init(information: BitArray) {
        super(information);
    }

    protected func addWeightCode(buf: ArrayList<Char>, weight: Int64): Unit {
        if (weight < 10000) {
            buf.appendAll("(3202)".toRuneArray());
        } else {
            buf.appendAll("(3203)".toRuneArray());
        }
    }

    //@Override
    protected func checkWeight(weight: Int64): Int64 {
        if (weight < 10000) {
            return weight
        }
        return weight - 10000
    }
}
