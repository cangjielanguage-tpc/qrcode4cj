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
    let tester = RSSExpandedImage2resultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class RSSExpandedImage2resultTestCase {
    @TestCase
    public func testDecodeRow2result2(): Unit {
        // (01)90012345678908(3103)001750
        var expected: ExpandedProductParsedResult = ExpandedProductParsedResult(
            "(01)90012345678908(3103)001750",
            "90012345678908",
            "",
            "",
            "",
            "",
            "",
            "",
            "001750",
            ExpandedProductParsedResult.KILOGRAM,
            "3",
            "",
            "",
            "",
            HashMap<String, String>()
        );

        assertCorrectImage2result("2.png", expected);
    }

    private static func assertCorrectImage2result(fileName: String, expected: ExpandedProductParsedResult) {
        var path: Path = AbstractBlackBoxTestCase.buildTestBase("./rssexpanded-1").join(fileName)

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(path.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        var binaryMap: BinaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(BufferedImageLuminanceSource(imagei)));
        var rowNumber: Int64 = binaryMap.getHeight() / 2
        var row: BitArray = binaryMap.getBlackRow(rowNumber, BitArray());

        var theResult: Result
        try {
            var rssExpandedReader: RSSExpandedReader = RSSExpandedReader();
            theResult = rssExpandedReader.decodeRow(rowNumber, row, HashMap<DecodeHintType, Any>())
        } catch (re: Qrcoder4cjReaderException) {
            return;
        }

        @Expect(BarcodeFormat.RSS_EXPANDED, theResult.getBarcodeFormat())

        var result: ParsedResult = ResultParser.parseResult(theResult)
        var result_txt: String = result.toString()
        var expected_txt: String = expected.toString()
        @Expect(expected_txt, result_txt)
    }
}
