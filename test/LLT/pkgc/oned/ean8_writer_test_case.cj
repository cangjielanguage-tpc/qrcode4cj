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
    let tester = EAN8WriterTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class EAN8WriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        var testStr: String = "0000001010001011010111101111010110111010101001110111001010001001011100101000000";

        var result: BitMatrix = EAN8Writer().encode("96385074", BarcodeFormat.EAN_8, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testAddChecksumAndEncode(): Unit {
        var testStr: String = "0000001010001011010111101111010110111010101001110111001010001001011100101000000";
        var result: BitMatrix = EAN8Writer().encode("9638507", BarcodeFormat.EAN_8, testStr.size, 0);
        @Expect(testStr, matrixToString(result))
    }

    @TestCase
    public func testEncodeIllegalCharacters(): Unit {
        try {
            EAN8Writer().encode("96385abc", BarcodeFormat.EAN_8, 0, 0);
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
