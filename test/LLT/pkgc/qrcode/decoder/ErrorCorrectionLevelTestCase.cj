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
from QRCode4cj import zxing.code.tools.UTF32String
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import regex.*
from std import io.*

main(): Int64 {
    let tester = ErrorCorrectionLevelTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Sean Owen
 */
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
