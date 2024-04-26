// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from QRCode4cj import pdf417.encoder.*
from QRCode4cj import common.*

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
        var comp1 = Compaction.AUTO
        @Assert(Compaction.valueOf("AUTO").toString(),"AUTO")
        @Assert(Compaction.valueOf("TEXT").toString(),"TEXT")
        @Assert(Compaction.valueOf("BYTE").toString(),"BYTE")
        @Assert(Compaction.valueOf("NUMERIC").toString(),"NUMERIC")
    }

    @TestCase
    func t2(): Unit {
        var dimens = Dimensions(4, 7, 8, 9)
        @Assert(dimens.getMinCols(),4)
        @Assert(dimens.getMaxCols(),7)
        @Assert(dimens.getMinRows(),8)
        @Assert(dimens.getMaxRows(),9)
    }
}
