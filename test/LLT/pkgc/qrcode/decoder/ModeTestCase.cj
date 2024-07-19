

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
    let tester = ModeTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class ModeTestCase {
    @TestCase
    public func testForBits(): Unit {
        @Assert(Mode.TERMINATOR([0, 0, 0], 0x00), Mode.forBits(0x00))
        @Assert(Mode.NUMERIC([10, 12, 14], 0x01), Mode.forBits(0x01))
        @Assert(Mode.ALPHANUMERIC([9, 11, 13], 0x02), Mode.forBits(0x02))
        @Assert(Mode.BYTE([8, 16, 16], 0x04), Mode.forBits(0x04))
        @Assert(Mode.KANJI([8, 10, 12], 0x08), Mode.forBits(0x08))
    }

    @TestCase
    public func testBadMode(): Unit {
        try {
            Mode.forBits(0x10);
            @Assert(false)
        } catch (e: IllegalArgumentException) {}
    }

    @TestCase
    public func testCharacterCount(): Unit {
        // Spot check a few values
        @Assert(10, Mode.NUMERIC([10, 12, 14], 0x01).getCharacterCountBits(Version.getVersionForNumber(5)))
        @Assert(12, Mode.NUMERIC([10, 12, 14], 0x01).getCharacterCountBits(Version.getVersionForNumber(26)))
        @Assert(14, Mode.NUMERIC([10, 12, 14], 0x01).getCharacterCountBits(Version.getVersionForNumber(40)))
        @Assert(9, Mode.ALPHANUMERIC([9, 11, 13], 0x02).getCharacterCountBits(Version.getVersionForNumber(6)))
        @Assert(8, Mode.BYTE([8, 16, 16], 0x04).getCharacterCountBits(Version.getVersionForNumber(7)))
        @Assert(8, Mode.KANJI([8, 10, 12], 0x08).getCharacterCountBits(Version.getVersionForNumber(8)))
    }
}
