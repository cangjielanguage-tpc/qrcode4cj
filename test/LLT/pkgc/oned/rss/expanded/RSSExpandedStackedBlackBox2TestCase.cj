// DEPENDENCE: ../../../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../../../common/test_result.cj
// DEPENDENCE: ../../../../test_common.cj
// DEPENDENCE: ../../../../resources/blackbox/rssexpandedstacked-2
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
    let tester = RSSExpandedStackedBlackBox2TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * A test of {@link RSSExpandedReader} against a fixed test set of images including
 * stacked RSS barcodes.
 */
@Test
public class RSSExpandedStackedBlackBox2TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./rssexpandedstacked-2",
            MultiFormatReader(),
            BarcodeFormat.RSS_EXPANDED
        )
        abs.addTest(2, 7, 0.0)
        abs.addTest(2, 7, 180.0)
        abs.testBlackBox()
    }
}
