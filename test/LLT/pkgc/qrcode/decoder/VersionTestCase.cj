

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
    let tester = VersionTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class VersionTestCase {
    @TestCase
    public func testBadVersion(): Unit {
        try {
            Version.getVersionForNumber(0);
            @Assert(false)
        } catch (e: IllegalArgumentException) {}
    }

    @TestCase
    public func testVersionForNumber(): Unit {
        for (i in 1..=40) {
            checkVersion(Version.getVersionForNumber(i), i, 4 * i + 17);
        }
    }

    private static func checkVersion(version: Version, number: Int64, dimension: Int64): Unit {
        @Assert(number, version.getVersionNumber())

        if (number > 1) {
            @Assert(version.getAlignmentPatternCenters().size > 0)
        }
        @Assert(dimension, version.getDimensionForVersion())

        version.getECBlocksForLevel(ErrorCorrectionLevel.H(0x02));
        version.getECBlocksForLevel(ErrorCorrectionLevel.L(0x01));
        version.getECBlocksForLevel(ErrorCorrectionLevel.M(0x00));
        version.getECBlocksForLevel(ErrorCorrectionLevel.Q(0x03));
        version.buildFunctionPattern();
    }

    @TestCase
    public func testGetProvisionalVersionForDimension(): Unit {
        for (i in 1..=40) {
            @Assert(i, Version.getProvisionalVersionForDimension(4 * i + 17).getVersionNumber())
        }
    }

    @TestCase
    public func testDecodeVersionInformation(): Unit {
        // Spot check
        doTestVersion(7, 0x07C94);
        doTestVersion(12, 0x0C762);
        doTestVersion(17, 0x1145D);
        doTestVersion(22, 0x168C9);
        doTestVersion(27, 0x1B08E);
        doTestVersion(32, 0x209D5);
    }

    private static func doTestVersion(expectedVersion: Int64, mask: Int64) {
        var version: ?Version = Version.decodeVersionInformation(mask);

        if (let Some(v) <- version) {
            @Assert(expectedVersion, v.getVersionNumber())
        } else {
            @Assert(false)
        }
    }
}
