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
// import pkgc.oned.rss.expanded.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
abstract class AbstractDecoderTest {
    static let numeric10: String = "..X..XX";
    static let numeric12: String = "..X.X.X";
    static let numeric1FNC1: String = "..XXX.X";

    // static let String numericFNC11                  = "XXX.XXX";
    static let numeric2alpha: String = "....";

    static let alphaA: String = "X.....";
    static let alphaFNC1: String = ".XXXX";
    static let alpha2numeric: String = "...";
    static let alpha2isoiec646: String = "..X..";

    static let i646B: String = "X.....X";
    static let i646C: String = "X....X.";
    static let i646FNC1: String = ".XXXX";
    static let isoiec6462alpha: String = "..X..";

    static let compressedGtin900123456798908: String = ".........X..XXX.X.X.X...XX.XXXXX.XXXX.X.";
    static let compressedGtin900000000000008: String = "........................................";

    static let compressed15bitWeight1750: String = "....XX.XX.X.XX.";
    static let compressed15bitWeight11750: String = ".X.XX.XXXX..XX.";
    static let compressed15bitWeight0: String = "...............";

    static let compressed20bitWeight1750: String = ".........XX.XX.X.XX.";

    static let compressedDateMarch12th2010: String = "....XXXX.X..XX..";
    static let compressedDateEnd: String = "X..X.XX.........";

    static func assertCorrectBinaryString(binaryString: String, expectedNumber: String) {
        try {
            var binary: BitArray = BinaryUtil.buildBitArrayFromStringWithoutSpaces(binaryString);
            var decoder: AbstractExpandedDecoder = AbstractExpandedDecoder.createDecoder(binary);
            var result: String = decoder.parseInformation();
            @Expect(expectedNumber, result)
        } catch (re: Qrcoder4cjNotFoundException) {
            @Expect("Qrcoder4cjNotFoundException: ", re.toString())
        }
    }
}
