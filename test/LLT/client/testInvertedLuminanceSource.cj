// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import QRCode4cj.common.*
import QRCode4cj.common.ResultPoint
import QRCode4cj.client.result.*

main(): Int64 {
    let tester = Tester()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class Tester {
    @TestCase
    func t1(): Unit {
        var source = RGBLuminanceSource(2, 2, Array<Int64>([5, 9, 45, 7]))
        var inl = InvertedLuminanceSource(source)
        @Assert(inl.getMatrix().toString(),"[254, 253, 244, 254]")
    }

    @TestCase
    func t2(): Unit {
        var source = RGBLuminanceSource(2, 2, Array<Int64>([5, 9, 45, 7]))
        var inl = InvertedLuminanceSource(source)
        inl.crop(0, 0, 2, 2)
        @Assert(inl.isCropSupported(),true)
    }

    @TestCase
    func t3(): Unit {
        var source = RGBLuminanceSource(2, 2, Array<Int64>([5, 9, 45, 7]))
        var inl = InvertedLuminanceSource(source)
        inl.invert()
        //inl.rotateCounterClockwise()
        //inl.rotateCounterClockwise45()
        @Assert(inl.isRotateSupported(),false)
    }

    @TestCase
    func t4(): Unit {
        var source = RGBLuminanceSource(2, 2, Array<Int64>([5, 9, 45, 7]))
        var inl = InvertedLuminanceSource(source)
        var flag = false
        try {
            inl.rotateCounterClockwise()
        } catch (e: Exception) {
            flag = true
        }
        @Assert(flag,true)
    }

    @TestCase
    func t5(): Unit {
        var source = RGBLuminanceSource(2, 2, Array<Int64>([5, 9, 45, 7]))
        var inl = InvertedLuminanceSource(source)
        var flag = false
        try {
            inl.rotateCounterClockwise45()
        } catch (e: Exception) {
            flag = true
        }
        @Assert(flag,true)
    }

    @TestCase
    func t6(): Unit {
        var res = CalendarParsedResult()
        res.getStart(0)
        res.getEnd()
        @Assert(res.isEndAllDay(),false)
        @Assert(res.isStartAllDay(),false)
    }
}

