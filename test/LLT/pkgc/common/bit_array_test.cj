// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.math.*

main(): Int64 {
    let tester = BitArrayTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class BitArrayTestCase {
    @TestCase
    public func testGetSet(): Unit {
        var array: BitArray = BitArray(33);
        for (i in 0..33) {
            @Assert(array.get(i),false)
            array.set(i);
            @Assert(array.get(i))
        }
    }

    @TestCase
    public func testGetNextSet1(): Unit {
        var array: BitArray = BitArray(32);
        for (i in 0..array.getSize()) {
            @Assert(array.getNextSet(i), 32)
        }
        array = BitArray(33)
        for (i in 0..array.getSize()) {
            @Assert(array.getNextSet(i), 33)
        }
    }

    @TestCase
    public func testGetNextSet2(): Unit {
        var array: BitArray = BitArray(33);
        array.set(31);
        for (i in 0..array.getSize()) {
            var expected: Int64
            if (i <= 31) {
                expected = 31
            } else {
                expected = 33
                @Assert( array.getNextSet(i),expected)
            }
        }
        array = BitArray(33)
        array.set(32);
        for (i in 0..array.getSize()) {
            @Assert( array.getNextSet(i),32)
        }
    }

    @TestCase
    public func testGetNextSet3(): Unit {
        var array: BitArray = BitArray(63);
        array.set(31);
        array.set(32);
        for (i in 0..array.getSize()) {
            var expected: Int64
            if (i <= 31) {
                expected = 31
            } else if (i == 32) {
                expected = 32
            } else {
                expected = 63
                @Assert(array.getNextSet(i),expected)
            }
        }
    }

    @TestCase
    public func testGetNextSet4(): Unit {
        var array: BitArray = BitArray(63);
        array.set(33);
        array.set(40);
        for (i in 0..array.getSize()) {
            var expected: Int64
            if (i <= 33) {
                expected = 33
            } else if (i <= 40) {
                expected = 40
            } else {
                expected = 63

                @Assert( array.getNextSet(i),expected,)
            }
        }
    }
    @TestCase
    public func testSetBulk(): Unit {
        var array: BitArray = BitArray(64);

        array.setBulk(32, -65536);

        for (i in 0..48) {
            @Assert(array.get(i),false)
        }
        for (i in 48..64) {
            @Assert(array.get(i))
        }
    }

    @TestCase
    public func testSetRange(): Unit {
        var array: BitArray = BitArray(64);
        array.setRange(28, 36);
        @Assert(array.get(27),false)
        for (i in 28..36) {
            @Assert(array.get(i))
        }
        @Assert(array.get(36),false)
    }

    @TestCase
    public func testClear(): Unit {
        var array: BitArray = BitArray(32);
        for (i in 0..32) {
            array.set(i);
        }
        array.clear();
        for (i in 0..32) {
            @Assert(array.get(i),false)
        }
    }

    @TestCase
    public func testFlip(): Unit {
        var array: BitArray = BitArray(32);
        @Assert(array.get(5),false)
        array.flip(5);
        @Assert(array.get(5))
        array.flip(5);
        @Assert(array.get(5),false)
    }

    @TestCase
    public func testGetArray(): Unit {
        var array: BitArray = BitArray(64);
        array.set(0);
        array.set(63);
        var ints: Array<Int32> = array.getBitArray();
        @Assert(1, ints[0])
        @Assert(Int32.Min, ints[1])
    }

    @TestCase
    public func testIsRange(): Unit {
        var array: BitArray = BitArray(64);
        @Assert(array.isRange(0, 64, false))
        @Assert(!array.isRange(0, 64, true))
        array.set(32);
        @Assert(array.isRange(32, 33, true))
        array.set(31);
        @Assert(array.isRange(31, 33, true))
        array.set(34);
        @Assert(!array.isRange(31, 35, true))
        for (i in 0..31) {
            array.set(i);
        }
        @Assert(array.isRange(0, 33, true))
        for (i in 33..64) {
            array.set(i);
        }
        @Assert(array.isRange(0, 64, true))
        @Assert(!array.isRange(0, 64, false))
    }
    public func reverseAlgorithmTest() {
        var oldBits: Array<Int32> = [128, 256, 512, 6453324, 50934953]
        for (size in 1..160) {
            var newBitsOriginal: Array<Int32> = reverseOriginal(oldBits.clone(), size);
            var newBitArray: BitArray = BitArray(oldBits.clone(), size);
            newBitArray.reverse();
            var newBitsNew: Array<Int32> = newBitArray.getBitArray();
            @Assert(arraysAreEqual(newBitsOriginal, newBitsNew, size / 32 + 1))
        }
    }

    @TestCase
    public func testClone(): Unit {
        var array: BitArray = BitArray(32);
        array.clone().set(0);
        @Assert(array.get(0),false)
    }

    @TestCase
    public func testEquals(): Unit {
        var a: BitArray = BitArray(32);
        var b: BitArray = BitArray(32);
        @Assert(a, b)
        @Assert(a.hashCode(), b.hashCode())
        @Assert((BitArray(31)!=a))
        a.set(16);
        @Assert((b!=a))
        @Assert((a.hashCode()!=b.hashCode()))
        b.set(16);
        @Assert(a, b)
        @Assert(a.hashCode(), b.hashCode())
    }

    private static func reverseOriginal(oldBits: Array<Int32>, size: Int64): Array<Int32> {
        var newBits: Array<Int32> = Array<Int32>(oldBits.size, item: 0)
        for (i in 0..size) {
            if (bitSet(oldBits, size - i - 1)) {
                newBits[i / 32] |= 1 << (i & 0x1F)
            }
        }
        return newBits
    }

    private static func bitSet(bits: Array<Int32>, i: Int64): Bool {
        return (bits[i / 32] & (1 << (i & 0x1F))) != 0
    }

    private static func arraysAreEqual(left: Array<Int32>, right: Array<Int32>, size: Int64): Bool {
        for (i in 0..size) {
            if (left[i] != right[i]) {
                return false;
            }
        }
        return true;
    }

    public static func add() {}
}
