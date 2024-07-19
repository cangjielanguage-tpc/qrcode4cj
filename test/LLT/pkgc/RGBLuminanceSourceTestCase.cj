// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import std.unittest.*
import std.unittest.testmacro.*
import QRCode4cj.common.*

main(): Int64 {
    let tester = RGBLuminanceSourceTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link RGBLuminanceSource}.
 */
@Test
public class RGBLuminanceSourceTestCase {
    static let slurceData: Array<Int64> = [
        0x000000,
        0x7F7F7F,
        0xFFFFFF,
        0xFF0000,
        0x00FF00,
        0x0000FF,
        0x0000FF,
        0x00FF00,
        0xFF0000
    ]
    private static let SOURCE: RGBLuminanceSource = RGBLuminanceSource(3, 3, slurceData);

    @TestCase
    public func testCrop(): Unit {
        @Expect(SOURCE.isCropSupported(),true)
        var cropped: LuminanceSource = SOURCE.crop(1, 1, 1, 1);
        @Expect(1, cropped.getHeight())
        @Expect(1, cropped.getWidth())
        @Expect(Array<UInt8>([0x7F]), cropped.getRow(0, Array<UInt8>()))
    }

    @TestCase
    public func testMatrix(): Unit {
        @Expect(
            Array<UInt8>([0x00, 0x7F, 0xFF, 0x3F, 0x7F, 0x3F, 0x3F, 0x7F, 0x3F]),
            SOURCE.getMatrix()
        )
        var croppedFullWidth: LuminanceSource = SOURCE.crop(0, 1, 3, 2);
        @Expect(
            Array<UInt8>([0x3F, 0x7F, 0x3F, 0x3F, 0x7F, 0x3F]),
            croppedFullWidth.getMatrix()
        )
        var croppedCorner: LuminanceSource = SOURCE.crop(1, 1, 2, 2);
        @Expect(
            Array<UInt8>([0x7F, 0x3F, 0x7F, 0x3F]),
            croppedCorner.getMatrix()
        )
    }

    @TestCase
    public func testGetRow(): Unit {
        @Expect(Array<UInt8>([0x3F, 0x7F, 0x3F]), SOURCE.getRow(2, Array<UInt8>(3, item: 0)))
    }

    @TestCase
    public func testToString(): Unit {
        @Expect("#+ \n#+#\n#+#\n", SOURCE.toString())
    }
}
