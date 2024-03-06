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

// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import zxing.code.tools.*
from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.common.reader.*
from QRCode4cj import zxing.code.oned.*
from charset import charset.tools.UTF32String
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import collection.*
from std import os.posix.*

main(): Int64 {
    let tester = EANManufacturerOrgSupportTest()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link EANManufacturerOrgSupport}.
 *
 * @author Sean Owen
 */
@Test
public open class EANManufacturerOrgSupportTest {
    @TestCase
    public func testLookup(): Unit {
        var support: EANManufacturerOrgSupport = EANManufacturerOrgSupport()
        @Expect(support.lookupCountryIdentifier(UTF32String("472000")),"")
        @Expect("US/CA", support.lookupCountryIdentifier(UTF32String("000000")))
        @Expect("MO", support.lookupCountryIdentifier(UTF32String("958000")))
        @Expect("GB", support.lookupCountryIdentifier(UTF32String("500000")))
        @Expect("GB", support.lookupCountryIdentifier(UTF32String("509000")))
    }
}
