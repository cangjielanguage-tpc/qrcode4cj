/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.aztec.decoder

import std.collection.*
import std.io.*
import QRCode4cj.aztec.common.AztecDetectorResult
import QRCode4cj.common.*
import QRCode4cj.common.reedsolomon.*
import QRCode4cj.tools.UTF32String

enum DecoderTable {
    | UPPER
    | LOWER
    | MIXED
    | DIGIT
    | PUNCT
    | BINARY

    public operator func ==(right: DecoderTable): Bool {
        if (this.toString() == right.toString()) {
            return true;
        } else {
            return false;
        }
    }

    public operator func !=(right: DecoderTable): Bool {
        if (this.toString() != right.toString()) {
            return true;
        } else {
            return false;
        }
    }

    public func toString(): String {
        match (this) {
            case UPPER => return "UPPER";
            case LOWER => return "LOWER";
            case MIXED => return "MIXED";
            case DIGIT => return "DIGIT";
            case PUNCT => return "PUNCT";
            case BINARY => return "BINARY";
        }
    }
}

class CorrectedBitsResult {
    public var correctBits: Array<Bool> = Array<Bool>();
    public var ecLevel: Int64 = 0;

    public init(correctBits: Array<Bool>, ecLevel: Int64) {
        this.correctBits = correctBits
        this.ecLevel = ecLevel
    }
}

public class Decoder {
    private static let checkStr = UTF32String("FLG(n)");
    private static let UPPER_TABLE: Array<UTF32String> = [
        UTF32String("CTRL_PS"),
        UTF32String(" "),
        UTF32String("A"),
        UTF32String("B"),
        UTF32String("C"),
        UTF32String("D"),
        UTF32String("E"),
        UTF32String("F"),
        UTF32String("G"),
        UTF32String("H"),
        UTF32String("I"),
        UTF32String("J"),
        UTF32String("K"),
        UTF32String("L"),
        UTF32String("M"),
        UTF32String("N"),
        UTF32String("O"),
        UTF32String("P"),
        UTF32String("Q"),
        UTF32String("R"),
        UTF32String("S"),
        UTF32String("T"),
        UTF32String("U"),
        UTF32String("V"),
        UTF32String("W"),
        UTF32String("X"),
        UTF32String("Y"),
        UTF32String("Z"),
        UTF32String("CTRL_LL"),
        UTF32String("CTRL_ML"),
        UTF32String("CTRL_DL"),
        UTF32String("CTRL_BS")
    ]

    private static let LOWER_TABLE: Array<UTF32String> = [
        UTF32String("CTRL_PS"),
        UTF32String(" "),
        UTF32String("a"),
        UTF32String("b"),
        UTF32String("c"),
        UTF32String("d"),
        UTF32String("e"),
        UTF32String("f"),
        UTF32String("g"),
        UTF32String("h"),
        UTF32String("i"),
        UTF32String("j"),
        UTF32String("k"),
        UTF32String("l"),
        UTF32String("m"),
        UTF32String("n"),
        UTF32String("o"),
        UTF32String("p"),
        UTF32String("q"),
        UTF32String("r"),
        UTF32String("s"),
        UTF32String("t"),
        UTF32String("u"),
        UTF32String("v"),
        UTF32String("w"),
        UTF32String("x"),
        UTF32String("y"),
        UTF32String("z"),
        UTF32String("CTRL_US"),
        UTF32String("CTRL_ML"),
        UTF32String("CTRL_DL"),
        UTF32String("CTRL_BS")
    ]

    private static let MIXED_TABLE: Array<UTF32String> = [
        UTF32String("CTRL_PS"),
        UTF32String(" "),
        UTF32String(Rune(1).toString()),
        UTF32String(Rune(2).toString()),
        UTF32String(Rune(3).toString()),
        UTF32String(Rune(4).toString()),
        UTF32String(Rune(5).toString()),
        UTF32String(Rune(6).toString()),
        UTF32String(Rune(7).toString()),
        UTF32String("\b"),
        UTF32String("\t"),
        UTF32String("\n"),
        UTF32String("\v"),
        UTF32String("\f"),
        UTF32String("\r"),
        UTF32String(Rune(27).toString()),
        UTF32String(Rune(28).toString()),
        UTF32String(Rune(29).toString()),
        UTF32String(Rune(30).toString()),
        UTF32String(Rune(31).toString()),
        UTF32String("@"),
        UTF32String("\\"),
        UTF32String("^"),
        UTF32String("_"),
        UTF32String("`"),
        UTF32String("|"),
        UTF32String("~"),
        UTF32String(Rune(0x7F).toString()),
        UTF32String("CTRL_LL"),
        UTF32String("CTRL_UL"),
        UTF32String("CTRL_PL"),
        UTF32String("CTRL_BS")
    ]

