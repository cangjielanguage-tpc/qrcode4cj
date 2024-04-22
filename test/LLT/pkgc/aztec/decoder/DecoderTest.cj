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

from QRCode4cj import common.Qrcoder4cjFormatException
from QRCode4cj import common.ResultPoint
from QRCode4cj import aztec.common.AztecDetectorResult
from QRCode4cj import common.BitArray
from QRCode4cj import common.BitMatrix
from QRCode4cj import common.DecoderResult
from QRCode4cj import aztec.decoder.Decoder
from QRCode4cj import tools.UTF32String
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import regex.*

main(): Int64 {
    let tester = DecoderTest()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * Tests {@link Decoder}.
 */
@Test
public class DecoderTest {
    private static var NO_POINTS: Array<ResultPoint> = Array<ResultPoint>();
    private static var DOTX: Regex = Regex("[^.X]")
    private static var SPACES: Regex = Regex("\\s+")
    @TestCase
    public func testHighLevelDecode(): Unit {
        // no ECI codes
        testHighLevelDecodeString(
            "A. b.",
            // 'A'  P/S   '. ' L/L    b    D/L    '.'
            "...X. ..... ...XX XXX.. ...XX XXXX. XX.X"
        )

        // initial ECI code 26 (switch to UTF-8)
        testHighLevelDecodeString(
            "Ça",
            // P/S FLG(n) 2  '2'  '6'  B/S   2     0xc3     0x87     L/L   'a'
            "..... ..... .X. .X.. X... XXXXX ...X. XX....XX X....XXX XXX.. ...X."
        )

        // initial character without ECI (must be interpreted as ISO_8859_1)
        // followed by ECI code 26 (= UTF-8) and UTF-8 text
        testHighLevelDecodeString(
            "±Ça",
            // B/S 1     0xb1     P/S   FLG(n) 2  '2'  '6'  B/S   2     0xc3     0x87     L/L   'a'
            "XXXXX ....X X.XX...X ..... ..... .X. .X.. X... XXXXX ...X. XX....XX X....XXX XXX.. ...X."
        )

        // GS1 data
        testHighLevelDecodeString(
            "101233742",
            // P/S FLG(n) 0  D/L   1    0    1    2    3    P/S  FLG(n) 0  3    7    4    2
            "..... ..... ... XXXX. ..XX ..X. ..XX .X.. .X.X .... ..... ... .X.X X..X .XX. .X.."
        )
    }
    public static func toBitArray(bits: String): BitArray {
        var start: BitArray = BitArray()
        var str: Array<Char> = DOTX.matcher(bits).replaceAll("").toRuneArray()
        for (aStrN in 0..str.size) {
            var aStr = str[aStrN]
            start.appendBit(aStr == 'X')
        }
        return start
    }
    public static func stripSpace(s: String): String {
        return SPACES.matcher(s).replaceAll("")
    }
    public static func toBooleanArray(bitArray: BitArray): Array<Bool> {
        var result: Array<Bool> = Array<Bool>(bitArray.getSize(), item: true)
        for (i in 0..result.size) {
            result[i] = bitArray.get(i)
        }
        return result
    }

    private static func testHighLevelDecodeString(expectedString: String, b: String) {
        var bits: BitArray = toBitArray(stripSpace(b))
        @Assert(
                expectedString,
                Decoder.highLevelDecode(toBooleanArray(bits))
            )
    }

    @TestCase
    public func testAztecResult(): Unit {
        var matrix: BitMatrix = BitMatrix.parse(
            UTF32String(
                "X X X X X     X X X       X X X     X X X     \n" + "X X X     X X X     X X X X     X X X     X X \n" +
                    "  X   X X       X   X   X X X X     X     X X \n" +
                    "  X   X X     X X     X     X   X       X   X \n" +
                    "  X X   X X         X               X X     X \n" +
                    "  X X   X X X X X X X X X X X X X X X     X   \n" +
                    "  X X X X X                       X   X X X   \n" +
                    "  X   X   X   X X X X X X X X X   X X X   X X \n" +
                    "  X   X X X   X               X   X X       X \n" +
                    "  X X   X X   X   X X X X X   X   X X X X   X \n" +
                    "  X X   X X   X   X       X   X   X   X X X   \n" +
                    "  X   X   X   X   X   X   X   X   X   X   X   \n" +
                    "  X X X   X   X   X       X   X   X X   X X   \n" +
                    "  X X X X X   X   X X X X X   X   X X X   X X \n" +
                    "X X   X X X   X               X   X   X X   X \n" +
                    "  X       X   X X X X X X X X X   X   X     X \n" +
                    "  X X   X X                       X X   X X   \n" +
                    "  X X X   X X X X X X X X X X X X X X   X X   \n" +
                    "X     X     X     X X   X X               X X \n" +
                    "X   X X X X X   X X X X X     X   X   X     X \n" +
                    "X X X   X X X X           X X X       X     X \n" +
                    "X X     X X X     X X X X     X X X     X X   \n" +
                    "    X X X     X X X       X X X     X X X X   \n"
            ),
            UTF32String("X "),
            UTF32String("  ")
        )
        var aztecResult: AztecDetectorResult = AztecDetectorResult(matrix, NO_POINTS, false, 30, 2)
        var result: DecoderResult = Decoder().decode(aztecResult)
        @Assert("88888TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT", result.getText())

        var arr1: Array<UInt8> = [
            245,
            85,
            85,
            117,
            107,
            90,
            214,
            181,
            173,
            107,
            90,
            214,
            181,
            173,
            107,
            90,
            214,
            181,
            173,
            107,
            90,
            214,
            176
        ]
        assertEqual("Array", "result.getRawBytes()", arr1, result.getRawBytes())
        @Assert(180, result.getNumBits())
    }

    @TestCase
    public func testAztecResultECI(): Unit {
        var matrix: BitMatrix = BitMatrix.parse(
            UTF32String(
                "      X     X X X   X           X     \n" + "    X X   X X   X X X X X X X   X     \n" +
                    "    X X                         X   X \n" + "  X X X X X X X X X X X X X X X X X   \n" +
                    "      X                       X       \n" + "      X   X X X X X X X X X   X   X   \n" +
                    "  X X X   X               X   X X X   \n" + "  X   X   X   X X X X X   X   X X X   \n" +
                    "      X   X   X       X   X   X X X   \n" + "  X   X   X   X   X   X   X   X   X   \n" +
                    "X   X X   X   X       X   X   X     X \n" + "  X X X   X   X X X X X   X   X X     \n" +
                    "      X   X               X   X X   X \n" + "      X   X X X X X X X X X   X   X X \n" +
                    "  X   X                       X       \n" + "X X   X X X X X X X X X X X X X X X   \n" +
                    "X X     X   X         X X X       X X \n" + "  X   X   X   X X X X X     X X   X   \n" +
                    "X     X       X X   X X X       X     \n"
            ),
            UTF32String("X "),
            UTF32String("  ")
        )
        var aztecResult: AztecDetectorResult = AztecDetectorResult(matrix, NO_POINTS, false, 15, 1)
        var result: DecoderResult = Decoder().decode(aztecResult)
        @Assert("Français", result.getText())
    }

    @TestCase
    public func testDecodeTooManyErrors(): Unit {
        try {
            var matrix: BitMatrix = BitMatrix.parse(
                UTF32String(
                    "" + "X X . X . . . X X . . . X . . X X X . X . X X X X X . \n" +
                        "X X . . X X . . . . . X X . . . X X . . . X . X . . X \n" +
                        "X . . . X X . . X X X . X X . X X X X . X X . . X . . \n" +
                        ". . . . X . X X . . X X . X X . X . X X X X . X . . X \n" +
                        "X X X . . X X X X X . . . . . X X . . . X . X . X . X \n" +
                        "X X . . . . . . . . X . . . X . X X X . X . . X . . . \n" +
                        "X X . . X . . . . . X X . . . . . X . . . . X . . X X \n" +
                        ". . . X . X . X . . . . . X X X X X X . . . . . . X X \n" +
                        "X . . . X . X X X X X X . . X X X . X . X X X X X X . \n" +
                        "X . . X X X . X X X X X X X X X X X X X . . . X . X X \n" +
                        ". . . . X X . . . X . . . . . . . X X . . . X X . X . \n" +
                        ". . . X X X . . X X . X X X X X . X . . X . . . . . . \n" +
                        "X . . . . X . X . X . X . . . X . X . X X . X X . X X \n" +
                        "X . X . . X . X . X . X . X . X . X . . . . . X . X X \n" +
                        "X . X X X . . X . X . X . . . X . X . X X X . . . X X \n" +
                        "X X X X X X X X . X . X X X X X . X . X . X . X X X . \n" +
                        ". . . . . . . X . X . . . . . . . X X X X . . . X X X \n" +
                        "X X . . X . . X . X X X X X X X X X X X X X . . X . X \n" +
                        "X X X . X X X X . . X X X X . . X . . . . X . . X X X \n" +
                        ". . . . X . X X X . . . . X X X X . . X X X X . . . . \n" +
                        ". . X . . X . X . . . X . X X . X X . X . . . X . X . \n" +
                        "X X . . X . . X X X X X X X . . X . X X X X X X X . . \n" +
                        "X . X X . . X X . . . . . X . . . . . . X X . X X X . \n" +
                        "X . . X X . . X X . X . X . . . . X . X . . X . . X . \n" +
                        "X . X . X . . X . X X X X X X X X . X X X X . . X X . \n" +
                        "X X X X . . . X . . X X X . X X . . X . . . . X X X . \n" +
                        "X X . X . X . . . X . X . . . . X X . X . . X X . . . \n"
                ),
                UTF32String("X "),
                UTF32String(". ")
            );
            var aztecResult: AztecDetectorResult = AztecDetectorResult(matrix, NO_POINTS, true, 16, 4)
            Decoder().decode(aztecResult)
        } catch (e: Qrcoder4cjFormatException) {}
    }

    @TestCase
    public func testDecodeTooManyErrors2(): Unit {
        try {
            var matrix: BitMatrix = BitMatrix.parse(
                UTF32String(
                    "" + ". X X . . X . X X . . . X . . X X X . . . X X . X X . \n" +
                        "X X . X X . . X . . . X X . . . X X . X X X . X . X X \n" +
                        ". . . . X . . . X X X . X X . X X X X . X X . . X . . \n" +
                        "X . X X . . X . . . X X . X X . X . X X . . . . . X . \n" +
                        "X X . X . . X . X X . . . . . X X . . . . . X . . . X \n" +
                        "X . . X . . . . . . X . . . X . X X X X X X X . . . X \n" +
                        "X . . X X . . X . . X X . . . . . X . . . . . X X X . \n" +
                        ". . X X X X . X . . . . . X X X X X X . . . . . . X X \n" +
                        "X . . . X . X X X X X X . . X X X . X . X X X X X X . \n" +
                        "X . . X X X . X X X X X X X X X X X X X . . . X . X X \n" +
                        ". . . . X X . . . X . . . . . . . X X . . . X X . X . \n" +
                        ". . . X X X . . X X . X X X X X . X . . X . . . . . . \n" +
                        "X . . . . X . X . X . X . . . X . X . X X . X X . X X \n" +
                        "X . X . . X . X . X . X . X . X . X . . . . . X . X X \n" +
                        "X . X X X . . X . X . X . . . X . X . X X X . . . X X \n" +
                        "X X X X X X X X . X . X X X X X . X . X . X . X X X . \n" +
                        ". . . . . . . X . X . . . . . . . X X X X . . . X X X \n" +
                        "X X . . X . . X . X X X X X X X X X X X X X . . X . X \n" +
                        "X X X . X X X X . . X X X X . . X . . . . X . . X X X \n" +
                        ". . X X X X X . X . . . . X X X X . . X X X . X . X . \n" +
                        ". . X X . X . X . . . X . X X . X X . . . . X X . . . \n" +
                        "X . . . X . X . X X X X X X . . X . X X X X X . X . . \n" +
                        ". X . . . X X X . . . . . X . . . . . X X X X X . X . \n" +
                        "X . . X . X X X X . X . X . . . . X . X X . X . . X . \n" +
                        "X . . . X X . X . X X X X X X X X . X X X X . . X X . \n" +
                        ". X X X X . . X . . X X X . X X . . X . . . . X X X . \n" +
                        "X X . . . X X . . X . X . . . . X X . X . . X . X . X \n"
                ),
                UTF32String("X "),
                UTF32String(". ")
            )
            var aztecResult: AztecDetectorResult = AztecDetectorResult(matrix, NO_POINTS, true, 16, 4)
            Decoder().decode(aztecResult)
        } catch (e: Qrcoder4cjFormatException) {}
    }

    @TestCase
    public func testRawBytes(): Unit {
        var bool0: Array<Bool> = []
        var bool1: Array<Bool> = [true]
        var bool7: Array<Bool> = [true, false, true, false, true, false, true]
        var bool8: Array<Bool> = [true, false, true, false, true, false, true, false]
        var bool9: Array<Bool> = [true, false, true, false, true, false, true, false, true]
        var bool16: Array<Bool> = [
            false,
            true,
            true,
            false,
            false,
            false,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            true
        ]
        var byte0: Array<UInt8> = []
        var byte1: Array<UInt8> = [128]
        var byte7: Array<UInt8> = [170]
        var byte8: Array<UInt8> = [170]
        var byte9: Array<UInt8> = [170, 128]
        var byte16: Array<UInt8> = [99, 193]

        assertEqual("byte0", "bool0", byte0, Decoder.convertBoolArrayToByteArray(bool0))
        assertEqual("byte1", "bool1", byte1, Decoder.convertBoolArrayToByteArray(bool1))
        assertEqual("byte7", "bool7", byte7, Decoder.convertBoolArrayToByteArray(bool7))
        assertEqual("byte8", "bool8", byte8, Decoder.convertBoolArrayToByteArray(bool8))
        assertEqual("byte9", "bool9", byte9, Decoder.convertBoolArrayToByteArray(bool9))
        assertEqual("byte16", "bool16", byte16, Decoder.convertBoolArrayToByteArray(bool16))
    }
}
