// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.*
import QRCode4cj.qrcode.encoder.*
import QRCode4cj.qrcode.decoder.Mode
import QRCode4cj.qrcode.*
import QRCode4cj.qrcode.decoder.ErrorCorrectionLevel
import QRCode4cj.tools.UTF32String
import QRCode4cj.qrcode.decoder.Version
import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.unicode.*
import std.regex.*
import std.io.*

main(): Int64 {
    let tester = QRCodeTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

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
