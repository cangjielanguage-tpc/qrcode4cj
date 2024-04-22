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
    let tester = FieldParserTest()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
@Test
public class FieldParserTest {
    private static func checkFields(expected: String) {
        let field: String = expected.replace("(", "").replace(")", "");
        let actual: String = FieldParser.parseFieldsInGeneralPurpose(UTF32String(field)).toString();
        @Expect(expected, actual)
    }

    @TestCase
    public func testParseField(): Unit {
        checkFields("(15)991231(3103)001750(10)12A");
    }

    @TestCase
    public func testParseField2(): Unit {
        checkFields("(15)991231(15)991231(3103)001750(10)12A");
    }
}
