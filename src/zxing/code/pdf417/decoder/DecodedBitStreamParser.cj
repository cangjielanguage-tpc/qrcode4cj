/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.pdf417.decoder

from std import convert.*
from std import format.*
import zxing.code.common.Qrcoder4cjFormatException
import zxing.code.common.ECIStringBuilder
import zxing.code.common.DecoderResult
import zxing.code.pdf417.common.PDF417ResultMetadata
import zxing.code.tools.BigInteger
from charset import charset.tools.UTF32String

enum Mode {
    | ALPHA
    | LOWER
    | MIXED
    | PUNCT
    | ALPHA_SHIFT
    | PUNCT_SHIFT
}

/**
 * This class contains the methods for decoding the PDF417 codewords.
 */
public open class DecodedBitStreamParser {
    private static let TEXT_COMPACTION_MODE_LATCH: Int64 = 900
    private static let BYTE_COMPACTION_MODE_LATCH: Int64 = 901
    private static let NUMERIC_COMPACTION_MODE_LATCH: Int64 = 902
    private static let BYTE_COMPACTION_MODE_LATCH_6: Int64 = 924
    private static let ECI_USER_DEFINED: Int64 = 925
    private static let ECI_GENERAL_PURPOSE: Int64 = 926
    private static let ECI_CHARSET: Int64 = 927
    private static let BEGIN_MACRO_PDF417_CONTROL_BLOCK: Int64 = 928
    private static let BEGIN_MACRO_PDF417_OPTIONAL_FIELD: Int64 = 923
    private static let MACRO_PDF417_TERMINATOR: Int64 = 922
    private static let MODE_SHIFT_TO_BYTE_COMPACTION_MODE: Int64 = 913
    private static let MAX_NUMERIC_CODEWORDS: Int64 = 15

    private static let MACRO_PDF417_OPTIONAL_FIELD_FILE_NAME: Int64 = 0
    private static let MACRO_PDF417_OPTIONAL_FIELD_SEGMENT_COUNT: Int64 = 1
    private static let MACRO_PDF417_OPTIONAL_FIELD_TIME_STAMP: Int64 = 2
    private static let MACRO_PDF417_OPTIONAL_FIELD_SENDER: Int64 = 3
    private static let MACRO_PDF417_OPTIONAL_FIELD_ADDRESSEE: Int64 = 4
    private static let MACRO_PDF417_OPTIONAL_FIELD_FILE_SIZE: Int64 = 5
    private static let MACRO_PDF417_OPTIONAL_FIELD_CHECKSUM: Int64 = 6

    private static let PL: Int64 = 25
    private static let LL: Int64 = 27
    private static let AS: Int64 = 27
    private static let ML: Int64 = 28
    private static let AL: Int64 = 28
    private static let PS: Int64 = 29
    private static let PAL: Int64 = 29

    private static let PUNCT_CHARS: Array<Char> = ";<>@[\\]_`~!\r\t,:\n-.$/\"|*()?{}'".toRuneArray()

    private static let MIXED_CHARS: Array<Char> = "0123456789&\r\t,:#-.$/+%*=^".toRuneArray()

    /**
     * Table containing values for the exponent of 900.
     * This is used in the numeric compaction decode algorithm.
     */
    private static var EXP900: Array<String> = [
        "1",
        "900",
        "810000",
        "729000000",
        "656100000000",
        "590490000000000",
        "531441000000000000",
        "478296900000000000000",
        "430467210000000000000000",
        "387420489000000000000000000",
        "348678440100000000000000000000",
        "313810596090000000000000000000000",
        "282429536481000000000000000000000000",
        "254186582832900000000000000000000000000",
        "228767924549610000000000000000000000000000",
        "205891132094649000000000000000000000000000000"
    ]

    private static let NUMBER_OF_SEQUENCE_CODEWORDS: Int64 = 2

    private init() {}

