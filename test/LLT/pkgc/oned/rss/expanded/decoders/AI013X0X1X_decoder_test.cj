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
    let tester = AI013X0X1XDecoderTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class AI013X0X1XDecoderTest {
    private static let header310x11: String = "..XXX...";
    private static let header320x11: String = "..XXX..X";
    private static let header310x13: String = "..XXX.X.";
    private static let header320x13: String = "..XXX.XX";
    private static let header310x15: String = "..XXXX..";
    private static let header320x15: String = "..XXXX.X";
    private static let header310x17: String = "..XXXXX.";
    private static let header320x17: String = "..XXXXXX";

    @TestCase
    public func test01310X1XendDate(): Unit {
        let data: String = header310x11 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateEnd
        let expected: String = "(01)90012345678908(3100)001750";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01310X111(): Unit {
        let data: String = header310x11 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3100)001750(11)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01320X111(): Unit {
        let data: String = header320x11 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3200)001750(11)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01310X131(): Unit {
        let data: String = header310x13 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3100)001750(13)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01320X131(): Unit {
        let data: String = header320x13 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3200)001750(13)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01310X151(): Unit {
        let data: String = header310x15 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3100)001750(15)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01320X151(): Unit {
        let data: String = header320x15 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3200)001750(15)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01310X171(): Unit {
        let data: String = header310x17 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3100)001750(17)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01320X171(): Unit {
        let data: String = header320x17 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3200)001750(17)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }
}
