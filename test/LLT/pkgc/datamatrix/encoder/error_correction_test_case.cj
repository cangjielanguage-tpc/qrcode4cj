// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.datamatrix.encoder.*
import std.unittest.*
import std.unittest.testmacro.*
import QRCode4cj.tools.UTF32String

main(): Int64 {
    let tester = ErrorCorrectionTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests for the ECC200 error correction.
 */
@Test
public class ErrorCorrectionTestCase {
    @TestCase
    public func testRS(): Unit {
        //Sample from Annexe R in ISO/IEC 16022:2000(E)
        var cw: Array<Rune> = [Rune(142), Rune(164), Rune(186)]
        let symbolInfo: ?SymbolInfo = SymbolInfo.lookup(3);
        var s: String = ErrorCorrection.encodeECC200(UTF32String(cw), symbolInfo.getOrThrow());
        @Assert("142 164 186 114 25 5 88 102", visualize(UTF32String(s)))

        //"A" encoded (ASCII encoding + 2 padding characters)
        cw = [Rune(66), Rune(129), Rune(70)]
        s = ErrorCorrection.encodeECC200(UTF32String(cw), symbolInfo.getOrThrow())
        @Assert("66 129 70 138 234 82 82 95", visualize(UTF32String(s)))
    }
}

func visualize(codewords: UTF32String): String {
    var sb: StringBuilder = StringBuilder();
    for (i in 0..codewords.charSize) {
        if (i > 0) {
            sb.append(' ');
        }
        sb.append(codewords.get(i).hashCode())
    }
    return sb.toString();
}
