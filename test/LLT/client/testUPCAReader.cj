// DEPENDENCE: ../pkgc/common/abstract_back_box_test_case.cj
// DEPENDENCE: ../pkgc/common/test_result.cj
// DEPENDENCE: ../test_common.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import QRCode4cj.oned.*
import QRCode4cj.common.*
import QRCode4cj.multi.*

main(): Int64 {
    let tester = Tester()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class Tester {
    @TestCase
    func t1(): Unit {
        var bitmatrix = UPCAWriter().encode("12345678910", BarcodeFormat.UPC_A, 120, 120)
        var bitmap = bitMatrixToBinaryBitmap(bitmatrix, bitmatrix.width, bitmatrix.height)
        var bitarr = bitmap.getBlackRow(50, BitArray())

        var reader = UPCAReader()
        var res = reader.decodeRow(50, bitarr, HashMap<DecodeHintType, Any>())
        @Assert(res.getBarcodeFormat().toString(),"UPC_A")
    }

    @TestCase
    func t2(): Unit {
        var bitmatrix = UPCAWriter().encode("12345678910", BarcodeFormat.UPC_A, 120, 120)
        var bitmap = bitMatrixToBinaryBitmap(bitmatrix, bitmatrix.width, bitmatrix.height)

        var reader = UPCAReader()
        var res = reader.decode(bitmap)
        @Assert(res.getBarcodeFormat().toString(),"UPC_A")
        res = reader.decode(bitmap, HashMap<DecodeHintType, Any>())
        @Assert(res.getBarcodeFormat().toString(),"UPC_A")
    }

    @TestCase
    func t3(): Unit {
        var reader = UPCAReader()
        @Assert(reader.getBarcodeFormat().toString(),"UPC_A")
    }

    @TestCase
    func t4(): Unit {
        var reader = UPCAReader()
        var decoder = ByQuadrantReader(reader)
        decoder.reset()
        var bitmatrix = UPCAWriter().encode("12345678910", BarcodeFormat.UPC_A, 120, 120)
        var bitmap = bitMatrixToBinaryBitmap(bitmatrix, bitmatrix.width, bitmatrix.height)
        try {
            decoder.decode(bitmap)
        } catch (e: Qrcoder4cjNotFoundException) {
            @Assert(reader.getBarcodeFormat().toString(),"UPC_A")
        }
    }
}

func bitMatrixToBinaryBitmap(bitMatrix: BitMatrix, width: Int64, height: Int64): BinaryBitmap {
    var image = Gray_p(Rectangle_p(0, 0, width, height))
    for (y in 0..height) {
        for (x in 0..width) {
            var gryc: GrayC
            if (bitMatrix.get(x, y)) {
                gryc = GrayC(0)
            } else {
                gryc = GrayC(255)
            }

            var colors: GrayC = (grayModel(gryc) as GrayC).getOrThrow()
            image.setGray(x, y, colors)
        }
    }
    var imageiop = image as ImageI
    var imagei: ImageI = imageiop.getOrThrow()
    var source: LuminanceSource = BufferedImageLuminanceSource(imagei)
    var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)
    var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer)
    return bitmap
}
