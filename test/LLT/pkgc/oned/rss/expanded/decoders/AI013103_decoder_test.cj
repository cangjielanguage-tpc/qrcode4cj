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
    let tester = AI013103DecoderTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class AI013103DecoderTest {
    private static let header: String = "..X..";

    @TestCase
    public func test0131031(): Unit {
        let data: String = header + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed15bitWeight1750
        let expected: String = "(01)90012345678908(3103)001750";
        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test0131032(): Unit {
        let data: String = header + AbstractDecoderTest.compressedGtin900000000000008 + AbstractDecoderTest.
            compressed15bitWeight0
        let expected: String = "(01)90000000000003(3103)000000";
        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test013103invalid(): Unit {
        let data: String = header + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed15bitWeight1750 + ".."

        AbstractDecoderTest.assertCorrectBinaryString(data, "");
    }
}
