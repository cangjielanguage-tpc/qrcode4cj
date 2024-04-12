/*
 * Copyright 2006 Jeremias Maerki.
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

package pkgc.datamatrix.encoder

// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import zxing.code.datamatrix.encoder.*
from QRCode4cj import zxing.code.common.*
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from QRCode4cj import zxing.code.tools.UTF32String

main(): Int64 {
    let tester = HighLevelEncodeTestCase()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

/**
 * Tests for {@link HighLevelEncoder} and {@link MinimalEncoder}
 */
@Test
public class HighLevelEncodeTestCase {
    private static let TEST_SYMBOLS: Array<SymbolInfo> = [
        SymbolInfo(false, 3, 5, 8, 8, 1),
        SymbolInfo(false, 5, 7, 10, 10, 1),
        /*rect*/ SymbolInfo(true, 5, 7, 16, 6, 1),
        SymbolInfo(false, 8, 10, 12, 12, 1),
        /*rect*/ SymbolInfo(true, 10, 11, 14, 6, 2),
        SymbolInfo(false, 13, 0, 0, 0, 1),
        SymbolInfo(false, 77, 0, 0, 0, 1)
        //The last entries are fake entries to test special conditions with C40 encoding
    ]

    private static func useTestSymbols() {
        SymbolInfo.overrideSymbolSet(TEST_SYMBOLS);
    }

    private static func resetSymbols() {
        SymbolInfo.overrideSymbolSet(SymbolInfo.PROD_SYMBOLS);
    }

    private static func encodeHighLevel(msg: String, sizes: Array<Int64>) {
        sizes[0] = HighLevelEncoder.encodeHighLevel(UTF32String(msg)).charSize
        sizes[1] = MinimalEncoder.encodeHighLevel(UTF32String(msg)).charSize
    }

    private static func encodeHighLevel(msg: String): String {
        return encodeHighLevel(msg, true);
    }

    private static func encodeHighLevel(msg: String, compareSizeToMinimalEncoder: Bool): String {
        var encoded: UTF32String = HighLevelEncoder.encodeHighLevel(UTF32String(msg));
        var encoded2: UTF32String = MinimalEncoder.encodeHighLevel(UTF32String(msg));
        @Assert(!compareSizeToMinimalEncoder || encoded2.charSize <= encoded.charSize)
        return visualize(encoded);
    }

    /**
     * Convert a string of char codewords into a different string which lists each character
     * using its decimal value.
     *
     * @param codewords the codewords
     * @return the visualized codewords
     */
    public static func visualize(codewords: UTF32String): String {
        var sb: StringBuilder = StringBuilder();
        for (i in 0..codewords.charSize) {
            if (i > 0) {
                sb.append(' ');
            }
            sb.append(codewords.get(i).hashCode())
        }
        return sb.toString();
    }

    @TestCase
    public func testASCIIEncodation(): Unit {
        var visualized: String = encodeHighLevel("123456");
        @Assert("142 164 186", visualized)

        visualized = encodeHighLevel("123456£")
        @Assert("142 164 186 235 36", visualized)

        visualized = encodeHighLevel("30Q324343430794<OQQ")
        @Assert("160 82 162 173 173 173 137 224 61 80 82 82", visualized)
    }

    @TestCase
    public func testC40EncodationBasic1(): Unit {
        var visualized: String = encodeHighLevel("AIMAIMAIM");
        @Assert("230 91 11 91 11 91 11 254", visualized)
        //230 shifts to C40 encodation, 254 unlatches, "else" case
    }

