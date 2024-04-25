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
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "2HGCJ541312345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t2(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "3BGCJ541212345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t3(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "9BGCJ541612345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t4(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "JBGCJ541812345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t5(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "KMGCJ541812345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t6(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "MBGCJ541X12345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t7(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "SSGCJ541512345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
        fakeResult = Result(
            "SFGCJ541012345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        )
        res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t8(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "VFGCJ541212345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
        fakeResult = Result(
            "VSGCJ541712345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        )
        res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t9(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "WSGCJ541412345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t10(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "X0GCJ541912345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t11(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "ZAGCJ541X12345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())

        fakeResult = Result(
            "0AGCJ541412345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        )
        res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t12(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "1AGCJ5414E2345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isSome())

        fakeResult = Result(
            "1AGCJ5410P2345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        )
        res = paser.parse(fakeResult)
        @Assert(true,res.isSome())

        fakeResult = Result(
            "1AGCJ5417R2345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        )
        res = paser.parse(fakeResult)
        @Assert(true,res.isSome())

        fakeResult = Result(
            "1AGCJ5414V2345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        )
        res = paser.parse(fakeResult)
        @Assert(true,res.isSome())

        fakeResult = Result(
            "1AGCJ5411A2345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        )
        res = paser.parse(fakeResult)
        @Assert(true,res.isSome())
    }

    @TestCase
    func t13(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "1AGCJ5417Z2345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = paser.parse(fakeResult)
        @Assert(true,res.isNone())
    }

    func t14(): Unit {
        var paser = VINResultParser()
        var fakeResult: Result = Result(
            "2HGCJ541312345678",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.CODE_39
        );
        var res = (paser.parse(fakeResult).getOrThrow() as VINParsedResult).getOrThrow()
        var res2 = VINParsedResult()
        res.getVIN()
        res.getDisplayResult()
        @Assert(res.getVIN(),"2HGCJ541312345678")
    }
}
