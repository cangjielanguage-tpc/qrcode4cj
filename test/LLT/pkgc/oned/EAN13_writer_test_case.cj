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
    let tester = EAN13WriterTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class EAN13WriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        var testStr: String = "00001010001011010011101100110010011011110100111010101011001101101100100001010111001001110100010010100000";
        var result: BitMatrix = EAN13Writer().encode("5901234123457", BarcodeFormat.EAN_13, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testAddChecksumAndEncode(): Unit {
        var testStr: String = "00001010001011010011101100110010011011110100111010101011001101101100100001010111001001110100010010100000";
        var result: BitMatrix = EAN13Writer().encode("590123412345", BarcodeFormat.EAN_13, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testEncodeIllegalCharacters(): Unit {
        try {
            EAN13Writer().encode("5901234123abc", BarcodeFormat.EAN_13, 0, 0);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Illegal contents")
        }
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