    private static let PUNCT_TABLE: Array<UTF32String> = [
        UTF32String("FLG(n)"),
        UTF32String("\r"),
        UTF32String("\r\n"),
        UTF32String(". "),
        UTF32String(", "),
        UTF32String(": "),
        UTF32String("!"),
        UTF32String("\""),
        UTF32String("#"),
        UTF32String("$"),
        UTF32String("%"),
        UTF32String("&"),
        UTF32String("'"),
        UTF32String("("),
        UTF32String(")"),
        UTF32String("*"),
        UTF32String("+"),
        UTF32String(","),
        UTF32String("-"),
        UTF32String("."),
        UTF32String("/"),
        UTF32String(":"),
        UTF32String(";"),
        UTF32String("<"),
        UTF32String("="),
        UTF32String(">"),
        UTF32String("?"),
        UTF32String("["),
        UTF32String("]"),
        UTF32String("{"),
        UTF32String("}"),
        UTF32String("CTRL_UL")
    ]

    private static let DIGIT_TABLE: Array<UTF32String> = [
        UTF32String("CTRL_PS"),
        UTF32String(" "),
        UTF32String("0"),
        UTF32String("1"),
        UTF32String("2"),
        UTF32String("3"),
        UTF32String("4"),
        UTF32String("5"),
        UTF32String("6"),
        UTF32String("7"),
        UTF32String("8"),
        UTF32String("9"),
        UTF32String(","),
        UTF32String("."),
        UTF32String("CTRL_UL"),
        UTF32String("CTRL_US")
    ]

    private static var DEFAULT_ENCODING: MyCharset = StandardCharsets.ISO_8859_1

    private var ddata: ?AztecDetectorResult = None

    public func decode(detectorResult: AztecDetectorResult): DecoderResult {
        ddata = detectorResult
        var matrix: BitMatrix = detectorResult.getBits()
        var rawbits: Array<Bool> = extractBits(matrix)
        var correctedBits: CorrectedBitsResult = correctBits(rawbits)
        var rawBytes: Array<UInt8> = convertBoolArrayToByteArray(correctedBits.correctBits)

        var result: String = getEncodedData(correctedBits.correctBits)

        var decoderResult: DecoderResult = DecoderResult(
            rawBytes,
            result,
            ArrayList<Array<UInt8>>(),
            "${correctedBits.ecLevel}%%",
        )
        decoderResult.setNumBits(correctedBits.correctBits.size)
        return decoderResult
    }

    public static func highLevelDecode(correctedBits: Array<Bool>): String {
        return getEncodedData(correctedBits)
    }

