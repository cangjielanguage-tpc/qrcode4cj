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

from QRCode4cj import tools.*
from QRCode4cj import common.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = PlanarYUVLuminanceSourceTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * Tests {@link PlanarYUVLuminanceSource}.
 */
@Test
public class PlanarYUVLuminanceSourceTestCase {
    private static let YUV: Array<UInt8> = ([
        0,
        1,
        1,
        2,
        3,
        5,
        8,
        13,
        21,
        34,
        55,
        89,
        0,
        255,
        255,
        254,
        253,
        251,
        248,
        243,
        235,
        222,
        201,
        167,
        127,
        127,
        127,
        127,
        127,
        127,
        127,
        127,
        127,
        127,
        127,
        127
    ])
    private static let COLS: Int64 = 6;
    private static let ROWS: Int64 = 4;
    private static var Y: Array<UInt8> = Array<UInt8>(COLS * ROWS, item: 0)

    init() {
        YUV.copyTo(Y, 0, 0, Y.size);
    }

    @TestCase
    public func testNoCrop(): Unit {
        var source: PlanarYUVLuminanceSource = PlanarYUVLuminanceSource(YUV, COLS, ROWS, 0, 0, COLS, ROWS, false);
        assertEquals(Y, 0, source.getMatrix(), 0, Y.size);

        for (r in 0..ROWS) {
            assertEquals(Y, r * COLS, source.getRow(r, Array<UInt8>()), 0, COLS);
        }
    }

    @TestCase
    public func testCrop(): Unit {
        var source: PlanarYUVLuminanceSource = PlanarYUVLuminanceSource(YUV, COLS, ROWS, 1, 1, COLS - 2, ROWS - 2, false
        );
        @Expect(source.isCropSupported(),true)
        var cropMatrix: Array<UInt8> = source.getMatrix();
        for (r in 0..ROWS - 2) {
            assertEquals(Y, (r + 1) * COLS + 1, cropMatrix, r * (COLS - 2), COLS - 2);
        }
        for (r in 0..ROWS - 2) {
            assertEquals(Y, (r + 1) * COLS + 1, source.getRow(r, Array<UInt8>()), 0, COLS - 2);
        }
    }

    @TestCase
    public func testThumbnail(): Unit {
        var source: PlanarYUVLuminanceSource = PlanarYUVLuminanceSource(YUV, COLS, ROWS, 0, 0, COLS, ROWS, false);
        @Expect(
            Array<Int64>([0xFF000000, 0xFF010101, 0xFF030303, 0xFF000000, 0xFFFFFFFF, 0xFFFDFDFD]),
            source.renderThumbnail()
        )
    }

    private static func assertEquals(
        expected: Array<UInt8>,
        expectedFrom: Int64,
        actual: Array<UInt8>,
        actualFrom: Int64,
        size: Int64
    ) {
        for (i in 0..size) {
            @Expect(expected[expectedFrom + i], actual[actualFrom + i])
        }
    }
}
