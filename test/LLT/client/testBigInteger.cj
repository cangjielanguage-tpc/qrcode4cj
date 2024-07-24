// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import QRCode4cj.tools.*

main(): Int64 {
    let tester = Tester()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class Tester {
    @TestCase
    func t1(): Unit {
        var num = BigInteger("d")
        @Assert(true,num.absolute() == BigInteger("d"))
    }

    @TestCase
    func t2(): Unit {
        var num = BigInteger("1568764564564")
        var num1 = BigInteger("100")
        @Assert(true,num > num1)
    }

    @TestCase
    func t3(): Unit {
        var num = BigInteger("1568764564564")
        var num1 = BigInteger("100")
        @Assert(false,num < num1)
    }

    @TestCase
    func t4(): Unit {
        var num = BigInteger("1568764564564")
        var num1 = BigInteger("1568764564564")
        var num2 = BigInteger("100", false)
        var num3 = BigInteger(100)
        @Assert(true,num <= num1)
    }

    @TestCase
    func t5(): Unit {
        var num = BigInteger("1545645464")
        var num1 = BigInteger("1545645464")
        @Assert(true,num >= num1)
    }

    @TestCase
    func t6(): Unit {
        var num = BigInteger("1111")
        var num1 = BigInteger("1234", true)
        var res = num + num1
        @Assert(false,res == BigInteger(2345))

        var num3 = BigInteger("1234")
        var num4 = BigInteger("1111", true)
        var res2 = num3 - num4
        @Assert(false,res2 == BigInteger(123))
    }

    @TestCase
    func t7(): Unit {
        var num = BigInteger("1111", true)
        var num1 = BigInteger("1234", true)
        @Assert(false,num <= num1)
    }

    @TestCase
    func t8(): Unit {
        var flag = false

        try {
            var num: Float32 = 1.1
            var res = floatToIntBits(num)
            flag = true
        } catch (e: Exception) {}

        @Assert(flag,true)
    }

    @TestCase
    func t9(): Unit {
        var flag = false

        try {
            var num: Float32 = 1.1
            var res = floatToIntBits(num)
            flag = true
        } catch (e: Exception) {}

        @Assert(flag,true)
    }
}
