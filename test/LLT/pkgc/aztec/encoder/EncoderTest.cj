/*
 * Copyright 2013 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

from QRCode4cj import zxing.code.common.EncodeHintType
from QRCode4cj import zxing.code.common.BarcodeFormat
from QRCode4cj import zxing.code.common.Qrcoder4cjFormatException
from QRCode4cj import zxing.code.common.ResultPoint
from QRCode4cj import zxing.code.aztec.common.AztecDetectorResult
from QRCode4cj import zxing.code.aztec.AztecWriter
from QRCode4cj import zxing.code.aztec.decoder.Decoder
from QRCode4cj import zxing.code.aztec.encoder.AztecCode
from QRCode4cj import zxing.code.aztec.encoder.Encoder
from QRCode4cj import zxing.code.aztec.encoder.HighLevelEncoder
from QRCode4cj import zxing.code.common.BitArray
from QRCode4cj import zxing.code.common.BitMatrix
from QRCode4cj import zxing.code.common.MyCharset
from QRCode4cj import zxing.code.common.DecoderResult
from QRCode4cj import zxing.code.common.StandardCharsets
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import regex.*
from std import random.*
from QRCode4cj import zxing.code.tools.UTF32String

main(): Int64 {
    let tester = EncoderTest()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * Aztec 2D generator unit tests.
 *
 * @author Rustam Abdullaev
 * @author Frank Yellin
 */
@Test
public class EncoderTest {
    private static var ISO_8859_1: MyCharset = StandardCharsets.ISO_8859_1
    private static var UTF_8: MyCharset = StandardCharsets.UTF_8
    private static var SHIFT_JIS: MyCharset = MyCharset.forName("Shift_JIS")
    private static var ISO_8859_15: MyCharset = MyCharset.forName("ISO-8859-15")
    private static var WINDOWS_1252: MyCharset = MyCharset.forName("windows-1252")

    private static var DOTX: Regex = Regex("[^.X]")
    private static var SPACES: Regex = Regex("\\s+")
    private static var NO_POINTS: Array<ResultPoint> = Array<ResultPoint>()

    private static var testEncodeDecode1_random = [0, 1, 11, 0, 0, 4, 0, 14]
    private static var testEncodeDecode2_random = [6, 1, 11, 0, 0, 5, 0, 2]
    private static var testEncodeDecode3_random = [21, 1, 14, 0, 0, 13, 0, 4]
    private static var testEncodeDecode4_random = [15, 1, 20, 0, 0, 16, 0, 2]
    private static var testEncodeDecode5_random = [20, 1, 16, 0, 0, 17, 0, 36]
    private static var testEncodeDecode10_random = [6, 1, 11, 0, 0, 43, 0, 2]
    private static var testEncodeDecode23_random = [96, 1, 28, 0, 0, 39, 0, 27]
    private static var testEncodeDecode31_random = [141, 1, 98, 0, 0, 31, 0, 41]
    private static var testWriter1_BOOL_random = [false, true]
    private static var testWriter1_INT64_random = [1, 0]
    private static var testWriter2_BOOL_random = [false, true]
    private static var testWriter2_INT64_random = [1, 0]
    private static var testWriter3_BOOL_random = [false, true, false, false]
    private static var testWriter3_INT64_random = [3, 0, 2, 2]
    private static var testWriter4_BOOL_random = [false, true, false, false]
    private static var testWriter4_INT64_random = [3, 0, 2, 2]
    private static var testWriter5_BOOL_random = [false, true, false, false, true, true]
    private static var testWriter5_INT64_random = [3, 0, 2, 2, 2, 3]
    private static var testWriter6_BOOL_random = [
        false,
        true,
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        false,
        true,
        true,
        false,
        true,
        false,
        false
    ]
    private static var testWriter6_INT64_random = [0, 3, 1, 5, 3, 1, 5, 0, 5, 1, 4, 4, 0, 2, 3, 1, 1, 2]
    private static var testWriter7_BOOL_random = [
        false,
        true,
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        false,
        true,
        true,
        false,
        true,
        false,
        false,
        true,
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        true,
        true,
        false,
        false,
        true,
        false,
        true,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        true,
        true,
        true,
        false,
        true,
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        false,
        false,
        false,
        true
    ]
    private static var testWriter7_INT64_random = [
        6,
        0,
        5,
        5,
        4,
        7,
        3,
        0,
        4,
        2,
        3,
        5,
        3,
        4,
        5,
        6,
        0,
        1,
        6,
        6,
        3,
        6,
        3,
        1,
        0,
        2,
        5,
        6,
        0,
        0,
        2,
        0,
        1,
        1,
        4,
        3,
        0,
        2,
        0,
        4,
        6,
        6,
        4,
        3,
        1,
        0,
        0,
        1,
        4,
        2,
        4,
        4,
        2,
        3,
        7,
        1
    ]
    private static var testWriter8_BOOL_random = [
        false,
        true,
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        false,
        true,
        true,
        false,
        true,
        false,
        false,
        true,
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        true,
        true,
        false,
        false,
        true,
        false,
        true,
        true,
        false,
        true,
        false,
        false,
        false,
        false,
        true,
        true,
        true,
        false,
        true,
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        false,
        false,
        false,
        true,
        true,
        false,
        true,
        false,
        true,
        true,
        false,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        false,
        false,
        true,
        true,
        true,
        false,
        false,
        true,
        false,
        true,
        true,
        false,
        false
    ]
    private static var testWriter8_INT64_random = [
        6,
        1,
        9,
        9,
        3,
        5,
        5,
        8,
        3,
        7,
        0,
        4,
        6,
        6,
        5,
        3,
        1,
        8,
        4,
        2,
        7,
        9,
        3,
        2,
        0,
        2,
        9,
        5,
        0,
        9,
        3,
        7,
        0,
        1,
        6,
        1,
        0,
        5,
        5,
        7,
        5,
        0,
        8,
        0,
        8,
        2,
        2,
        4,
        0,
        2,
        9,
        9,
        9,
        1,
        1,
        2,
        5,
        2,
        7,
        3,
        1,
        4,
        4,
        3,
        3,
        0,
        1,
        7,
        2,
        5,
        1,
        2,
        4,
        5,
        7,
        1,
        4,
        2,
        5,
        3,
        2,
        8,
        3,
        9,
        6,
        9,
        7,
        7,
        3,
        3,
        6,
        3,
        4,
        4
    ]
    private static var testWriter9_BOOL_random = [false, true, false, false, true, true]
    private static var testWriter9_INT64_random = [0, 3, 1, 5, 3, 1]

