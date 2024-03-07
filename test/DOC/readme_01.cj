// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import zxing.code.common.FormatException
from QRCode4cj import zxing.code.common.ResultPoint
from QRCode4cj import zxing.code.aztec.common.AztecDetectorResult
from QRCode4cj import zxing.code.common.BitArray
from QRCode4cj import zxing.code.common.BitMatrix
from QRCode4cj import zxing.code.common.DecoderResult
from QRCode4cj import zxing.code.aztec.decoder.Decoder
from charset import charset.tools.UTF32String
from std import unittest.*
from std import unittest.testmacro.*

main(): Int64 {
    let tester = DecoderTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
}

@Test
public class DecoderTestCase {
    @TestCase
    public func testDecode(): Unit {
        var matrix: BitMatrix = BitMatrix.parse(
            UTF32String(
                "X X X X X     X X X       X X X     X X X     \n" + "X X X     X X X     X X X X     X X X     X X \n" +
                "  X   X X       X   X   X X X X     X     X X \n" + "  X   X X     X X     X     X   X       X   X \n" +
                "  X X   X X         X               X X     X \n" + "  X X   X X X X X X X X X X X X X X X     X   \n" +
                "  X X X X X                       X   X X X   \n" + "  X   X   X   X X X X X X X X X   X X X   X X \n" +
                "  X   X X X   X               X   X X       X \n" + "  X X   X X   X   X X X X X   X   X X X X   X \n" +
                "  X X   X X   X   X       X   X   X   X X X   \n" + "  X   X   X   X   X   X   X   X   X   X   X   \n" +
                "  X X X   X   X   X       X   X   X X   X X   \n" + "  X X X X X   X   X X X X X   X   X X X   X X \n" +
                "X X   X X X   X               X   X   X X   X \n" + "  X       X   X X X X X X X X X   X   X     X \n" +
                "  X X   X X                       X X   X X   \n" + "  X X X   X X X X X X X X X X X X X X   X X   \n" +
                "X     X     X     X X   X X               X X \n" + "X   X X X X X   X X X X X     X   X   X     X \n" +
                "X X X   X X X X           X X X       X     X \n" + "X X     X X X     X X X X     X X X     X X   \n" +
                "    X X X     X X X       X X X     X X X X   \n"),
            UTF32String("X "),
            UTF32String("  ")
        )
        var aztecResult: AztecDetectorResult = AztecDetectorResult(matrix, Array<ResultPoint>(), false, 30, 2)
        var result: DecoderResult = Decoder().decode(aztecResult)
        @Assert("88888TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT", result.getText())
    }
}