    private static func getEncodedData(correctedBits: Array<Bool>): String {
        var endIndex: Int64 = correctedBits.size
        var latchTable = DecoderTable.UPPER // table most recently latched to
        var shiftTable = DecoderTable.UPPER // table to use for the next read

        var result: ArrayList<Rune> = ArrayList<Rune>()

        var decodedBytes: ByteBuffer = ByteBuffer()
        var encoding: MyCharset = DEFAULT_ENCODING
        let ASCIIencoding = MyCharset.forName("ASCII").newEncoder()

        var index_: Int64 = 0
        while (index_ < endIndex) {
            if (shiftTable == DecoderTable.BINARY) {
                if (endIndex - index_ < 5) {
                    break
                }
                var length: Int64 = readCode(correctedBits, index_, 5)
                index_ += 5
                if (length == 0) {
                    if (endIndex - index_ < 11) {
                        break
                    }
                    length = readCode(correctedBits, index_, 11) + 31
                    index_ += 11
                }
                for (charCount in 0..length) {
                    if (endIndex - index_ < 8) {
                        index_ = endIndex // Force outer loop to exit
                        break
                    }
                    var code: Int64 = readCode(correctedBits, index_, 8)
                    decodedBytes.write(UInt8(code))
                    index_ += 8
                }

                // Go back to whatever mode we had been in
                shiftTable = latchTable
            } else {
                var size: Int64 = 5
                if (shiftTable == DecoderTable.DIGIT) {
                    size = 4
                }
                if (endIndex - index_ < size) {
                    break
                }
                var code: Int64 = readCode(correctedBits, index_, size)
                index_ += size
                var str: UTF32String = getCharacter(shiftTable, code)
                if (checkStr == str) {
                    if (endIndex - index_ < 3) {
                        break
                    }
                    var n: Int64 = readCode(correctedBits, index_, 3)
                    index_ += 3

                    //  flush bytes, FLG changes state
                    try {
                        var decodeout: Array<Byte> = decodedBytes.bytes()
                        var decoder: CharsetDecoder = encoding.newDecoder()
                        var byteString = decoder.decode(decodeout)
                        result.appendAll(byteString.toRuneArray())
                    } catch (uee: Exception) {
                        throw IllegalArgumentException()
                    }
                    decodedBytes = ByteBuffer()
                    match (n) {
                        case 0 => result.append(Rune(UInt32(29))) // translate FNC1 as ASCII 29 
                        case 7 => throw Qrcoder4cjFormatException.getFormatInstance() // FLG(7) is reserved and illegal
                        case _ =>
                            // ECI is decimal integer encoded as 1-6 codes in DIGIT mode
                            var eci: Int64 = 0
                            if (endIndex - index_ < 4 * n) {
                                break
                            }
                            (n, eci, index_) = exgetEncodedData(n, index_, correctedBits, eci)
                            var charsetECI: CharacterSetECI = CharacterSetECI.getCharacterSetECIByValue(eci)

                            encoding = charsetECI.getCharset()
                    }

                    // Go back to whatever mode we had been in
                    shiftTable = latchTable
                } else if (str.size >= 5 && str[0..5] == "CTRL_") {
                    // DecoderTable changes
                    // ISO/IEC 24778:2008 prescribes ending a shift sequence in the mode from which it was invoked.
                    // That's including when that mode is a shift.
                    // Our test case dlusbs.png for issue #642 exercises that.
                    latchTable = shiftTable // Latch the current mode, so as to return to Upper after U/S B/S
                    shiftTable = getTable(str[5])
                    if (str[6] == r'L') {
                        latchTable = shiftTable
                    }
                } else {
                    // Though stored as a table of strings for convenience, codes actually represent 1 or 2 *bytes*.
                    var b: Array<UInt8> = ASCIIencoding.getBytes(str);
                    decodedBytes.write(b)

                    // Go back to whatever mode we had been in
                    shiftTable = latchTable
                }
            }
        }
        try {
            var decodeout: Array<Byte> = decodedBytes.bytes()
            var decoder: CharsetDecoder = encoding.newDecoder()
            var byteString = decoder.decode(decodeout)
            result.appendAll(byteString.toRuneArray())
        } catch (uee: Exception) {
            // can't happen
            throw IllegalArgumentException()
        }
        return String(result)
    }

    private static func exgetEncodedData(n: Int64, index_: Int64, correctedBits: Array<Bool>, eci: Int64) {
        var n_p = n
        var eci_p = eci
        var index_p = index_
        while (n_p > 0) {
            n_p--
            var nextDigit: Int64 = readCode(correctedBits, index_p, 4)
            index_p += 4
            if (nextDigit < 2 || nextDigit > 11) {
                throw Qrcoder4cjFormatException.getFormatInstance() // Not a decimal digit
            }
            eci_p = eci_p * 10 + (nextDigit - 2)
        }
        return (n_p, eci_p, index_p)
    }

    /**
     * gets the table corresponding to the char passed
     */
    private static func getTable(t: Rune): DecoderTable {
        match (t) {
            case r'L' => return DecoderTable.LOWER
            case r'P' => return DecoderTable.PUNCT
            case r'M' => return DecoderTable.MIXED
            case r'D' => return DecoderTable.DIGIT
            case r'B' => return DecoderTable.BINARY
            case r'U' => return DecoderTable.UPPER
            case _ => return DecoderTable.UPPER
        }
    }

