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
from QRCode4cj import zxing.code.qrcode.decoder.*
from QRCode4cj import zxing.code.tools.UTF32String
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import regex.*

main(): Int64 {
    let tester = DataMaskTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Sean Owen
 */
@Test
public class DataMaskTestCase {
    @TestCase
    public func testMask0(): Unit {
        testMaskAcrossDimensions(0, {i, j => (i + j) % 2 == 0});
    }

    @TestCase
    public func testMask1(): Unit {
        testMaskAcrossDimensions(1, {i, j => i % 2 == 0});
    }

    @TestCase
    public func testMask2(): Unit {
        testMaskAcrossDimensions(2, {i, j => j % 3 == 0});
    }

    @TestCase
    public func testMask3(): Unit {
        testMaskAcrossDimensions(3, {i, j => (i + j) % 3 == 0});
    }

    @TestCase
    public func testMask4(): Unit {
        testMaskAcrossDimensions(4, {i, j => (i / 2 + j / 3) % 2 == 0});
    }

    @TestCase
    public func testMask5(): Unit {
        testMaskAcrossDimensions(5, {i, j => (i * j) % 2 + (i * j) % 3 == 0});
    }

    @TestCase
    public func testMask6(): Unit {
        testMaskAcrossDimensions(6, {i, j => ((i * j) % 2 + (i * j) % 3) % 2 == 0});
    }

    @TestCase
    public func testMask7(): Unit {
        testMaskAcrossDimensions(7, {i, j => ((i + j) % 2 + (i * j) % 3) % 2 == 0});
    }

    private static func testMaskAcrossDimensions(reference: Int64, condition: (Int64, Int64) -> Bool) {
        let mask: DataMask = DataMask.values()[reference]
        for (version in 1..=40) {
            let dimension: Int64 = 17 + 4 * version
            testMask(mask, dimension, condition);
        }
    }

    private static func testMask(mask: DataMask, dimension: Int64, condition: (Int64, Int64) -> Bool) {
        let bits: BitMatrix = BitMatrix(dimension);
        mask.unmaskBitMatrix(bits, dimension);
        for (i in 0..dimension) {
            for (j in 0..dimension) {
                @Assert(
            condition(i, j),
            bits.get(j, i))
            }
        }
    }
}
