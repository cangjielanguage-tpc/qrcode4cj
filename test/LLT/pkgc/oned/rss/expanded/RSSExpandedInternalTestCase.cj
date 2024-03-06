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

// DEPENDENCE: ../../../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../../../common/test_result.cj
// DEPENDENCE: ../../../../test_common.cj
// DEPENDENCE: ../../../../resources/blackbox/rssexpanded-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
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
    let tester = RSSExpandedInternalTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
@Test
public class RSSExpandedInternalTestCase {
    @TestCase
    public func testFindFinderPatterns(): Unit {
        var binaryMap: BinaryBitmap = readImage("2.png")
        var rowNumber: Int64 = binaryMap.getHeight() / 2
        var row: BitArray = binaryMap.getBlackRow(rowNumber, BitArray());

        var previousPairs: ArrayList<ExpandedPair> = ArrayList<ExpandedPair>();

        var rssExpandedReader: RSSExpandedReader = RSSExpandedReader();
        var pair1: ExpandedPair = rssExpandedReader.retrieveNextPair(row, previousPairs, rowNumber);
        previousPairs.append(pair1);
        var finderPattern = pair1.getFinderPattern();
        if (let Some(finderPattern_have) <- finderPattern) {
            @Assert(true)
        } else {
            @Assert(false)
        }

        @Assert(0, finderPattern.getOrThrow().getValue())

        var pair2: ExpandedPair = rssExpandedReader.retrieveNextPair(row, previousPairs, rowNumber);
        previousPairs.append(pair2);
        finderPattern = pair2.getFinderPattern()

        if (let Some(finderPattern_have) <- finderPattern) {
            @Assert(true)
        } else {
            @Assert(false)
        }
        @Assert(1, finderPattern.getOrThrow().getValue())

        var pair3: ExpandedPair = rssExpandedReader.retrieveNextPair(row, previousPairs, rowNumber);
        previousPairs.append(pair3);
        finderPattern = pair3.getFinderPattern()

        if (let Some(finderPattern_have) <- finderPattern) {
            @Assert(true)
        } else {
            @Assert(false)
        }
        @Assert(1, finderPattern.getOrThrow().getValue())

        try {
            rssExpandedReader.retrieveNextPair(row, previousPairs, rowNumber);
            //   the previous was the last pair
            // fail(NotFoundException.class.getName() + " expected");
        } catch (nfe: NotFoundException) {
            // ok
        }
    }

    @TestCase
    public func testRetrieveNextPairPatterns(): Unit {
        var binaryMap: BinaryBitmap = readImage("3.png")
        var rowNumber: Int64 = binaryMap.getHeight() / 2
        var row: BitArray = binaryMap.getBlackRow(rowNumber, BitArray());

        var previousPairs: ArrayList<ExpandedPair> = ArrayList<ExpandedPair>()

        var rssExpandedReader: RSSExpandedReader = RSSExpandedReader();
        var pair1: ExpandedPair = rssExpandedReader.retrieveNextPair(row, previousPairs, rowNumber);
        previousPairs.append(pair1);
        var finderPattern = pair1.getFinderPattern();
        if (let Some(finderPattern_have) <- finderPattern) {
            @Assert(true)
        } else {
            @Assert(false)
        }
        var test1 = finderPattern.getOrThrow().getValue()
        @Assert(0, test1)

        var pair2: ExpandedPair = rssExpandedReader.retrieveNextPair(row, previousPairs, rowNumber);
        previousPairs.append(pair2);
        finderPattern = pair2.getFinderPattern()
        if (let Some(finderPattern_have) <- finderPattern) {
            @Assert(true)
        } else {
            @Assert(false)
        }

        @Assert(0, finderPattern.getOrThrow().getValue())
    }

    @TestCase
    public func testDecodeCheckCharacter(): Unit {
        var binaryMap: BinaryBitmap = readImage("3.png")
        var rowNumber: Int64 = binaryMap.getHeight() / 2
        var row: BitArray = binaryMap.getBlackRow(rowNumber, BitArray());
        var startEnd: Array<Int64> = [145, 243]

        //image pixels where the A1 pattern starts (at 124) and ends (at 214)
        var value: Int64 = 0; // A
        var finderPatternA1: FinderPattern = FinderPattern(
            value,
            startEnd,
            startEnd[0],
            startEnd[1],
            rowNumber
        );

        var rssExpandedReader: RSSExpandedReader = RSSExpandedReader();
        var dataCharacter: DataCharacter = rssExpandedReader.decodeDataCharacter(row, finderPatternA1, true, true);

        @Assert(98, dataCharacter.getValue())
    }

    @TestCase
    public func testDecodeDataCharacter(): Unit {
        var binaryMap: BinaryBitmap = readImage("3.png")
        var rowNumber: Int64 = binaryMap.getHeight() / 2
        var row: BitArray = binaryMap.getBlackRow(rowNumber, BitArray());
        var startEnd: Array<Int64> = [145, 243] //image pixels where the A1 pattern starts (at 124) and ends (at 214)
        var value: Int64 = 0; // A
        var finderPatternA1: FinderPattern = FinderPattern(
            value,
            startEnd,
            startEnd[0],
            startEnd[1],
            rowNumber
        );

        var rssExpandedReader: RSSExpandedReader = RSSExpandedReader();
        var dataCharacter: DataCharacter = rssExpandedReader.decodeDataCharacter(row, finderPatternA1, true, false);

        @Assert(19, dataCharacter.getValue())
        @Assert(1007, dataCharacter.getChecksumPortion())
    }
    private static func readImage(fileName: String): BinaryBitmap {
        var path: Path = AbstractBlackBoxTestCase.buildTestBase("./rssexpanded-1").join(fileName)

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(path.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        let bounds = imagei.bounds()
        let sW = bounds.dx()
        let sH = bounds.dy()

        var binaryMap: BinaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(BufferedImageLuminanceSource(imagei)));
        return binaryMap
    }
}
