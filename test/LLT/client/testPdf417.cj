// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import QRCode4cj.pdf417.encoder.*
import QRCode4cj.common.*

main(): Int64 {
    let tester = Tester()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
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
