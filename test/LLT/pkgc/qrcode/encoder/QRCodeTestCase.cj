/*
 * Copyright 2008 ZXing authors
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

from QRCode4cj import common.*
from QRCode4cj import qrcode.encoder.*
from QRCode4cj import qrcode.decoder.Mode
from QRCode4cj import qrcode.*
from QRCode4cj import qrcode.decoder.ErrorCorrectionLevel
from QRCode4cj import tools.UTF32String
from QRCode4cj import qrcode.decoder.Version
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import regex.*
from std import io.*

main(): Int64 {
    let tester = QRCodeTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * @author satorux@google.com (Satoru Takabayashi) - creator
 * @author mysen@google.com (Chris Mysen) - ported from C++
 */
@Test
public class QRCodeTestCase {
    @TestCase
    public func test(): Unit {
        var qrCode: QRCode = QRCode();

        // First, test simple setters and getters.
        // We use numbers of version 7-H.
        qrCode.setMode(Mode.BYTE([8, 16, 16], 0x04));
        qrCode.setECLevel(ErrorCorrectionLevel.H(0x02));
        qrCode.setVersion(Version.getVersionForNumber(7));
        qrCode.setMaskPattern(3);

        @Assert(Mode.BYTE([8, 16, 16], 0x04), qrCode.getMode())
        @Assert(ErrorCorrectionLevel.H(0x02), qrCode.getECLevel())
        @Assert(7, qrCode.getVersion().getVersionNumber())
        @Assert(3, qrCode.getMaskPattern())

        // Prepare the matrix.
        var matrix: ByteMatrix = ByteMatrix(45, 45);

        // Just set bogus zero/one values.
        for (y in 0..45) {
            for (x in 0..45) {
                matrix.set(x, y, (y + x) % 2);
            }
        }

        // Set the matrix.
        qrCode.setMatrix(matrix);
        @Assert(matrix, qrCode.getMatrix())
    }

    @TestCase
    public func testToString1(): Unit {
        var qrCode: QRCode = QRCode();
        var expected: String = "<<\n" + " mode: null\n" + " ecLevel: M\n" + " version: null\n" + " maskPattern: -1\n" +
            " matrix: null\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    @TestCase
    public func testToString2(): Unit {
        var qrCode: QRCode = QRCode();
        qrCode.setMode(Mode.BYTE([8, 16, 16], 0x04));
        qrCode.setECLevel(ErrorCorrectionLevel.H(0x02));
        qrCode.setVersion(Version.getVersionForNumber(1));
        qrCode.setMaskPattern(3);
        var matrix: ByteMatrix = ByteMatrix(21, 21);
        for (y in 0..21) {
            for (x in 0..21) {
                matrix.set(x, y, (y + x) % 2);
            }
        }
        qrCode.setMatrix(matrix);
        var expected: String = "<<\n" + " mode: BYTE\n" + " ecLevel: H\n" + " version: 1\n" + " maskPattern: 3\n" +
            " matrix:\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" +
            " 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1\n" + " 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    @TestCase
    public func testIsValidMaskPattern(): Unit {
        @Assert(false,QRCode.isValidMaskPattern(-1))
        @Assert(QRCode.isValidMaskPattern(0))
        @Assert(QRCode.isValidMaskPattern(7))
        @Assert(false,QRCode.isValidMaskPattern(8))
    }
}
