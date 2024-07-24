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
        var str = UTF32String("qwert12314543")
        var res = str.split(UTF32String("t12"))        
        @Assert(2,res.size)
    }

    @TestCase
    func t2(): Unit {
        var str = UTF32String("qwert12314543")
        var res = str.indexOfToList(UTF32String("t12"))    
        @Assert(1,res.size)
    }

    @TestCase
    func t3(): Unit {
        var str = UTF32String("qwert12314543")
        var res = str.replace(UTF32String("t12"), UTF32String("rep"))    
        @Assert("qwerrep314543",res.toString())
    }

    @TestCase
    func t4(): Unit {
        var str = UTF32String("qwert123145431")
        var res = str.replace(UTF32String("1"), UTF32String("0"))    
        @Assert("qwert023045430",res.toString())
    }

    @TestCase
    func t5(): Unit {
        var str = UTF32String("QAZCDE")
        var res = str.toAsciiLower()
        @Assert("qazcde",res.toString())
    }

    @TestCase
    func t6(): Unit {
        var str = UTF32String("QAZCDE")
        var str2 = UTF32String("qazxse")
        var res = str.toAsciiLower()
        @Assert(true,str != str2)
    }

    @TestCase
    func t7(): Unit {
        var str = UTF32String("QAZCDE")
        var str2 = UTF32String("qazxs")
        var res = str.toAsciiLower()
        @Assert(true,str < str2)
    }

    @TestCase
    func t8(): Unit {
        var str = UTF32String("QAZCDE")
        var str2 = UTF32String("qazxs")
        var res = str.toAsciiLower()
        @Assert(true,str > str2)
    }

    @TestCase
    func t9(): Unit {
        var str = UTF32String("E11")
        var str2 = UTF32String("qazxs")
        var res = str.toAsciiLower()
        @Assert(true,str < str2)
    }

    @TestCase
    func t10(): Unit {
        var str = UTF32String("QAZCDE")
        var str2 = UTF32String("qazxs11")
        var res = str.toAsciiLower()
        @Assert(true,str > str2)
    }
}

