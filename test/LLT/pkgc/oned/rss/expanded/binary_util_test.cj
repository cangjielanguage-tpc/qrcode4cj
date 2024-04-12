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

// DEPENDENCE: ./binary_util.cj
// EXEC: cjc %import-path %L %l %f binary_util.cj
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
from QRCode4cj import zxing.code.tools.UTF32String
from std import unittest.*
from std import unittest.testmacro.*


main(): Int64 {
    let tester = BinaryUtilTest()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
@Test
public class BinaryUtilTest {
    private static let SPACE: Regex = Regex(" ");

    @TestCase
    public func testBuildBitArrayFromString(): Unit {
        var data: String = " ..X..X.. ..XXX... XXXXXXXX ........";
        check(data);

        data = " XXX..X.."
        check(data);

        data = " XX"
        check(data);

        data = " ....XX.. ..XX"
        check(data);

        data = " ....XX.. ..XX..XX ....X.X. ........"
        check(data);
    }

    private static func check(data: String) {
        var binary: BitArray = BinaryUtil.buildBitArrayFromString(data);
        @Expect(data, binary.toString())
    }

    @TestCase
    public func testBuildBitArrayFromStringWithoutSpaces(): Unit {
        var data: String = " ..X..X.. ..XXX... XXXXXXXX ........";
        checkWithoutSpaces(data);

        data = " XXX..X.."
        checkWithoutSpaces(data);

        data = " XX"
        checkWithoutSpaces(data);

        data = " ....XX.. ..XX"
        checkWithoutSpaces(data);

        data = " ....XX.. ..XX..XX ....X.X. ........"
        checkWithoutSpaces(data);
    }

    private static func checkWithoutSpaces(data: String) {
        var dataWithoutSpaces: String = SPACE.matcher(data).replaceAll("");
        var binary: BitArray = BinaryUtil.buildBitArrayFromStringWithoutSpaces(dataWithoutSpaces);
        @Expect(data, binary.toString())
    }
}
