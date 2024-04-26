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
        var arr = Array<String>(["q","w"])
        var result = AddressBookParsedResult(arr,arr,"test",arr,arr,arr,arr,"test","test",arr,arr,"test","test","test",arr,arr)
        var arr2 = Array<String>(["qe","wr"])
        result.AddressBookParsedResult(arr2,arr2,arr2,arr2,arr2,arr2,arr2)
        @Assert(result.getNicknames(),arr)
    }

    @TestCase
    func t2(): Unit {
        var arr = Array<String>(["q","w"])
        var result = AddressBookParsedResult(arr,arr,"test",arr,arr,arr,arr,"test","test",arr,arr,"test","test","test",arr,arr)
        @Assert(result.getEmailTypes(),arr)
    }

    @TestCase
    func t3(): Unit {
        var arr = Array<String>(["q","w"])
        var result = AddressBookParsedResult(arr,arr,"test",arr,arr,arr,arr,"test","test",arr,arr,"test","test","test",arr,arr)
        @Assert(result.getInstantMessenger(),"test")
    }

    @TestCase
    func t4(): Unit {
        var arr = Array<String>(["q","w"])
        var result = AddressBookParsedResult(arr,arr,"test",arr,arr,arr,arr,"test","test",arr,arr,"test","test","test",arr,arr)
        @Assert(result.getAddressTypes(),arr)
    }

    @TestCase
    func t5(): Unit {
        var arr = Array<String>(["q","w"])
        var result = AddressBookParsedResult(arr,arr,"test",arr,arr,arr,arr,"test","test",arr,arr,"test","test","test",arr,arr)
        @Assert(result.getGeo(),arr)
    }
}

