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
    let tester = MatrixUtilTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class MatrixUtilTestCase {
    @TestCase
    public func testToString(): Unit {
        var array: ByteMatrix = ByteMatrix(3, 3);
        array.set(0, 0, 0);
        array.set(1, 0, 1);
        array.set(2, 0, 0);
        array.set(0, 1, 1);
        array.set(1, 1, 0);
        array.set(2, 1, 1);
        array.set(0, 2, -1);
        array.set(1, 2, -1);
        array.set(2, 2, -1);
        var expected: String = " 0 1 0\n" + " 1 0 1\n" + "      \n"
        @Assert(expected, array.toString())
    }

    @TestCase
    public func testClearMatrix(): Unit {
        var matrix: ByteMatrix = ByteMatrix(2, 2);
        MatrixUtil.clearMatrix(matrix);
        @Assert(255, matrix.get(0, 0))
        @Assert(255, matrix.get(1, 0))
        @Assert(255, matrix.get(0, 1))
        @Assert(255, matrix.get(1, 1))
    }

    @TestCase
    public func testEmbedBasicPatterns1(): Unit {
        // Version 1.
        var matrix: ByteMatrix = ByteMatrix(21, 21);
        MatrixUtil.clearMatrix(matrix);
        MatrixUtil.embedBasicPatterns(Version.getVersionForNumber(1), matrix);
        var expected: String = " 1 1 1 1 1 1 1 0           0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0           0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0           0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0           0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0           0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0           0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0           0 0 0 0 0 0 0 0\n" + "             1                            \n" +
            "             0                            \n" + "             1                            \n" +
            "             0                            \n" + "             1                            \n" +
            " 0 0 0 0 0 0 0 0 1                        \n" + " 1 1 1 1 1 1 1 0                          \n" +
            " 1 0 0 0 0 0 1 0                          \n" + " 1 0 1 1 1 0 1 0                          \n" +
            " 1 0 1 1 1 0 1 0                          \n" + " 1 0 1 1 1 0 1 0                          \n" +
            " 1 0 0 0 0 0 1 0                          \n" + " 1 1 1 1 1 1 1 0                          \n"
        @Assert(expected, matrix.toString())
    }

    @TestCase
    public func testEmbedBasicPatterns2(): Unit {
        // Version 2.  Position adjustment pattern should apppear at right
        // bottom corner.
        var matrix: ByteMatrix = ByteMatrix(25, 25);
        MatrixUtil.clearMatrix(matrix);
        MatrixUtil.embedBasicPatterns(Version.getVersionForNumber(2), matrix);
        var expected: String = " 1 1 1 1 1 1 1 0                   0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0                   0 1 0 0 0 0 0 1\n" +
            " 1 0 1 1 1 0 1 0                   0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0                   0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0                   0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0                   0 1 0 0 0 0 0 1\n" +
            " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0                   0 0 0 0 0 0 0 0\n" +
            "             1                                    \n" +
            "             0                                    \n" +
            "             1                                    \n" +
            "             0                                    \n" +
            "             1                                    \n" +
            "             0                                    \n" +
            "             1                                    \n" +
            "             0                                    \n" +
            "             1                   1 1 1 1 1        \n" +
            " 0 0 0 0 0 0 0 0 1               1 0 0 0 1        \n" +
            " 1 1 1 1 1 1 1 0                 1 0 1 0 1        \n" +
            " 1 0 0 0 0 0 1 0                 1 0 0 0 1        \n" +
            " 1 0 1 1 1 0 1 0                 1 1 1 1 1        \n" +
            " 1 0 1 1 1 0 1 0                                  \n" +
            " 1 0 1 1 1 0 1 0                                  \n" +
            " 1 0 0 0 0 0 1 0                                  \n" +
            " 1 1 1 1 1 1 1 0                                  \n"
        @Assert(expected, matrix.toString())
    }

    @TestCase
    public func testEmbedTypeInfo(): Unit {
        // Type info bits = 100000011001110.
        var matrix: ByteMatrix = ByteMatrix(21, 21);
        MatrixUtil.clearMatrix(matrix);
        MatrixUtil.embedTypeInfo(ErrorCorrectionLevel.M(0x00), 5, matrix);
        var expected: String = "                 0                        \n" +
            "                 1                        \n" + "                 1                        \n" +
            "                 1                        \n" + "                 0                        \n" +
            "                 0                        \n" + "                                          \n" +
            "                 1                        \n" + " 1 0 0 0 0 0   0 1         1 1 0 0 1 1 1 0\n" +
            "                                          \n" + "                                          \n" +
            "                                          \n" + "                                          \n" +
            "                                          \n" + "                 0                        \n" +
            "                 0                        \n" + "                 0                        \n" +
            "                 0                        \n" + "                 0                        \n" +
            "                 0                        \n" + "                 1                        \n"
        @Assert(expected, matrix.toString())
    }

    @TestCase
    public func testEmbedVersionInfo(): Unit {
        // Version info bits = 000111 110010 010100
        // Actually, version 7 QR Code has 45x45 matrix but we use 21x21 here
        // since 45x45 matrix is too big to depict.
        var matrix: ByteMatrix = ByteMatrix(21, 21);
        MatrixUtil.clearMatrix(matrix);
        MatrixUtil.maybeEmbedVersionInfo(Version.getVersionForNumber(7), matrix);
        var expected: String = "                     0 0 1                \n" +
            "                     0 1 0                \n" + "                     0 1 0                \n" +
            "                     0 1 1                \n" + "                     1 1 1                \n" +
            "                     0 0 0                \n" + "                                          \n" +
            "                                          \n" + "                                          \n" +
            "                                          \n" + " 0 0 0 0 1 0                              \n" +
            " 0 1 1 1 1 0                              \n" + " 1 0 0 1 1 0                              \n" +
            "                                          \n" + "                                          \n" +
            "                                          \n" + "                                          \n" +
            "                                          \n" + "                                          \n" +
            "                                          \n" + "                                          \n"
        @Assert(expected, matrix.toString())
    }

    @TestCase
    public func testEmbedDataBits(): Unit {
        // Cells other than basic patterns should be filled with zero.
        var matrix: ByteMatrix = ByteMatrix(21, 21);
        MatrixUtil.clearMatrix(matrix);
        MatrixUtil.embedBasicPatterns(Version.getVersionForNumber(1), matrix);
        var bits: BitArray = BitArray();
        MatrixUtil.embedDataBits(bits, -1, matrix);
        var expected: String = " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" + " 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" +
            " 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" + " 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" +
            " 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" + " 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" +
            " 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0\n" + " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" + " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" +
            " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" + " 1 0 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n" + " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n"
        @Assert(expected, matrix.toString())
    }

    @TestCase
    public func testBuildMatrix(): Unit {
        // From http://www.swetake.com/qr/qr7.html
        var bytes: Array<Int64> = [
            32,
            65,
            205,
            69,
            41,
            220,
            46,
            128,
            236,
            42,
            159,
            74,
            221,
            244,
            169,
            239,
            150,
            138,
            70,
            237,
            85,
            224,
            96,
            74,
            219,
            61
        ]
        var bits: BitArray = BitArray();
        for (c in bytes) {
            bits.appendBits(c, 8);
        }
        var matrix: ByteMatrix = ByteMatrix(21, 21);
        MatrixUtil.buildMatrix(
            bits,
            ErrorCorrectionLevel.H(0x02),
            Version.getVersionForNumber(1), // Version 1
            3, // Mask pattern 3
            matrix
        );
        var expected: String = " 1 1 1 1 1 1 1 0 0 1 1 0 0 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0 0 0 0 1 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 1 1 0 0 0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 1 1 0 0 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 1 1 0 1 1 0 0 0 0 0 0 0 0\n" + " 0 0 1 1 0 0 1 1 1 0 0 1 1 1 1 0 1 0 0 0 0\n" +
            " 1 0 1 0 1 0 0 0 0 0 1 1 1 0 0 1 0 1 1 1 0\n" + " 1 1 1 1 0 1 1 0 1 0 1 1 1 0 0 1 1 1 0 1 0\n" +
            " 1 0 1 0 1 1 0 1 1 1 0 0 1 1 1 0 0 1 0 1 0\n" + " 0 0 1 0 0 1 1 1 0 0 0 0 0 0 1 0 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 1 1 0 1 0 0 0 0 0 1 0 1 1\n" + " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 0 0 1 0 1 1 0\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 1 0 1 1 1 0 0 0 0 0\n" + " 1 0 1 1 1 0 1 0 0 1 0 0 1 1 0 0 1 0 0 1 1\n" +
            " 1 0 1 1 1 0 1 0 1 1 0 1 0 0 0 0 0 1 1 1 0\n" + " 1 0 1 1 1 0 1 0 1 1 1 1 0 0 0 0 1 1 1 0 0\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 1 0 0\n" + " 1 1 1 1 1 1 1 0 0 0 1 1 1 1 1 0 1 0 0 1 0\n"
        @Assert(expected, matrix.toString())
    }

    @TestCase
    public func testFindMSBSet(): Unit {
        @Assert(0, MatrixUtil.findMSBSet(0))
        @Assert(1, MatrixUtil.findMSBSet(1))
        @Assert(8, MatrixUtil.findMSBSet(0x80))
        @Assert(32, MatrixUtil.findMSBSet(0x80000000))
    }

    @TestCase
    public func testCalculateBCHCode(): Unit {
        // Encoding of type information.
        // From Appendix C in JISX0510:2004 (p 65)
        @Assert(0xdc, MatrixUtil.calculateBCHCode(5, 0x537))

        // From http://www.swetake.com/qr/qr6.html
        @Assert(0x1c2, MatrixUtil.calculateBCHCode(0x13, 0x537))

        // From http://www.swetake.com/qr/qr11.html
        @Assert(0x214, MatrixUtil.calculateBCHCode(0x1b, 0x537))

        // Encoding of version information.
        // From Appendix D in JISX0510:2004 (p 68)
        @Assert(0xc94, MatrixUtil.calculateBCHCode(7, 0x1f25))
        @Assert(0x5bc, MatrixUtil.calculateBCHCode(8, 0x1f25))
        @Assert(0xa99, MatrixUtil.calculateBCHCode(9, 0x1f25))
        @Assert(0x4d3, MatrixUtil.calculateBCHCode(10, 0x1f25))
        @Assert(0x9a6, MatrixUtil.calculateBCHCode(20, 0x1f25))
        @Assert(0xd75, MatrixUtil.calculateBCHCode(30, 0x1f25))
        @Assert(0xc69, MatrixUtil.calculateBCHCode(40, 0x1f25))
    }

    // We don't test a lot of cases in this function since we've already
    // tested them in TEST(calculateBCHCode).
    @TestCase
    public func testMakeVersionInfoBits(): Unit {
        // From Appendix D in JISX0510:2004 (p 68)
        var bits: BitArray = BitArray();
        MatrixUtil.makeVersionInfoBits(Version.getVersionForNumber(7), bits);
        @Assert(" ...XXXXX ..X..X.X ..", bits.toString())
    }

    // We don't test a lot of cases in this function since we've already
    // tested them in TEST(calculateBCHCode).
    @TestCase
    public func testMakeTypeInfoInfoBits(): Unit {
        // From Appendix C in JISX0510:2004 (p 65)
        var bits: BitArray = BitArray();
        MatrixUtil.makeTypeInfoBits(ErrorCorrectionLevel.M(0x00), 5, bits);
        @Assert(" X......X X..XXX.", bits.toString())
    }
}
