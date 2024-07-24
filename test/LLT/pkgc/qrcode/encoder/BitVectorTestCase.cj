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
import std.io.*

main(): Int64 {
    let tester = BitVectorTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class BitVectorTestCase {
    private static func getUnsignedInt(v: BitArray): Int64 {
        var result: Int64 = 0i64;
        var offset: Int64 = 0;
        for (i in 0..32) {
            if (v.get(offset + i)) {
                result |= 1i64 << (31 - i)
            }
        }
        return result
    }

    @TestCase
    public func testAppendBit(): Unit {
        var v: BitArray = BitArray();
        @Assert(0, v.getSizeInBytes())

        // 1
        v.appendBit(true);
        @Assert(1, v.getSize())
        @Assert(0x80000000i64, getUnsignedInt(v))

        // 10
        v.appendBit(false);
        @Assert(2, v.getSize())
        @Assert(0x80000000i64, getUnsignedInt(v))

        // 101
        v.appendBit(true);
        @Assert(3, v.getSize())
        @Assert(0xa0000000i64, getUnsignedInt(v))

        // 1010
        v.appendBit(false);
        @Assert(4, v.getSize())
        @Assert(0xa0000000i64, getUnsignedInt(v))

        // 10101
        v.appendBit(true);
        @Assert(5, v.getSize())
        @Assert(0xa8000000i64, getUnsignedInt(v))

        // 101010
        v.appendBit(false);
        @Assert(6, v.getSize())
        @Assert(0xa8000000i64, getUnsignedInt(v))

        // 1010101
        v.appendBit(true);
        @Assert(7, v.getSize())
        @Assert(0xaa000000i64, getUnsignedInt(v))

        // 10101010
        v.appendBit(false);
        @Assert(8, v.getSize())
        @Assert(0xaa000000i64, getUnsignedInt(v))

        // 10101010 1
        v.appendBit(true);
        @Assert(9, v.getSize())
        @Assert(0xaa800000i64, getUnsignedInt(v))

        // 10101010 10
        v.appendBit(false);
        @Assert(10, v.getSize())
        @Assert(0xaa800000i64, getUnsignedInt(v))
    }

    @TestCase
    public func testAppendBits(): Unit {
        var v: BitArray = BitArray();
        v.appendBits(0x1, 1);
        @Assert(1, v.getSize())
        @Assert(0x80000000i64, getUnsignedInt(v))
        v = BitArray()
        v.appendBits(0xff, 8);
        @Assert(8, v.getSize())
        @Assert(0xff000000i64, getUnsignedInt(v))
        v = BitArray()
        v.appendBits(0xff7, 12);
        @Assert(12, v.getSize())
        @Assert(0xff700000i64, getUnsignedInt(v))
    }

    @TestCase
    public func testNumBytes(): Unit {
        var v: BitArray = BitArray();
        @Assert(0, v.getSizeInBytes())
        v.appendBit(false);

        // 1 bit was added in the vector, so 1 byte should be consumed.
        @Assert(1, v.getSizeInBytes())
        v.appendBits(0, 7);
        @Assert(1, v.getSizeInBytes())
        v.appendBits(0, 8);
        @Assert(2, v.getSizeInBytes())
        v.appendBits(0, 1);

        // We now have 17 bits, so 3 bytes should be consumed.
        @Assert(3, v.getSizeInBytes())
    }

    @TestCase
    public func testAppendBitVector(): Unit {
        var v1: BitArray = BitArray();
        v1.appendBits(0xbe, 8);
        var v2: BitArray = BitArray();
        v2.appendBits(0xef, 8);
        v1.appendBitArray(v2);

        // beef = 1011 1110 1110 1111
        @Assert(" X.XXXXX. XXX.XXXX", v1.toString())
    }

    @TestCase
    public func testXOR(): Unit {
        var v1: BitArray = BitArray();
        v1.appendBits(0x5555aaaa, 32);
        var v2: BitArray = BitArray();
        v2.appendBits(0xaaaa5555, 32);
        v1.xor(v2);
        @Assert(0xffffffffi64, getUnsignedInt(v1))
    }

    @TestCase
    public func testXOR2(): Unit {
        var v1: BitArray = BitArray();
        v1.appendBits(0x2a, 7);

        // 010 1010
        var v2: BitArray = BitArray();
        v2.appendBits(0x55, 7);

        // 101 0101
        v1.xor(v2);
        @Assert(0xfe000000i64, getUnsignedInt(v1))
        // 1111 1110
    }

    @TestCase
    public func testAt(): Unit {
        var v: BitArray = BitArray();
        v.appendBits(0xdead, 16);

        // 1101 1110 1010 1101
        @Assert(v.get(0))
        @Assert(v.get(1))
        @Assert(!v.get(2))
        @Assert(v.get(3))

        @Assert(v.get(4))
        @Assert(v.get(5))
        @Assert(v.get(6))
        @Assert(!v.get(7))

        @Assert(v.get(8))
        @Assert(!v.get(9))
        @Assert(v.get(10))
        @Assert(!v.get(11))

        @Assert(v.get(12))
        @Assert(v.get(13))
        @Assert(!v.get(14))
        @Assert(v.get(15))
    }

    @TestCase
    public func testToString(): Unit {
        var v: BitArray = BitArray();
        v.appendBits(0xdead, 16);

        // 1101 1110 1010 1101
        @Assert(" XX.XXXX. X.X.XX.X", v.toString())
    }
}
