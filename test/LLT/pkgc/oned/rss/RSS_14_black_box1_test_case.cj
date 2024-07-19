
// DEPENDENCE: ../../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../../common/test_result.cj
// DEPENDENCE: ../../../test_common.cj
// DEPENDENCE: ../../../resources/blackbox/rss14-1
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
    let tester = RSS14BlackBox1TestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class RSS14BlackBox1TestCase {
    @TestCase
    public func dotest(): Unit {
        var abs: AbstractBlackBoxTestCase = AbstractBlackBoxTestCase(
            "./rss14-1",
            MultiFormatReader(),
            BarcodeFormat.RSS_14
        )
        abs.addTest(6, 6, 0.0);
        abs.addTest(6, 6, 180.0);
        abs.testBlackBox()
    }
}
