// DEPENDENCE: ../../../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../../../common/test_result.cj
// DEPENDENCE: ../../../../test_common.cj
// DEPENDENCE: ../../../../resources/blackbox/rssexpanded-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.tools.*
import QRCode4cj.common.*
import QRCode4cj.oned.*
import QRCode4cj.oned.rss.*
import QRCode4cj.oned.rss.expanded.*
import QRCode4cj.oned.rss.expanded.decoders.*
import QRCode4cj.client.result.*
import QRCode4cj.common.reader.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.regex.*
import std.collection.*
import std.convert.*
import std.fs.*
import std.log.*
import std.os.posix.*


main(): Int64 {
    let tester = RSSExpandedInternalTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

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
            // fail(Qrcoder4cjNotFoundException.class.getName() + " expected");
        } catch (nfe: Qrcoder4cjNotFoundException) {
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
