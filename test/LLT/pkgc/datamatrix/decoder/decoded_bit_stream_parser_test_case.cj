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
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import zxing.code.datamatrix.decoder.*
from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let tester = DecodedBitStreamParserTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author bbrown@google.com (Brian Brown)
 */
@Test
public class DecodedBitStreamParserTestCase {
    @TestCase
    public func testAsciiStandardDecode(): Unit {
        // ASCII characters 0-127 are encoded as the value + 1
        let bytes = [
            UInt8('a'.hashCode() + 1),
            UInt8('b'.hashCode() + 1),
            UInt8('c'.hashCode() + 1),
            UInt8('A'.hashCode() + 1),
            UInt8('B'.hashCode() + 1),
            UInt8('C'.hashCode() + 1)
        ]
        let decodedString = DecodedBitStreamParser.decode(bytes).getText();
        @Assert("abcABC", decodedString)
    }

    @TestCase
    public func testAsciiDoubleDigitDecode(): Unit {
        // ASCII double digit (00 - 99) Numeric Value + 130
        let bytes = [
            UInt8(130),
            UInt8(1 + 130),
            UInt8(98 + 130),
            UInt8(99 + 130)
        ]
        let decodedString = DecodedBitStreamParser.decode(bytes).getText();
        @Assert("00019899", decodedString)
    }
}
