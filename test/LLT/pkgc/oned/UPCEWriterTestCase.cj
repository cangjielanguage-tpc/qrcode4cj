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
    let tester = UPCEWriterTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link UPCEWriter}.
 */
@Test
public class UPCEWriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        doTest(
            "05096893",
            "0000000000010101110010100111000101101011110110111001011101010100000000000"
        );
    }

    @TestCase
    public func testEncodeSystem1(): Unit {
        doTest(
            "12345670",
            "0000000000010100100110111101010001101110010000101001000101010100000000000"
        );
    }

    @TestCase
    public func testAddChecksumAndEncode(): Unit {
        doTest(
            "0509689",
            "0000000000010101110010100111000101101011110110111001011101010100000000000"
        );
    }

    private static func doTest(content: String, encoding: String) {
        var result: BitMatrix = UPCEWriter().encode(content, BarcodeFormat.UPC_E, encoding.size, 0);
        @Assert(encoding, matrixToString(result))
    }

    @TestCase
    public func testEncodeIllegalCharacters(): Unit {
        try {
            UPCEWriter().encode("05096abc", BarcodeFormat.UPC_E, 0, 0);
            @Assert(false)
        } catch (i: IllegalArgumentException) {
            @Assert(true)
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