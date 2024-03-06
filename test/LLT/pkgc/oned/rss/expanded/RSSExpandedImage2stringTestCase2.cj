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
    let tester = RSSExpandedImage2stringTestCase2()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
@Test
public class RSSExpandedImage2stringTestCase2 {
    @TestCase
    public func testDecodeRow2string1(): Unit {
        assertCorrectImage2string("1.png", "(11)100224(17)110224(3102)000100");
    }

    @TestCase
    public func testDecodeRow2string2(): Unit {
        assertCorrectImage2string("2.png", "(01)90012345678908(3103)001750");
    }

    @TestCase
    public func testDecodeRow2string3(): Unit {
        assertCorrectImage2string("3.png", "(10)12A");
    }

    @TestCase
    public func testDecodeRow2string4(): Unit {
        assertCorrectImage2string("4.png", "(01)98898765432106(3202)012345(15)991231");
    }

    @TestCase
    public func testDecodeRow2string5(): Unit {
        assertCorrectImage2string("5.png", "(01)90614141000015(3202)000150");
    }

    @TestCase
    public func testDecodeRow2string7(): Unit {
        assertCorrectImage2string("7.png", "(10)567(11)010101");
    }

    @TestCase
    public func testDecodeRow2string10(): Unit {
        var expected: String = "(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)012345678901";
        assertCorrectImage2string("10.png", expected);
    }

    @TestCase
    public func testDecodeRow2string11(): Unit {
        assertCorrectImage2string("11.png", "(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456");
    }

    @TestCase
    public func testDecodeRow2string12(): Unit {
        assertCorrectImage2string("12.png", "(01)98898765432106(3103)001750");
    }

    @TestCase
    public func testDecodeRow2string13(): Unit {
        assertCorrectImage2string("13.png", "(01)90012345678908(3922)795");
    }

    @TestCase
    public func testDecodeRow2string14(): Unit {
        assertCorrectImage2string("14.png", "(01)90012345678908(3932)0401234");
    }

    @TestCase
    public func testDecodeRow2string15(): Unit {
        assertCorrectImage2string("15.png", "(01)90012345678908(3102)001750(11)100312");
    }

    @TestCase
    public func testDecodeRow2string16(): Unit {
        assertCorrectImage2string("16.png", "(01)90012345678908(3202)001750(11)100312");
    }

    @TestCase
    public func testDecodeRow2string17(): Unit {
        assertCorrectImage2string("17.png", "(01)90012345678908(3102)001750(13)100312");
    }

    @TestCase
    public func testDecodeRow2string18(): Unit {
        assertCorrectImage2string("18.png", "(01)90012345678908(3202)001750(13)100312");
    }

    @TestCase
    public func testDecodeRow2string19(): Unit {
        assertCorrectImage2string("19.png", "(01)90012345678908(3102)001750(15)100312");
    }

    @TestCase
    public func testDecodeRow2string20(): Unit {
        assertCorrectImage2string("20.png", "(01)90012345678908(3202)001750(15)100312");
    }

    @TestCase
    public func testDecodeRow2string21(): Unit {
        assertCorrectImage2string("21.png", "(01)90012345678908(3102)001750(17)100312");
    }

    @TestCase
    public func testDecodeRow2string22(): Unit {
        assertCorrectImage2string("22.png", "(01)90012345678908(3202)001750(17)100312");
    }

    @TestCase
    public func testDecodeRow2string25(): Unit {
        assertCorrectImage2string("25.png", "(10)123");
    }

    @TestCase
    public func testDecodeRow2string26(): Unit {
        assertCorrectImage2string("26.png", "(10)5678(11)010101");
    }

    @TestCase
    public func testDecodeRow2string27(): Unit {
        assertCorrectImage2string("27.png", "(10)1098-1234");
    }

    @TestCase
    public func testDecodeRow2string28(): Unit {
        assertCorrectImage2string("28.png", "(10)1098/1234");
    }

    @TestCase
    public func testDecodeRow2string29(): Unit {
        assertCorrectImage2string("29.png", "(10)1098.1234");
    }

    @TestCase
    public func testDecodeRow2string30(): Unit {
        assertCorrectImage2string("30.png", "(10)1098*1234");
    }

    @TestCase
    public func testDecodeRow2string31(): Unit {
        assertCorrectImage2string("31.png", "(10)1098,1234");
    }

    @TestCase
    public func testDecodeRow2string32(): Unit {
        assertCorrectImage2string("32.png", "(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012");
    }

    private static func assertCorrectImage2string(fileName: String, expected: String) {
        var path: Path = AbstractBlackBoxTestCase.buildTestBase("./rssexpanded-1").join(fileName)

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(path.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        var binaryMap: BinaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(BufferedImageLuminanceSource(imagei)));
        var rowNumber: Int64 = binaryMap.getHeight() / 2
        var row: BitArray = binaryMap.getBlackRow(rowNumber, BitArray());

        var result: Result
        try {
            var rssExpandedReader: RSSExpandedReader = RSSExpandedReader();
            result = rssExpandedReader.decodeRow(rowNumber, row, HashMap<DecodeHintType, Any>())
        } catch (re: ReaderException) {
            return;
        }

        @Expect(BarcodeFormat.RSS_EXPANDED, result.getBarcodeFormat())
        @Expect(expected, result.getText())
    }
}