    // real life tests
    @TestCase
    public func testEncode1(): Unit {
        testEncode(
            "This is an example Aztec symbol for Wikipedia.",
            true,
            3,
            "X     X X       X     X X     X     X         \n" + "X         X     X X     X   X X   X X       X \n" +
                "X X   X X X X X   X X X                 X     \n" + "X X                 X X   X       X X X X X X \n" +
                "    X X X   X   X     X X X X         X X     \n" + "  X X X   X X X X   X     X   X     X X   X   \n" +
                "        X X X X X     X X X X   X   X     X   \n" + "X       X   X X X X X X X X X X X     X   X X \n" +
                "X   X     X X X               X X X X   X X   \n" + "X     X X   X X   X X X X X   X X   X   X X X \n" +
                "X   X         X   X       X   X X X X       X \n" + "X       X     X   X   X   X   X   X X   X     \n" +
                "      X   X X X   X       X   X     X X X     \n" + "    X X X X X X   X X X X X   X X X X X X   X \n" +
                "  X X   X   X X               X X X   X X X X \n" + "  X   X       X X X X X X X X X X X X   X X   \n" +
                "  X X   X       X X X   X X X       X X       \n" + "  X               X   X X     X     X X X     \n" +
                "  X   X X X   X X   X   X X X X   X   X X X X \n" + "    X   X   X X X   X   X   X X X X     X     \n" +
                "        X               X                 X   \n" + "        X X     X   X X   X   X   X       X X \n" +
                "  X   X   X X       X   X         X X X     X \n"
        )
    }

