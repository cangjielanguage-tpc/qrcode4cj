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

from QRCode4cj import zxing.code.tools.*
from QRCode4cj import zxing.code.common.*
from QRCode4cj import zxing.code.common.reader.*
from QRCode4cj import zxing.code.oned.*
from QRCode4cj import zxing.code.tools.UTF32String
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import collection.*
from std import os.posix.*

main(): Int64 {
    let tester = Code128WriterTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link Code128Writer}.
 */
@Test
public class Code128WriterTestCase {
    private static let FNC1: String = "11110101110";
    private static let FNC2: String = "11110101000";
    private static let FNC3: String = "10111100010";
    private static let FNC4A: String = "11101011110";
    private static let FNC4B: String = "10111101110";
    private static let START_CODE_A: String = "11010000100";
    private static let START_CODE_B: String = "11010010000";
    private static let START_CODE_C: String = "11010011100";
    private static let SWITCH_CODE_A: String = "11101011110";
    private static let SWITCH_CODE_B: String = "10111101110";
    private static let QUIET_SPACE: String = "00000";
    private static let STOP: String = "1100011101011";
    private static let LF: String = "10000110010";

    private var writer: Writer = Code128Writer()
    private var reader: Code128Reader = Code128Reader()

    @TestCase
    public func testEncodeWithFunc3(): Unit {
        var toEncode: String = "\u{00f3}" + "123"
        var expected: String = QUIET_SPACE + START_CODE_B + FNC3 + // "1"            "2"             "3"            check digit 51
            "10011100110" + "11001110010" + "11001011100" +
            "11101000110" + STOP + QUIET_SPACE

        var result: BitMatrix = encode(toEncode, false, "123");
        var actual: String = matrixToString(result);
        @Expect(expected, actual)

        var width: Int64 = result.getWidth();
        result = encode(toEncode, true, "123")
        @Expect(width, result.getWidth())
    }

    @TestCase
    public func testEncodeWithFunc2(): Unit {
        var toEncode: String = "\u{00f2}" + "123"
        var expected: String = QUIET_SPACE + START_CODE_B + FNC2 + // "1"            "2"             "3"             check digit 56
            "10011100110" + "11001110010" + "11001011100" +
            "11100010110" + STOP + QUIET_SPACE

        var result: BitMatrix = encode(toEncode, false, "123");

        var actual: String = matrixToString(result);
        @Expect(expected, actual)

        var width: Int64 = result.getWidth();
        result = encode(toEncode, true, "123")

        @Expect(width, result.getWidth())
    }

    @TestCase
    public func testEncodeWithFunc1(): Unit {
        var toEncode: String = "\u{00f1}" + "123"
        var expected: String = QUIET_SPACE + START_CODE_C + FNC1 + // "12"                           "3"            check digit 92
            "10110011100" + SWITCH_CODE_B + "11001011100" +
            "10101111000" + STOP + QUIET_SPACE

        var result: BitMatrix = encode(toEncode, false, "123");

        var actual: String = matrixToString(result);
        @Expect(expected, actual)

        var width: Int64 = result.getWidth();
        result = encode(toEncode, true, "123")

        @Expect(width, result.getWidth())
    }

    @TestCase
    public func testRoundtrip(): Unit {
        var toEncode: String = "\u{00f1}" + "10958" + "\u{00f1}" + "17160526"
        var expected: String = "1095817160526"

        var encResult: BitMatrix = encode(toEncode, false, expected);

        var width: Int64 = encResult.getWidth();

        encResult = encode(toEncode, true, expected)

        //Compact encoding has one latch less and encodes as STARTA,FNC1,1,CODEC,09,58,FNC1,17,16,05,26
        @Expect(width, encResult.getWidth() + 11)
    }

    @TestCase
    public func testCompaction1(): Unit {
        //compare fast to compact
        var toEncode: String = "AAAAAAAAAAA12AAAAAAAAA";
        var result: BitMatrix = encode(toEncode, false, toEncode);

        var width: Int64 = result.getWidth();
        result = encode(toEncode, true, toEncode)

        //very good, no difference
        @Expect(width, result.getWidth())
    }