    /**
     * Gets the character (or string) corresponding to the passed code in the given table
     *
     * @param table the table used
     * @param code the code of the character
     */
    private static func getCharacter(table: DecoderTable, code: Int64): UTF32String {
        match (table) {
            case UPPER => return UPPER_TABLE[code]
            case LOWER => return LOWER_TABLE[code]
            case MIXED => return MIXED_TABLE[code]
            case PUNCT => return PUNCT_TABLE[code]
            case DIGIT => return DIGIT_TABLE[code]
            case _ => // Should not reach here.
                throw IllegalArgumentException()
        }
    }

    /**
     * <p>Performs RS error correction on an array of bits.</p>
     *
     * @return the corrected array
     * @throws Qrcoder4cjFormatException if the input contains too many errors
     */
    private func correctBits(rawbits: Array<Bool>): CorrectedBitsResult {
        var gf: GenericGF
        var codewordSize: Int64

        if (ddata.getOrThrow().getNbLayers() <= 2) {
            codewordSize = 6
            gf = GenericGF.AZTEC_DATA_6
        } else if (ddata.getOrThrow().getNbLayers() <= 8) {
            codewordSize = 8
            gf = GenericGF.AZTEC_DATA_8
        } else if (ddata.getOrThrow().getNbLayers() <= 22) {
            codewordSize = 10
            gf = GenericGF.AZTEC_DATA_10
        } else {
            codewordSize = 12
            gf = GenericGF.AZTEC_DATA_12
        }

        var numDataCodewords: Int64 = ddata.getOrThrow().getNbDatablocks()
        var numCodewords: Int64 = rawbits.size / codewordSize
        if (numCodewords < numDataCodewords) {
            throw Qrcoder4cjFormatException.getFormatInstance()
        }
        var offset: Int64 = rawbits.size % codewordSize

        var dataWords: Array<Int64> = Array<Int64>(numCodewords, repeat: 0)
        for (i in 0..numCodewords) {
            dataWords[i] = readCode(rawbits, offset, codewordSize)
            offset += codewordSize
        }

        try {
            var rsDecoder: ReedSolomonDecoder = ReedSolomonDecoder(gf)
            rsDecoder.decode(dataWords, numCodewords - numDataCodewords)
        } catch (ex: Exception) {
            throw Qrcoder4cjFormatException.getFormatInstance(ex)
        }

        // Now perform the unstuffing operation.
        // First, count how many bits are going to be thrown out as stuffing
        var mask: Int64 = (1 << codewordSize) - 1
        var stuffedBits: Int64 = 0
        for (i in 0..numDataCodewords) {
            var dataWord: Int64 = dataWords[i]
            if (dataWord == 0 || dataWord == mask) {
                throw Qrcoder4cjFormatException.getFormatInstance()
            } else if (dataWord == 1 || dataWord == mask - 1) {
                stuffedBits++
            }
        }

        // Now, actually unpack the bits and remove the stuffing
        var correctedBits: Array<Bool> = Array<Bool>(numDataCodewords * codewordSize - stuffedBits, repeat: false)
        extracted(numDataCodewords, dataWords, mask, correctedBits, codewordSize)
        return CorrectedBitsResult(correctedBits, 100 * (numCodewords - numDataCodewords) / numCodewords)
    }

    private static func extracted(numDataCodewords: Int64, dataWords: Array<Int64>, mask: Int64,
        correctedBits: Array<Bool>, codewordSize: Int64) {
        var index_: Int64 = 0
        for (i in 0..numDataCodewords) {
            var dataWord: Int64 = dataWords[i]
            if (dataWord == 1 || dataWord == mask - 1) {
                // next codewordSize-1 bits are all zeros or all ones
                correctedBits[index_..index_ + codewordSize - 1] = Array<Bool>(index_ + codewordSize - 1 - index_,repeat: dataWord > 1)
                index_ += codewordSize - 1
            } else {
                var bit: Int64 = codewordSize - 1
                while (bit >= 0) {
                    correctedBits[index_] = (dataWord & (1 << bit)) != 0
                    index_++
                    bit--
                }
            }
        }
    }

