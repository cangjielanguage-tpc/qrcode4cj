// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.tools.*
import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.oned.*
import QRCode4cj.tools.UTF32String
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.collection.*
import std.os.posix.*

main(): Int64 {
    let tester = EANManufacturerOrgSupportTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class EANManufacturerOrgSupportTest {
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
