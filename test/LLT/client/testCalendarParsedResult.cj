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
        var result = ExpandedProductParsedResult("", "", "", "", "", "", "", "", "", "", "", "", "", "",
            HashMap<String, String>())
        @Assert(result.equals(result),true)
    }

    @TestCase
    func t2(): Unit {
        var result = ExpandedProductParsedResult("testtest", "", "", "", "", "", "", "", "", "", "", "", "", "",
            HashMap<String, String>())

        @Assert(result.getRawText(),"testtest")
    }

    @TestCase
    func t3(): Unit {
        var result = ExpandedProductParsedResult("testtest", "", "", "", "", "", "", "", "", "", "", "", "", "",
            HashMap<String, String>())
        var flag = true
        try {
            result.hashCode()
        } catch (e: Exception) {
            flag = false
        }

        @Assert(flag,true)
    }

    @TestCase
    func t4(): Unit {
        var result = ExpandedProductParsedResult("testtest", "", "", "", "", "", "", "", "", "", "", "", "", "",
            HashMap<String, String>())
        @Assert(result.equals(this),false)
    }
}
