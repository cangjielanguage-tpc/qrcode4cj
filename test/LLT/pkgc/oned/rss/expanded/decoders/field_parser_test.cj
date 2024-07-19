// DEPENDENCE: ./abstract_decoder_test.cj
// DEPENDENCE: ../binary_util.cj
// EXEC: cjc %import-path %L %l %f abstract_decoder_test.cj binary_util.cj
// EXEC: ./main

import QRCode4cj.tools.*
import QRCode4cj.common.*
import QRCode4cj.oned.*
import QRCode4cj.oned.rss.*
import QRCode4cj.oned.rss.expanded.*
import QRCode4cj.oned.rss.expanded.decoders.*
import QRCode4cj.client.result.*
import QRCode4cj.common.reader.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.regex.*
import std.collection.*
import std.convert.*
import std.fs.*
import std.log.*
import std.os.posix.*
import QRCode4cj.tools.UTF32String
import std.unittest.*
import std.unittest.testmacro.*


main(): Int64 {
    let tester = FieldParserTest()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

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
