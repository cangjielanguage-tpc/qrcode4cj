// DEPENDENCE: ../../DOC/libs.cj
// EXEC: cjc %import-path %L %l %f libs.cj
// EXEC: ./main

import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.common.writer.*
import QRCode4cj.tools.UTF32String
import QRCode4cj.aztec.common.*
import std.collection.*
import std.fs.*
import std.unittest.*
import std.unittest.testmacro.*

main(): Int64 {
    let tester = DecoderTestCase()
    let test = tester.asTestSuite().runTests()
    test.errorCount + test.failedCount
}

@Test
public class DecoderTestCase {
    @TestCase
    public func testDecode(): Unit {
try{
        let content = String.fromUtf8([26])

        let mfw = MultiFormatWriter()
        var bitMatrixAfterEncode: BitMatrix = mfw.encode(content, BarcodeFormat.AZTEC, 480, 360)
        var bitmap = bitMatrixToBinaryBitmap(bitMatrixAfterEncode, bitMatrixAfterEncode.getWidth(),
            bitMatrixAfterEncode.getHeight())
        let hintType: DecodeHintType = DecodeHintType.TRY_HARDER
        var hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>()
        hints.put(hintType, true)
        let reader: MultiFormatReader = MultiFormatReader()
        let result = reader.decode(bitmap, hints)
}catch (e: Exception) {
    e.printStackTrace()
    
}

        //@Assert(content, result.getText())
    }
}


