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
    let tester = UPCAWriterTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class UPCAWriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        var testStr: String = "00001010100011011011101100010001011010111101111010101011100101110100100111011001101101100101110010100000";
        var result: BitMatrix = UPCAWriter().encode("485963095124", BarcodeFormat.UPC_A, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testAddChecksumAndEncode(): Unit {
        var testStr: String = "00001010011001001001101111010100011011000101011110101010001001001000111010011100101100110110110010100000";
        var result: BitMatrix = UPCAWriter().encode("12345678901", BarcodeFormat.UPC_A, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }
}

public func matrixToString(result: BitMatrix): String {
    @Assert(1, result.getHeight())
    var builder: StringBuilder = StringBuilder();
    for (i in 0..result.getWidth()) {
        builder.append(
            if (result.get(i, 0)) {
                "1"
            } else {
                "0"
            }
        );
    }
    return builder.toString();
}