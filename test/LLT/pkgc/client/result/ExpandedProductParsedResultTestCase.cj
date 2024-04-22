/*
 * Copyright (C) 2010 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", led by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 * http://www.piramidepse.com/
 */

// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import math.*
from std import time.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from QRCode4cj import common.BarcodeFormat
from QRCode4cj import common.Result
from QRCode4cj import common.ResultPoint
from QRCode4cj import client.result.*

main(): Int64 {
    let tester = ExpandedProductParsedResultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Antonio Manuel Benjumea Conde, Servinform, S.A.
 * @author Agustín Delgado, Servinform, S.A.
 */
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
