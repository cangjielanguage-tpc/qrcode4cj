/*
 * Copyright 2014 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from std import unittest.*
from std import unittest.testmacro.*
from QRCode4cj import zxing.code.common.*

main(): Int64 {
    let tester = RGBLuminanceSourceTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
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
