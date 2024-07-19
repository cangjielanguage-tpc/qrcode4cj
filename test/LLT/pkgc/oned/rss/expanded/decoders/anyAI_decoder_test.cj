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
    let tester = AnyAIDecoderTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class AnyAIDecoderTest {
    private static let header: String = ".....";

    @TestCase
    public func testAnyAIDecoder1(): Unit {
        let data: String = header + AbstractDecoderTest.numeric10 + AbstractDecoderTest.numeric12 + AbstractDecoderTest.
            numeric2alpha + AbstractDecoderTest.alphaA + AbstractDecoderTest.alpha2numeric + AbstractDecoderTest.
            numeric12
        let expected: String = "(10)12A12";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func testAnyAIDecoder2(): Unit {
        let data: String = header + AbstractDecoderTest.numeric10 + AbstractDecoderTest.numeric12 + AbstractDecoderTest.
            numeric2alpha + AbstractDecoderTest.alphaA + AbstractDecoderTest.alpha2isoiec646 + AbstractDecoderTest.i646B
        let expected: String = "(10)12AB";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func testAnyAIDecoder3(): Unit {
        let data: String = header + AbstractDecoderTest.numeric10 + AbstractDecoderTest.numeric2alpha +
            AbstractDecoderTest.alpha2isoiec646 + AbstractDecoderTest.i646B + AbstractDecoderTest.i646C +
            AbstractDecoderTest.isoiec6462alpha + AbstractDecoderTest.alphaA + AbstractDecoderTest.alpha2numeric +
            AbstractDecoderTest.numeric10
        let expected: String = "(10)BCA10";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func testAnyAIDecodernumericFNC1secondDigit(): Unit {
        let data: String = header + AbstractDecoderTest.numeric10 + AbstractDecoderTest.numeric1FNC1
        let expected: String = "(10)1";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func testAnyAIDecoderalphaFNC1(): Unit {
        let data: String = header + AbstractDecoderTest.numeric10 + AbstractDecoderTest.numeric2alpha +
            AbstractDecoderTest.alphaA + AbstractDecoderTest.alphaFNC1
        let expected: String = "(10)A";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func testAnyAIDecoder646FNC1(): Unit {
        let data: String = header + AbstractDecoderTest.numeric10 + AbstractDecoderTest.numeric2alpha +
            AbstractDecoderTest.alphaA + AbstractDecoderTest.isoiec6462alpha + AbstractDecoderTest.i646B +
            AbstractDecoderTest.i646FNC1
        let expected: String = "(10)AB";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }
}
