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

// DEPENDENCE: ./abstract_decoder_test.cj
// DEPENDENCE: ../binary_util.cj
// EXEC: cjc %import-path %L %l %f abstract_decoder_test.cj binary_util.cj
// EXEC: ./main

from QRCode4cj import tools.*
from QRCode4cj import common.*
from QRCode4cj import oned.*
from QRCode4cj import oned.rss.*
from QRCode4cj import oned.rss.expanded.*
from QRCode4cj import oned.rss.expanded.decoders.*
from QRCode4cj import client.result.*
from QRCode4cj import common.reader.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import regex.*
from std import collection.*
from std import convert.*
from std import fs.*
from std import log.*
from std import os.posix.*
from QRCode4cj import tools.UTF32String
from std import unittest.*
from std import unittest.testmacro.*


main(): Int64 {
    let tester = AI013X0X1XDecoderTest()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
@Test
public class AI013X0X1XDecoderTest {
    private static let header310x11: String = "..XXX...";
    private static let header320x11: String = "..XXX..X";
    private static let header310x13: String = "..XXX.X.";
    private static let header320x13: String = "..XXX.XX";
    private static let header310x15: String = "..XXXX..";
    private static let header320x15: String = "..XXXX.X";
    private static let header310x17: String = "..XXXXX.";
    private static let header320x17: String = "..XXXXXX";

    @TestCase
    public func test01310X1XendDate(): Unit {
        let data: String = header310x11 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateEnd
        let expected: String = "(01)90012345678908(3100)001750";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01310X111(): Unit {
        let data: String = header310x11 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3100)001750(11)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01320X111(): Unit {
        let data: String = header320x11 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3200)001750(11)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01310X131(): Unit {
        let data: String = header310x13 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3100)001750(13)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01320X131(): Unit {
        let data: String = header320x13 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3200)001750(13)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01310X151(): Unit {
        let data: String = header310x15 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3100)001750(15)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01320X151(): Unit {
        let data: String = header320x15 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3200)001750(15)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01310X171(): Unit {
        let data: String = header310x17 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3100)001750(17)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }

    @TestCase
    public func test01320X171(): Unit {
        let data: String = header320x17 + AbstractDecoderTest.compressedGtin900123456798908 + AbstractDecoderTest.
            compressed20bitWeight1750 + AbstractDecoderTest.compressedDateMarch12th2010
        let expected: String = "(01)90012345678908(3200)001750(17)100312";

        AbstractDecoderTest.assertCorrectBinaryString(data, expected);
    }
}
