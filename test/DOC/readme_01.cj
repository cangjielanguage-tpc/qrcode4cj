// DEPENDENCE: ./libs.cj
// EXEC: cjc %import-path %L %l %f libs.cj
// EXEC: ./main

from QRCode4cj import common.*
from QRCode4cj import common.reader.*
from QRCode4cj import common.writer.*
from QRCode4cj import tools.UTF32String
from std import collection.*
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
        let content = "ABCDEF"
        let mfw = MultiFormatWriter();
        var bitMatrixAfterEncode: BitMatrix = mfw.encode(content, BarcodeFormat.AZTEC, 30, 30)
        var bitmap = bitMatrixToBinaryBitmap(bitMatrixAfterEncode, bitMatrixAfterEncode.getWidth(),
            bitMatrixAfterEncode.getHeight())
        let hintType: DecodeHintType = DecodeHintType.TRY_HARDER
        var hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>()
        hints.put(hintType, true)
        let reader: MultiFormatReader = MultiFormatReader()
        let result = reader.decode(bitmap, hints)
        @Assert(content, result.getText())
    }
}
