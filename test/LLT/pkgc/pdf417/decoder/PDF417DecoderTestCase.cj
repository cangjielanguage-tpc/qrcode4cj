// DEPENDENCE: ../decoder
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.Qrcoder4cjFormatException
import QRCode4cj.common.Qrcoder4cjWriterException
import QRCode4cj.pdf417.common.PDF417ResultMetadata
import QRCode4cj.common.DecoderResult
import QRCode4cj.pdf417.encoder.Compaction
import QRCode4cj.pdf417.encoder.PDF417HighLevelEncoderTestAdapter
import QRCode4cj.common.MyCharset
import QRCode4cj.pdf417.decoder.*
import QRCode4cj.common.StandardCharsets
import QRCode4cj.tools.UTF32String
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.fs.*
import std.math.*
import std.random.*
import std.collection.*
import std.convert.*

main(): Int64 {
    let tester = PDF417DecoderTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

/**
 * Tests {@link DecodedBitStreamParser}.
 */
@Test
public class PDF417DecoderTestCase {
    /**
     * Tests the first sample given in ISO/IEC 15438:2015(E) - Annex H.4
     */
    @TestCase
    public func testStandardSample1(): Unit {
        var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata();
        let sampleCodes: Array<Int64> = [
            20,
            928,
            111,
            100,
            17,
            53,
            923,
            1,
            111,
            104,
            923,
            3,
            64,
            416,
            34,
            923,
            4,
            258,
            446,
            67,
            // we should never reach these1000,1000,
            1000
        ]

        DecodedBitStreamParser.decodeMacroBlock(sampleCodes, 2, resultMetadata);

        @Assert(0, resultMetadata.getSegmentIndex())
        @Assert("017053", resultMetadata.getFileId())
        @Assert(resultMetadata.isLastSegment(),false)
        @Assert(4, resultMetadata.getSegmentCount())
        @Assert("CEN BE", resultMetadata.getSender())
        @Assert("ISO CH", resultMetadata.getAddressee())

        var optionalData: Array<Int64> = resultMetadata.getOptionalData();
        @Assert( 1, optionalData[0])
        @Assert(67, optionalData[optionalData.size - 1])
    }

    /**
     * Tests the second given in ISO/IEC 15438:2015(E) - Annex H.4
     */
    @TestCase
    public func testStandardSample2(): Unit {
        var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata();
        var sampleCodes: Array<Int64> = [
            11,
            928,
            111,
            103,
            17,
            53,
            923,
            1,
            111,
            104,
            922,
            // we should never reach these1000,1000,
            1000
        ]

        DecodedBitStreamParser.decodeMacroBlock(sampleCodes, 2, resultMetadata);

        @Assert(3, resultMetadata.getSegmentIndex())
        @Assert("017053", resultMetadata.getFileId())
        @Assert(resultMetadata.isLastSegment(),true)
        @Assert(4, resultMetadata.getSegmentCount())
        @Assert(resultMetadata.getAddressee().size>0,false)
        @Assert(resultMetadata.getSender().size>0,false)

        var optionalData: Array<Int64> = resultMetadata.getOptionalData();
        @Assert(1, optionalData[0])
        @Assert(104, optionalData[optionalData.size - 1])
    }

    /**
     * Tests the example given in ISO/IEC 15438:2015(E) - Annex H.6
     */
    @TestCase
    public func testStandardSample3(): Unit {
        var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata();
        var sampleCodes: Array<Int64> = [
            7,
            928,
            111,
            100,
            100,
            200,
            300,
            0
        ]

        // Final dummy ECC codeword required to avoid ArrayIndexOutOfBounds
        DecodedBitStreamParser.decodeMacroBlock(sampleCodes, 2, resultMetadata);

        @Assert(0, resultMetadata.getSegmentIndex())
        @Assert("100200300", resultMetadata.getFileId())
        @Assert(resultMetadata.isLastSegment(),false)
        @Assert(-1, resultMetadata.getSegmentCount())
        @Assert(resultMetadata.getAddressee().size>0,false)
        @Assert(resultMetadata.getSender().size>0,false)
        @Assert(resultMetadata.getOptionalData().size>0,false)

        // Check that symbol containing no data except Macro is accepted (see note in Annex H.2)
        var decoderResult: DecoderResult = DecodedBitStreamParser.decode(sampleCodes, "0");
        @Assert("", decoderResult.getText())

        if (let Some(d) <- (decoderResult.getOther() as PDF417ResultMetadata)) {}
        else {
            @Assert(false)
        }
    }

    @TestCase
    public func testSampleWithFilename(): Unit {
        var sampleCodes: Array<Int64> = [
            23,
            477,
            928,
            111,
            100,
            0,
            252,
            21,
            86,
            923,
            0,
            815,
            251,
            133,
            12,
            148,
            537,
            593,
            599,
            923,
            1,
            111,
            102,
            98,
            311,
            355,
            522,
            920,
            779,
            40,
            628,
            33,
            749,
            267,
            506,
            213,
            928,
            465,
            248,
            493,
            72,
            780,
            699,
            780,
            493,
            755,
            84,
            198,
            628,
            368,
            156,
            198,
            809,
            19,
            113
        ]
        var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata();

        DecodedBitStreamParser.decodeMacroBlock(sampleCodes, 3, resultMetadata);

        @Assert(0, resultMetadata.getSegmentIndex())
        @Assert("000252021086", resultMetadata.getFileId())
        @Assert(resultMetadata.isLastSegment(),false)
        @Assert(2, resultMetadata.getSegmentCount())
        @Assert(resultMetadata.getAddressee().size == 0,true)
        @Assert(resultMetadata.getSender().size == 0,true)
        @Assert("filename.txt", resultMetadata.getFileName())
    }

    @TestCase
    public func testSampleWithNumericValues(): Unit {
        var sampleCodes: Array<Int64> = [
            25,
            477,
            928,
            111,
            100,
            0,
            252,
            21,
            86,
            923,
            2,
            2,
            0,
            1,
            0,
            0,
            0,
            923,
            5,
            130,
            923,
            6,
            1,
            500,
            13,
            0
        ]
        var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata();

        DecodedBitStreamParser.decodeMacroBlock(sampleCodes, 3, resultMetadata);

        @Assert(0, resultMetadata.getSegmentIndex())
        @Assert("000252021086", resultMetadata.getFileId())
        @Assert(resultMetadata.isLastSegment(),false)

        @Assert(180980729000000, resultMetadata.getTimestamp())
        @Assert(30, resultMetadata.getFileSize())
        @Assert(260013, resultMetadata.getChecksum())
    }

    @TestCase
    public func testSampleWithMacroTerminatorOnly(): Unit {
        var sampleCodes: Array<Int64> = [7, 477, 928, 222, 198, 0, 922]
        var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata();

        DecodedBitStreamParser.decodeMacroBlock(sampleCodes, 3, resultMetadata);

        @Assert(99998, resultMetadata.getSegmentIndex())
        @Assert("000", resultMetadata.getFileId())
        @Assert(resultMetadata.isLastSegment(),true)
        @Assert(-1, resultMetadata.getSegmentCount())
        @Assert(resultMetadata.getOptionalData().size>0,false)
    }

    @TestCase
    public func testSampleWithBadSequenceIndexMacro(): Unit {
        try {
            var sampleCodes: Array<Int64> = [3, 928, 222, 0]
            var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata();
            DecodedBitStreamParser.decodeMacroBlock(sampleCodes, 2, resultMetadata);
            @Assert(false)
        } catch (f: Qrcoder4cjFormatException) {}
    }

    @TestCase
    public func testSampleWithNoFileIdMacro(): Unit {
        try {
            var sampleCodes: Array<Int64> = [4, 928, 222, 198, 0]
            var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata();
            DecodedBitStreamParser.decodeMacroBlock(sampleCodes, 2, resultMetadata);
            @Assert(false)
        } catch (f: Qrcoder4cjFormatException) {}
    }

    @TestCase
    public func testSampleWithNoDataNoMacro(): Unit {
        try {
            var sampleCodes: Array<Int64> = [3, 899, 899, 0]
            DecodedBitStreamParser.decode(sampleCodes, "0");
            @Assert(false)
        } catch (f: Qrcoder4cjFormatException) {}
    }

    @TestCase
    public func testUppercase(): Unit {
        performEncodeTest(r'A', [3, 4, 5, 6, 4, 4, 5, 5]);
    }

    @TestCase
    public func testNumeric(): Unit {
        performEncodeTest(r'1', [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10]);
    }

    @TestCase
    public func testByte(): Unit {
        performEncodeTest(r'\u{00c4}', [3, 4, 5, 6, 7, 7, 8]);
    }

    @TestCase
    public func testUppercaseLowercaseMix1(): Unit {
        encodeDecode("aA", 4);
        encodeDecode("aAa", 5);
        encodeDecode("Aa", 4);
        encodeDecode("Aaa", 5);
        encodeDecode("AaA", 5);
        encodeDecode("AaaA", 6);
        encodeDecode("Aaaa", 6);
        encodeDecode("AaAaA", 5);
        encodeDecode("AaaAaaA", 6);
        encodeDecode("AaaAAaaA", 7);
    }

    @TestCase
    public func testPunctuation(): Unit {
        performEncodeTest(r';', [3, 4, 5, 6, 6, 7, 8]);
        encodeDecode(";;;;;;;;;;;;;;;;", 17);
    }

    @TestCase
    public func testUppercaseLowercaseMix2(): Unit {
        performPermutationTest([r'A', r'a'], 10, 8972);
    }

    @TestCase
    public func testUppercaseNumericMix(): Unit {
        performPermutationTest([r'A', r'1'], 14, 192510);
    }

    @TestCase
    public func testUppercaseMixedMix(): Unit {
        performPermutationTest([r'A', r'1', r' ', r';'], 7, 106060);
    }

    @TestCase
    public func testUppercasePunctuationMix(): Unit {
        performPermutationTest([r'A', r';'], 10, 8967);
    }

    @TestCase
    public func testUppercaseByteMix(): Unit {
        performPermutationTest([r'A', r'\u{00c4}'], 10, 11222);
    }

    @TestCase
    public func testLowercaseByteMix(): Unit {
        performPermutationTest([r'a', r'\u{00c4}'], 10, 11233);
    }

    public func testUppercaseLowercaseNumericMix(): Unit {
        performPermutationTest([r'A', r'a', r'1'], 7, 15491);
    }

    @TestCase
    public func testUppercaseLowercasePunctuationMix(): Unit {
        performPermutationTest([r'A', r'a', r';'], 7, 15491);
    }

    @TestCase
    public func testUppercaseLowercaseByteMix(): Unit {
        performPermutationTest([r'A', r'a', r'\u{00c4}'], 7, 17288);
    }

    @TestCase
    public func testLowercasePunctuationByteMix(): Unit {
        performPermutationTest([r'a', r';', r'\u{00c4}'], 7, 17427);
    }

    @TestCase
    public func testUppercaseLowercaseNumericPunctuationMix(): Unit {
        performPermutationTest([r'A', r'a', r'1', r';'], 7, 120479);
    }

    @TestCase
    public func testBinaryData(): Unit {
        var bytes: Array<UInt8> = Array<UInt8>(500, item: 0)
        bytes = [
            96,
            180,
            32,
            187,
            56,
            81,
            217,
            212,
            122,
            203,
            147,
            61,
            190,
            112,
            57,
            155,
            246,
            201,
            45,
            163,
            58,
            240,
            29,
            79,
            183,
            112,
            233,
            140,
            3,
            37,
            244,
            29,
            62,
            186,
            248,
            152,
            109,
            167,
            18,
            200,
            43,
            205,
            77,
            85,
            75,
            240,
            181,
            64,
            35,
            194,
            155,
            98,
            77,
            233,
            239,
            156,
            47,
            147,
            30,
            252,
            88,
            15,
            154,
            251,
            8,
            27,
            18,
            225,
            7,
            177,
            232,
            5,
            242,
            180,
            245,
            240,
            241,
            208,
            12,
            45,
            15,
            98,
            99,
            70,
            112,
            146,
            28,
            80,
            88,
            103,
            255,
            32,
            246,
            168,
            51,
            94,
            152,
            175,
            135,
            37,
            56,
            85,
            134,
            180,
            31,
            239,
            242,
            5,
            180,
            224,
            90,
            0,
            8,
            35,
            247,
            139,
            95,
            143,
            92,
            2,
            67,
            156,
            232,
            246,
            122,
            120,
            29,
            144,
            203,
            230,
            191,
            26,
            231,
            242,
            188,
            64,
            164,
            151,
            9,
            160,
            108,
            14,
            49,
            73,
            155,
            240,
            41,
            105,
            202,
            66,
            210,
            3,
            229,
            102,
            188,
            198,
            150,
            222,
            8,
            250,
            1,
            2,
            160,
            253,
            46,
            35,
            48,
            176,
            150,
            74,
            187,
            124,
            68,
            48,
            32,
            222,
            28,
            173,
            9,
            191,
            214,
            56,
            31,
            251,
            148,
            218,
            175,
            187,
            144,
            196,
            237,
            145,
            160,
            97,
            58,
            209,
            220,
            75,
            71,
            3,
            175,
            132,
            193,
            214,
            59,
            26,
            135,
            105,
            33,
            198,
            213,
            134,
            157,
            97,
            204,
            185,
            142,
            209,
            58,
            230,
            192,
            154,
            19,
            252,
            145,
            225,
            73,
            34,
            243,
            1,
            207,
            139,
            207,
            147,
            67,
            21,
            166,
            4,
            157,
            47,
            7,
            217,
            131,
            250,
            169,
            27,
            143,
            78,
            114,
            101,
            236,
            184,
            21,
            167,
            203,
            171,
            193,
            69,
            12,
            183,
            43,
            60,
            116,
            16,
            119,
            23,
            170,
            36,
            172,
            66,
            242,
            91,
            108,
            103,
            132,
            118,
            125,
            14,
            53,
            70,
            196,
            247,
            37,
            1,
            145,
            163,
            182,
            170,
            162,
            182,
            77,
            18,
            110,
            85,
            131,
            176,
            76,
            17,
            50,
            89,
            201,
            72,
            225,
            208,
            179,
            155,
            185,
            86,
            12,
            213,
            64,
            155,
            110,
            202,
            254,
            219,
            200,
            172,
            175,
            238,
            167,
            77,
            183,
            248,
            90,
            223,
            148,
            190,
            154,
            133,
            161,
            221,
            75,
            3,
            170,
            136,
            131,
            29,
            210,
            156,
            64,
            120,
            129,
            11,
            58,
            40,
            210,
            45,
            102,
            128,
            182,
            79,
            203,
            177,
            178,
            55,
            194,
            68,
            18,
            52,
            206,
            171,
            191,
            218,
            216,
            124,
            49,
            21,
            72,
            246,
            121,
            2,
            116,
            185,
            46,
            106,
            89,
            29,
            58,
            177,
            166,
            11,
            115,
            64,
            11,
            196,
            116,
            197,
            45,
            60,
            188,
            242,
            251,
            174,
            114,
            182,
            230,
            212,
            159,
            176,
            177,
            133,
            19,
            54,
            250,
            44,
            84,
            12,
            223,
            191,
            120,
            200,
            219,
            73,
            44,
            101,
            231,
            91,
            1,
            242,
            86,
            10,
            157,
            196,
            86,
            254,
            164,
            3,
            66,
            134,
            86,
            158,
            48,
            134,
            234,
            100,
            151,
            36,
            149,
            156,
            68,
            8,
            146,
            218,
            235,
            114,
            76,
            6,
            229,
            19,
            58,
            201,
            170,
            148,
            16,
            238,
            186,
            45,
            84,
            254,
            138,
            253,
            248,
            80,
            125,
            33,
            19,
            226,
            2,
            106,
            147,
            122,
            228,
            57,
            152,
            43,
            206,
            121,
            204,
            36,
            14,
            38,
            74,
            246,
            205,
            67,
            204,
            48,
            37,
            102,
            107,
            185,
            179,
            127,
            129,
            231,
            20,
            21,
            103,
            173
        ]
        var random: Random = Random(0);
        var total: Int64 = 0;

        total = encodeDecode(StandardCharsets.ISO_8859_1.newDecoder().decode(bytes))

        @Assert(419, total)
    }

    @TestCase
    public func testECIEnglishHiragana(): Unit {
        readFile("testECIEnglishHiragana")

        //multi ECI UTF-8, UTF-16 and ISO-8859-1
        performECITest(
            [r'a', r'1', r'\u{3040}'],
            [20.0, 1.0, 10.0],
            1055,
            1101
        );
    }

    @TestCase
    public func testECIEnglishKatakana(): Unit {
        readFile("testECIEnglishKatakana")

        //multi ECI UTF-8, UTF-16 and ISO-8859-1
        performECITest(
            [r'a', r'1', r'\u{30a0}'],
            [20.0, 1.0, 10.0],
            1079,
            1101
        );
    }

    @TestCase
    public func testECIEnglishHalfWidthKatakana(): Unit {
        readFile("testECIEnglishHalfWidthKatakana")

        //single ECI
        performECITest(
            [r'a', r'1', r'\u{ff80}'],
            [20.0, 1.0, 10.0],
            793,
            1101
        );
    }

    @TestCase
    public func testECIEnglishChinese(): Unit {
        readFile("testECIEnglishChinese")

        //single ECI
        performECITest(
            [r'a', r'1', r'\u{4e00}'],
            [20.0, 1.0, 10.0],
            947,
            1101
        );
    }

    @TestCase
    public func testECIGermanCyrillic(): Unit {
        readFile("testECIGermanCyrillic")

        //single ECI since the German Umlaut is in ISO-8859-1
        performECITest(
            [r'a', r'1', r'\u{00c4}', r'\u{042f}'],
            [20.0, 1.0, 1.0, 10.0],
            802,
            989
        );
    }

    @TestCase
    public func testECIEnglishCzechCyrillic1(): Unit {
        readFile("testECIEnglishCzechCyrillic1")

        //multi ECI between ISO-8859-2 and ISO-8859-5
        performECITest(
            [r'a', r'1', r'\u{010c}', r'\u{042f}'],
            [10.0, 1.0, 10.0, 10.0],
            1040,
            1219
        );
    }

    @TestCase
    public func testECIEnglishCzechCyrillic2(): Unit {
        readFile("testECIEnglishCzechCyrillic2")

        //multi ECI between ISO-8859-2 and ISO-8859-5
        performECITest(
            [r'a', r'1', r'\u{010c}', r'\u{042f}'],
            [40.0, 1.0, 10.0, 10.0],
            810,
            885
        );
    }

    @TestCase
    public func testECIEnglishArabicCyrillic(): Unit {
        readFile("testECIEnglishArabicCyrillic");

        //multi ECI between UTF-8 (ISO-8859-6 is excluded in CharacterSetECI) and ISO-8859-5
        performECITest(
            [r'a', r'1', r'\u{0620}', r'\u{042f}'],
            [10.0, 1.0, 10.0, 10.0],
            1182,
            1219
        );
    }

    @TestCase
    public func testBinaryMultiECI(): Unit {
        //Test the cases described in 5.5.5.3 "ECI and Byte Compaction mode using latch 924 and 901"
        performDecodeTest([5, 927, 4, 913, 200], "\u{010c}");
        performDecodeTest([9, 927, 4, 913, 200, 927, 7, 913, 207], "\u{010c}\u{042f}");
        performDecodeTest([9, 927, 4, 901, 200, 927, 7, 901, 207], "\u{010c}\u{042f}");
        performDecodeTest([8, 927, 4, 901, 200, 927, 7, 207], "\u{010c}\u{042f}");
        performDecodeTest(
            [14, 927, 4, 901, 200, 927, 7, 207, 927, 4, 200, 927, 7, 207],
            "\u{010c}\u{042f}\u{010c}\u{042f}"
        );
        performDecodeTest(
            [16, 927, 4, 924, 336, 432, 197, 51, 300, 927, 7, 348, 231, 311, 858, 567],
            "\u{010c}\u{010c}\u{010c}\u{010c}\u{010c}\u{010c}\u{042f}\u{042f}\u{042f}\u{042f}\u{042f}\u{042f}"
        );
    }

    static var digits: Array<Rune> = [
        r'0',
        r'1',
        r'2',
        r'3',
        r'4',
        r'5',
        r'6',
        r'7',
        r'8',
        r'9',
        r'a',
        r'b',
        r'c',
        r'd',
        r'e',
        r'f',
        r'g',
        r'h',
        r'i',
        r'j',
        r'k',
        r'l',
        r'm',
        r'n',
        r'o',
        r'p',
        r'q',
        r'r',
        r's',
        r't',
        r'u',
        r'v',
        r'w',
        r'x',
        r'y',
        r'z'
    ]

    public static func toString(i_: Int64, radix_: Int64): String {
        var i = i_
        var radix: Int64 = radix_
        if (radix < 2 || radix > 36) {
            radix = 10
        }

        /* Use the faster version */
        if (radix == 10) {
            return i.toString();
        }

        var buf: Array<Rune> = Array<Rune>(33, item: r' ');
        var negative: Bool = (i < 0)
        var charPos: Int64 = 32;

        if (!negative) {
            i = -i
        }

        while (i <= -radix) {
            buf[charPos] = digits[-(i % radix)]
            charPos--
            i = i / radix
        }
        buf[charPos] = digits[-i]

        if (negative) {
            buf[charPos] = r'-'
            charPos--
        }

        return String(buf.slice(charPos, 33 - charPos));
    }

    private static func encodeDecode(input: String, expectedLength: Int64) {
        @Assert(expectedLength, encodeDecode(input))
    }

    private static func encodeDecode(input: String): Int64 {
        return encodeDecode(input, MyCharset(), false, true);
    }

    private static func encodeDecode(input: String, charset: MyCharset, autoECI: Bool, decode: Bool): Int64 {
        var s: UTF32String = PDF417HighLevelEncoderTestAdapter.encodeHighLevel(input, Compaction.AUTO, charset, autoECI);
        if (decode) {
            var codewords: Array<Int64> = Array<Int64>(s.charSize + 1, item: 0)
            codewords[0] = codewords.size

            for (i in 1..codewords.size) {
                codewords[i] = s.get(i - 1).hashCode()
            }
            performDecodeTest(codewords, input);
        }
        return s.charSize + 1
    }

    private static func getEndIndex(length: Int64, chars: Array<Rune>): Int64 {
        var decimalLength: Float64 = log10(Float64(chars.size));
        return Int64(ceil(pow(Float64(10), decimalLength * Float64(length))))
    }

    private static func generatePermutation(index: Int64, length: Int64, chars: Array<Rune>): String {
        var N: Int64 = chars.size;
        var baseNNumber: UTF32String = UTF32String(toString(index, N));
        while (baseNNumber.charSize < length) {
            baseNNumber = UTF32String("0") + baseNNumber
        }
        var prefix: String = "";
        for (i in 0..baseNNumber.charSize) {
            prefix += String(chars[baseNNumber.get(i).hashCode() - r'0'.hashCode()])
        }
        return prefix
    }

    private static func performPermutationTest(chars: Array<Rune>, length: Int64, expectedTotal: Int64) {
        var endIndex: Int64 = getEndIndex(length, chars);
        var total: Int64 = 0;
        for (i in 0..endIndex) {
            total += encodeDecode(generatePermutation(i, length, chars))
        }
        @Assert(expectedTotal, total)
    }

    private static func performEncodeTest(c: Rune, expectedLengths: Array<Int64>) {
        for (i in 0..expectedLengths.size) {
            var sb: ArrayList<Rune> = ArrayList<Rune>();

            for (j in 0..=i) {
                sb.append(c);
            }
            encodeDecode(String(sb), expectedLengths[i]);
        }
    }

    private static func performDecodeTest(codewords: Array<Int64>, expectedResult: String) {
        var result: DecoderResult = DecodedBitStreamParser.decode(codewords, "0");
        @Assert(expectedResult, result.getText())
    }

    private static func performECITest(
        chars: Array<Rune>,
        weights: Array<Float32>,
        expectedMinLength: Int64,
        expectedUTFLength: Int64
    ) {
        var random: Random = Random(0);
        var minLength: Int64 = 0;
        var utfLength: Int64 = 0;

        for (i in 0..10) {
            var s: String = generateText(random, 100, chars, weights);
            minLength += encodeDecode(s, MyCharset(), true, true)
            utfLength += encodeDecode(s, StandardCharsets.UTF_8, false, true)
        }
        @Assert(expectedMinLength, minLength)
        @Assert(expectedUTFLength, utfLength)
    }

    private static func generateText(random: Random, maxWidth: Int64, chars: Array<Rune>, weights: Array<Float32>): String {
        var result: ArrayList<Rune> = ArrayList<Rune>();
        let maxWordWidth: Int64 = 7;
        var total: Float32 = 0.0;

        for (i in 0..weights.size) {
            total += weights[i]
        }

        for (i in 0..weights.size) {
            weights[i] /= total
        }
        var cnt: Int64 = 0;
        do {
            var maxValue: Float32 = 0.0;
            var maxIndex: Int64 = 0;

            for (j in 0..weights.size) {
                var value: Float32 = nextFloat() * weights[j]
                if (value > maxValue) {
                    maxValue = value
                    maxIndex = j
                }
            }
            let wordLength: Float32 = Float32(maxWordWidth) * nextFloat()
            if (wordLength > 0.0 && result.size > 0) {
                result.append(r' ');
            }

            var j = 0;
            while (Float32(j) < wordLength) {
                var c: Rune = chars[maxIndex]
                if (j == 0 && c.hashCode() >= r'a'.hashCode() && c.hashCode() <= r'z'.hashCode() && nextBool()) {
                    c = Rune(c.hashCode() - r'a'.hashCode() + r'A'.hashCode())
                }
                result.append(c);
                j++
            }

            if (cnt % 2 != 0 && nextBool()) {
                result.append(r'.');
            }
            cnt++
        } while (result.size < maxWidth - maxWordWidth)
        return String(result);
    }

    static var floatList: ArrayList<Float32> = ArrayList<Float32>();
    static var boolList: ArrayList<Bool> = ArrayList<Bool>();

    static var fileNum = 0;
    static var fileNum_bool = 0;

    private static func nextFloat(): Float32 {
        var numItem: Float32 = 0.0;

        numItem = floatList.get(fileNum).getOrThrow()
        fileNum++

        return numItem
    }

    private static func nextBool(): Bool {
        var numItem: Bool

        numItem = boolList.get(fileNum_bool).getOrThrow()
        fileNum_bool++

        return numItem
    }

    private func readFile(fileName: String) {
        fileNum = 0
        fileNum_bool = 0

        floatList.clear();
        boolList.clear();

        var file: File = File("./decoder/" + fileName + ".txt", OpenOption.Open(true, true));
        var file_bool: File = File("./decoder/" + fileName + "_bool.txt", OpenOption.Open(true, true));

        var info_bool = Array<Byte>(file_bool.length, item: 0);
        var info = Array<Byte>(file.length, item: 0);

        var size = file.read(info);
        var size_bool = file_bool.read(info_bool);

        file.close();
        file_bool.close();

        var item = ArrayList<Rune>();
        var str = String();
        for (i in 0..size) {
            if (Rune(UInt8(info[i])) == r' ' || Rune(UInt8(info[i])) == r'\n' || Rune(UInt8(info[i])) == r'\r') {
                str = String(item)
                floatList.append(Float32.parse(str));
                item.clear();
            } else {
                item.append(Rune(UInt8(info[i])));
            }
        }
        item.clear();
        for (i in 0..size_bool) {
            if (Rune(UInt8(info_bool[i])) == r' ' || Rune(UInt8(info_bool[i])) == r'\n' || Rune(UInt8(info_bool[i])) ==
                r'\r') {
                str = String(item)
                boolList.append(Bool.parse(str));

                item.clear();
            } else {
                item.append(Rune(UInt8(info_bool[i])));
            }
        }
    }
}
