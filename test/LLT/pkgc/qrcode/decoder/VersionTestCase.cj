/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// DEPENDENCE: ../../common/bit_source_builder.cj
// EXEC: cjc %import-path %L %l %f ./bit_source_builder.cj
// EXEC: ./main

from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.qrcode.decoder.*
from charset import charset.tools.UTF32String
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import regex.*
from std import io.*

main(): Int64 {
    let tester = VersionTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Sean Owen
 */
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