    public static func decode(codewords: Array<Int64>, ecLevel: String): DecoderResult {
        var result: ECIStringBuilder = ECIStringBuilder(codewords.size * 2)
        var codeIndex: Int64 = textCompaction(codewords, 1, result)
        var resultMetadata: PDF417ResultMetadata = PDF417ResultMetadata()
        while (codeIndex < codewords[0]) {
            var code: Int64 = codewords[codeIndex]
            codeIndex++
            if (code == TEXT_COMPACTION_MODE_LATCH) {
                codeIndex = textCompaction(codewords, codeIndex, result)
            } else if (code == BYTE_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH_6) {
                codeIndex = byteCompaction(
                    code,
                    codewords,
                    codeIndex,
                    result
                )
            } else if (code == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                result.append(Char(codewords[codeIndex]))
                codeIndex++
            } else if (code == NUMERIC_COMPACTION_MODE_LATCH) {
                codeIndex = numericCompaction(codewords, codeIndex, result)
            } else if (code == ECI_CHARSET) {
                result.appendECI(codewords[codeIndex])
                codeIndex++
            } else if (code == ECI_GENERAL_PURPOSE || code == ECI_USER_DEFINED) {
                codeIndex++
            } else if (code == BEGIN_MACRO_PDF417_CONTROL_BLOCK) {
                codeIndex = decodeMacroBlock(
                    codewords,
                    codeIndex,
                    resultMetadata
                )
            } else if (code == BEGIN_MACRO_PDF417_OPTIONAL_FIELD) {
                throw Qrcoder4cjFormatException.getFormatInstance()
            } else if (code == MACRO_PDF417_TERMINATOR) {
                throw Qrcoder4cjFormatException.getFormatInstance()
            } else {
                codeIndex--
                codeIndex = textCompaction(codewords, codeIndex, result)
            }
        }
        if (result.isEmpty() && resultMetadata.getFileId().isEmpty()) {
            throw Qrcoder4cjFormatException.getFormatInstance()
        }
        var decoderResult: DecoderResult = DecoderResult(Array<UInt8>(), result.toString(), ArrayList<Array<UInt8>>(),
            ecLevel)
        decoderResult.setOther(resultMetadata)
        return decoderResult
    }