    @TestCase
    public func testCompaction2(): Unit {
        //compare fast to compact
        var toEncode: String = "AAAAAAAAAAA1212aaaaaaaaa";
        var result: BitMatrix = encode(toEncode, false, toEncode);

        var width: Int64 = result.getWidth();
        result = encode(toEncode, true, toEncode)

        //very good, no difference
        @Expect(width, result.getWidth())
    }

    @TestCase
    public func testEncodeWithFunc4(): Unit {
        var toEncode: String = "\u{00f4}" + "123"
        var expected: String = QUIET_SPACE + START_CODE_B + FNC4B + // "1"            "2"             "3"            check digit 59
            "10011100110" + "11001110010" + "11001011100" +
            "11100011010" + STOP + QUIET_SPACE

        var result: BitMatrix = encode(toEncode, false, "");

        var actual: String = matrixToString(result);
        @Expect(expected, actual)

        var width: Int64 = result.getWidth();
        result = encode(toEncode, true, "")
        @Expect(width, result.getWidth())
    }

    @TestCase
    public func testEncodeWithFncsAndNumberInCodesetA(): Unit {
        var toEncode: String = "\n" + "\u{00f1}" + "\u{00f4}" + "1" + "\n"

        var expected: String = QUIET_SPACE + START_CODE_A + LF + FNC1 + FNC4A + "10011100110" + LF + "10101111000" + STOP +
            QUIET_SPACE

        var result: BitMatrix = encode(toEncode, false, "");

        var actual: String = matrixToString(result);

        @Expect(expected, actual)

        var width: Int64 = result.getWidth();
        result = encode(toEncode, true, "")
        @Expect(width, result.getWidth())
    }

    @TestCase
    public func testEncodeSwitchBetweenCodesetsAAndB(): Unit {
        // start with A switch to B and back to A
        testEncode(
            "\0ABab\u{0010}",
            QUIET_SPACE + START_CODE_A +
                // "\0"            "A"             "B"             Switch to B     "a"             "b"
                "10100001100" + "10100011000" + "10001011000" + SWITCH_CODE_B + "10010110000" +
                "10010000110" + SWITCH_CODE_A +
            // Switch to A    "\u0010"        check digit
            "10100111100" + "11001110100" + STOP + QUIET_SPACE
        );

        // start with B switch to A and back to B
        // the compact encoder encodes this shorter as STARTB,a,b,SHIFT,NUL,a,b
        testEncode(
            "ab\0ab",
            QUIET_SPACE + START_CODE_B + //  "a"             "b"            Switch to A     "\0"           Switch to B
                "10010110000" + "10010000110" + SWITCH_CODE_A + "10100001100" + SWITCH_CODE_B +
                //  "a"             "b"            check digit
                "10010110000" + "10010000110" + "11010001110" + STOP + QUIET_SPACE
        );
    }

