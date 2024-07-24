// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.math.*
import std.format.*
import std.collection.*
import QRCode4cj.tools.UTF32String

main(): Int64 {
    let tester = BitSourceTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

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