    public static func decodeMacroBlock(codewords: Array<Int64>, codeIndex: Int64, resultMetadata: PDF417ResultMetadata): Int64 {
        var codeIndex_ = codeIndex
        if (codeIndex_ + NUMBER_OF_SEQUENCE_CODEWORDS > codewords[0]) {
            // we must have at least two bytes left for the segment index
            throw Qrcoder4cjFormatException.getFormatInstance()
        }
        var segmentIndexArray: Array<Int64> = Array<Int64>(NUMBER_OF_SEQUENCE_CODEWORDS, item: 0)
        for (i in 0..NUMBER_OF_SEQUENCE_CODEWORDS) {
            segmentIndexArray[i] = codewords[codeIndex_]
            codeIndex_++
        }
        var segmentIndexString: String = decodeBase900toBase10(segmentIndexArray, NUMBER_OF_SEQUENCE_CODEWORDS)
        if (segmentIndexString.isEmpty()) {
            resultMetadata.setSegmentIndex(0)
        } else {
            resultMetadata.setSegmentIndex(Int64.parse(segmentIndexString))
        }

        // Decoding the fileId codewords as 0-899 numbers, each 0-filled to width 3. This follows the spec
        // (See ISO/IEC 15438:2015 Annex H.6) and preserves all info, but some generators (e.g. TEC-IT) write the
        // fileId using text compaction, so in those cases the fileId will appear mangled.
        var fileId: ArrayList<Char> = ArrayList<Char>()
        while (codeIndex_ < codewords[0] && codeIndex_ < codewords.size && codewords[codeIndex_] !=
                MACRO_PDF417_TERMINATOR && codewords[codeIndex_] != BEGIN_MACRO_PDF417_OPTIONAL_FIELD) {
            fileId.appendAll(codewords[codeIndex_].format(".3").toRuneArray())
            codeIndex_++
        }
        if (fileId.size == 0) {
            // at least one fileId codeword is required (Annex H.2)
            throw Qrcoder4cjFormatException.getFormatInstance()
        }
        resultMetadata.setFileId(String(fileId))

        var optionalFieldsStart: Int64 = -1
        if (codewords[codeIndex_] == BEGIN_MACRO_PDF417_OPTIONAL_FIELD) {
            optionalFieldsStart = codeIndex_ + 1
        }

        while (codeIndex_ < codewords[0]) {
            if (codewords[codeIndex_] == BEGIN_MACRO_PDF417_OPTIONAL_FIELD) {
                codeIndex_++
                if (codewords[codeIndex_] == MACRO_PDF417_OPTIONAL_FIELD_FILE_NAME) {
                    var fileName: ECIStringBuilder = ECIStringBuilder()
                    codeIndex_ = textCompaction(codewords, codeIndex_ + 1, fileName)
                    resultMetadata.setFileName(fileName.toString())
                } else if (codewords[codeIndex_] == MACRO_PDF417_OPTIONAL_FIELD_SENDER) {
                    var sender: ECIStringBuilder = ECIStringBuilder()
                    codeIndex_ = textCompaction(codewords, codeIndex_ + 1, sender)
                    resultMetadata.setSender(sender.toString())
                } else if (codewords[codeIndex_] == MACRO_PDF417_OPTIONAL_FIELD_ADDRESSEE) {
                    var addressee: ECIStringBuilder = ECIStringBuilder()
                    codeIndex_ = textCompaction(codewords, codeIndex_ + 1, addressee)
                    resultMetadata.setAddressee(addressee.toString())
                } else if (codewords[codeIndex_] == MACRO_PDF417_OPTIONAL_FIELD_SEGMENT_COUNT) {
                    var segmentCount: ECIStringBuilder = ECIStringBuilder()
                    codeIndex_ = numericCompaction(codewords, codeIndex_ + 1, segmentCount)
                    try {
                        resultMetadata.setSegmentCount(Int64.parse(segmentCount.toString()))
                    } catch (nfe: IllegalArgumentException) {
                        throw Qrcoder4cjFormatException.getFormatInstance()
                    }
                } else if (codewords[codeIndex_] == MACRO_PDF417_OPTIONAL_FIELD_TIME_STAMP) {
                    var timestamp: ECIStringBuilder = ECIStringBuilder()
                    codeIndex_ = numericCompaction(codewords, codeIndex_ + 1, timestamp)
                    try {
                        resultMetadata.setTimestamp(Int64.parse(timestamp.toString()))
                    } catch (nfe: IllegalArgumentException) {
                        throw Qrcoder4cjFormatException.getFormatInstance()
                    }
                } else if (codewords[codeIndex_] == MACRO_PDF417_OPTIONAL_FIELD_CHECKSUM) {
                    var checksum: ECIStringBuilder = ECIStringBuilder()
                    codeIndex_ = numericCompaction(codewords, codeIndex_ + 1, checksum)
                    try {
                        resultMetadata.setChecksum(Int64.parse(checksum.toString()))
                    } catch (nfe: IllegalArgumentException) {
                        throw Qrcoder4cjFormatException.getFormatInstance()
                    }
                } else if (codewords[codeIndex_] == MACRO_PDF417_OPTIONAL_FIELD_FILE_SIZE) {
                    var fileSize: ECIStringBuilder = ECIStringBuilder()
                    codeIndex_ = numericCompaction(codewords, codeIndex_ + 1, fileSize)
                    try {
                        resultMetadata.setFileSize(Int64.parse(fileSize.toString()))
                    } catch (nfe: IllegalArgumentException) {
                        throw Qrcoder4cjFormatException.getFormatInstance()
                    }
                } else {
                    throw Qrcoder4cjFormatException.getFormatInstance()
                }
            } else if (codewords[codeIndex_] == MACRO_PDF417_TERMINATOR) {
                codeIndex_++
                resultMetadata.setLastSegment(true)
            } else {
                throw Qrcoder4cjFormatException.getFormatInstance()
            }
        }

        // copy optional fields to additional options
        if (optionalFieldsStart != -1) {
            var optionalFieldsLength: Int64 = codeIndex_ - optionalFieldsStart
            if (resultMetadata.isLastSegment()) {
                // do not include terminator
                optionalFieldsLength--
            }
            if (optionalFieldsLength > 0) {
                var newArray: Array<Int64> = Array<Int64>(optionalFieldsLength, item: 0);
                for (i in optionalFieldsStart..optionalFieldsStart + optionalFieldsLength) {
                    if (let Some(num) <- codewords.get(i)) {
                        newArray[i - optionalFieldsStart] = num
                    }
                }
                resultMetadata.setOptionalData(newArray)
            }
        }

        return codeIndex_
    }

