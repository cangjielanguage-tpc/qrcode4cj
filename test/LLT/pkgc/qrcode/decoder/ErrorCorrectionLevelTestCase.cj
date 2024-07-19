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
    let tester = ErrorCorrectionLevelTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class ErrorCorrectionLevelTestCase {
    @TestCase
    public func testForBits(): Unit {
        @Assert(ErrorCorrectionLevel.M(0x00), ErrorCorrectionLevel.forBits(0))
        @Assert(ErrorCorrectionLevel.L(0x01), ErrorCorrectionLevel.forBits(1))
        @Assert(ErrorCorrectionLevel.H(0x02), ErrorCorrectionLevel.forBits(2))
        @Assert(ErrorCorrectionLevel.Q(0x03), ErrorCorrectionLevel.forBits(3))
    }

    @TestCase
    public func testBadECLevel(): Unit {
        try {
            ErrorCorrectionLevel.forBits(4);
        } catch (e: IllegalArgumentException) {}
    }
}
