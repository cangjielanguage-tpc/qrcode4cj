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