    /**
     * Text Compaction mode permits all printable ASCII characters to be
     * encoded, i.e. values 32 - 126 inclusive in accordance with ISO/IEC 646 (IRV), as well as
     * selected control characters.
     *
     * @param codewords The array of codewords (data + error)
     * @param codeIndex The current index into the codeword array.
     * @param result    The decoded data is appended to the result.
     *
     * @return The next index into the codeword array.
     */
    private static func textCompaction(codewords: Array<Int64>, codeIndex: Int64, result: ECIStringBuilder): Int64 {
        var codeIndex_ = codeIndex

        // 2 character per codeword
        var textCompactionData: Array<Int64> = Array<Int64>((codewords[0] - codeIndex) * 2, item: 0)

        // Used to hold the byte compaction value if there is a mode shift
        var byteCompactionData: Array<Int64> = Array<Int64>((codewords[0] - codeIndex) * 2, item: 0)

        var index: Int64 = 0
        var end: Bool = false
        var subMode: Mode = Mode.ALPHA
        while ((codeIndex_ < codewords[0]) && !end) {
            var code: Int64 = codewords[codeIndex_]
            codeIndex_++
            if (code < TEXT_COMPACTION_MODE_LATCH) {
                textCompactionData[index] = code / 30
                textCompactionData[index + 1] = code % 30
                index += 2
            } else {
                if (code == TEXT_COMPACTION_MODE_LATCH) {
                    textCompactionData[index] = TEXT_COMPACTION_MODE_LATCH
                    index++
                } else if (code == BYTE_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH_6 || code ==
                    NUMERIC_COMPACTION_MODE_LATCH || code == BEGIN_MACRO_PDF417_CONTROL_BLOCK || code ==
                    BEGIN_MACRO_PDF417_OPTIONAL_FIELD || code == MACRO_PDF417_TERMINATOR) {
                    codeIndex_--
                    end = true
                } else if (code == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                    textCompactionData[index] = MODE_SHIFT_TO_BYTE_COMPACTION_MODE
                    code = codewords[codeIndex_]
                    codeIndex_++
                    byteCompactionData[index] = code
                    index++
                } else if (code == ECI_CHARSET) {
                    subMode = decodeTextCompaction(textCompactionData, byteCompactionData, index, result, subMode)
                    result.appendECI(codewords[codeIndex_])
                    codeIndex_++
                    if (codeIndex_ > codewords[0]) {
                        throw Qrcoder4cjFormatException.getFormatInstance()
                    }
                    textCompactionData = Array<Int64>((codewords[0] - codeIndex_) * 2, item: 0)
                    byteCompactionData = Array<Int64>((codewords[0] - codeIndex_) * 2, item: 0)
                    index = 0
                }
            }
        }
        decodeTextCompaction(textCompactionData, byteCompactionData, index, result, subMode)

        return codeIndex_
    }