    private func testEncode(toEncode: String, expected: String) {
        var result: BitMatrix = encode(toEncode, false, toEncode);
        var actual: String = matrixToString(result);
        @Expect(expected, actual)

        var width: Int64 = result.getWidth();
        result = encode(toEncode, true, toEncode)
        @Expect(result.getWidth() <= width,true)
    }
    @TestCase
    public func testEncodeWithForcedCodeSetFailureCodeSetABadCharacter(): Unit {
        // Lower case characters should not be accepted when the code set is forced to A.
        var toEncode: String = "ASDFx0123";

        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        hints.put(EncodeHintType.FORCE_CODE_SET, "A");
        try {
            writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0, hints);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Bad character in input for forced code set A: ASCII value=120")
        }
    }

    @TestCase
    public func testEncodeWithForcedCodeSetFailureCodeSetBBadCharacter(): Unit {
        var toEncode: String = "ASdf\00123"; // \0 (ascii value 0)

        // Characters with ASCII value below 32 should not be accepted when the code set is forced to B.
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        hints.put(EncodeHintType.FORCE_CODE_SET, "B");
        try {
            writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0, hints);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Bad character in input for forced code set B: ASCII value=0")
        }
    }

    @TestCase
    public func testEncodeWithForcedCodeSetFailureCodeSetCBadCharactersNonNum(): Unit {
        var toEncode: String = "123a5678";

        // Non-digit characters should not be accepted when the code set is forced to C.
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        hints.put(EncodeHintType.FORCE_CODE_SET, "C");
        try {
            writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0, hints);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Bad character in input for forced code set C: ASCII value=97")
        }
    }

    @TestCase
    public func testEncodeWithForcedCodeSetFailureCodeSetCBadCharactersFncCode(): Unit {
        var toEncode: String = "123\u{00f2}a678";

        // Function codes other than 1 should not be accepted when the code set is forced to C.
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        hints.put(EncodeHintType.FORCE_CODE_SET, "C");
        try {
            writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0, hints);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Bad character in input for forced code set C: ASCII value=242")
        }
    }

    @TestCase
    public func testEncodeWithForcedCodeSetFailureCodeSetCWrongAmountOfDigits(): Unit {
        var toEncode: String = "123456789";

        // An uneven amount of digits should not be accepted when the code set is forced to C.
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        hints.put(EncodeHintType.FORCE_CODE_SET, "C");
        try {
            writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0, hints);
        } catch (e: IllegalArgumentException) {
            @Expect(e.message,"Bad number of characters for digit only encoding.")
        }
    }

    @TestCase
    public func testEncodeWithForcedCodeSetFailureCodeSetA(): Unit {
        var toEncode: String = "AB123";

        //                          would default to B   "A"             "B"             "1"
        var expected: String = QUIET_SPACE + START_CODE_A + "10100011000" + "10001011000" + "10011100110" +
            // "2"             "3"           check digit 10
            "11001110010" +
            "11001011100" + "11001000100" + STOP + QUIET_SPACE

        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        hints.put(EncodeHintType.FORCE_CODE_SET, "A");
        var result: BitMatrix = writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0, hints);

        var actual: String = matrixToString(result);
        @Expect(expected, actual)
    }

    @TestCase
    public func testEncodeWithForcedCodeSetFailureCodeSetB(): Unit {
        var toEncode: String = "1234";

        //                          would default to C   "1"             "2"             "3"
        var expected: String = QUIET_SPACE + START_CODE_B + "10011100110" + "11001110010" + "11001011100" + // "4"           check digit 88
            "11001001110" +
            "11110010010" + STOP + QUIET_SPACE

        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        hints.put(EncodeHintType.FORCE_CODE_SET, "B");
        var result: BitMatrix = writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0, hints);

        var actual: String = matrixToString(result);
        @Expect(expected, actual)
    }
    private func encode(toEncode: String, compact: Bool, expectedLoopback: String): BitMatrix {
        var hints: HashMap<EncodeHintType, Any> = HashMap<EncodeHintType, Any>()
        if (compact) {
            hints.put(EncodeHintType.CODE128_COMPACT, true);
        }

        var encResult: BitMatrix = writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0, hints);

        if (expectedLoopback != "") {
            var row: BitArray = encResult.getRow(0, BitArray());

            var rtResult: Result = reader.decodeRow(0, row, HashMap<DecodeHintType, Any>());

            var actual: String = rtResult.getText();

            @Expect(expectedLoopback, actual)
        }

        if (compact) {
            //check that what is encoded compactly yields the same on loopback as what was encoded fast.
            var row: BitArray = encResult.getRow(0, BitArray());
            var rtResult: Result = reader.decodeRow(0, row, HashMap<DecodeHintType, Any>());
            var actual: String = rtResult.getText();
            var encResultFast: BitMatrix = writer.encode(toEncode, BarcodeFormat.CODE_128, 0, 0);
            row = encResultFast.getRow(0, BitArray())
            rtResult = reader.decodeRow(0, row, HashMap<DecodeHintType, Any>())
            @Expect(rtResult.getText(), actual)
        }
        return encResult
    }
}

public func matrixToString(result: BitMatrix): String {
    @Assert(1, result.getHeight())
    var builder: StringBuilder = StringBuilder();
    for (i in 0..result.getWidth()) {
        builder.append(
            if (result.get(i, 0)) {
                "1"
            } else {
                "0"
            }
        );
    }
    return builder.toString();
}