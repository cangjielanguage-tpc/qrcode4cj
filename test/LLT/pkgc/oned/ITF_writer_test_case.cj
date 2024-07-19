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
    let tester = ITFWriterTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link ITFWriter}.
 */
@Test
public class ITFWriterTestCase {
    @TestCase
    public func testEncode(): Unit {
        doTest(
            "00123456789012",
            "0000010101010111000111000101110100010101110001110111010001010001110100011" +
                "100010101000101011100011101011101000111000101110100010101110001110100000"
        );
    }

    private static func doTest(input: String, expected: String) {
        var result: BitMatrix = ITFWriter().encode(input, BarcodeFormat.ITF, 0, 0)
        @Expect(expected, matrixToString(result))
    }

    @TestCase
    public func testEncodeIllegalCharacters(): Unit {
        try {
            ITFWriter().encode("00123456789abc", BarcodeFormat.ITF, 0, 0);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Input should only contain digits 0-9")
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