    /**
     * The Text Compaction mode includes all the printable ASCII characters
     * (i.e. values from 32 to 126) and three ASCII control characters: HT or tab
     * (ASCII value 9), LF or line feed (ASCII value 10), and CR or carriage return
     * (ASCII value 13). The Text Compaction mode also includes various latch
     * and shift characters which are used exclusively within the mode. The Text Compaction
     * mode encodes up to 2 characters per codeword. The compaction rules
     * for converting data into PDF417 codewords are defined in 5.4.2.2. The sub-mode switches
     * are defined in 5.4.2.3.
     *
     * @param textCompactionData The text compaction data.
     * @param byteCompactionData The byte compaction data if there
     * was a mode shift.
     * @param length             The size of the text compaction and byte compaction data.
     * @param result             The decoded data is appended to the result.
     * @param startMode          The mode in which decoding starts
     *
     * @return The mode in which decoding ended
     */
    private static func decodeTextCompaction(
        textCompactionData: Array<Int64>,
        byteCompactionData: Array<Int64>,
        length: Int64,
        result: ECIStringBuilder,
        startMode: Mode
    ): Mode {

        // Beginning from an initial state
        // The default compaction mode for PDF417 in effect at the start of each symbol shall always be Text
        // Compaction mode Alpha sub-mode (uppercase alphabetic). A latch codeword from another mode to the Text
        // Compaction mode shall always switch to the Text Compaction Alpha sub-mode.
        var subMode: Mode = startMode
        var priorToShiftMode: Mode = startMode
        var latchedMode: Mode = startMode
        var i: Int64 = 0
        while (i < length) {
            var subModeCh: Int64 = textCompactionData[i]
            var ch: Char = Char(0x00)
            match (subMode) {
                case ALPHA =>
                    // Alpha (uppercase alphabetic)
                    if (subModeCh < 26) {
                    // Upper case Alpha Character
                    ch = Char('A'.hashCode() + subModeCh)
                } else {
                    if (subModeCh == 26) {
                        ch = ' '
                    } else if (subModeCh == LL) {
                        subMode = Mode.LOWER
                        latchedMode = subMode
                    } else if (subModeCh == ML) {
                        subMode = Mode.MIXED
                        latchedMode = subMode
                    } else if (subModeCh == PS) {
                        priorToShiftMode = subMode
                        subMode = Mode.PUNCT_SHIFT
                    } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        result.append(Char(byteCompactionData[i]))
                    } else if (subModeCh == TEXT_COMPACTION_MODE_LATCH) {
                        subMode = Mode.ALPHA
                        latchedMode = subMode
                    }
                }
                case LOWER =>
                    // Lower (lowercase alphabetic)
                    if (subModeCh < 26) {
                    ch = Char('a'.hashCode() + subModeCh)
                } else {
                    if (subModeCh == 26) {
                        ch = ' '
                    } else if (subModeCh == AS) {
                        priorToShiftMode = subMode
                        subMode = Mode.ALPHA_SHIFT
                    } else if (subModeCh == ML) {
                        subMode = Mode.MIXED
                        latchedMode = subMode
                    } else if (subModeCh == PS) {
                        priorToShiftMode = subMode
                        subMode = Mode.PUNCT_SHIFT
                    } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        result.append(Char(byteCompactionData[i]))
                    } else if (subModeCh == TEXT_COMPACTION_MODE_LATCH) {
                        subMode = Mode.ALPHA
                        latchedMode = subMode
                    }
                }
                case MIXED =>
                    // Mixed (numeric and some punctuation)
                    if (subModeCh < PL) {
                    ch = MIXED_CHARS[subModeCh]
                } else {
                    if (subModeCh == PL) {
                        subMode = Mode.PUNCT
                        latchedMode = subMode
                    } else if (subModeCh == 26) {
                        ch = ' '
                    } else if (subModeCh == LL) {
                        subMode = Mode.LOWER
                        latchedMode = subMode
                    } else if (subModeCh == AL || subModeCh == TEXT_COMPACTION_MODE_LATCH) {
                        subMode = Mode.ALPHA
                        latchedMode = subMode
                    } else if (subModeCh == PS) {
                        priorToShiftMode = subMode
                        subMode = Mode.PUNCT_SHIFT
                    } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        result.append(Char(byteCompactionData[i]))
                    }
                }
                case PUNCT =>
                    // Punctuation
                    if (subModeCh < PAL) {
                    ch = PUNCT_CHARS[subModeCh]
                } else {
                    if (subModeCh == PAL || subModeCh == TEXT_COMPACTION_MODE_LATCH) {
                        subMode = Mode.ALPHA
                        latchedMode = subMode
                    } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                        result.append(Char(byteCompactionData[i]))
                    }
                }
                case ALPHA_SHIFT =>
                    // Restore sub-mode
                    subMode = priorToShiftMode
                    if (subModeCh < 26) {
                        ch = Char('A'.hashCode() + subModeCh)
                    } else {
                        if (subModeCh == 26) {
                            ch = ' '
                        } else if (subModeCh == TEXT_COMPACTION_MODE_LATCH) {
                            subMode = Mode.ALPHA
                        }
                    }
                case PUNCT_SHIFT =>
                    // Restore sub-mode
                    subMode = priorToShiftMode
                    if (subModeCh < PAL) {
                        ch = PUNCT_CHARS[subModeCh]
                    } else {
                        if (subModeCh == PAL || subModeCh == TEXT_COMPACTION_MODE_LATCH) {
                            subMode = Mode.ALPHA
                        } else if (subModeCh == MODE_SHIFT_TO_BYTE_COMPACTION_MODE) {
                            result.append(Char(byteCompactionData[i]))
                        }
                    }
            }
            if (ch != Char(0x00)) {
                // Append decoded character to result
                result.append(ch)
            }
            i++
        }

        return latchedMode
    }

    /**
     * Byte Compaction mode (see 5.4.3) permits all 256 possible 8-bit byte values to be encoded.
     * This includes all ASCII characters value 0 to 127 inclusive and provides for international character
     * set support.
     *
     * @param mode      The byte compaction mode i.e. 901 or 924
     * @param codewords The array of codewords (data + error)
     * @param codeIndex The current index into the codeword array.
     * @param result    The decoded data is appended to the result.
     *
     * @return The next index into the codeword array.
     */
    @OverflowWrapping
    private static func byteCompaction(mode: Int64, codewords: Array<Int64>, codeIndex: Int64, result: ECIStringBuilder): Int64 {
        var end: Bool = false
        var codeIndex_ = codeIndex

        while (codeIndex_ < codewords[0] && !end) {
            //handle leading ECIs
            while (codeIndex_ < codewords[0] && codewords[codeIndex_] == ECI_CHARSET) {
                codeIndex_++
                result.appendECI(codewords[codeIndex_])
                codeIndex_++
            }

            if (codeIndex_ >= codewords[0] || codewords[codeIndex_] >= TEXT_COMPACTION_MODE_LATCH) {
                end = true
            } else {
                //decode one block of 5 codewords to 6 bytes
                var value: Int64 = 0
                var count: Int64 = 0
                do {
                    value = 900 * value + codewords[codeIndex_]
                    codeIndex_++
                    count++
                } while (count < 5 && codeIndex_ < codewords[0] && codewords[codeIndex_] < TEXT_COMPACTION_MODE_LATCH)
                if (count == 5 && (mode == BYTE_COMPACTION_MODE_LATCH_6 || codeIndex_ < codewords[0] &&
                    codewords[codeIndex_] < TEXT_COMPACTION_MODE_LATCH)) {
                    for (i in 0..6) {
                        result.append(UInt8(value >> (8 * (5 - i))))
                    }
                } else {
                    codeIndex_ -= count
                    (codeIndex_,end) = exbyteCompaction(codeIndex_, codewords, end, result)
                }
            }
        }

        return codeIndex_
    }

    private static func exbyteCompaction(codeIndex_: Int64, codewords: Array<Int64>, end: Bool, result: ECIStringBuilder):(Int64,Bool) {
        var codeIndex_p = codeIndex_
        var end_p = end
        while ((codeIndex_p < codewords[0]) && !end_p) {
            var code: Int64 = codewords[codeIndex_p]
            codeIndex_p++
            if (code < TEXT_COMPACTION_MODE_LATCH) {
                result.append(UInt8(code))
            } else if (code == ECI_CHARSET) {
                result.appendECI(codewords[codeIndex_p])
                codeIndex_p++
            } else {
                codeIndex_p--
                end_p = true
            }
        }
        return (codeIndex_p,end_p)
    }

    /**
     * Numeric Compaction mode (see 5.4.4) permits efficient encoding of numeric data strings.
     *
     * @param codewords The array of codewords (data + error)
     * @param codeIndex The current index into the codeword array.
     * @param result    The decoded data is appended to the result.
     *
     * @return The next index into the codeword array.
     */
    private static func numericCompaction(codewords: Array<Int64>, codeIndex: Int64, result: ECIStringBuilder): Int64 {
        var count: Int64 = 0
        var end: Bool = false
        var codeIndex_ = codeIndex

        var numericCodewords: Array<Int64> = Array<Int64>(MAX_NUMERIC_CODEWORDS, item: 0)

        while (codeIndex_ < codewords[0] && !end) {
            var code: Int64 = codewords[codeIndex_]
            codeIndex_++
            if (codeIndex_ == codewords[0]) {
                end = true
            }
            if (code < TEXT_COMPACTION_MODE_LATCH) {
                numericCodewords[count] = code
                count++
            } else {
                if (code == TEXT_COMPACTION_MODE_LATCH || code == BYTE_COMPACTION_MODE_LATCH || code ==
                    BYTE_COMPACTION_MODE_LATCH_6 || code == BEGIN_MACRO_PDF417_CONTROL_BLOCK || code ==
                    BEGIN_MACRO_PDF417_OPTIONAL_FIELD || code == MACRO_PDF417_TERMINATOR || code == ECI_CHARSET) {
                    codeIndex_--
                    end = true
                }
            }
            if ((count % MAX_NUMERIC_CODEWORDS == 0 || code == NUMERIC_COMPACTION_MODE_LATCH || end) && count > 0) {
                // Re-invoking Numeric Compaction mode (by using codeword 902
                // while in Numeric Compaction mode) serves  to terminate the current
                // Numeric Compaction mode grouping as described,
                // and then to start a new one grouping.
                result.append(decodeBase900toBase10(numericCodewords, count))
                count = 0
            }
        }

        return codeIndex_
    }

    /**
     * Convert a list of Numeric Compacted codewords from Base 900 to Base 10.
     *
     * @param codewords The array of codewords
     * @param count     The number of codewords
     *
     * @return The decoded string representing the Numeric data.
     */
    /**
     * EXAMPLE
     * Encode the fifteen digit numeric string 000213298174000
     * Prefix the numeric string with a 1 and set the initial value of
     * t = 1 000 213 298 174 000
     * Calculate codeword 0
     * d0 = 1 000 213 298 174 000 mod 900 = 200
     *
     * t = 1 000 213 298 174 000 div 900 = 1 111 348 109 082
     * Calculate codeword 1
     * d1 = 1 111 348 109 082 mod 900 = 282
     * 
     * t = 1 111 348 109 082 div 900 = 1 234 831 232
     * Calculate codeword 2
     * d2 = 1 234 831 232 mod 900 = 632
     * 
     * t = 1 234 831 232 div 900 = 1 372 034
     * Calculate codeword 3
     * d3 = 1 372 034 mod 900 = 434
     * 
     * t = 1 372 034 div 900 = 1 524
     * Calculate codeword 4
     * d4 = 1 524 mod 900 = 624
     * 
     * t = 1 524 div 900 = 1
     * Calculate codeword 5
     * d5 = 1 mod 900 = 1
     * t = 1 div 900 = 0
     * Codeword sequence is: 1, 624, 434, 632, 282, 200
     * 
     * Decode the above codewords involves
     * 1 x 900 power of 5 + 624 x 900 power of 4 + 434 x 900 power of 3 +
     * 632 x 900 power of 2 + 282 x 900 power of 1 + 200 x 900 power of 0 = 1000213298174000
     * 
     * Remove leading 1 =>  Result is 000213298174000
     */
    private static func decodeBase900toBase10(codewords: Array<Int64>, count: Int64): String {
        var result: BigInteger = BigInteger("0")

        for (i in 0..count) {
            result = result + (BigInteger(EXP900[count - i - 1]) * (BigInteger(codewords[i])))
        }
        var resultString: String = result.toString()
        if (Char(resultString[0]) != '1') {
            throw Qrcoder4cjFormatException.getFormatInstance()
        }
        return resultString[Range<Int64>(1, resultString.size, 1, true, true, false)]
    }
}
