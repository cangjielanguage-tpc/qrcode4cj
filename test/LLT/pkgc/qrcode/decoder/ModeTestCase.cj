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
    let tester = ModeTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Sean Owen
 */
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