    @TestCase
    public func testEncode2(): Unit {
        testEncode(
            "Aztec Code is a public domain 2D matrix barcode symbology" +
                " of nominally square symbols built on a square grid with a " +
                "distinctive square bullseye pattern at their center.",
            false,
            6,
            "        X X     X X     X     X     X   X X X         X   X         X   X X       \n" +
                "  X       X X     X   X X   X X       X             X     X   X X   X           X \n" +
                "  X   X X X     X   X   X X     X X X   X   X X               X X       X X     X \n" +
                "X X X             X   X         X         X     X     X   X     X X       X   X   \n" +
                "X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X \n" +
                "    X X   X   X   X X X               X       X       X X     X X   X X       X   \n" +
                "X X     X       X       X X X X   X   X X       X   X X   X       X X   X X   X   \n" +
                "  X       X   X     X X   X   X X   X X   X X X X X X   X X           X   X   X X \n" +
                "X X   X X   X   X X X X   X X X X X X X X   X   X       X X   X X X X   X X X     \n" +
                "  X       X   X     X       X X     X X   X   X   X     X X   X X X   X     X X X \n" +
                "  X   X X X   X X       X X X         X X           X   X   X   X X X   X X     X \n" +
                "    X     X   X X     X X X X     X   X     X X X X   X X   X X   X X X     X   X \n" +
                "X X X   X             X         X X X X X   X   X X   X   X   X X   X   X   X   X \n" +
                "          X       X X X   X X     X   X           X   X X X X   X X               \n" +
                "  X     X X   X   X       X X X X X X X X X X X X X X X   X   X X   X   X X X     \n" +
                "    X X                 X   X                       X X   X       X         X X X \n" +
                "        X   X X   X X X X X X   X X X X X X X X X   X     X X           X X X X   \n" +
                "          X X X   X     X   X   X               X   X X     X X X   X X           \n" +
                "X X     X     X   X   X   X X   X   X X X X X   X   X X X X X X X       X   X X X \n" +
                "X X X X       X       X   X X   X   X       X   X   X     X X X     X X       X X \n" +
                "X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X \n" +
                "    X     X       X         X   X   X       X   X   X     X   X X                 \n" +
                "        X X     X X X X X   X   X   X X X X X   X   X X X     X X X X   X         \n" +
                "X     X   X   X         X   X   X               X   X X   X X   X X X     X   X   \n" +
                "  X   X X X   X   X X   X X X   X X X X X X X X X   X X         X X     X X X X   \n" +
                "    X X   X   X   X X X     X                       X X X   X X   X   X     X     \n" +
                "    X X X X   X         X   X X X X X X X X X X X X X X   X       X X   X X   X X \n" +
                "            X   X   X X       X X X X X     X X X       X       X X X         X   \n" +
                "X       X         X   X X X X   X     X X     X X     X X           X   X       X \n" +
                "X     X       X X X X X     X   X X X X   X X X     X       X X X X   X   X X   X \n" +
                "  X X X X X               X     X X X   X       X X   X X   X X X X     X X       \n" +
                "X             X         X   X X   X X     X     X     X   X   X X X X             \n" +
                "    X   X X       X     X       X   X X X X X X   X X   X X X X X X X X X   X   X \n" +
                "    X         X X   X       X     X   X   X       X     X X X     X       X X X X \n" +
                "X     X X     X X X X X X             X X X   X               X   X     X     X X \n" +
                "X   X X     X               X X X X X     X X     X X X X X X X X     X   X   X X \n" +
                "X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X   X \n" +
                "X           X     X X X X     X     X         X         X   X       X X   X X X   \n" +
                "X   X   X X   X X X   X         X X     X X X X     X X   X   X     X   X       X \n" +
                "      X     X     X     X X     X   X X   X X   X         X X       X       X   X \n" +
                "X       X           X   X   X     X X   X               X     X     X X X         \n"
        )
    }

    @TestCase
    public func testAztecWriter(): Unit {
        testWriter("Espa\u{00F1}ol", MyCharset(), 25, true, 1, testWriter1_BOOL_random, testWriter1_INT64_random) // Without ECI (implicit ISO-8859-1)
        testWriter("Espa\u{00F1}ol", ISO_8859_1, 25, true, 1, testWriter2_BOOL_random, testWriter2_INT64_random) // Explicit ISO-8859-1
        testWriter(
            "\u{20AC} 1 sample data.",
            WINDOWS_1252,
            25,
            true,
            2,
            testWriter3_BOOL_random,
            testWriter3_INT64_random
        ) // ISO-8859-1 can't encode Euro; Windows-1252 can
        testWriter(
            "\u{20AC} 1 sample data.",
            ISO_8859_15,
            25,
            true,
            2,
            testWriter4_BOOL_random,
            testWriter4_INT64_random
        )
        testWriter("\u{20AC} 1 sample data.", UTF_8, 25, true, 2, testWriter5_BOOL_random, testWriter5_INT64_random)
        testWriter("\u{20AC} 1 sample data.", UTF_8, 100, true, 3, testWriter6_BOOL_random, testWriter6_INT64_random)
        testWriter("\u{20AC} 1 sample data.", UTF_8, 300, true, 4, testWriter7_BOOL_random, testWriter7_INT64_random)
        testWriter("\u{20AC} 1 sample data.", UTF_8, 500, false, 5, testWriter8_BOOL_random, testWriter8_INT64_random)

        testWriter(
            "The capital of Japan is named \u{6771}\u{4EAC}.",
            SHIFT_JIS,
            25,
            true,
            3,
            testWriter9_BOOL_random,
            testWriter9_INT64_random
        )

        // Test AztecWriter defaults
        var data: String = "In ut magna vel mauris malesuada"
        var writer: AztecWriter = AztecWriter()
        var matrix: BitMatrix = writer.encode(data, BarcodeFormat.AZTEC, 0, 0)
        var aztec: AztecCode = Encoder.encode(
            data,
            Encoder.DEFAULT_EC_PERCENT,
            Encoder.DEFAULT_AZTEC_LAYERS
        )
        var expectedMatrix: BitMatrix = aztec.getMatrix()
        @Assert(matrix, expectedMatrix)
    }

