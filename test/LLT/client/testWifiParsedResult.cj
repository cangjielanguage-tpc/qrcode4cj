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
        var res = WifiParsedResult()
        res.WifiParsedResult("WPA2", "SSID", "pw")
        res.WifiParsedResult("WPA2", "SSID", "pw", false)
        @Assert(res.isHidden(),false)
    }

    @TestCase
    func t2(): Unit {
        var res = WifiParsedResult()
        res.WifiParsedResult("WPA3", "SSID", "pw")
        @Assert(res.getIdentity(),"")
    }

    @TestCase
    func t3(): Unit {
        var res = WifiParsedResult()
        res.WifiParsedResult("WPA3", "SSID", "pw")
        @Assert(res.getAnonymousIdentity(),"")
    }

    @TestCase
    func t4(): Unit {
        var res = WifiParsedResult()
        res.WifiParsedResult("WPA3", "SSID", "pw")
        @Assert(res.getEapMethod(),"")
    }
    @TestCase
    func t5(): Unit {
        var res = WifiParsedResult()
        res.WifiParsedResult("WPA3", "SSID", "pw")
        @Assert(res.getPhase2Method(),"")
    }

    @TestCase
    func t6(): Unit {
        var res = WifiParsedResult()
        res.WifiParsedResult("WPA3", "SSID", "pw")
        @Assert(res.getDisplayResult(),"false")
    }
}
