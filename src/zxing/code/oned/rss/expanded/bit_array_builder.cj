/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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