    // synthetic tests (encode-decode round-trip)
    @TestCase
    public func testEncodeDecode1(): Unit {
        try {
            testEncodeDecode("Abc123!", true, 1, testEncodeDecode1_random)
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testEncodeDecode2(): Unit {
        try {
            testEncodeDecode("Lorem ipsum. http://test/", true, 2, testEncodeDecode2_random)
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testEncodeDecode3(): Unit {
        try {
            testEncodeDecode("AAAANAAAANAAAANAAAANAAAANAAAANAAAANAAAANAAAANAAAAN", true, 3, testEncodeDecode3_random)
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testEncodeDecode4(): Unit {
        try {
            testEncodeDecode("http://test/~!@#*^%&)__ ;:'\"[]{}\\|-+-=`1029384", true, 4, testEncodeDecode4_random)
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testEncodeDecode5(): Unit {
        try {
            testEncodeDecode(
                "http://test/~!@#*^%&)__ ;:'\"[]{}\\|-+-=`1029384756<>/?abc" +
                    "Four score and seven our forefathers brought forth",
                false,
                5,
                testEncodeDecode5_random
            )
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testEncodeDecode10(): Unit {
        try {
            testEncodeDecode(
                "In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam" +
                    " cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum" +
                    " est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue" +
                    " auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla" +
                    " ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id" +
                    " elementum sapien dolor et diam.",
                false,
                10,
                testEncodeDecode10_random
            )
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testEncodeDecode23(): Unit {
        try {
            testEncodeDecode(
                "In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam" +
                    " cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum" +
                    " est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue" +
                    " auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla" +
                    " ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id" +
                    " elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend." +
                    " Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus" +
                    " justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu" +
                    " tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus" +
                    " quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec" +
                    " laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida," +
                    " justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec" +
                    " lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar" +
                    " nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat" +
                    " eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra" +
                    " fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo" +
                    " diam, lobortis eu tristique ac, p. In ut magna vel mauris malesuada dictum. Nulla" +
                    " ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum" +
                    " sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet." +
                    " Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit" +
                    " felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo" +
                    " erat pulvinar nisi, id elementum sapien dolor et diam.",
                false,
                23,
                testEncodeDecode23_random
            )
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testEncodeDecode31(): Unit {
        try {
            testEncodeDecode(
                "In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam" +
                    " cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum" +
                    " est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue" +
                    " auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla" +
                    " ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id" +
                    " elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend." +
                    " Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus" +
                    " justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu" +
                    " tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus" +
                    " quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec" +
                    " laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida," +
                    " justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec" +
                    " lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar" +
                    " nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat" +
                    " eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra" +
                    " fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo" +
                    " diam, lobortis eu tristique ac, p. In ut magna vel mauris malesuada dictum. Nulla" +
                    " ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum" +
                    " sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet." +
                    " Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit" +
                    " felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo" +
                    " erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit" +
                    " placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at" +
                    " pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est." +
                    " Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada" +
                    " dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id" +
                    " justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum" +
                    " sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat," +
                    " eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet" +
                    " laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac" +
                    " nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula," +
                    " massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus" +
                    " sed est. Ut justo diam, lobortis eu tris. In ut magna vel mauris malesuada dictum." +
                    " Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum" +
                    " sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet." +
                    " Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget" +
                    " hendrerit felis turpis nec lorem.",
                false,
                31,
                testEncodeDecode31_random
            )
        } catch (e: Exception) {
            throw Exception()
        }
    }

    @TestCase
    public func testGenerateModeMessage(): Unit {
        testModeMessage(true, 2, 29, ".X .XXX.. ...X XX.. ..X .XX. .XX.X")
        testModeMessage(true, 4, 64, "XX XXXXXX .X.. ...X ..XX .X.. XX..")
        testModeMessage(false, 21, 660, "X.X.. .X.X..X..XX .XXX ..X.. .XXX. .X... ..XXX")
        testModeMessage(false, 32, 4096, "XXXXX XXXXXXXXXXX X.X. ..... XXX.X ..X.. X.XXX")
    }

    @TestCase
    public func testStuffBits1(): Unit {
        testStuffBits(
            5,
            ".X.X. X.X.X .X.X.",
            ".X.X. X.X.X .X.X."
        )
        testStuffBits(
            5,
            ".X.X. ..... .X.X",
            ".X.X. ....X ..X.X"
        )
        testStuffBits(
            3,
            "XX. ... ... ..X XXX .X. ..",
            "XX. ..X ..X ..X ..X .XX XX. .X. ..X"
        )
        testStuffBits(
            6,
            ".X.X.. ...... ..X.XX",
            ".X.X.. .....X. ..X.XX XXXX."
        )
        testStuffBits(
            6,
            ".X.X.. ...... ...... ..X.X.",
            ".X.X.. .....X .....X ....X. X.XXXX"
        )
        testStuffBits(
            6,
            ".X.X.. XXXXXX ...... ..X.XX",
            ".X.X.. XXXXX. X..... ...X.X XXXXX."
        )
        testStuffBits(
            6,
            "...... ..XXXX X..XX. .X.... .X.X.X .....X .X.... ...X.X .....X ....XX ..X... ....X. X..XXX X.XX.X",
            ".....X ...XXX XX..XX ..X... ..X.X. X..... X.X... ....X. X..... X....X X..X.. .....X X.X..X XXX.XX .XXXXX"
        )
    }

    @TestCase
    public func testHighLevelEncode(): Unit {
        try {
            testHighLevelEncodeString(
                "A. b.",
                // 'A'  P/S   '. ' L/L    b    D/L    '.'
                "...X. ..... ...XX XXX.. ...XX XXXX. XX.X"
            )
            testHighLevelEncodeString(
                "Lorem ipsum.",
                // 'L'  L/L   'o'   'r'   'e'   'm'   ' '   'i'   'p'   's'   'u'   'm'   D/L   '.'
                ".XX.X XXX.. X.... X..XX ..XX. .XXX. ....X .X.X. X...X X.X.. X.XX. .XXX. XXXX. XX.X"
            )
            testHighLevelEncodeString(
                "Lo. Test 123.",
                // 'L'  L/L   'o'   P/S   '. '  U/S   'T'   'e'   's'   't'    D/L   ' '  '1'  '2'  '3'  '.'
                ".XX.X XXX.. X.... ..... ...XX XXX.. X.X.X ..XX. X.X.. X.X.X  XXXX. ...X ..XX .X.. .X.X XX.X"
            )
            testHighLevelEncodeString(
                "Lo...x",
                // 'L'  L/L   'o'   D/L   '.'  '.'  '.'  U/L  L/L   'x'
                ".XX.X XXX.. X.... XXXX. XX.X XX.X XX.X XXX. XXX.. XX..X"
            )
            testHighLevelEncodeString(
                ". x://abc/.",
                //P/S   '. '  L/L   'x'   P/S   ':'   P/S   '/'   P/S   '/'   'a'   'b'   'c'   P/S   '/'   D/L   '.'
                "..... ...XX XXX.. XX..X ..... X.X.X ..... X.X.. ..... X.X.. ...X. ...XX ..X.. ..... X.X.. XXXX. XX.X"
            )

            // Uses Binary/Shift rather than Lower/Shift to save two bits.
            testHighLevelEncodeString(
                "ABCdEFG",
                //'A'   'B'   'C'   B/S    =1    'd'     'E'   'F'   'G'
                "...X. ...XX ..X.. XXXXX ....X .XX..X.. ..XX. ..XXX .X..."
            )

            testHighLevelEncodeString(
                // Found on an airline boarding pass.  Several stretches of Binary shift are
                // necessary to keep the bitcount so low.
                "09  UAG    ^160MEUCIQC0sYS/HpKxnBELR1uB85R20OoqqwFGa0q2uEi" +
                    "Ygh6utAIgLl1aBVM4EOTQtMQQYH9M2Z3Dp4qnA/fwWuQ+M8L3V8U=",
                823
            )
        } catch (e: Qrcoder4cjFormatException) {
            throw Qrcoder4cjFormatException()
        }
    }

    @TestCase
    public func testHighLevelEncodeBinary(): Unit {
        try {
            // binary short form single byte
            testHighLevelEncodeString(
                "N\0N",
                // 'N'  B/S    =1   '\0'      N
                ".XXXX XXXXX ....X ........ .XXXX"
            ) // Encode "N" in UPPER

            testHighLevelEncodeString(
                "N\0n",
                // 'N'  B/S    =2   '\0'       'n'
                ".XXXX XXXXX ...X. ........ .XX.XXX."
            ) // Encode "n" in BINARY

            // binary short form consecutive bytes
            testHighLevelEncodeString(
                "N\0\u{0080} A",
                // 'N'  B/S    =2    '\0'    \u0080   ' '  'A'
                ".XXXX XXXXX ...X. ........ X....... ....X ...X."
            )

            // binary skipping over single character
            testHighLevelEncodeString(
                "\0a\u{00FF}\u{0080} A",
                // B/S  =4    '\0'      'a'     '\3ff'   '\200'   ' '   'A'
                "XXXXX ..X.. ........ .XX....X XXXXXXXX X....... ....X ...X."
            )

            // getting into binary mode from digit mode
            testHighLevelEncodeString(
                "1234\0",
                //D/L   '1'  '2'  '3'  '4'  U/L  B/S    =1    \0
                "XXXX. ..XX .X.. .X.X .XX. XXX. XXXXX ....X ........"
            )

            // Create a string in which every character requires binary
            var sb: ArrayList<Char> = ArrayList<Char>()
            for (i in 0..=3000) {
                sb.append(Char(128 + (i % 30)))
            }

            // Test the output generated by Binary/Switch, particularly near the
            // places where the encoding changes: 31, 62, and 2047+31=2078
            var iArr: Array<Int64> = [
                1,
                2,
                3,
                10,
                29,
                30,
                31,
                32,
                33,
                60,
                61,
                62,
                63,
                64,
                2076,
                2077,
                2078,
                2079,
                2080,
                2100
            ]
            for (iN in iArr) {
                // This is the expected length of a binary string of length "i"
                var sumSecond = 0;
                if (iN <= 31) {
                    sumSecond = 10
                } else if (iN <= 62) {
                    sumSecond = 20
                } else if (iN <= 2078) {
                    sumSecond = 21
                } else {
                    sumSecond = 31
                }
                var expectedLength: Int64 = (8 * iN) + sumSecond

                // Verify that we are correct about the length.
                testHighLevelEncodeString(UTF32String(sb).substring(0, iN).toString(), expectedLength)
                if (iN != 1 && iN != 32 && iN != 2079) {
                    // The addition of an 'a' at the beginning or end gets merged into the binary code
                    // in those cases where adding another binary character only adds 8 or 9 bits to the result.
                    // So we exclude the border cases i=1,32,2079
                    // A lower case letter at the beginning will be merged into binary mode
                    testHighLevelEncodeString("a" + UTF32String(sb).substring(0, iN - 1).toString(), expectedLength)

                    // A lower case letter at the end will also be merged into binary mode
                    testHighLevelEncodeString(UTF32String(sb).substring(0, iN - 1).toString() + "a", expectedLength)
                }

                // A lower case letter at both ends will enough to latch us into LOWER.
                testHighLevelEncodeString("a" + UTF32String(sb).substring(0, iN).toString() + "b", expectedLength + 15)
            }

            sb = ArrayList<Char>()
            for (i in 0..32) {
                sb.append('§') // § forces binary encoding
            }
            sb.remove(1);
            sb.insert(1, 'A')

            // expect B/S(1) A B/S(30)
            testHighLevelEncodeString(String(sb), 5 + 20 + 31 * 8)

            sb = ArrayList<Char>()
            for (i in 0..31) {
                sb.append('§')
            }
            sb.remove(1);
            sb.insert(1, 'A')

            // expect B/S(31)
            testHighLevelEncodeString(String(sb), 10 + 31 * 8)

            sb = ArrayList<Char>()
            for (i in 0..34) {
                sb.append('§')
            }
            sb.remove(1);
            sb.insert(1, 'A')

            // expect B/S(31) B/S(3)
            testHighLevelEncodeString(String(sb), 20 + 34 * 8)

            sb = ArrayList<Char>()
            for (i in 0..64) {
                sb.append('§')
            }
            sb.remove(30);
            sb.insert(30, 'A')

            // expect B/S(64)
            testHighLevelEncodeString(String(sb), 21 + 64 * 8)
        } catch (e: Qrcoder4cjFormatException) {
            throw Qrcoder4cjFormatException()
        }
    }

    @TestCase
    public func testHighLevelEncodePairs(): Unit {
        try {
            // Typical usage
            testHighLevelEncodeString(
                "ABC. DEF\r\n",
                //  A     B    C    P/S   .<sp>   D    E     F    P/S   \r\n
                "...X. ...XX ..X.. ..... ...XX ..X.X ..XX. ..XXX ..... ...X."
            )

            // We should latch to PUNCT mode, rather than shift.  Also check all pairs
            testHighLevelEncodeString(
                "A. : , \r\n",
                // 'A'    M/L   P/L   ". "  ": "   ", " "\r\n"
                "...X. XXX.X XXXX. ...XX ..X.X  ..X.. ...X."
            )

            // Latch to DIGIT rather than shift to PUNCT
            testHighLevelEncodeString(
                "A. 1234",
                // 'A'  D/L   '.'  ' '  '1' '2'   '3'  '4'
                "...X. XXXX. XX.X ...X ..XX .X.. .X.X .X X."
            )

            // Don't bother leaving Binary Shift.
            testHighLevelEncodeString(
                "A\u{0080}. \u{0080}",
                // 'A'  B/S    =2    \200      "."     " "     \200
                "...X. XXXXX ..X.. X....... ..X.XXX. ..X..... X......."
            )
        } catch (e: Qrcoder4cjFormatException) {
            throw Qrcoder4cjFormatException()
        }
    }

    @TestCase
    // 测试正确结果为报错，错误为IllegalArgumentException
    public func testUserSpecifiedLayers(): Unit {
        try {
            doTestUserSpecifiedLayers(33)
        } catch (e: IllegalArgumentException) {
            //throw IllegalArgumentException()
        }
    }

    @TestCase
    // 测试正确结果为报错，错误为IllegalArgumentException
    public func testUserSpecifiedLayers2(): Unit {
        try {
            doTestUserSpecifiedLayers(-1)
        } catch (e: IllegalArgumentException) {
            //throw IllegalArgumentException()
        }
    }

    private func doTestUserSpecifiedLayers(userSpecifiedLayers: Int64) {
        var alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var aztec: AztecCode = Encoder.encode(alphabet, 25, -2)
        @Assert(2, aztec.getLayers())
        @Assert(aztec.isCompact())

        aztec = Encoder.encode(alphabet, 25, 32)
        @Assert(32, aztec.getLayers())
        @Assert(aztec.isCompact(),false)

        Encoder.encode(alphabet, 25, userSpecifiedLayers)
    }

    @TestCase
    // 测试正确结果为报错，错误为IllegalArgumentException
    public func testBorderCompact4CaseFailed(): Unit {
        try {
            // Compact(4) con hold 608 bits of information, but at most 504 can be data.  Rest must
            // be error correction
            var alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

            // encodes as 26 * 5 * 4 = 520 bits of data
            var alphabet4: String = alphabet + alphabet + alphabet + alphabet
            Encoder.encode(alphabet4, 0, -4)
        } catch (e: IllegalArgumentException) {
            //throw IllegalArgumentException()
        }
    }

    @TestCase
    public func testBorderCompact4Case(): Unit {
        // Compact(4) con hold 608 bits of information, but at most 504 can be data.  Rest must
        // be error correction
        var alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        // encodes as 26 * 5 * 4 = 520 bits of data
        var alphabet4: String = alphabet + alphabet + alphabet + alphabet

        // If we just try to encode it normally, it will go to a non-compact 4 layer
        var aztecCode: AztecCode = Encoder.encode(alphabet4, 0, Encoder.DEFAULT_AZTEC_LAYERS)
        @Assert(aztecCode.isCompact(),false)
        @Assert(4, aztecCode.getLayers())

        // But shortening the string to 100 bytes (500 bits of data), compact works fine, even if we
        // include more error checking.
        aztecCode = Encoder.encode(UTF32String(alphabet4).substring(0, 100).toString(), 10, Encoder.DEFAULT_AZTEC_LAYERS
        )
        @Assert(aztecCode.isCompact())
        @Assert(4, aztecCode.getLayers())
    }

    // Helper routines
    private static func testEncode(data: String, compact: Bool, layers: Int64, expected: String) {
        var aztec: AztecCode = Encoder.encode(data, 33, Encoder.DEFAULT_AZTEC_LAYERS)
        @Assert(compact, aztec.isCompact())
        @Assert(layers, aztec.getLayers())
        var matrix: BitMatrix = aztec.getMatrix()
        @Assert(expected, matrix.toString())
    }

    private static func testEncodeDecode(data: String, compact: Bool, layers: Int64, random_Int64: Array<Int64>) {
        try {
            var Int64num = 0

            var aztec: AztecCode = Encoder.encode(data, 25, Encoder.DEFAULT_AZTEC_LAYERS)
            @Assert(compact, aztec.isCompact())
            @Assert(layers, aztec.getLayers())
            var matrix: BitMatrix = aztec.getMatrix()
            var r: AztecDetectorResult = AztecDetectorResult(
                matrix,
                NO_POINTS,
                aztec.isCompact(),
                aztec.getCodeWords(),
                aztec.getLayers()
            )
            var res: DecoderResult = Decoder().decode(r)
            @Assert(data, res.getText())

            // Check error correction by introducing a few minor errors
            var random: Random = getPseudoRandom()
            var i1 = random_Int64[Int64num]
            Int64num++
            var i2 = random_Int64[Int64num]
            Int64num++
            matrix.flip(i1, i2)

            i1 = random_Int64[Int64num]
            Int64num++
            i2 = random_Int64[Int64num]
            Int64num++
            matrix.flip(i1, matrix.getHeight() - 2 + i2)

            i1 = random_Int64[Int64num]
            Int64num++
            i2 = random_Int64[Int64num]
            Int64num++
            matrix.flip(i1, i2)

            i1 = random_Int64[Int64num]
            Int64num++
            i2 = random_Int64[Int64num]
            Int64num++
            matrix.flip(matrix.getWidth() - 2 + i1, i2)
            r = AztecDetectorResult(matrix, NO_POINTS, aztec.isCompact(), aztec.getCodeWords(), aztec.getLayers())
            res = Decoder().decode(r)
            @Assert(data, res.getText())
        } catch (e: Exception) {
            throw Exception()
        }
    }

    private static func testWriter(
        data: String,
        charset: MyCharset,
        eccPercent: Int64,
        compact: Bool,
        layers: Int64,
        random_Bool: Array<Bool>,
        random_Int64: Array<Int64>
    ) {
        var boolnum = 0;
        var Int64num = 0;

        // Perform an encode-decode round-trip because it can be lossy.
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        if (charset.flag) {
            if (charset.realName != "") {
                hints.put(EncodeHintType.CHARACTER_SET, charset.realName)
            } else {
                hints.put(EncodeHintType.CHARACTER_SET, charset.name())
            }
        }
        hints.put(EncodeHintType.ERROR_CORRECTION, eccPercent)
        var writer: AztecWriter = AztecWriter()
        var matrix: BitMatrix = writer.encode(data, BarcodeFormat.AZTEC, 0, 0, hints)
        var aztec: AztecCode = Encoder.encode(UTF32String(data), eccPercent, Encoder.DEFAULT_AZTEC_LAYERS, charset)
        @Assert(compact, aztec.isCompact())
        @Assert(layers, aztec.getLayers())
        var matrix2: BitMatrix = aztec.getMatrix()
        @Assert(matrix, matrix2)
        var r: AztecDetectorResult = AztecDetectorResult(
            matrix,
            NO_POINTS,
            aztec.isCompact(),
            aztec.getCodeWords(),
            aztec.getLayers()
        )
        var res: DecoderResult = Decoder().decode(r)
        @Assert(data, res.getText())

        // Check error correction by introducing up to eccPercent/2 errors
        var ecWords: Int64 = aztec.getCodeWords() * eccPercent / 100 / 2
        var random: Random = getPseudoRandom()
        for (i in 0..ecWords) {
            // don't touch the core
            var x: Int64
            if (random_Bool[boolnum]) {
                x = random_Int64[Int64num]
                Int64num++
            } else {
                x = matrix.getWidth() - 1 - random_Int64[Int64num]
                Int64num++
            }
            boolnum++

            var y: Int64
            if (random_Bool[boolnum]) {
                y = random_Int64[Int64num]
                Int64num++
            } else {
                y = matrix.getHeight() - 1 - random_Int64[Int64num]
                Int64num++
            }
            boolnum++
            matrix.flip(x, y)
        }
        r = AztecDetectorResult(matrix, NO_POINTS, aztec.isCompact(), aztec.getCodeWords(), aztec.getLayers())
        res = Decoder().decode(r)
        @Assert(data, res.getText())
    }

    private static func getPseudoRandom(): Random {
        return Random(0xDEADBEEF)
    }

    private static func testModeMessage(compact: Bool, layers: Int64, words: Int64, expected: String) {
        var start: BitArray = Encoder.generateModeMessage(compact, layers, words)
        @Assert(stripSpace(expected), stripSpace(start.toString()))
    }

    private static func testStuffBits(wordSize: Int64, bits: String, expected: String) {
        var start: BitArray = toBitArray(bits)
        var stuffed: BitArray = Encoder.stuffBits(start, wordSize)
        @Assert(
            stripSpace(expected),
            stripSpace(stuffed.toString())
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

    public static func toBooleanArray(bitArray: BitArray): Array<Bool> {
        var result: Array<Bool> = Array<Bool>(bitArray.getSize(), item: true)
        for (i in 0..result.size) {
            result[i] = bitArray.get(i)
        }
        return result
    }

    private static func testHighLevelEncodeString(s: String, expectedBits: String) {
        try {
            var bits: BitArray = HighLevelEncoder(StandardCharsets.ISO_8859_1.newEncoder().getBytes(UTF32String(s))).
                encode()
            var receivedBits: String = stripSpace(bits.toString())
            var result: String = stripSpace(expectedBits)
            @Assert(stripSpace(expectedBits), receivedBits)
            @Assert(s, Decoder.highLevelDecode(toBooleanArray(bits)))
        } catch (e: Qrcoder4cjFormatException) {
            throw Qrcoder4cjFormatException()
        }
    }

    private static func testHighLevelEncodeString(s: String, expectedReceivedBits: Int64) {
        try {
            var bits: BitArray = HighLevelEncoder(StandardCharsets.ISO_8859_1.newEncoder().getBytes(UTF32String(s))).
                encode()
            var receivedBitCount: Int64 = stripSpace(bits.toString()).size
            @Assert(
                expectedReceivedBits,
                receivedBitCount
            )
            @Assert(s, Decoder.highLevelDecode(toBooleanArray(bits)))
        } catch (e: Qrcoder4cjFormatException) {
            throw Qrcoder4cjFormatException()
        }
    }

    public static func stripSpace(s: String): String {
        return SPACES.matcher(s).replaceAll("")
    }
}