    @TestCase
    public func testC40EncodationBasic2(): Unit {
        var visualized: String = encodeHighLevel("AIMAIAB");
        @Assert("230 91 11 90 255 254 67 129", visualized)

        //"B" is normally encoded as "15" (one C40 value)
        //"else" case: "B" is encoded as ASCII
        visualized = encodeHighLevel("AIMAIAb")
        @Assert("66 74 78 66 74 66 99 129", visualized)

        //Encoded as ASCII
        //Alternative solution:
        //@Assert("230 91 11 90 255 254 99 129", visualized);
        //"b" is normally encoded as "Shift 3, 2" (two C40 values)
        //"else" case: "b" is encoded as ASCII
        visualized = encodeHighLevel("AIMAIMAIMË")
        @Assert("230 91 11 91 11 91 11 254 235 76", visualized)

        //Alternative solution:
        //@Assert("230 91 11 91 11 91 11 11 9 254", visualized);
        //Expl: 230 = shift to C40, "91 11" = "AIM",
        //"11 9" = "\u{FFFD}" = "Shift 2, UpperShift, <char>
        //"else" case
        visualized = encodeHighLevel("AIMAIMAIMë")
        @Assert("230 91 11 91 11 91 11 254 235 108", visualized)
        //Activate when additional rectangulars are available
        //Expl: 230 = shift to C40, "91 11" = "AIM",
        //"\u{FFFD}" in C40 encodes to: 1 30 2 11 which doesn't fit into a triplet
        //"10 243" =
        //254 = unlatch, 235 = Upper Shift, 108 = \u{FFFD} = 0xEB/235 - 128 + 1
        //"else" case
    }

    @TestCase
    public func testC40EncodationSpecExample(): Unit {
        //Example in Figure 1 in the spec
        var visualized: String = encodeHighLevel("A1B2C3D4E5F6G7H8I9J0K1L2");
        @Assert("230 88 88 40 8 107 147 59 67 126 206 78 126 144 121 35 47 254", visualized)
    }

    @TestCase
    public func testC40EncodationSpecialCases1(): Unit {
        //Special tests avoiding ultra-long test strings because these tests are only used
        //with the 16x48 symbol (47 data codewords)
        useTestSymbols();

        var visualized: String = encodeHighLevel("AIMAIMAIMAIMAIMAIM", false);
        @Assert("230 91 11 91 11 91 11 91 11 91 11 91 11", visualized)

        //case "a": Unlatch is not required
        visualized = encodeHighLevel("AIMAIMAIMAIMAIMAI", false)
        @Assert("230 91 11 91 11 91 11 91 11 91 11 90 241", visualized)

        //case "b": Add trailing shift 0 and Unlatch is not required
        visualized = encodeHighLevel("AIMAIMAIMAIMAIMA")
        @Assert("230 91 11 91 11 91 11 91 11 91 11 254 66", visualized)

        //case "c": Unlatch and write last character in ASCII
        resetSymbols();

        visualized = encodeHighLevel("AIMAIMAIMAIMAIMAI")
        @Assert("230 91 11 91 11 91 11 91 11 91 11 254 66 74 129 237", visualized)

        visualized = encodeHighLevel("AIMAIMAIMA")
        @Assert("230 91 11 91 11 91 11 66", visualized)
        //case "d": Skip Unlatch and write last character in ASCII
    }

    @TestCase
    public func testC40EncodationSpecialCases2(): Unit {
        var visualized: String = encodeHighLevel("AIMAIMAIMAIMAIMAIMAI");
        @Assert("230 91 11 91 11 91 11 91 11 91 11 91 11 254 66 74", visualized)
        //available > 2, rest = 2 --> unlatch and encode as ASCII
    }

    @TestCase
    public func testTextEncodation(): Unit {
        var visualized: String = encodeHighLevel("aimaimaim");
        @Assert("239 91 11 91 11 91 11 254", visualized)

        //239 shifts to Text encodation, 254 unlatches
        visualized = encodeHighLevel("aimaimaim'")
        @Assert("239 91 11 91 11 91 11 254 40 129", visualized)

        //@Assert("239 91 11 91 11 91 11 7 49 254", visualized);
        //This is an alternative, but doesn't strictly follow the rules in the spec.
        visualized = encodeHighLevel("aimaimaIm")
        @Assert("239 91 11 91 11 87 218 110", visualized)

        visualized = encodeHighLevel("aimaimaimB")
        @Assert("239 91 11 91 11 91 11 254 67 129", visualized)

        visualized = encodeHighLevel("aimaimaim{txt}\u{0004}")
        @Assert("239 91 11 91 11 91 11 254 124 117 121 117 126 5 129 237", visualized)
    }

