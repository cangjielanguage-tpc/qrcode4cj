/*
 * Copyright 2007 ZXing authors
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
    let tester = FormatInformationTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Sean Owen
 */
@Test
public class FormatInformationTestCase {
    private static var MASKED_TEST_FORMAT_INFO: Int64 = 0x2BED;
    private static var UNMASKED_TEST_FORMAT_INFO: Int64 = MASKED_TEST_FORMAT_INFO ^ 0x5412

    @TestCase
    public func testBitsDiffering(): Unit {
        @Assert(0, FormatInformation.numBitsDiffering(1, 1))
        @Assert(1, FormatInformation.numBitsDiffering(0, 2))
        @Assert(2, FormatInformation.numBitsDiffering(1, 2))
        @Assert(32, FormatInformation.numBitsDiffering(-1, 0))
    }

    @TestCase
    public func testDecode(): Unit {
        // Normal case
        var expected: ?FormatInformation = FormatInformation.decodeFormatInformation(
            MASKED_TEST_FORMAT_INFO,
            MASKED_TEST_FORMAT_INFO
        );
        if (let Some(e) <- expected) {
            @Assert(UInt8(0x07), e.getDataMask())

            @Assert(ErrorCorrectionLevel.Q(0x03), e.getErrorCorrectionLevel())

            // where the code forgot the mask!
            @Assert(e,
                    FormatInformation.decodeFormatInformation(UNMASKED_TEST_FORMAT_INFO, MASKED_TEST_FORMAT_INFO).getOrThrow())
        } else {
            @Assert(false)
        }
    }

    @TestCase
    public func testDecodeWithBitDifference(): Unit {
        var expected: ?FormatInformation = FormatInformation.decodeFormatInformation(
            MASKED_TEST_FORMAT_INFO,
            MASKED_TEST_FORMAT_INFO
        );

        if (let Some(e) <- expected) {
            // 1,2,3,4 bits difference
            @Assert(e, FormatInformation.decodeFormatInformation(
            MASKED_TEST_FORMAT_INFO ^ 0x01, MASKED_TEST_FORMAT_INFO ^ 0x01).getOrThrow())
            @Assert(e, FormatInformation.decodeFormatInformation(
            MASKED_TEST_FORMAT_INFO ^ 0x03, MASKED_TEST_FORMAT_INFO ^ 0x03).getOrThrow())
            @Assert(e, FormatInformation.decodeFormatInformation(
            MASKED_TEST_FORMAT_INFO ^ 0x07, MASKED_TEST_FORMAT_INFO ^ 0x07).getOrThrow())
        }

        if (let Some(e) <- FormatInformation.decodeFormatInformation(
            MASKED_TEST_FORMAT_INFO ^ 0x0F,
            MASKED_TEST_FORMAT_INFO ^ 0x0F
        )) {
            @Assert(false)
        }
    }

    @TestCase
    public func testDecodeWithMisread(): Unit {
        var expected: ?FormatInformation = FormatInformation.decodeFormatInformation(
            MASKED_TEST_FORMAT_INFO,
            MASKED_TEST_FORMAT_INFO
        );

        if (let Some(e) <- expected) {
            @Assert(e, FormatInformation.decodeFormatInformation(
            MASKED_TEST_FORMAT_INFO ^ 0x03, MASKED_TEST_FORMAT_INFO ^ 0x0F).getOrThrow())
        } else {
            @Assert(false)
        }
    }
}
