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
 *
 * This software consists of contributions made by many individuals,
 * listed below:
 *
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 *
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", leaded by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 * http://www.piramidepse.com/
 *
 */

// DEPENDENCE: ../../../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../../../common/test_result.cj
// DEPENDENCE: ../../../../test_common.cj
// DEPENDENCE: ../../../../resources/blackbox/rssexpanded-1
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

from QRCode4cj import zxing.code.tools.*
from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.oned.*
from QRCode4cj import zxing.code.oned.rss.*
from QRCode4cj import zxing.code.oned.rss.expanded.*
from QRCode4cj import zxing.code.oned.rss.expanded.decoders.*
from QRCode4cj import zxing.code.client.result.*
from QRCode4cj import zxing.code.common.reader.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import regex.*
from std import collection.*
from std import convert.*
from std import fs.*
from std import log.*
from std import os.posix.*


main(): Int64 {
    let tester = RSSExpandedImage2resultTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
@Test
public class RSSExpandedImage2resultTestCase {
    @TestCase
    public func testDecodeRow2result2(): Unit {
        // (01)90012345678908(3103)001750
        var expected: ExpandedProductParsedResult = ExpandedProductParsedResult(
            "(01)90012345678908(3103)001750",
            "90012345678908",
            "",
            "",
            "",
            "",
            "",
            "",
            "001750",
            ExpandedProductParsedResult.KILOGRAM,
            "3",
            "",
            "",
            "",
            HashMap<String, String>()
        );

        assertCorrectImage2result("2.png", expected);
    }

    private static func assertCorrectImage2result(fileName: String, expected: ExpandedProductParsedResult) {
        var path: Path = AbstractBlackBoxTestCase.buildTestBase("./rssexpanded-1").join(fileName)

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(path.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        var binaryMap: BinaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(BufferedImageLuminanceSource(imagei)));
        var rowNumber: Int64 = binaryMap.getHeight() / 2
        var row: BitArray = binaryMap.getBlackRow(rowNumber, BitArray());

        var theResult: Result
        try {
            var rssExpandedReader: RSSExpandedReader = RSSExpandedReader();
            theResult = rssExpandedReader.decodeRow(rowNumber, row, HashMap<DecodeHintType, Any>())
        } catch (re: Qrcoder4cjReaderException) {
            return;
        }

        @Expect(BarcodeFormat.RSS_EXPANDED, theResult.getBarcodeFormat())

        var result: ParsedResult = ResultParser.parseResult(theResult)
        var result_txt: String = result.toString()
        var expected_txt: String = expected.toString()
        @Expect(expected_txt, result_txt)
    }
}