    @TestCase
    public func testX12Encodation(): Unit {
        //238 shifts to X12 encodation, 254 unlatches
        var visualized: String = encodeHighLevel("ABC>ABC123>AB");
        @Assert("238 89 233 14 192 100 207 44 31 67", visualized)

        visualized = encodeHighLevel("ABC>ABC123>ABC")
        @Assert("238 89 233 14 192 100 207 44 31 254 67 68", visualized)

        visualized = encodeHighLevel("ABC>ABC123>ABCD")
        @Assert("238 89 233 14 192 100 207 44 31 96 82 254", visualized)

        visualized = encodeHighLevel("ABC>ABC123>ABCDE")
        @Assert("238 89 233 14 192 100 207 44 31 96 82 70", visualized)

        visualized = encodeHighLevel("ABC>ABC123>ABCDEF")
        @Assert("238 89 233 14 192 100 207 44 31 96 82 254 70 71 129 237", visualized)
    }

    @TestCase
    public func testEDIFACTEncodation(): Unit {
        //240 shifts to EDIFACT encodation
        var visualized: String = encodeHighLevel(".A.C1.3.DATA.123DATA.123DATA");
        @Assert("240 184 27 131 198 236 238 16 21 1 187 28 179 16 21 1 187 28 179 16 21 1",
                 visualized)

        visualized = encodeHighLevel(".A.C1.3.X.X2..")
        @Assert("240 184 27 131 198 236 238 98 230 50 47 47", visualized)

        visualized = encodeHighLevel(".A.C1.3.X.X2.")
        @Assert("240 184 27 131 198 236 238 98 230 50 47 129", visualized)

        visualized = encodeHighLevel(".A.C1.3.X.X2")
        @Assert("240 184 27 131 198 236 238 98 230 50", visualized)

        visualized = encodeHighLevel(".A.C1.3.X.X")
        @Assert("240 184 27 131 198 236 238 98 230 31", visualized)

        visualized = encodeHighLevel(".A.C1.3.X.")
        @Assert("240 184 27 131 198 236 238 98 231 192", visualized)

        visualized = encodeHighLevel(".A.C1.3.X")
        @Assert("240 184 27 131 198 236 238 89", visualized)

        //Checking temporary unlatch from EDIFACT
        visualized = encodeHighLevel(".XXX.XXX.XXX.XXX.XXX.XXX.üXX.XXX.XXX.XXX.XXX.XXX.XXX")
        @Assert("240 185 134 24 185 134 24 185 134 24 185 134 24 185 134 24 185 134 24" +
                      " 124 47 235 125 240"  + //<-- this is the temporary unlatch 
                      " 97 139 152 97 139 152 97 139 152 97 139 152 97 139 152 97 139 152 89 89",
                 visualized)
        //<-- this is the temporary unlatch 
        //<-- this is the temporary unlatch //<-- this is the temporary unlatch 
    }

