/*
 * Copyright (C) 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

// DEPENDENCE: ./TestCaseUtil.cj
// DEPENDENCE: ../../../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../../../common/test_result.cj
// DEPENDENCE: ../../../../test_common.cj
// DEPENDENCE: ../../../../resources/blackbox/rssexpandedstacked-2
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj ./TestCaseUtil.cj
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


main(): Int64 {
    let tester = RSSExpandedStackedInternalTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link RSSExpandedReader} handling of stacked RSS barcodes.
 */
@Test
public class RSSExpandedStackedInternalTestCase {
    @TestCase
    public func testDecodingRowByRow(): Unit {
        var rssExpandedReader: RSSExpandedReader = RSSExpandedReader()

        var binaryMap: BinaryBitmap = TestCaseUtil.getBinaryBitmap(
            "./rssexpandedstacked-2",
            "1000.png"
        )

        var firstRowNumber: Int64 = binaryMap.getHeight() / 3
        var firstRow: BitArray = binaryMap.getBlackRow(firstRowNumber, BitArray())
        try {
            rssExpandedReader.decodeRow2pairs(firstRowNumber, firstRow)
        } catch (nfe: NotFoundException) {
            // ok
        }

        @Assert(1, rssExpandedReader.getRows().size)
        var firstExpandedRow: ExpandedRow = rssExpandedReader.getRows().get(0).getOrThrow()
        @Assert(firstRowNumber, firstExpandedRow.getRowNumber())

        @Assert(2, firstExpandedRow.getPairs().size)

        firstExpandedRow.getPairs().get(1).getOrThrow().getFinderPattern().getOrThrow().getStartEnd().set(1, 0)

        var secondRowNumber: Int64 = 2 * binaryMap.getHeight() / 3
        var secondRow: BitArray = binaryMap.getBlackRow(secondRowNumber, BitArray())
        secondRow.reverse()

        var totalPairs: ArrayList<ExpandedPair> = rssExpandedReader.decodeRow2pairs(secondRowNumber, secondRow)

        var result: Result = RSSExpandedReader.constructResult(totalPairs)
        @Assert("(01)98898765432106(3202)012345(15)991231", result.getText())
    }

    @TestCase
    public func testCompleteDecode(): Unit {
        var rssExpandedReader: OneDReader = RSSExpandedReader()

        var binaryMap: BinaryBitmap = TestCaseUtil.getBinaryBitmap(
            "./rssexpandedstacked-2",
            "1000.png"
        )

        var result: Result = rssExpandedReader.decode(binaryMap)
        @Assert("(01)98898765432106(3202)012345(15)991231", result.getText())
    }
}
