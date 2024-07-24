// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.EncodeHintType
import QRCode4cj.common.Qrcoder4cjWriterException
import QRCode4cj.common.BitMatrix
import QRCode4cj.pdf417.PDF417Writer
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.collection.*

main(): Int64 {
    let tester = PDF417WriterTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link PDF417Writer}.
 */
@Test
public class PDF417WriterTestCase {
    @TestCase
    public func testDataMatrixImageWriter(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.MARGIN, 0);
        var size: Int64 = 64;
        var writer: PDF417Writer = PDF417Writer();
        var matrix: BitMatrix = writer.encode("Hello Google", BarcodeFormat.PDF_417, size, size, hints);
        @Assert(matrix.flag)
        var expected: String = "X X X X X X X X   X   X   X       X X X X   X   X   X X X X         X X   X   X           X X         X X X X   X X     X     X X X     X X   X           X       X X     X X X X X   X   X   X X X X X     X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X   X   X   X X X X         X X   X   X           X X         X X X X   X X     X     X X X     X X   X           X       X X     X X X X X   X   X   X X X X X     X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X   X   X   X X X X         X X   X   X           X X         X X X X   X X     X     X X X     X X   X           X       X X     X X X X X   X   X   X X X X X     X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X   X   X   X X X X         X X   X   X           X X         X X X X   X X     X     X X X     X X   X           X       X X     X X X X X   X   X   X X X X X     X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X   X   X         X         X   X X     X     X X X X X X     X X X           X   X X       X   X X X   X           X X     X     X X X X X X   X   X   X X X       X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X   X   X         X         X   X X     X     X X X X X X     X X X           X   X X       X   X X X   X           X X     X     X X X X X X   X   X   X X X       X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X   X   X         X         X   X X     X     X X X X X X     X X X           X   X X       X   X X X   X           X X     X     X X X X X X   X   X   X X X       X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X   X   X         X         X   X X     X     X X X X X X     X X X           X   X X       X   X X X   X           X X     X     X X X X X X   X   X   X X X       X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X   X   X     X X X X             X   X X X       X       X X       X     X X   X X     X X X X       X X       X X X X X     X     X   X   X   X         X X X X         X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X   X   X     X X X X             X   X X X       X       X X       X     X X   X X     X X X X       X X       X X X X X     X     X   X   X   X         X X X X         X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X   X   X     X X X X             X   X X X       X       X X       X     X X   X X     X X X X       X X       X X X X X     X     X   X   X   X         X X X X         X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X   X   X     X X X X             X   X X X       X       X X       X     X X   X X     X X X X       X X       X X X X X     X     X   X   X   X         X X X X         X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X   X   X X X X     X X X X       X         X X       X X     X     X   X     X X X X       X X X X   X       X X       X X         X   X X   X   X X X X     X X X X X   X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X   X   X X X X     X X X X       X         X X       X X     X     X   X     X X X X       X X X X   X       X X       X X         X   X X   X   X X X X     X X X X X   X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X   X   X X X X     X X X X       X         X X       X X     X     X   X     X X X X       X X X X   X       X X       X X         X   X X   X   X X X X     X X X X X   X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X   X   X X X X     X X X X       X         X X       X X     X     X   X     X X X X       X X X X   X       X X       X X         X   X X   X   X X X X     X X X X X   X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X   X   X X X           X       X X     X       X X X     X       X X X X X X   X X   X     X X     X   X X X   X     X X X X X       X X X   X   X X X     X X         X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X   X   X X X           X       X X     X       X X X     X       X X X X X X   X X   X     X X     X   X X X   X     X X X X X       X X X   X   X X X     X X         X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X   X   X X X           X       X X     X       X X X     X       X X X X X X   X X   X     X X     X   X X X   X     X X X X X       X X X   X   X X X     X X         X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X   X   X X X           X       X X     X       X X X     X       X X X X X X   X X   X     X X     X   X X X   X     X X X X X       X X X   X   X X X     X X         X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X X   X   X X X X   X X     X           X   X       X X X X   X       X   X         X X X X     X           X X X   X       X X   X X X X   X   X X X X X   X X     X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X X   X   X X X X   X X     X           X   X       X X X X   X       X   X         X X X X     X           X X X   X       X X   X X X X   X   X X X X X   X X     X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X X   X   X X X X   X X     X           X   X       X X X X   X       X   X         X X X X     X           X X X   X       X X   X X X X   X   X X X X X   X X     X X X X X X X   X       X   X     X \n" +
            "X X X X X X X X   X   X   X       X X X X X   X   X X X X   X X     X           X   X       X X X X   X       X   X         X X X X     X           X X X   X       X X   X X X X   X   X X X X X   X X     X X X X X X X   X       X   X     X \n"
        @Assert(expected, matrix.toString())
    }
}
