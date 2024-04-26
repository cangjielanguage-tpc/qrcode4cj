// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from QRCode4cj import common.*
from QRCode4cj import common.ResultPoint
from QRCode4cj import client.result.*

main(): Int64 {
    let tester = Tester()
    tester.execute()
    tester.printResult()
    0
}

@Test
public class Tester {
    @TestCase
    func t1(): Unit {
        var result = ExpandedProductParsedResult("","","","","","","","","","","","","","",HashMap<String, String>())
        @Assert(result.equals(result),true)
    }

    @TestCase
    func t2(): Unit {
        var result = ExpandedProductParsedResult("testtest","","","","","","","","","","","","","",HashMap<String, String>())

        @Assert(result.getRawText(),"testtest")
    }

    @TestCase
    func t3(): Unit {
        var result = ExpandedProductParsedResult("testtest","","","","","","","","","","","","","",HashMap<String, String>())

        @Assert(result.hashCode(),5863005)
    }

    @TestCase
    func t4(): Unit {
        var result = ExpandedProductParsedResult("testtest","","","","","","","","","","","","","",HashMap<String, String>())
        @Assert(result.equals(this),false)
    }
}

