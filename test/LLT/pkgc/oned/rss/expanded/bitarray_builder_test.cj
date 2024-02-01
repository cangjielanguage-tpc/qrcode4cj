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

// DEPENDENCE: ./binary_util.cj
// EXEC: cjc %import-path %L %l %f binary_util.cj
// EXEC: ./main

from QRCode4cj import zxing.code.tools.*
from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.oned.*
from QRCode4cj import zxing.code.oned.rss.*
from QRCode4cj import zxing.code.oned.rss.expanded.*
from QRCode4cj import zxing.code.oned.rss.expanded.decoders.*
from QRCode4cj import zxing.code.client.result.*
from QRCode4cj import zxing.code.common.reader.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import regex.*
from std import collection.*
from std import convert.*
from std import fs.*
from std import log.*
from std import os.posix.*
from charset import charset.tools.UTF32String
from std import unittest.*
from std import unittest.testmacro.*


main(): Int64 {
    let tester = BitArrayBuilderTest()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
@Test
public class BitArrayBuilderTest {
    @TestCase
    public func testBuildBitArray1(): Unit {
        let pairValues: Array<Array<Int64>> = [[19], [673, 16]]

        let expected: String = " .......X ..XX..X. X.X....X .......X ....";

        checkBinary(pairValues, expected);
    }

    private static func checkBinary(pairValues: Array<Array<Int64>>, expected: String) {
        var binary: BitArray = buildBitArray(pairValues);
        @Expect(expected, binary.toString())
    }

    private static func buildBitArray(pairValues: Array<Array<Int64>>): BitArray {
        let pairs: ArrayList<ExpandedPair> = ArrayList<ExpandedPair>()
        for (i in 0..pairValues.size) {
            var pair: Array<Int64> = pairValues[i]

            var leftChar: DataCharacter
            if (i == 0) {
                leftChar = DataCharacter()
            } else {
                leftChar = DataCharacter(pair[0], 0)
            }

            var rightChar: DataCharacter
            if (i == 0) {
                rightChar = DataCharacter(pair[0], 0)
            } else if (pair.size == 2) {
                rightChar = DataCharacter(pair[1], 0)
            } else {
                rightChar = DataCharacter()
            }

            var expandedPair: ExpandedPair = ExpandedPair(leftChar, rightChar, FinderPattern());

            pairs.append(expandedPair);
        }

        return BitArrayBuilder.buildBitArray(pairs);
    }
}