    @TestCase
    public func testBase256Encodation(): Unit {
        //231 shifts to Base256 encodation
        var visualized: String = encodeHighLevel("\u{00AB}äöüé\u{00BB}");
        @Assert("231 44 108 59 226 126 1 104", visualized)
        visualized = encodeHighLevel("\u{00AB}äöüéà\u{00BB}")
        @Assert("231 51 108 59 226 126 1 141 254 129", visualized)
        visualized = encodeHighLevel("\u{00AB}äöüéàá\u{00BB}")
        @Assert("231 44 108 59 226 126 1 141 36 147", visualized)

        visualized = encodeHighLevel(" 23£")

        //ASCII only (for reference)
        @Assert("33 153 235 36 129", visualized)

        visualized = encodeHighLevel("\u{00AB}äöüé\u{00BB} 234")

        //Mixed Base256 + ASCII
        @Assert("231 50 108 59 226 126 1 104 33 153 53 129", visualized)

        visualized = encodeHighLevel("\u{00AB}äöüé\u{00BB} 23£ 1234567890123456789")
        @Assert("231 54 108 59 226 126 1 104 99 10 161 167 33 142 164 186 208" +
                      " 220 142 164 186 208 58 129 59 209 104 254 150 45", visualized)

        visualized = encodeHighLevel(createBinaryMessage(20))
        @Assert("231 44 108 59 226 126 1 141 36 5 37 187 80 230 123 17 166 60 210 103 253 150",
                 visualized)
        visualized = encodeHighLevel(createBinaryMessage(19))

        //padding necessary at the end
        @Assert("231 63 108 59 226 126 1 141 36 5 37 187 80 230 123 17 166 60 210 103 1 129",
                 visualized)

        visualized = encodeHighLevel(createBinaryMessage(276))
        assertStartsWith("231 38 219 2 208 120 20 150 35", visualized);
        assertEndsWith("146 40 194 129", visualized);

        visualized = encodeHighLevel(createBinaryMessage(277))
        assertStartsWith("231 38 220 2 208 120 20 150 35", visualized);
        assertEndsWith("146 40 190 87", visualized);
    }

    private static func createBinaryMessage(len: Int64): String {
        var sb: ArrayList<Char> = ArrayList<Char>();
        sb.appendAll("\u{00AB}äöüéàá-".toRuneArray());
        for (i in 0..(len - 9)) {
            sb.append('\u{00B7}');
        }
        sb.append('\u{00BB}');
        return String(sb);
    }

    private static func assertStartsWith(expected: String, actual: String) {
        if (!actual.startsWith(expected)) {
            throw IllegalArgumentException();
        }
    }

    private static func assertEndsWith(expected: String, actual: String) {
        if (!actual.endsWith(expected)) {
            throw IllegalArgumentException();
        }
    }

    @TestCase
    public func testUnlatchingFromC40(): Unit {
        var visualized: String = encodeHighLevel("AIMAIMAIMAIMaimaimaim");
        @Assert("230 91 11 91 11 91 11 254 66 74 78 239 91 11 91 11 91 11", visualized)
    }

    @TestCase
    public func testUnlatchingFromText(): Unit {
        var visualized: String = encodeHighLevel("aimaimaimaim12345678");
        @Assert("239 91 11 91 11 91 11 91 11 254 142 164 186 208 129 237", visualized)
    }

    @TestCase
    public func testHelloWorld(): Unit {
        var visualized: String = encodeHighLevel("Hello World!");
        @Assert("73 239 116 130 175 123 148 64 158 233 254 34", visualized)
    }

    @TestCase
    public func testBug1664266(): Unit {
        //There was an exception and the encoder did not handle the unlatching from
        //EDIFACT encoding correctly
        var visualized: String = encodeHighLevel("CREX-TAN:h");
        @Assert("68 83 70 89 46 85 66 79 59 105", visualized)

        visualized = encodeHighLevel("CREX-TAN:hh")
        @Assert("68 83 70 89 46 85 66 79 59 105 105 129", visualized)

        visualized = encodeHighLevel("CREX-TAN:hhh")
        @Assert("68 83 70 89 46 85 66 79 59 105 105 105", visualized)
    }

    @TestCase
    public func testX12Unlatch(): Unit {
        var visualized: String = encodeHighLevel("*DTCP01");
        @Assert("43 69 85 68 81 131 129 56", visualized)
    }

    @TestCase
    public func testX12Unlatch2(): Unit {
        var visualized: String = encodeHighLevel("*DTCP0");
        @Assert("238 9 10 104 141", visualized)
    }

    @TestCase
    public func testBug3048549(): Unit {
        //There was an IllegalArgumentException for an illegal character here because
        //of an encoding problem of the character 0x0060 in Java source code.
        var visualized: String = encodeHighLevel("fiykmj*Rh2`,e6");
        @Assert("103 106 122 108 110 107 43 83 105 51 97 45 102 55 129 237", visualized)
    }

