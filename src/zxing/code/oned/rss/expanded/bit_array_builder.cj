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

package zxing.code.oned.rss.expanded

import zxing.code.common.*
from std import collection.*

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
public class BitArrayBuilder {
    private init() {}

    public static func buildBitArray(pairs: ArrayList<ExpandedPair>): BitArray {
        var charNumber: Int64 = (pairs.size * 2) - 1
        if (let None <- pairs.get(pairs.size - 1).getOrThrow().getRightChar()) {
            charNumber -= 1
        }

        var size: Int64 = 12 * charNumber

        var binary: BitArray = BitArray(size);
        var accPos: Int64 = 0;

        var firstPair: ExpandedPair = pairs.get(0).getOrThrow();
        var firstValue: Int64 = firstPair.getRightChar().getOrThrow().getValue();

        for (i in 11..-1 : -1) {
            if ((firstValue & (1 << i)) != 0) {
                binary.set(accPos);
            }
            accPos++
        }

        for (i in 1..pairs.size) {
            var currentPair: ExpandedPair = pairs.get(i).getOrThrow();

            var leftValue: Int64 = currentPair.getLeftChar().getOrThrow().getValue();

            for (j in 11..-1 : -1) {
                if ((leftValue & (1 << j)) != 0) {
                    binary.set(accPos);
                }
                accPos++
            }

            if (let Some(c) <- currentPair.getRightChar()) {
                var rightValue: Int64 = c.getValue();
                for (j in 11..-1 : -1) {
                    if ((rightValue & (1 << j)) != 0) {
                        binary.set(accPos);
                    }
                    accPos++
                }
            }
        }
        return binary
    }
}
