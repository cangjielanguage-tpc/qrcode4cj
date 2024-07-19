// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.math.*
import std.time.*
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.Result
import QRCode4cj.common.ResultPoint
import QRCode4cj.client.result.*

main(): Int64 {
    let tester = ExpandedProductParsedResultTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class ExpandedProductParsedResultTestCase {
    @TestCase
    public func testRSSExpanded(): Unit {
        var uncommonAIs: HashMap<String, String> = HashMap<String, String>();
        uncommonAIs.put("123", "544654");
        var result: Result = Result(
            "(01)66546(13)001205(3932)4455(3102)6544(123)544654",
            Array<UInt8>(),
            Array<ResultPoint>(),
            BarcodeFormat.RSS_EXPANDED
        );
        var o: ExpandedProductParsedResult = (ExpandedProductResultParser().parse(result).getOrThrow() as ExpandedProductParsedResult).
            getOrThrow();
        @Assert(o.flag,true)
        @Assert(o.toString().isEmpty (),false)
        @Assert("66546", o.getProductID())
        @Assert(o.getSscc(),"")
        @Assert(o.getLotNumber(),"")
        @Assert(o.getProductionDate(),"")
        @Assert("001205", o.getPackagingDate())
        @Assert(o.getBestBeforeDate(),"")
        @Assert(o.getExpirationDate(),"")
        @Assert("6544", o.getWeight())
        @Assert("KG", o.getWeightType())
        @Assert("2", o.getWeightIncrement())
        @Assert("5", o.getPrice())
        @Assert("2", o.getPriceIncrement())
        @Assert("445", o.getPriceCurrency())

        var ouncommonAIs: HashMap<String, String> = o.getUncommonAIs()
        @Assert(uncommonAIs.size, ouncommonAIs.size)

        @Assert(ouncommonAIs.get("123").getOrThrow(),"544654")
    }
}
