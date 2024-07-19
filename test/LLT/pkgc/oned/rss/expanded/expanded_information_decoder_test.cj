// DEPENDENCE: ./binary_util.cj
// EXEC: cjc %import-path %L %l %f binary_util.cj
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
import QRCode4cj.tools.UTF32String
import std.unittest.*
import std.unittest.testmacro.*


main(): Int64 {
    let tester = ExpandedInformationDecoderTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class ExpandedInformationDecoderTest {
    @TestCase
    public func testNoAi(): Unit {
        let information: BitArray = BinaryUtil.buildBitArrayFromString(" .......X ..XX..X. X.X....X .......X ....");

        let decoder: AbstractExpandedDecoder = AbstractExpandedDecoder.createDecoder(information);
        let decoded: String = decoder.parseInformation();
        @Expect("(10)12A", decoded)
    }
}
