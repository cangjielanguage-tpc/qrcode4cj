// DEPENDENCE: ../../common/bit_source_builder.cj
// EXEC: cjc %import-path %L %l %f ./bit_source_builder.cj
// EXEC: ./main

import QRCode4cj.common.*
import QRCode4cj.qrcode.decoder.*
import QRCode4cj.tools.UTF32String
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*
import std.regex.*
import std.io.*

main(): Int64 {
    let tester = DecodedBitStreamParserTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class DecodedBitStreamParserTestCase {
    @TestCase
    public func testSimpleByteMode(): Unit {
        var builder: BitSourceBuilder = BitSourceBuilder();
        builder.write(0x04, 4);

        // Byte mode
        builder.write(0x03, 8);

        // 3 bytes
        builder.write(0xF1, 8);
        builder.write(0xF2, 8);
        builder.write(0xF3, 8);
        var result: String = DecodedBitStreamParser.decode(
            builder.toByteArray(),
            Version.getVersionForNumber(1),
            None,
            HashMap<DecodeHintType, Any>()
        ).getText();
        @Assert("\u{00f1}\u{00f2}\u{00f3}", result)
    }

    @TestCase
    public func testSimpleSJIS(): Unit {
        var builder: BitSourceBuilder = BitSourceBuilder();
        builder.write(0x04, 4);

        // Byte mode
        builder.write(0x04, 8);

        // 4 bytes
        builder.write(0xA1, 8);
        builder.write(0xA2, 8);
        builder.write(0xA3, 8);
        builder.write(0xD0, 8);
        var result: String = DecodedBitStreamParser.decode(
            builder.toByteArray(),
            Version.getVersionForNumber(1),
            None,
            HashMap<DecodeHintType, Any>()
        ).getText();
        @Assert("\u{ff61}\u{ff62}\u{ff63}\u{ff90}", result)
    }

    @TestCase
    public func testHanzi(): Unit {
        var builder: BitSourceBuilder = BitSourceBuilder();
        builder.write(0x0D, 4);

        // Hanzi mode
        builder.write(0x01, 4);

        // Subset 1 = GB2312 encoding
        builder.write(0x01, 8);

        // 1 characters
        builder.write(0x03C1, 13);
        var result: String = DecodedBitStreamParser.decode(
            builder.toByteArray(),
            Version.getVersionForNumber(1),
            None,
            HashMap<DecodeHintType, Any>()
        ).getText();
        @Assert("\u{963f}", result)
    }

    @TestCase
    public func testHanziLevel1(): Unit {
        var builder: BitSourceBuilder = BitSourceBuilder();
        builder.write(0x0D, 4);

        // Hanzi mode
        builder.write(0x01, 4);

        // Subset 1 = GB2312 encoding
        builder.write(0x01, 8);

        // 1 characters
        // A5A2 (U+30A2) => A5A2 - A1A1 = 401, 4*60 + 01 = 0181
        builder.write(0x0181, 13);
        var result: String = DecodedBitStreamParser.decode(
            builder.toByteArray(),
            Version.getVersionForNumber(1),
            None,
            HashMap<DecodeHintType, Any>()
        ).getText();
        @Assert("\u{30a2}", result)
    }
    // TODO definitely need more tests here
}
