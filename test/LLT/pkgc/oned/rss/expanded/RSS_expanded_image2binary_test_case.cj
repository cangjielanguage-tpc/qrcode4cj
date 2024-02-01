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
    let tester = RSSExpandedImage2binaryTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
@Test
public class RSSExpandedImage2binaryTestCase {
    @TestCase
    public func testDecodeRow2binary1(): Unit {
        // (11)100224(17)110224(3102)000100
        assertCorrectImage2binary(
            "1.png",
            " ...X...X .X....X. .XX...X. X..X...X ...XX.X. ..X.X... ..X.X..X ...X..X. X.X....X .X....X. .....X.. X...X..."
        );
    }

    @TestCase
    public func testDecodeRow2binary2(): Unit {
        // (01)90012345678908(3103)001750
        assertCorrectImage2binary("2.png", " ..X..... ......X. .XXX.X.X .X...XX. XXXXX.XX XX.X.... .XX.XX.X .XX.");
    }

    @TestCase
    public func testDecodeRow2binary3(): Unit {
        // (10)12A
        assertCorrectImage2binary("3.png", " .......X ..XX..X. X.X....X .......X ....");
    }

    @TestCase
    public func testDecodeRow2binary4(): Unit {
        // (01)98898765432106(3202)012345(15)991231
        assertCorrectImage2binary(
            "4.png",
            " ..XXXX.X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX..XX XX.X.XXX X..XX..X .X.XXXXX XXXX"
        );
    }

    @TestCase
    public func testDecodeRow2binary5(): Unit {
        // (01)90614141000015(3202)000150
        assertCorrectImage2binary("5.png", " ..X.X... .XXXX.X. XX..XXXX ....XX.. X....... ....X... ....X..X .XX.");
    }

    @TestCase
    public func testDecodeRow2binary10(): Unit {
        // (01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012
        assertCorrectImage2binary(
            "10.png",
            " .X.XX..X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX...X XX.X.... X.X.X.X. X.X..X.X .X....X. XX...X.. ...XX.X. .XXXXXX. .X..XX.. X.X.X... .X...... XXXX.... XX.XX... XXXXX.X. ...XXXXX .....X.X ...X.... X.XXX..X X.X.X... XX.XX..X .X..X..X .X.X.X.X X.XX...X .XX.XXX. XXX.X.XX ..X."
        );
    }

    @TestCase
    public func testDecodeRow2binary11(): Unit {
        // (01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456
        assertCorrectImage2binary(
            "11.png",
            " .X.XX..X XX.XXXX. .XXX.XX. XX..X... .XXXXX.. XX.X..X. ..XX...X XX.X.... X.X.X.X. X.X..X.X .X....X. XX...X.. ...XX.X. .XXXXXX. .X..XX.. X.X.X... .X...... XXXX.... XX.XX... XXXXX.X. ...XXXXX .....X.X ...X.... X.XXX..X X.X.X... ...."
        );
    }

    @TestCase
    public func testDecodeRow2binary12(): Unit {
        // (01)98898765432106(3103)001750
        assertCorrectImage2binary("12.png", " ..X..XX. XXXX..XX X.XX.XX. .X....XX XXX..XX. X..X.... .XX.XX.X .XX.");
    }

    @TestCase
    public func testDecodeRow2binary13(): Unit {
        // (01)90012345678908(3922)795
        assertCorrectImage2binary(
            "13.png",
            " ..XX..X. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. X.X.XXXX .X..X..X ......X."
        );
    }

    @TestCase
    public func testDecodeRow2binary14(): Unit {
        // (01)90012345678908(3932)0401234
        assertCorrectImage2binary(
            "14.png",
            " ..XX.X.. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. X.....X. X.....X. X.X.X.XX .X...... X..."
        );
    }

    @TestCase
    public func testDecodeRow2binary15(): Unit {
        // (01)90012345678908(3102)001750(11)100312
        assertCorrectImage2binary(
            "15.png",
            " ..XXX... ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX.."
        );
    }

    @TestCase
    public func testDecodeRow2binary16(): Unit {
        // (01)90012345678908(3202)001750(11)100312
        assertCorrectImage2binary(
            "16.png",
            " ..XXX..X ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX.."
        );
    }

    @TestCase
    public func testDecodeRow2binary17(): Unit {
        // (01)90012345678908(3102)001750(13)100312
        assertCorrectImage2binary(
            "17.png",
            " ..XXX.X. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX.."
        );
    }

    @TestCase
    public func testDecodeRow2binary18(): Unit {
        // (01)90012345678908(3202)001750(13)100312
        assertCorrectImage2binary(
            "18.png",
            " ..XXX.XX ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX.."
        );
    }

    @TestCase
    public func testDecodeRow2binary19(): Unit {
        // (01)90012345678908(3102)001750(15)100312
        assertCorrectImage2binary(
            "19.png",
            " ..XXXX.. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX.."
        );
    }

    @TestCase
    public func testDecodeRow2binary20(): Unit {
        // (01)90012345678908(3202)001750(15)100312
        assertCorrectImage2binary(
            "20.png",
            " ..XXXX.X ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX.."
        );
    }

    @TestCase
    public func testDecodeRow2binary21(): Unit {
        // (01)90012345678908(3102)001750(17)100312
        assertCorrectImage2binary(
            "21.png",
            " ..XXXXX. ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX.."
        );
    }

    @TestCase
    public func testDecodeRow2binary22(): Unit {
        // (01)90012345678908(3202)001750(17)100312
        assertCorrectImage2binary(
            "22.png",
            " ..XXXXXX ........ .X..XXX. X.X.X... XX.XXXXX .XXXX.X. ..XX...X .X.....X .XX..... XXXX.X.. XX.."
        );
    }

    private static func assertCorrectImage2binary(fileName: String, expected: String) {
        var path: Path = AbstractBlackBoxTestCase.buildTestBase("./rssexpanded-1").join(fileName)

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(path.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        var binaryMap: BinaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(BufferedImageLuminanceSource(imagei)));
        var rowNumber: Int64 = binaryMap.getHeight() / 2
        var row: BitArray = binaryMap.getBlackRow(rowNumber, BitArray());

        var pairs: ArrayList<ExpandedPair>
        try {
            var rssExpandedReader: RSSExpandedReader = RSSExpandedReader();
            pairs = rssExpandedReader.decodeRow2pairs(rowNumber, row)
        } catch (re: ReaderException) {
            return;
        }
        var binary: BitArray = BitArrayBuilder.buildBitArray(pairs);
        @Expect(expected, binary.toString())
    }
}
