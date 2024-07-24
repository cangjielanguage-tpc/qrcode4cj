// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.*
import QRCode4cj.qrcode.decoder.*
import QRCode4cj.tools.UTF32String
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*
import std.regex.*

main(): Int64 {
    let tester = DataMaskTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

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
