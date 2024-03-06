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

from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.qrcode.encoder.*
from QRCode4cj import zxing.code.qrcode.decoder.Mode
from QRCode4cj import zxing.code.qrcode.*
from QRCode4cj import zxing.code.qrcode.decoder.ErrorCorrectionLevel
from charset import charset.tools.UTF32String
from QRCode4cj import zxing.code.qrcode.decoder.Version
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import regex.*
from std import io.*

main(): Int64 {
    let tester = EncoderTestCase()
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
public class EncoderTestCase {
    @TestCase
    public func testGetAlphanumericCode(): Unit {
        // The first ten code points are numbers.
        for (i in 0..10) {
            @Assert(i, Encoder.getAlphanumericCode('0'.hashCode() + i))
        }

        // The next 26 code points are capital alphabet letters.
        for (i in 10..36) {
            @Assert(i, Encoder.getAlphanumericCode('A'.hashCode() + i - 10))
        }

        // Others are symbol letters
        @Assert(36, Encoder.getAlphanumericCode(' '.hashCode()))
        @Assert(37, Encoder.getAlphanumericCode('$'.hashCode()))
        @Assert(38, Encoder.getAlphanumericCode('%'.hashCode()))
        @Assert(39, Encoder.getAlphanumericCode('*'.hashCode()))
        @Assert(40, Encoder.getAlphanumericCode('+'.hashCode()))
        @Assert(41, Encoder.getAlphanumericCode('-'.hashCode()))
        @Assert(42, Encoder.getAlphanumericCode('.'.hashCode()))
        @Assert(43, Encoder.getAlphanumericCode('/'.hashCode()))
        @Assert(44, Encoder.getAlphanumericCode(':'.hashCode()))

        // Should return -1 for other letters;
        @Assert(-1, Encoder.getAlphanumericCode('a'.hashCode()))
        @Assert(-1, Encoder.getAlphanumericCode('#'.hashCode()))
        @Assert(-1, Encoder.getAlphanumericCode('\0'.hashCode()))
    }

    @TestCase
    public func testChooseMode(): Unit {
        // Numeric mode.
        @Assert(Mode.NUMERIC([10, 12, 14], 0x01), Encoder.chooseMode("0"))
        @Assert(Mode.NUMERIC([10, 12, 14], 0x01), Encoder.chooseMode("0123456789"))

        // Alphanumeric mode.
        @Assert(Mode.ALPHANUMERIC([9, 11, 13], 0x02), Encoder.chooseMode("A"))
        @Assert(
            Mode.ALPHANUMERIC([9, 11, 13], 0x02),
            Encoder.chooseMode("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:")
        )

        // 8-bit byte mode.
        @Assert(Mode.BYTE([8, 16, 16], 0x04), Encoder.chooseMode("a"))
        @Assert(Mode.BYTE([8, 16, 16], 0x04), Encoder.chooseMode("#"))
        @Assert(Mode.BYTE([8, 16, 16], 0x04), Encoder.chooseMode(""))

        // Kanji mode.  We used to use MODE_KANJI for these, but we stopped
        // doing that as we cannot distinguish Shift_JIS from other encodings
        // from data bytes alone.  See also comments in qrcode_encoder.h.

        // AIUE in Hiragana in Shift_JIS
        @Assert(
            Mode.BYTE([8, 16, 16], 0x04),
            Encoder.chooseMode(shiftJISString(bytes(0x8, 0xa, 0x8, 0xa, 0x8, 0xa, 0x8, 0xa6)))
        )

        // Nihon in Kanji in Shift_JIS.
        @Assert(Mode.BYTE([8, 16, 16], 0x04), Encoder.chooseMode(shiftJISString(bytes(0x9, 0xf, 0x9, 0x7b))))

        // Sou-Utsu-Byou in Kanji in Shift_JIS.
        @Assert(Mode.BYTE([8, 16, 16], 0x04), Encoder.chooseMode(shiftJISString(bytes(0xe, 0x4, 0x9, 0x5, 0x9, 0x61))))
    }

    @TestCase
    public func testEncode(): Unit {
        var qrCode: QRCode = Encoder.encode("ABCDEF", ErrorCorrectionLevel.H(0x02));
        var expected: String = "<<\n" + " mode: ALPHANUMERIC\n" + " ecLevel: H\n" + " version: 1\n" + " maskPattern: 0\n" +
            " matrix:\n" + " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 1 1 0 0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0 0 1 0 1 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 1 1 1 0 1 0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0\n" + " 0 0 1 0 1 1 1 0 1 1 0 0 1 1 0 0 0 1 0 0 1\n" +
            " 1 0 1 1 1 0 0 1 0 0 0 1 0 1 0 0 0 0 0 0 0\n" + " 0 0 1 1 0 0 1 0 1 0 0 0 1 0 1 0 1 0 1 1 0\n" +
            " 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 0 1 0\n" + " 0 0 1 1 0 1 1 1 1 0 0 0 1 0 1 0 1 1 1 1 0\n" +
            " 0 0 0 0 0 0 0 0 1 0 0 1 1 1 0 1 0 1 0 0 0\n" + " 1 1 1 1 1 1 1 0 0 0 1 0 1 0 1 1 0 0 0 0 1\n" +
            " 1 0 0 0 0 0 1 0 1 1 1 1 0 1 0 1 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 1 0 1 1 0 1 0 1 0 0 0 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 1 1 0 1 1 1 1 0 1 0 1 0\n" + " 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 1 0 1 1 0 1 0 0 0 1 1\n" + " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1 0 1 0 1\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    @TestCase
    public func testEncodeWithVersion(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.QR_VERSION, 7);
        var qrCode: QRCode = Encoder.encode("ABCDEF", ErrorCorrectionLevel.H(0x02), hints);
        @Assert(qrCode.toString().contains(" version: 7\n"))
    }

    @TestCase
    public func testEncodeWithVersionTooSmall(): Unit {
        try {
            var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
            hints.put(EncodeHintType.QR_VERSION, 3);
            Encoder.encode("THISMESSAGEISTOOLONGFORAQRCODEVERSION3", ErrorCorrectionLevel.H(0x02), hints);
            @Assert(false)
        } catch (e: WriterException) {}
    }

    @TestCase
    public func testSimpleUTF8ECI(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        var qrCode: QRCode = Encoder.encode("hello", ErrorCorrectionLevel.H(0x02), hints);
        var expected: String = "<<\n" + " mode: BYTE\n" + " ecLevel: H\n" + " version: 1\n" + " maskPattern: 3\n" +
            " matrix:\n" + " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 0 1 0 1 0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 1 1 0 1 0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 0 1 0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0\n" + " 0 0 1 1 0 0 1 1 1 1 0 0 0 1 1 0 1 0 0 0 0\n" +
            " 0 0 1 1 1 0 0 0 0 0 1 1 0 0 0 1 0 1 1 1 0\n" + " 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 0 1 1 1 1\n" +
            " 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 0 1 0 1 1 0\n" + " 0 0 0 0 1 0 1 1 1 1 0 0 0 0 0 1 0 0 1 0 0\n" +
            " 0 0 0 0 0 0 0 0 1 1 1 1 0 0 1 1 1 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 1 1 0 1 0 1 1 0 0 1 0 0\n" +
            " 1 0 0 0 0 0 1 0 0 0 1 0 0 1 1 1 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 0 1 0 0 0 0 1 1 0 0 0 0 0\n" +
            " 1 0 1 1 1 0 1 0 1 1 1 0 1 0 0 0 1 1 0 0 0\n" + " 1 0 1 1 1 0 1 0 1 1 0 0 0 1 0 0 1 0 0 0 0\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 1 1 0 1 0 1 0 1 1 0\n" + " 1 1 1 1 1 1 1 0 0 1 0 1 1 1 0 1 1 0 0 0 0\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    @TestCase
    public func testEncodeKanjiMode(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.CHARACTER_SET, "Shift_JIS");

        // Nihon in Kanji
        var qrCode: QRCode = Encoder.encode("\u{65e5}\u{672c}", ErrorCorrectionLevel.M(0x00), hints);
        var expected: String = "<<\n" + " mode: KANJI\n" + " ecLevel: M\n" + " version: 1\n" + " maskPattern: 4\n" +
            " matrix:\n" + " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 1 1 0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0 0 0 1 0 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 1 1 0 1 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 1 0 1 0 1 0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0\n" + " 1 0 0 0 1 0 1 1 1 0 0 0 1 1 1 1 1 1 0 0 1\n" +
            " 0 1 1 0 0 1 0 1 1 0 1 0 1 1 1 0 0 0 1 0 1\n" + " 1 1 1 1 0 1 1 1 0 0 1 0 1 1 0 0 0 0 1 1 1\n" +
            " 1 0 1 0 1 1 0 0 0 0 1 1 1 0 0 1 0 0 1 1 0\n" + " 0 0 1 0 1 1 1 1 1 1 1 1 0 0 1 1 1 1 0 1 1\n" +
            " 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 1 0 1 0 0 0\n" + " 1 1 1 1 1 1 1 0 1 1 0 1 0 0 1 1 1 1 1 1 0\n" +
            " 1 0 0 0 0 0 1 0 0 0 0 0 0 1 1 0 1 0 1 0 1\n" + " 1 0 1 1 1 0 1 0 1 0 1 0 1 1 1 0 0 0 1 1 1\n" +
            " 1 0 1 1 1 0 1 0 0 1 0 0 1 1 1 0 0 0 1 1 1\n" + " 1 0 1 1 1 0 1 0 0 1 1 0 1 1 0 0 0 1 0 0 0\n" +
            " 1 0 0 0 0 0 1 0 0 0 1 1 1 0 0 1 0 1 0 0 0\n" + " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 1 1 1 0 1 1 0\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    @TestCase
    public func testEncodeShiftjisNumeric(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.CHARACTER_SET, "Shift_JIS");
        var qrCode: QRCode = Encoder.encode("0123", ErrorCorrectionLevel.M(0x00), hints);
        var expected: String = "<<\n" + " mode: NUMERIC\n" + " ecLevel: M\n" + " version: 1\n" + " maskPattern: 0\n" +
            " matrix:\n" + " 1 1 1 1 1 1 1 0 0 0 0 0 1 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 1 1 0 1 0 0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0 0 1 1 0 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 0 1 0 0 0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 1 0 1 1 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 0 1 0 0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0\n" + " 1 0 1 0 1 0 1 0 0 0 0 0 1 0 0 0 1 0 0 1 0\n" +
            " 0 0 0 0 0 0 0 1 1 0 1 1 0 1 0 1 0 1 0 1 0\n" + " 0 1 0 1 0 1 1 1 1 0 0 1 0 1 1 1 0 1 0 1 0\n" +
            " 0 1 1 1 0 0 0 0 0 0 1 1 1 1 0 1 1 1 0 1 0\n" + " 0 0 0 1 1 1 1 1 1 1 1 1 0 1 1 1 0 0 1 0 1\n" +
            " 0 0 0 0 0 0 0 0 1 1 0 0 0 0 1 0 0 0 1 1 0\n" + " 1 1 1 1 1 1 1 0 0 1 0 0 1 0 0 0 1 0 0 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 1 0 0\n" + " 1 0 1 1 1 0 1 0 1 1 0 0 1 0 1 0 1 0 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 1 1 1 0 1 0 1 0 1 0 1 0\n" + " 1 0 1 1 1 0 1 0 1 0 1 1 0 1 1 1 0 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 0 1 1 1 1 0 1 1 1 0 0 0\n" + " 1 1 1 1 1 1 1 0 1 0 1 1 0 1 1 1 0 1 1 0 1\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    @TestCase
    public func testEncodeGS1WithStringTypeHint(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.GS1_FORMAT, "true");
        var qrCode: QRCode = Encoder.encode("100001%11171218", ErrorCorrectionLevel.H(0x02), hints);
        verifyGS1EncodedData(qrCode);
    }

    @TestCase
    public func testEncodeGS1WithBooleanTypeHint(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.GS1_FORMAT, true);
        var qrCode: QRCode = Encoder.encode("100001%11171218", ErrorCorrectionLevel.H(0x02), hints);
        verifyGS1EncodedData(qrCode);
    }

    @TestCase
    public func testDoesNotEncodeGS1WhenBooleanTypeHintExplicitlyFalse(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.GS1_FORMAT, false);
        var qrCode: QRCode = Encoder.encode("ABCDEF", ErrorCorrectionLevel.H(0x02), hints);
        verifyNotGS1EncodedData(qrCode);
    }

    @TestCase
    public func testDoesNotEncodeGS1WhenStringTypeHintExplicitlyFalse(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.GS1_FORMAT, "false");
        var qrCode: QRCode = Encoder.encode("ABCDEF", ErrorCorrectionLevel.H(0x02), hints);
        verifyNotGS1EncodedData(qrCode);
    }

    @TestCase
    public func testGS1ModeHeaderWithECI(): Unit {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>();
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        hints.put(EncodeHintType.GS1_FORMAT, true);
        var qrCode: QRCode = Encoder.encode("hello", ErrorCorrectionLevel.H(0x02), hints);
        var expected: String = "<<\n" + " mode: BYTE\n" + " ecLevel: H\n" + " version: 1\n" + " maskPattern: 6\n" +
            " matrix:\n" + " 1 1 1 1 1 1 1 0 0 0 1 1 0 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 1 0 0 0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0 1 1 0 0 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 1 1 0 1 0 0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 0 0 1 1 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 0 0 1 0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0\n" + " 0 0 0 1 1 0 1 1 0 1 0 0 0 0 0 0 0 1 1 0 0\n" +
            " 0 1 0 1 1 0 0 1 0 1 1 1 1 1 1 0 1 1 1 0 1\n" + " 0 1 1 1 1 0 1 0 0 1 0 1 0 1 1 1 0 0 1 0 1\n" +
            " 1 1 1 1 1 0 0 1 0 0 0 1 1 0 0 1 0 0 1 0 0\n" + " 1 0 0 1 0 0 1 1 0 1 1 0 1 0 1 0 0 1 0 0 1\n" +
            " 0 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 0 1 0 1 1 0 1 0 1 0 0\n" +
            " 1 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 1 1 1 0 0\n" + " 1 0 1 1 1 0 1 0 1 1 0 1 1 0 0 0 1 1 0 0 0\n" +
            " 1 0 1 1 1 0 1 0 1 0 1 1 1 1 1 0 0 0 1 1 0\n" + " 1 0 1 1 1 0 1 0 0 0 1 0 0 1 0 0 1 0 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 1 1 0 0\n" + " 1 1 1 1 1 1 1 0 0 1 0 1 0 0 1 0 0 0 0 0 0\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    @TestCase
    public func testAppendModeInfo(): Unit {
        var bits: BitArray = BitArray();
        Encoder.appendModeInfo(Mode.NUMERIC([10, 12, 14], 0x01), bits);
        @Assert(" ...X", bits.toString())
    }

    @TestCase
    public func testAppendLengthInfo(): Unit {
        var bits: BitArray = BitArray();
        Encoder.appendLengthInfo(
            1, // 1 letter (1/1).
            Version.getVersionForNumber(1),
            Mode.NUMERIC([10, 12, 14], 0x01),
            bits
        );
        @Assert(" ........ .X", bits.toString())

        // 10 bits.
        bits = BitArray()
        Encoder.appendLengthInfo(
            2, // 2 letters (2/1).
            Version.getVersionForNumber(10),
            Mode.ALPHANUMERIC([9, 11, 13], 0x02),
            bits
        );
        @Assert(" ........ .X.", bits.toString())

        // 11 bits.
        bits = BitArray()
        Encoder.appendLengthInfo(
            255, // 255 letter (255/1).
            Version.getVersionForNumber(27),
            Mode.BYTE([8, 16, 16], 0x04),
            bits
        );
        @Assert(" ........ XXXXXXXX", bits.toString())

        // 16 bits.
        bits = BitArray()
        Encoder.appendLengthInfo(
            512, // 512 letters (1024/2).
            Version.getVersionForNumber(40),
            Mode.KANJI([8, 10, 12], 0x08),
            bits
        );
        @Assert(" ..X..... ....", bits.toString())
        // 12 bits.
    }

    @TestCase
    public func testAppendBytes(): Unit {
        // Should use appendNumericBytes.
        // 1 = 01 = 0001 in 4 bits.
        var bits: BitArray = BitArray();
        Encoder.appendBytes(UTF32String("1"), Mode.NUMERIC([10, 12, 14], 0x01), bits, Encoder.DEFAULT_BYTE_MODE_ENCODING
        );
        @Assert(" ...X" , bits.toString())

        // Should use appendAlphanumericBytes.
        // A = 10 = 0xa = 001010 in 6 bits
        bits = BitArray()
        Encoder.appendBytes(
            UTF32String("A"),
            Mode.ALPHANUMERIC([9, 11, 13], 0x02),
            bits,
            Encoder.DEFAULT_BYTE_MODE_ENCODING
        );
        @Assert(" ..X.X." , bits.toString())

        // Lower letters such as 'a' cannot be encoded in MODE_ALPHANUMERIC.
        try {
            Encoder.appendBytes(
                UTF32String("a"),
                Mode.ALPHANUMERIC([9, 11, 13], 0x02),
                bits,
                Encoder.DEFAULT_BYTE_MODE_ENCODING
            );
            @Assert(false)
        } catch (we: WriterException) {
            // good
        }

        // Should use append8BitBytes.
        // 0x61, 0x62, 0x63
        bits = BitArray()
        Encoder.appendBytes(UTF32String("abc"), Mode.BYTE([8, 16, 16], 0x04), bits, Encoder.DEFAULT_BYTE_MODE_ENCODING);
        @Assert(" .XX....X .XX...X. .XX...XX", bits.toString())

        // Anything can be encoded in QRCode.MODE_8BIT_BYTE.
        Encoder.appendBytes(UTF32String("\0"), Mode.BYTE([8, 16, 16], 0x04), bits, Encoder.DEFAULT_BYTE_MODE_ENCODING);

        // Should use appendKanjiBytes.
        // 0x93, 0x5f

        bits = BitArray()
        Encoder.appendBytes(
            UTF32String(shiftJISString(bytes(0x93, 0x5f))),
            Mode.KANJI([8, 10, 12], 0x08),
            bits,
            Encoder.DEFAULT_BYTE_MODE_ENCODING
        );
        @Assert(" .XX.XX.. XXXXX", bits.toString())
    }

    @TestCase
    public func testTerminateBits(): Unit {
        var v: BitArray = BitArray();
        Encoder.terminateBits(0, v);
        @Assert("", v.toString())
        v = BitArray()
        Encoder.terminateBits(1, v);
        @Assert(" ........", v.toString())
        v = BitArray()
        v.appendBits(0, 3);

        // Append 000
        Encoder.terminateBits(1, v);
        @Assert(" ........", v.toString())
        v = BitArray()
        v.appendBits(0, 5);

        // Append 00000
        Encoder.terminateBits(1, v);
        @Assert(" ........", v.toString())
        v = BitArray()
        v.appendBits(0, 8);

        // Append 00000000
        Encoder.terminateBits(1, v);
        @Assert(" ........", v.toString())
        v = BitArray()
        Encoder.terminateBits(2, v);
        @Assert(" ........ XXX.XX..", v.toString())
        v = BitArray()
        v.appendBits(0, 1);

        // Append 0
        Encoder.terminateBits(3, v);
        @Assert(" ........ XXX.XX.. ...X...X", v.toString())
    }

    @TestCase
    public func testGetNumDataBytesAndNumECBytesForBlockID(): Unit {
        var numDataBytes: Array<Int64> = Array<Int64>(1, item: 0);
        var numEcBytes: Array<Int64> = Array<Int64>(1, item: 0);

        // Version 1-H.
        Encoder.getNumDataBytesAndNumECBytesForBlockID(26, 9, 1, 0, numDataBytes, numEcBytes);
        @Assert(9, numDataBytes[0])
        @Assert(17, numEcBytes[0])

        // Version 3-H.  2 blocks.
        Encoder.getNumDataBytesAndNumECBytesForBlockID(70, 26, 2, 0, numDataBytes, numEcBytes);
        @Assert(13, numDataBytes[0])
        @Assert(22, numEcBytes[0])
        Encoder.getNumDataBytesAndNumECBytesForBlockID(70, 26, 2, 1, numDataBytes, numEcBytes);
        @Assert(13, numDataBytes[0])
        @Assert(22, numEcBytes[0])

        // Version 7-H. (4 + 1) blocks.
        Encoder.getNumDataBytesAndNumECBytesForBlockID(196, 66, 5, 0, numDataBytes, numEcBytes);
        @Assert(13, numDataBytes[0])
        @Assert(26, numEcBytes[0])
        Encoder.getNumDataBytesAndNumECBytesForBlockID(196, 66, 5, 4, numDataBytes, numEcBytes);
        @Assert(14, numDataBytes[0])
        @Assert(26, numEcBytes[0])

        // Version 40-H. (20 + 61) blocks.
        Encoder.getNumDataBytesAndNumECBytesForBlockID(3706, 1276, 81, 0, numDataBytes, numEcBytes);
        @Assert(15, numDataBytes[0])
        @Assert(30, numEcBytes[0])
        Encoder.getNumDataBytesAndNumECBytesForBlockID(3706, 1276, 81, 20, numDataBytes, numEcBytes);
        @Assert(16, numDataBytes[0])
        @Assert(30, numEcBytes[0])
        Encoder.getNumDataBytesAndNumECBytesForBlockID(3706, 1276, 81, 80, numDataBytes, numEcBytes);
        @Assert(16, numDataBytes[0])
        @Assert(30, numEcBytes[0])
    }

    @TestCase
    public func testInterleaveWithECBytes(): Unit {
        var dataBytes: Array<UInt8> = bytes(32, 65, 205, 69, 41, 220, 46, 128, 236);
        var inBits: BitArray = BitArray();
        for (dataByte in dataBytes) {
            inBits.appendBits(Int64(dataByte), 8);
        }
        var out: BitArray = Encoder.interleaveWithECBytes(inBits, 26, 9, 1);
        var expected: Array<UInt8> = bytes(
            // Data bytes.
            32,
            65,
            205,
            69,
            41,
            220,
            46,
            128,
            236,
            // Error correction bytes.
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
        );
        @Assert(expected.size, out.getSizeInBytes())
        var outArray: Array<UInt8> = Array<UInt8>(expected.size, item: 0);
        out.toBytes(0, outArray, 0, expected.size);

        // Can't use Arrays.equals(), because outArray may be longer than out.sizeInBytes()
        for (x in 0..expected.size) {
            @Assert(expected[x], outArray[x])
        }

        // Numbers are from http://www.swetake.com/qr/qr8.html
        dataBytes = bytes(
            67,
            70,
            22,
            38,
            54,
            70,
            86,
            102,
            118,
            134,
            150,
            166,
            182,
            198,
            214,
            230,
            247,
            7,
            23,
            39,
            55,
            71,
            87,
            103,
            119,
            135,
            151,
            166,
            22,
            38,
            54,
            70,
            86,
            102,
            118,
            134,
            150,
            166,
            182,
            198,
            214,
            230,
            247,
            7,
            23,
            39,
            55,
            71,
            87,
            103,
            119,
            135,
            151,
            160,
            236,
            17,
            236,
            17,
            236,
            17,
            236,
            17
        )
        inBits = BitArray()
        for (dataByte in dataBytes) {
            inBits.appendBits(Int64(dataByte), 8);
        }

        out = Encoder.interleaveWithECBytes(inBits, 134, 62, 4)
        expected = bytes(
            // Data bytes.
            67,
            230,
            54,
            55,
            70,
            247,
            70,
            71,
            22,
            7,
            86,
            87,
            38,
            23,
            102,
            103,
            54,
            39,
            118,
            119,
            70,
            55,
            134,
            135,
            86,
            71,
            150,
            151,
            102,
            87,
            166,
            160,
            118,
            103,
            182,
            236,
            134,
            119,
            198,
            17,
            150,
            135,
            214,
            236,
            166,
            151,
            230,
            17,
            182,
            166,
            247,
            236,
            198,
            22,
            7,
            17,
            214,
            38,
            23,
            236,
            39,
            17,
            // Error correction bytes.
            175,
            155,
            245,
            236,
            80,
            146,
            56,
            74,
            155,
            165,
            133,
            142,
            64,
            183,
            132,
            13,
            178,
            54,
            132,
            108,
            45,
            113,
            53,
            50,
            214,
            98,
            193,
            152,
            233,
            147,
            50,
            71,
            65,
            190,
            82,
            51,
            209,
            199,
            171,
            54,
            12,
            112,
            57,
            113,
            155,
            117,
            211,
            164,
            117,
            30,
            158,
            225,
            31,
            190,
            242,
            38,
            140,
            61,
            179,
            154,
            214,
            138,
            147,
            87,
            27,
            96,
            77,
            47,
            187,
            49,
            156,
            214
        )
        @Assert(expected.size, out.getSizeInBytes())
        outArray = Array<UInt8>(expected.size, item: 0)
        out.toBytes(0, outArray, 0, expected.size);
        for (x in 0..expected.size) {
            @Assert(expected[x], outArray[x])
        }
    }

    private static func bytes(ints: Array<Int64>): Array<UInt8> {
        var bytes: Array<UInt8> = Array<UInt8>(ints.size, item: 0);
        for (i in 0..ints.size) {
            bytes[i] = UInt8(ints[i])
        }
        return bytes
    }

    @TestCase
    public func testAppendNumericBytes(): Unit {
        // 1 = 01 = 0001 in 4 bits.
        var bits: BitArray = BitArray();
        Encoder.appendNumericBytes(UTF32String("1"), bits);
        @Assert(" ...X" , bits.toString())

        // 12 = 0xc = 0001100 in 7 bits.
        bits = BitArray()
        Encoder.appendNumericBytes(UTF32String("12"), bits);
        @Assert(" ...XX.." , bits.toString())

        // 123 = 0x7b = 0001111011 in 10 bits.
        bits = BitArray()
        Encoder.appendNumericBytes(UTF32String("123"), bits);
        @Assert(" ...XXXX. XX" , bits.toString())

        // 1234 = "123" + "4" = 0001111011 + 0100
        bits = BitArray()
        Encoder.appendNumericBytes(UTF32String("1234"), bits);
        @Assert(" ...XXXX. XX.X.." , bits.toString())

        // Empty.
        bits = BitArray()
        Encoder.appendNumericBytes(UTF32String(""), bits);
        @Assert("" , bits.toString())
    }

    @TestCase
    public func testAppendAlphanumericBytes(): Unit {
        // A = 10 = 0xa = 001010 in 6 bits
        var bits: BitArray = BitArray();
        Encoder.appendAlphanumericBytes(UTF32String("A"), bits);
        @Assert(" ..X.X." , bits.toString())

        // AB = 10 * 45 + 11 = 461 = 0x1cd = 00111001101 in 11 bits
        bits = BitArray()
        Encoder.appendAlphanumericBytes(UTF32String("AB"), bits);
        @Assert(" ..XXX..X X.X", bits.toString())

        // ABC = "AB" + "C" = 00111001101 + 001100
        bits = BitArray()
        Encoder.appendAlphanumericBytes(UTF32String("ABC"), bits);
        @Assert(" ..XXX..X X.X..XX. ." , bits.toString())

        // Empty.
        bits = BitArray()
        Encoder.appendAlphanumericBytes(UTF32String(""), bits);
        @Assert("" , bits.toString())

        // Invalid data.
        try {
            Encoder.appendAlphanumericBytes(UTF32String("abc"), BitArray());
        } catch (we: WriterException) {
            // good
        }
    }

    @TestCase
    public func testAppend8BitBytes(): Unit {
        // 0x61, 0x62, 0x63
        var bits: BitArray = BitArray();
        Encoder.append8BitBytes(UTF32String("abc"), bits, Encoder.DEFAULT_BYTE_MODE_ENCODING);
        @Assert(" .XX....X .XX...X. .XX...XX", bits.toString())

        // Empty.
        bits = BitArray()
        Encoder.append8BitBytes(UTF32String(""), bits, Encoder.DEFAULT_BYTE_MODE_ENCODING);
        @Assert("", bits.toString())
    }

    // Numbers are from page 21 of JISX0510:2004
    @TestCase
    public func testAppendKanjiBytes(): Unit {
        var bits: BitArray = BitArray();
        Encoder.appendKanjiBytes(UTF32String(shiftJISString(bytes(0x93, 0x5f))), bits);
        @Assert(" .XX.XX.. XXXXX", bits.toString())
        Encoder.appendKanjiBytes(UTF32String(shiftJISString(bytes(0xe4, 0xaa))), bits);
        @Assert(" .XX.XX.. XXXXXXX. X.X.X.X. X.", bits.toString())
    }

    // Numbers are from http://www.swetake.com/qr/qr3.html and
    // http://www.swetake.com/qr/qr9.html
    @TestCase
    public func testGenerateECBytes(): Unit {
        var dataBytes: Array<UInt8> = bytes(32, 65, 205, 69, 41, 220, 46, 128, 236);
        var ecBytes: Array<UInt8> = Encoder.generateECBytes(dataBytes, 17);
        var expected: Array<UInt8> = [42, 159, 74, 221, 244, 169, 239, 150, 138, 70, 237, 85, 224, 96, 74, 219, 61]
        @Assert(expected.size, ecBytes.size)
        for (x in 0..expected.size) {
            @Assert(expected[x], ecBytes[x] & 0xFF)
        }
        dataBytes = bytes(67, 70, 22, 38, 54, 70, 86, 102, 118, 134, 150, 166, 182, 198, 214)
        ecBytes = Encoder.generateECBytes(dataBytes, 18)
        expected = [175, 80, 155, 64, 178, 45, 214, 233, 65, 209, 12, 155, 117, 31, 140, 214, 27, 187]
        @Assert(expected.size, ecBytes.size)
        for (x in 0..expected.size) {
            @Assert(expected[x], ecBytes[x] & 0xFF)
        }

        // High-order zero coefficient case.
        dataBytes = bytes(32, 49, 205, 69, 42, 20, 0, 236, 17)
        ecBytes = Encoder.generateECBytes(dataBytes, 17)
        expected = [0, 3, 130, 179, 194, 0, 55, 211, 110, 79, 98, 72, 170, 96, 211, 137, 213]
        @Assert(expected.size, ecBytes.size)
        for (x in 0..expected.size) {
            @Assert(expected[x], ecBytes[x] & 0xFF)
        }
    }

    @TestCase
    public func testBugInBitVectorNumBytes(): Unit {
        // There was a bug in BitVector.sizeInBytes() that caused it to return a
        // smaller-by-one value (ex. 1465 instead of 1466) if the number of bits
        // in the vector is not 8-bit aligned.  In QRCodeEncoder::InitQRCode(),
        // BitVector::sizeInBytes() is used for finding the smallest QR Code
        // version that can fit the given data.  Hence there were corner cases
        // where we chose a wrong QR Code version that cannot fit the given
        // data.  Note that the issue did not occur with MODE_8BIT_BYTE, as the
        // bits in the bit vector are always 8-bit aligned.
        //
        // Before the bug was fixed, the following test didn't pass, because:
        //
        // - MODE_NUMERIC is chosen as all bytes in the data are '0'
        // - The 3518-byte numeric data needs 1466 bytes
        //   - 3518 / 3 * 10 + 7 = 11727 bits = 1465.875 bytes
        //   - 3 numeric bytes are encoded in 10 bits, hence the first
        //     3516 bytes are encoded in 3516 / 3 * 10 = 11720 bits.
        //   - 2 numeric bytes can be encoded in 7 bits, hence the last
        //     2 bytes are encoded in 7 bits.
        // - The version 27 QR Code with the EC level L has 1468 bytes for data.
        //   - 1828 - 360 = 1468
        // - In InitQRCode(), 3 bytes are reserved for a header.  Hence 1465 bytes
        //   (1468 -3) are left for data.
        // - Because of the bug in BitVector::sizeInBytes(), InitQRCode() determines
        //   the given data can fit in 1465 bytes, despite it needs 1466 bytes.
        // - Hence QRCodeEncoder.encode() failed and returned false.
        //   - To be precise, it needs 11727 + 4 (getMode info) + 14 (size info) =
        //     11745 bits = 1468.125 bytes are needed (i.e. cannot fit in 1468
        //     bytes).
        var builder: StringBuilder = StringBuilder();
        for (x in 0..3518) {
            builder.append('0');
        }
        Encoder.encode(builder.toString(), ErrorCorrectionLevel.L(0x01));
    }

    @TestCase
    public func testMinimalEncoder1(): Unit {
        verifyMinimalEncoding("A", "ALPHANUMERIC(A)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder2(): Unit {
        verifyMinimalEncoding("AB", "ALPHANUMERIC(AB)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder3(): Unit {
        verifyMinimalEncoding("ABC", "ALPHANUMERIC(ABC)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder4(): Unit {
        verifyMinimalEncoding("ABCD", "ALPHANUMERIC(ABCD)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder5(): Unit {
        verifyMinimalEncoding("ABCDE", "ALPHANUMERIC(ABCDE)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder6(): Unit {
        verifyMinimalEncoding("ABCDEF", "ALPHANUMERIC(ABCDEF)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder7(): Unit {
        verifyMinimalEncoding("ABCDEFG", "ALPHANUMERIC(ABCDEFG)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder8(): Unit {
        verifyMinimalEncoding("1", "NUMERIC(1)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder9(): Unit {
        verifyMinimalEncoding("12", "NUMERIC(12)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder10(): Unit {
        verifyMinimalEncoding("123", "NUMERIC(123)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder11(): Unit {
        verifyMinimalEncoding("1234", "NUMERIC(1234)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder12(): Unit {
        verifyMinimalEncoding("12345", "NUMERIC(12345)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder13(): Unit {
        verifyMinimalEncoding("123456", "NUMERIC(123456)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder14(): Unit {
        verifyMinimalEncoding("123A", "ALPHANUMERIC(123A)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder15(): Unit {
        verifyMinimalEncoding("A1", "ALPHANUMERIC(A1)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder16(): Unit {
        verifyMinimalEncoding("A12", "ALPHANUMERIC(A12)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder17(): Unit {
        verifyMinimalEncoding("A123", "ALPHANUMERIC(A123)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder18(): Unit {
        verifyMinimalEncoding("A1234", "ALPHANUMERIC(A1234)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder19(): Unit {
        verifyMinimalEncoding("A12345", "ALPHANUMERIC(A12345)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder20(): Unit {
        verifyMinimalEncoding("A123456", "ALPHANUMERIC(A123456)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder21(): Unit {
        verifyMinimalEncoding("A1234567", "ALPHANUMERIC(A1234567)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder22(): Unit {
        verifyMinimalEncoding("A12345678", "BYTE(A),NUMERIC(12345678)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder23(): Unit {
        verifyMinimalEncoding("A123456789", "BYTE(A),NUMERIC(123456789)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder24(): Unit {
        verifyMinimalEncoding("A1234567890", "ALPHANUMERIC(A1),NUMERIC(234567890)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder25(): Unit {
        verifyMinimalEncoding("AB1", "ALPHANUMERIC(AB1)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder26(): Unit {
        verifyMinimalEncoding("AB12", "ALPHANUMERIC(AB12)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder27(): Unit {
        verifyMinimalEncoding("AB123", "ALPHANUMERIC(AB123)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder28(): Unit {
        verifyMinimalEncoding("AB1234", "ALPHANUMERIC(AB1234)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder29(): Unit {
        verifyMinimalEncoding("ABC1", "ALPHANUMERIC(ABC1)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder30(): Unit {
        verifyMinimalEncoding("ABC12", "ALPHANUMERIC(ABC12)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder31(): Unit {
        verifyMinimalEncoding("ABC1234", "ALPHANUMERIC(ABC1234)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder32(): Unit {
        verifyMinimalEncoding(
            "http://foo.com",
            "BYTE(http://foo.com)" + "",
            MyCharset(),
            false
        );
    }

    @TestCase
    public func testMinimalEncoder33(): Unit {
        verifyMinimalEncoding(
            "HTTP://FOO.COM",
            "ALPHANUMERIC(HTTP://FOO.COM" + ")",
            MyCharset(),
            false
        );
    }

    @TestCase
    public func testMinimalEncoder34(): Unit {
        verifyMinimalEncoding(
            "1001114670010%01201220%107211220%140045003267781",
            "NUMERIC(1001114670010),ALPHANUMERIC(%01201220%107211220%),NUMERIC(140045003267781)",
            MyCharset(),
            false
        );
    }

    @TestCase
    public func testMinimalEncoder35(): Unit {
        verifyMinimalEncoding("\u{0150}", "ECI(ISO-8859-2),BYTE(.)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder36(): Unit {
        verifyMinimalEncoding("\u{015C}", "ECI(ISO-8859-3),BYTE(.)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder37(): Unit {
        verifyMinimalEncoding("\u{0150}\u{015C}", "ECI(UTF-8),BYTE(..)", MyCharset(), false);
    }

    @TestCase
    public func testMinimalEncoder38(): Unit {
        verifyMinimalEncoding(
            "\u{0150}\u{0150}\u{015C}\u{015C}",
            "ECI(ISO-8859-2),BYTE(." + ".),ECI(ISO-8859-3),BYTE(..)",
            MyCharset(),
            false
        );
    }

    @TestCase
    public func testMinimalEncoder39(): Unit {
        verifyMinimalEncoding(
            "abcdef\u{0150}ghij",
            "ECI(ISO-8859-2),BYTE(abcde" + "f.ghij)",
            MyCharset(),
            false
        );
    }

    @TestCase
    public func testMinimalEncoder40(): Unit {
        verifyMinimalEncoding(
            "2938928329832983\u{0150}2938928329832983\u{015C}2938928329832983",
            "NUMERIC(2938928329832983),ECI(ISO-8859-2),BYTE(.),NUMERIC(2938928329832983),ECI(ISO-8" +
                "859-3),BYTE(.),NUMERIC(2938928329832983)",
            MyCharset(),
            false
        );
    }

    @TestCase
    public func testMinimalEncoder41(): Unit {
        verifyMinimalEncoding(
            "1001114670010%01201220%107211220%140045003267781",
            "FNC1_FIRST_POSITION(),NUMERIC(100111" +
                "4670010),ALPHANUMERIC(%01201220%107211220%),NUMERIC(140045003267781)",
            MyCharset(),
            true
        );
    }

    @TestCase
    public func testMinimalEncoder42(): Unit {
        // test halfwidth Katakana character (they are single byte encoded in Shift_JIS)
        verifyMinimalEncoding(
            "Katakana:\u{FF66}\u{FF66}\u{FF66}\u{FF66}\u{FF66}\u{FF66}",
            "ECI(Shift_JIS),BYTE(Katakana:......)",
            MyCharset(),
            false
        );
    }

    @TestCase
    public func testMinimalEncoder43(): Unit {
        // The character \u30A2 encodes as double byte in Shift_JIS so KANJI is more compact in this case
        verifyMinimalEncoding(
            "Katakana:\u{30A2}\u{30A2}\u{30A2}\u{30A2}\u{30A2}\u{30A2}",
            "BYTE(Katakana:),KANJI(......)",
            MyCharset(),
            false
        );
    }

    @TestCase
    public func testMinimalEncoder44(): Unit {
        // The character \u30A2 encodes as double byte in Shift_JIS but KANJI is not more compact in this case because
        // KANJI is only more compact when it encodes pairs of characters. In the case of mixed text it can however be
        // that Shift_JIS encoding is more compact as in this example
        verifyMinimalEncoding(
            "Katakana:\u{30A2}a\u{30A2}a\u{30A2}a\u{30A2}a\u{30A2}a\u{30A2}",
            "ECI(Shift_JIS),BYTE(Katakana:.a.a.a" + ".a.a.)",
            MyCharset(),
            false
        );
    }

    static func verifyMinimalEncoding(input: String, expectedResult: String, priorityCharset: MyCharset, isGS1: Bool) {
        var result: ResultList = MinimalEncoder.encode(
            UTF32String(input),
            None,
            priorityCharset,
            isGS1,
            ErrorCorrectionLevel.L(0x01)
        );
        @Assert(result.toString(), expectedResult)
    }

    private static func verifyGS1EncodedData(qrCode: QRCode) {
        var expected: String = "<<\n" + " mode: ALPHANUMERIC\n" + " ecLevel: H\n" + " version: 2\n" + " maskPattern: 2\n" +
            " matrix:\n" + " 1 1 1 1 1 1 1 0 1 0 1 1 1 1 0 1 1 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 1 0 0 0 0 1 1 0 1 0 1 0 0 0 0 0 1\n" +
            " 1 0 1 1 1 0 1 0 1 0 1 1 0 1 1 0 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 1 1 0 1 0 1 1 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 1 1 1 1 1 1 1 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 1 0 0 1 1 1 0 0 0 0 1 0 0 0 0 0 1\n" +
            " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 1 1 1 0 0 0 1 1 1 0 0 0 0 0 0 0 0\n" +
            " 0 0 1 1 1 0 1 0 1 1 1 1 0 1 1 0 1 1 1 1 0 0 1 1 1\n" +
            " 0 0 0 1 1 1 0 1 0 0 1 0 0 1 0 0 1 1 1 0 0 1 0 0 1\n" +
            " 1 0 1 1 0 0 1 0 1 1 0 0 0 0 1 0 1 1 1 0 0 1 0 0 1\n" +
            " 0 0 1 1 0 1 0 1 1 1 1 0 0 1 1 1 1 0 0 0 1 1 0 1 1\n" +
            " 0 0 1 0 0 0 1 0 0 0 1 1 0 1 0 0 0 1 0 1 1 1 0 1 0\n" +
            " 1 1 1 0 1 1 0 1 0 0 0 0 0 0 0 1 1 0 1 1 0 1 0 0 0\n" +
            " 1 0 1 0 1 0 1 1 0 1 0 1 0 1 1 0 0 0 0 0 1 1 0 0 1\n" +
            " 1 0 0 1 0 1 0 1 0 0 0 1 1 1 1 0 1 0 1 0 0 1 0 0 1\n" +
            " 1 0 1 0 0 1 1 1 0 1 1 0 0 1 0 0 1 1 1 1 1 1 0 0 0\n" +
            " 0 0 0 0 0 0 0 0 1 0 0 1 0 1 1 0 1 0 0 0 1 0 0 1 0\n" +
            " 1 1 1 1 1 1 1 0 0 0 0 1 0 0 1 1 1 0 1 0 1 0 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 1 1 1 1 0 1 1 0 0 0 1 0 0 0 1\n" +
            " 1 0 1 1 1 0 1 0 1 0 1 0 0 1 1 1 1 1 1 1 1 0 0 0 1\n" +
            " 1 0 1 1 1 0 1 0 1 1 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0\n" +
            " 1 0 1 1 1 0 1 0 1 0 0 0 1 1 0 1 0 0 1 1 1 0 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 0 1 0 1 1 1 0 1 0 0 1 1 1 1 1\n" +
            " 1 1 1 1 1 1 1 0 0 1 1 0 0 1 1 0 1 0 0 0 0 1 0 1 1\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    private static func verifyNotGS1EncodedData(qrCode: QRCode) {
        var expected: String = "<<\n" + " mode: ALPHANUMERIC\n" + " ecLevel: H\n" + " version: 1\n" + " maskPattern: 0\n" +
            " matrix:\n" + " 1 1 1 1 1 1 1 0 1 1 1 1 0 0 1 1 1 1 1 1 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 1 1 0 0 1 0 0 0 0 0 1\n" + " 1 0 1 1 1 0 1 0 0 1 0 1 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 1 1 1 0 1 0 1 1 1 0 1 0 1 0 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 0 1 1 1 0 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 1\n" + " 1 1 1 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 1\n" +
            " 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0\n" + " 0 0 1 0 1 1 1 0 1 1 0 0 1 1 0 0 0 1 0 0 1\n" +
            " 1 0 1 1 1 0 0 1 0 0 0 1 0 1 0 0 0 0 0 0 0\n" + " 0 0 1 1 0 0 1 0 1 0 0 0 1 0 1 0 1 0 1 1 0\n" +
            " 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 0 1 0\n" + " 0 0 1 1 0 1 1 1 1 0 0 0 1 0 1 0 1 1 1 1 0\n" +
            " 0 0 0 0 0 0 0 0 1 0 0 1 1 1 0 1 0 1 0 0 0\n" + " 1 1 1 1 1 1 1 0 0 0 1 0 1 0 1 1 0 0 0 0 1\n" +
            " 1 0 0 0 0 0 1 0 1 1 1 1 0 1 0 1 1 1 1 0 1\n" + " 1 0 1 1 1 0 1 0 1 0 1 1 0 1 0 1 0 0 0 0 1\n" +
            " 1 0 1 1 1 0 1 0 0 1 1 0 1 1 1 1 0 1 0 1 0\n" + " 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 1 1 0 1\n" +
            " 1 0 0 0 0 0 1 0 0 1 1 0 1 1 0 1 0 0 0 1 1\n" + " 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1 0 1 0 1\n" + ">>\n"
        @Assert(expected, qrCode.toString())
    }

    private static func shiftJISString(bytes: Array<UInt8>): String {
        return StringUtils.SHIFT_JIS_CHARSET.newDecoder().decode(bytes);
    }
}