    @TestCase
    public func testMacroCharacters(): Unit {
        var visualized: String = encodeHighLevel("[)>\u{001E}05\u{001D}5555\u{001C}6666\u{001E}\u{0004}");

        @Assert("236 185 185 29 196 196 129 56", visualized)
    }

    @TestCase
    public func testEncodingWithStartAsX12AndLatchToEDIFACTInTheMiddle(): Unit {
        var visualized: String = encodeHighLevel("*MEMANT-1F-MESTECH");
        @Assert("240 168 209 77 4 229 45 196 107 77 21 53 5 12 135 192", visualized)
    }

    @TestCase
    public func testX12AndEDIFACTSpecErrors(): Unit {
        //X12 encoding error with spec conform float point comparisons in lookAheadTest()
        var visualized: String = encodeHighLevel("AAAAAAAAAAA**\u{00FC}AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        @Assert("230 89 191 89 191 89 191 89 178 56 114 10 243 177 63 89 191 89 191 89 191 89 191 89 191 89 191 89 " +
        "191 89 191 89 191 254 66 129", visualized)

        //X12 encoding error with integer comparisons in lookAheadTest()
        visualized = encodeHighLevel("AAAAAAAAAAAA0+****AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
        @Assert("238 89 191 89 191 89 191 89 191 254 240 194 186 170 170 160 65 4 16 65 4 16 65 4 16 65 4 16 65 4 " +
        "16 65 4 16 65 4 16 65 124 129 167 62 212 107", visualized)

        //EDIFACT encoding error with spec conform float point comparisons in lookAheadTest()
        visualized = encodeHighLevel("AAAAAAAAAAA++++\u{00FC}AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
        @Assert("230 89 191 89 191 89 191 254 66 66 44 44 44 44 235 125 230 89 191 89 191 89 191 89 191 89 191 89 " +
        "191 89 191 89 191 89 191 89 191 254 129 17 167 62 212 107", visualized)

        //EDIFACT encoding error with integer comparisons in lookAheadTest()
        visualized = encodeHighLevel("++++++++++AAa0 0++++++++++++++++++++++++++++++")
        @Assert("240 174 186 235 174 186 235 174 176 65 124 98 240 194 12 43 174 186 235 174 186 235 174 186 235 " +
        "174 186 235 174 186 235 174 186 235 174 186 235 173 240 129 167 62 212 107", visualized)
        visualized = encodeHighLevel("AAAAAAAAAAAA*+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
        @Assert("230 89 191 89 191 89 191 89 191 7 170 64 191 89 191 89 191 89 191 89 191 89 191 89 191 89 191 89 " +
        "191 89 191 66", visualized)
        visualized = encodeHighLevel("AAAAAAAAAAA*0a0 *AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
        @Assert("230 89 191 89 191 89 191 89 178 56 227 6 228 7 183 89 191 89 191 89 191 89 191 89 191 89 191 89 " +
        "191 89 191 89 191 254 66 66", visualized)
    }

    @TestCase
    public func testSizes(): Unit {
        var sizes: Array<Int64> = Array<Int64>(2, item: 0);
        encodeHighLevel("A", sizes);

        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("AB", sizes);
        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("ABC", sizes);
        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("ABCD", sizes);
        @Assert(5, sizes[0])
        @Assert(5, sizes[1])

        encodeHighLevel("ABCDE", sizes);
        @Assert(5, sizes[0])
        @Assert(5, sizes[1])

        encodeHighLevel("ABCDEF", sizes);
        @Assert(5, sizes[0])
        @Assert(5, sizes[1])

        encodeHighLevel("ABCDEFG", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("ABCDEFGH", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("ABCDEFGHI", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("ABCDEFGHIJ", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("a", sizes);
        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("ab", sizes);
        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("abc", sizes);
        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("abcd", sizes);
        @Assert(5, sizes[0])
        @Assert(5, sizes[1])

        encodeHighLevel("abcdef", sizes);
        @Assert(5, sizes[0])
        @Assert(5, sizes[1])

        encodeHighLevel("abcdefg", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("abcdefgh", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("+", sizes);
        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("++", sizes);
        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("+++", sizes);
        @Assert(3, sizes[0])
        @Assert(3, sizes[1])

        encodeHighLevel("++++", sizes);
        @Assert(5, sizes[0])
        @Assert(5, sizes[1])

        encodeHighLevel("+++++", sizes);
        @Assert(5, sizes[0])
        @Assert(5, sizes[1])

        encodeHighLevel("++++++", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("+++++++", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("++++++++", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel("+++++++++", sizes);
        @Assert(8, sizes[0])
        @Assert(8, sizes[1])

        encodeHighLevel(
            "\u{00F0}\u{00F0}" + "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEF",
            sizes
        );
        @Assert(114, sizes[0])
        @Assert(62, sizes[1])
    }

    @TestCase
    public func testECIs(): Unit {
        var visualized: String = visualize(
            MinimalEncoder.encodeHighLevel(
                UTF32String(
                    "that particularly stands out to me is \u{0625}\u{0650}" +
                        "\u{062C}\u{064E}\u{0651}\u{0627}\u{0635} (\u{02BE}\u{0101}\u{1E63}) \"pear\", suggested to have originated from Hebrew " +
                        "\u{05D0}\u{05B7}\u{05D2}\u{05B8}\u{05BC}\u{05E1} (ag\u{00E1}s)"
                )
            )
        );
        @Assert("239 209 151 206 214 92 122 140 35 158 144 162 52 205 55 171 137 23 67 206 218 175 147 113 15 254" +
        " 116 33 241 25 231 186 14 212 64 253 151 252 159 33 41 241 27 231 83 171 53 209 35 25 134 6 42 33 35 239 184" +
        " 31 193 234 7 252 205 101 127 241 209 34 24 5 22 23 221 148 179 239 128 140 92 187 106 204 198 59 19 25 114" +
        " 248 118 36 254 231 106 196 19 239 101 27 107 69 189 112 236 156 252 16 174 125 24 10 125 116 42 129",
        visualized)

        visualized = visualize(
            MinimalEncoder.encodeHighLevel(
                UTF32String(
                    "that particularly stands out to me is \u{0625}\u{0650}" +
                        "\u{062C}\u{064E}\u{0651}\u{0627}\u{0635} (\u{02BE}\u{0101}\u{1E63}) \"pear\", suggested to have originated from Hebrew " +
                        "\u{05D0}\u{05B7}\u{05D2}\u{05B8}\u{05BC}\u{05E1} (ag\u{00E1}s)"
                ),
                StandardCharsets.UTF_8,
                -1,
                SymbolShapeHint.FORCE_NONE
            )
        )
        @Assert("241 27 239 209 151 206 214 92 122 140 35 158 144 162 52 205 55 171 137 23 67 206 218 175 147 113" +
        " 15 254 116 33 231 202 33 131 77 154 119 225 163 238 206 28 249 93 36 150 151 53 108 246 145 228 217 71" +
        " 199 42 33 35 239 184 31 193 234 7 252 205 101 127 241 209 34 24 5 22 23 221 148 179 239 128 140 92 187 106" +
        " 204 198 59 19 25 114 248 118 36 254 231 43 133 212 175 38 220 44 6 125 49 172 93 189 209 111 61 217 203 62" +
        " 116 42 129 1 151 46 196 91 241 137 32 182 77 227 122 18 168 63 213 108 4 154 49 199 94 244 140 35 185 80",
         visualized)
    }

    @TestCase
    public func testPadding(): Unit {
        var sizes: Array<Int64> = Array<Int64>(2, item: 0)
        encodeHighLevel(
            "IS010000000000000000000000S1118058599124123S21.2.250.1.213.1.4.8 S3FIRST NAMETEST S5MS618-06" +
                "-1985S713201S4LASTNAMETEST",
            sizes
        );
        @Assert(86, sizes[0])
        @Assert(86, sizes[1])
    }
}
