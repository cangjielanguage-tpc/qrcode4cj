// DEPENDENCE: ./abstract_decoder_test.cj
// DEPENDENCE: ../binary_util.cj
// EXEC: cjc %import-path %L %l %f abstract_decoder_test.cj binary_util.cj
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
    let tester = AI0132023203DecoderTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class AI0132023203DecoderTest {
    private static let header: String = "..X.X";

    @TestCase
    public func test0132021(): Unit {
        let data: String = header + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed15bitWeight1750
        let expected: String = "(01)90012345678908(3202)001750";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test0132031(): Unit {
        let data: String = header + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed15bitWeight11750
        let expected: String = "(01)90012345678908(3203)001750";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }
}
