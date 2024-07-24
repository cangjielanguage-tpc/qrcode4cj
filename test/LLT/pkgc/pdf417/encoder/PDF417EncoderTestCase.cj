// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.Qrcoder4cjWriterException
import QRCode4cj.common.StandardCharsets
import QRCode4cj.pdf417.encoder.*
import QRCode4cj.pdf417.decoder.*
import QRCode4cj.common.MyCharset
import QRCode4cj.tools.UTF32String
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.fs.*
import std.math.*
import std.random.*
import std.collection.*
import std.convert.*

main(): Int64 {
    let tester = PDF417EncoderTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link PDF417HighLevelEncoder}.
 */
@Test
public class PDF417EncoderTestCase {
    @TestCase
    public func testEncodeAuto(): Unit {
        let encoded: String = PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("ABCD"),
            Compaction.AUTO,
            StandardCharsets.UTF_8,
            false
        ).toString();
        @Assert("\u{039f}\u{001A}\u{0385}ABCD", encoded)
    }

    @TestCase
    public func testEncodeAutoWithSpecialChars(): Unit {
        // Just check if this does not throw an exception
        PDF417HighLevelEncoder.encodeHighLevel(UTF32String("1%§s ?aG$"), Compaction.AUTO, StandardCharsets.UTF_8, false
        );
    }

    @TestCase
    public func testEncodeIso88591WithSpecialChars(): Unit {
        // Just check if this does not throw an exception
        PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("asdfg§asd"),
            Compaction.AUTO,
            StandardCharsets.ISO_8859_1,
            false
        );
    }

    @TestCase
    public func testEncodeText(): Unit {
        let encoded: String = PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("ABCD"),
            Compaction.TEXT,
            StandardCharsets.UTF_8,
            false
        ).toString();
        @Assert("Ο\u{001A}\u{0001}?", encoded)
    }

    @TestCase
    public func testEncodeNumeric(): Unit {
        let encoded: String = PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("1234"),
            Compaction.NUMERIC,
            StandardCharsets.UTF_8,
            false
        ).toString();
        @Assert("\u{039f}\u{001A}\u{0386}\f\u{01b2}", encoded)
    }

    @TestCase
    public func testEncodeByte(): Unit {
        let encoded: String = PDF417HighLevelEncoder.encodeHighLevel(
            UTF32String("abcd"),
            Compaction.BYTE,
            StandardCharsets.UTF_8,
            false
        ).toString();
        @Assert("\u{039f}\u{001A}\u{0385}abcd", encoded)
    }

    @TestCase
    public func testEncodeEmptyString(): Unit {
        try {
            PDF417HighLevelEncoder.encodeHighLevel(UTF32String(""), Compaction.AUTO, MyCharset(), false);
            @Assert(false)
        } catch (name: Qrcoder4cjWriterException) {}
    }
}
