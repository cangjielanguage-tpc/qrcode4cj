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

// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import zxing.code.common.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import math.*
from std import format.*
from std import collection.*
from QRCode4cj import zxing.code.tools.UTF32String

main(): Int64 {
    let tester = BitSourceTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Sean Owen
 */
@Test
public class BitSourceTestCase {
    @TestCase
    public func testSource(): Unit {
        let bytes: Array<Byte> = [1, 2, 3, 4, 5]
        var source = BitSource(bytes)
        @Assert(40, source.available())
        @Assert(0, source.readBits(1))
        @Assert(39, source.available())
        @Assert(0, source.readBits(6))
        @Assert(33, source.available())
        @Assert(1, source.readBits(1))
        @Assert(32, source.available())
        @Assert(2, source.readBits(8))
        @Assert(24, source.available())
        @Assert(12, source.readBits(10))
        @Assert(14, source.available())
        @Assert(16, source.readBits(8))
        @Assert(6, source.available())
        @Assert(5, source.readBits(6))
        @Assert(0, source.available())
    }
}
