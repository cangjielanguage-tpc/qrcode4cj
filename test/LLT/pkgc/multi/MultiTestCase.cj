// DEPENDENCE: ../../test_common.cj
// DEPENDENCE: ../../resources/blackbox/multi-1/1.png
// DEPENDENCE: ../common/abstract_back_box_test_case.cj
// DEPENDENCE: ../common/test_result.cj
// EXEC: cjc %import-path %L %l %f ./abstract_back_box_test_case.cj ./test_result.cj ./test_common.cj
// EXEC: ./main

import QRCode4cj.multi.GenericMultipleBarcodeReader
import QRCode4cj.multi.MultipleBarcodeReader
import QRCode4cj.common.reader.*
import QRCode4cj.common.*
import std.fs.*
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*

main(): Int64 {
    let tester = MultiTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link MultipleBarcodeReader}.
 */
@Test
public class MultiTestCase {
    @TestCase
    public func testMulti(): Unit {
        // Very basic test for now
        var testBase: Path = Path("./1.png")

        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(testBase.toString())

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        var source: LuminanceSource = BufferedImageLuminanceSource(imagei)
        var bitmap: BinaryBitmap = BinaryBitmap(HybridBinarizer(source))

        var reader: MultipleBarcodeReader = GenericMultipleBarcodeReader(MultiFormatReader())
        var results: Array<Result> = reader.decodeMultiple(bitmap)
        @Assert(!results.isEmpty())
        @Assert(2, results.size)

        @Assert("031415926531", results[0].getText())
        @Assert(BarcodeFormat.UPC_A, results[0].getBarcodeFormat())

        @Assert("www.airtable.com/jobs", results[1].getText())
        @Assert(BarcodeFormat.QR_CODE, results[1].getBarcodeFormat())
    }
}
