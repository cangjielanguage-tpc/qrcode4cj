// DEPENDENCE: ./TestCaseUtil.cj
// DEPENDENCE: ../../../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../../../common/test_result.cj
// DEPENDENCE: ../../../../test_common.cj
// DEPENDENCE: ../../../../resources/blackbox/rssexpandedstacked-2
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj ./TestCaseUtil.cj
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
    let tester = RSSExpandedStackedInternalTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
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
        } catch (nfe: Qrcoder4cjNotFoundException) {
            // ok
        }

        @Assert(1, rssExpandedReader.getRows().size)
        var firstExpandedRow: ExpandedRow = rssExpandedReader.getRows().get(0).getOrThrow()
        @Assert(firstRowNumber, firstExpandedRow.getRowNumber())
        firstExpandedRow.hashCode()
        firstExpandedRow.equals(firstExpandedRow)
        @Assert("{ [ [ 913 ( 0 ) , 989 ( 883 ) : 0 ] ][ [ 3702 ( 1822 ) , 3207 ( 1919 ) : 2 ] ] }", firstExpandedRow.toString())

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
