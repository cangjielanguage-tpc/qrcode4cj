// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.datamatrix.decoder.*
import std.unittest.*
import std.unittest.testmacro.*

main(): Int64 {
    let tester = DecodedBitStreamParserTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class DecodedBitStreamParserTestCase {
    @TestCase
    public func testAsciiStandardDecode(): Unit {
        // ASCII characters 0-127 are encoded as the value + 1
        let bytes = [
            UInt8(r'a'.hashCode() + 1),
            UInt8(r'b'.hashCode() + 1),
            UInt8(r'c'.hashCode() + 1),
            UInt8(r'A'.hashCode() + 1),
            UInt8(r'B'.hashCode() + 1),
            UInt8(r'C'.hashCode() + 1)
        ]
        let decodedString = DecodedBitStreamParser.decode(bytes).getText();
        @Assert("abcABC", decodedString)
    }

    @TestCase
    public func testAsciiDoubleDigitDecode(): Unit {
        // ASCII double digit (00 - 99) Numeric Value + 130
        let bytes = [
            UInt8(130),
            UInt8(1 + 130),
            UInt8(98 + 130),
            UInt8(99 + 130)
        ]
        let decodedString = DecodedBitStreamParser.decode(bytes).getText();
        @Assert("00019899", decodedString)
    }
}