    /**
     * Gets the array of bits from an Aztec Code matrix
     *
     * @return the array of bits
     */
    private func extractBits(matrix: BitMatrix): Array<Bool> {
        var compact: Bool = ddata.getOrThrow().isCompact()
        var layers: Int64 = ddata.getOrThrow().getNbLayers()
        var baseMatrixSize: Int64 = getbaseMatrixSize(compact, layers) // not including alignment lines
        var alignmentMap: Array<Int64> = Array<Int64>(baseMatrixSize, repeat: 0)
        var rawbits: Array<Bool> = Array<Bool>(totalBitsInLayer(layers, compact), repeat: true)

        if (compact) {
            for (i in 0..alignmentMap.size) {
                alignmentMap[i] = i
            }
        } else {
            var matrixSize: Int64 = baseMatrixSize + 1 + 2 * ((baseMatrixSize / 2 - 1) / 15)
            var origCenter: Int64 = baseMatrixSize / 2
            var center: Int64 = matrixSize / 2
            for (i in 0..origCenter) {
                var newOffset: Int64 = i + i / 15
                alignmentMap[origCenter - i - 1] = center - newOffset - 1
                alignmentMap[origCenter + i] = center + newOffset + 1
            }
        }
        var rowOffset = 0
        for (i in 0..layers) {
            var rowSize: Int64 = (layers - i) * 4 + (if (compact) {
                9
            } else {
                12
            })

            // The top-left most point of this layer is <low, low> (not including alignment lines)
            var low: Int64 = i * 2

            // The bottom-right most point of this layer is <high, high> (not including alignment lines)
            var high: Int64 = baseMatrixSize - 1 - low

            // We pull bits from the two 2 x rowSize columns and two rowSize x 2 rows
            for (j in 0..rowSize) {
                var columnOffset: Int64 = j * 2
                for (k in 0..2) {
                    // left column
                    rawbits[rowOffset + columnOffset + k] = matrix.get(alignmentMap[low + k], alignmentMap[low + j])

                    // bottom row
                    rawbits[rowOffset + 2 * rowSize + columnOffset + k] = matrix.get(
                        alignmentMap[low + j],
                        alignmentMap[high - k]
                    )

                    // right column
                    rawbits[rowOffset + 4 * rowSize + columnOffset + k] = matrix.get(
                        alignmentMap[high - k],
                        alignmentMap[high - j]
                    )

                    // top row
                    rawbits[rowOffset + 6 * rowSize + columnOffset + k] = matrix.get(
                        alignmentMap[high - j],
                        alignmentMap[low + k]
                    )
                }
            }
            rowOffset += rowSize * 8
        }
        return rawbits
    }

    private func getbaseMatrixSize(compact: Bool, layers: Int64): Int64 {
        return (if (compact) {
            11
        } else {
            14
        }) + layers * 4
    }

    /**
     * Reads a code of given length and at given index_ in an array of bits
     */
    private static func readCode(rawbits: Array<Bool>, startIndex: Int64, length: Int64): Int64 {
        var res_: Int64 = 0
        for (i in startIndex..(startIndex + length)) {
            res_ <<= 1
            if (rawbits[i]) {
                res_ |= 0x01
            }
        }
        return res_
    }

    /**
     * Reads a code of length 8 in an array of bits, padding with zeros
     */
    private static func readByte(rawbits: Array<Bool>, startIndex: Int64): UInt8 {
        var n: Int64 = rawbits.size - startIndex
        if (n >= 8) {
            return UInt8(readCode(rawbits, startIndex, 8))
        }
        return UInt8(readCode(rawbits, startIndex, n) << (8 - n))
    }

    /**
     * Packs a bit array into bytes, most significant bit first
     */
    public static func convertBoolArrayToByteArray(boolArr: Array<Bool>): Array<UInt8> {
        var byteArr: Array<UInt8> = Array<UInt8>((boolArr.size + 7) / 8, repeat: 0)
        for (i in 0..byteArr.size) {
            byteArr[i] = readByte(boolArr, 8 * i)
        }
        return byteArr
    }

    private static func totalBitsInLayer(layers: Int64, compact: Bool): Int64 {
        return ((if (compact) {
            88
        } else {
            112
        }) + 16 * layers) * layers
    }
}
