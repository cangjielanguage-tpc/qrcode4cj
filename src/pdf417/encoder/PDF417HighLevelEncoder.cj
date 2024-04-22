/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

/*
 * This file has been modified from its original form in Barcode4J.
 */

package pdf417.encoder

from std import convert.*
import common.CharacterSetECI
import common.ECIInput
import common.MinimalECIInput
import common.MyCharset
import common.CharsetEncoder
import common.StandardCharsets
import tools.BigInteger
import tools.UTF32String
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import math.*

/**
 * PDF417 high-level encoder following the algorithm described in ISO/IEC 15438:2001(E) in
 * annex P.
 */
public open class PDF417HighLevelEncoder {
    /**
     * code for Text compaction
     */
    private static let TEXT_COMPACTION: Int64 = 0

    /**
     * code for Byte compaction
     */
    private static let BYTE_COMPACTION: Int64 = 1

    /**
     * code for Numeric compaction
     */
    private static let NUMERIC_COMPACTION: Int64 = 2

    /**
     * Text compaction submode Alpha
     */
    private static let SUBMODE_ALPHA: Int64 = 0

    /**
     * Text compaction submode Lower
     */
    private static let SUBMODE_LOWER: Int64 = 1

    /**
     * Text compaction submode Mixed
     */
    private static let SUBMODE_MIXED: Int64 = 2

    /**
     * Text compaction submode Punctuation
     */
    private static let SUBMODE_PUNCTUATION: Int64 = 3

    /**
     * mode latch to Text Compaction mode
     */
    private static let LATCH_TO_TEXT: Int64 = 900

    /**
     * mode latch to Byte Compaction mode (number of characters NOT a multiple of 6)
     */
    private static let LATCH_TO_BYTE_PADDED: Int64 = 901

    /**
     * mode latch to Numeric Compaction mode
     */
    private static let LATCH_TO_NUMERIC: Int64 = 902

    /**
     * mode shift to Byte Compaction mode
     */
    private static let SHIFT_TO_BYTE: Int64 = 913

    /**
     * mode latch to Byte Compaction mode (number of characters a multiple of 6)
     */
    private static let LATCH_TO_BYTE: Int64 = 924

    /**
     * identifier for a user defined Extended Channel Interpretation (ECI)
     */
    private static let ECI_USER_DEFINED: Int64 = 925

    /**
     * identifier for a general purpose ECO format
     */
    private static let ECI_GENERAL_PURPOSE: Int64 = 926

    /**
     * identifier for an ECI of a character set of code page
     */
    private static let ECI_CHARSET: Int64 = 927

    /**
     * Raw code table for text compaction Mixed sub-mode
     */
    private static let TEXT_MIXED_RAW: Array<UInt8> = [
        48,
        49,
        50,
        51,
        52,
        53,
        54,
        55,
        56,
        57,
        38,
        13,
        9,
        44,
        58,
        35,
        45,
        46,
        36,
        47,
        43,
        37,
        42,
        61,
        94,
        0,
        32,
        0,
        0,
        0
    ]

    /**
     * Raw code table for text compaction: Punctuation sub-mode
     */
    private static let TEXT_PUNCTUATION_RAW: Array<UInt8> = [
        59,
        60,
        62,
        64,
        91,
        92,
        93,
        95,
        96,
        126,
        33,
        13,
        9,
        44,
        58,
        10,
        45,
        46,
        36,
        47,
        34,
        124,
        42,
        40,
        41,
        63,
        123,
        125,
        39,
        0
    ]

    private static var MIXED: Array<UInt8> = [
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        12,
        128,
        128,
        128,
        11,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        26,
        128,
        128,
        15,
        18,
        21,
        10,
        128,
        128,
        128,
        22,
        20,
        13,
        16,
        17,
        19,
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        14,
        128,
        128,
        23,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        24,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128
    ]
    private static var PUNCTUATION: Array<UInt8> = [
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        12,
        15,
        128,
        128,
        11,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        10,
        20,
        128,
        18,
        128,
        128,
        28,
        23,
        24,
        22,
        128,
        13,
        16,
        17,
        19,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        14,
        0,
        1,
        128,
        2,
        25,
        3,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        4,
        5,
        6,
        128,
        7,
        8,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        128,
        26,
        21,
        27,
        9,
        128
    ]

    private static let DEFAULT_ENCODING: MyCharset = StandardCharsets.ISO_8859_1

    private init() {
        for (i in 0..TEXT_MIXED_RAW.size) {
            var b: UInt8 = TEXT_MIXED_RAW[i]
            if (b > 0) {
                MIXED[Int64(b)] = UInt8(i)
            }
        }

        for (i in 0..TEXT_PUNCTUATION_RAW.size) {
            var b: UInt8 = TEXT_PUNCTUATION_RAW[i]
            if (b > 0) {
                PUNCTUATION[Int64(b)] = UInt8(i)
            }
        }
    }

    /**
     * Performs high-level encoding of a PDF417 message using the algorithm described in annex P of
     * ISO/IEC 15438:2001(E). If byte compaction has been selected, then only byte compaction is used.
     *
     * @param msg the message
     * @param compaction compaction mode to use
     * @param encoding character encoding used to encode in default or byte compaction
     * or None for default / not applicable
     * @param autoECI encode input minimally using multiple ECIs if needed
     * If autoECI encoding is specified and additionally {@code encoding} is specified, then the encoder will
     * use the specified {@link Charset} for any character that can be encoded by it, regardless
     * if a different encoding would lead to a more compact encoding. When no {@code encoding} is specified
     * then charsets will be chosen so that the byte representation is minimal.
     *
     * @return the encoded message (the Char values range from 0 to 928)
     */
    public static func encodeHighLevel(msg: UTF32String, compaction: Compaction, encoding: MyCharset, autoECI: Bool): UTF32String {
        var encoding_ = encoding
        if (msg.isEmpty()) {
            throw Qrcoder4cjWriterException("Empty message not allowed")
        }

        if (encoding_.flag == false && !autoECI) {
            for (i in 0..msg.charSize) {
                if (msg[i].hashCode() > 255) {
                    throw Qrcoder4cjWriterException(
                        "Non-encodable character detected: ${msg.toRuneArray()[i]} (Unicode: ${msg.toRuneArray()[i].hashCode()}). Consider specifying EncodeHintType.PDF417_AUTO_ECI and/or EncodeTypeHint.CHARACTER_SET."
                    )
                }
            }
        }

        //the codewords 0..928 are encoded as Unicode characters
        var sb: ArrayList<Char> = ArrayList<Char>()
        var input: ECIInput
        if (autoECI) {
            input = MinimalECIInput(msg, encoding_, -1)
        } else {
            input = NoECIInput(msg)
            if (encoding_.flag == false) {
                encoding_ = DEFAULT_ENCODING
            } else if (!DEFAULT_ENCODING.equals(encoding_)) {
                let eci: CharacterSetECI = CharacterSetECI.getCharacterSetECIByValue(
                    CharacterSetECI.getCharacterSetECI(encoding_))
                if (eci.flag == true) {
                    encodingECI(eci.getValue(), sb)
                }
            }
        }

        var len: Int64 = input.length()
        var p_: Int64 = 0
        var textSubMode: Int64 = SUBMODE_ALPHA

        // User selected encoding mode
        match (compaction) {
            case TEXT => encodeText(input, p_, len, sb, textSubMode)
            case BYTE => if (autoECI) {
                encodeMultiECIBinary(input, 0, input.length(), TEXT_COMPACTION, sb)
            } else {
                var msgBytes: Array<UInt8> = encoding_.newEncoder().getBytes(UTF32String(input.toString()))
                encodeBinary(msgBytes, p_, msgBytes.size, BYTE_COMPACTION, sb)
            }

            case NUMERIC =>
                sb.append(Char(LATCH_TO_NUMERIC))
                encodeNumeric(input, p_, len, sb)
            case _ =>
                var encodingMode: Int64 = TEXT_COMPACTION

                //Default mode
                while (p_ < len) {
                    while (p_ < len && input.isECI(p_)) {
                        encodingECI(input.getECIValue(p_), sb)
                        p_++
                    }
                    if (p_ >= len) {
                        break
                    }
                    var n: Int64 = determineConsecutiveDigitCount(input, p_)
                    if (n >= 13) {
                        sb.append(Char(LATCH_TO_NUMERIC))
                        encodingMode = NUMERIC_COMPACTION
                        textSubMode = SUBMODE_ALPHA

                        //Reset after latch
                        encodeNumeric(input, p_, n, sb)
                        p_ += n
                    } else {
                        var t: Int64 = determineConsecutiveTextCount(input, p_)
                        if (t >= 5 || n == len) {
                            if (encodingMode != TEXT_COMPACTION) {
                                sb.append(Char(LATCH_TO_TEXT))
                                encodingMode = TEXT_COMPACTION
                                textSubMode = SUBMODE_ALPHA
                                //start with submode alpha after latch
                            }
                            textSubMode = encodeText(input, p_, t, sb, textSubMode)
                            p_ += t
                        } else {
                            var b: Int64 = 0
                            if (autoECI) {
                                b = determineConsecutiveBinaryCount(input, p_, MyCharset())
                            } else {
                                b = determineConsecutiveBinaryCount(input, p_, encoding_)
                            }
                            if (b == 0) {
                                b = 1
                            }

                            var bytes: Array<UInt8>
                            if (autoECI) {
                                bytes = Array<UInt8>()
                            } else {
                                bytes = encoding_.newEncoder().getBytes(input.subSequence(p_, p_ + b))
                            }
                            if (((bytes.size == 0 && b == 1) || (bytes.size != 0 && bytes.size == 1)) && encodingMode ==
                                TEXT_COMPACTION) {
                                /* Switch for one byte (instead of latch) */
                                if (autoECI) {
                                    encodeMultiECIBinary(input, p_, 1, TEXT_COMPACTION, sb)
                                } else {
                                    encodeBinary(bytes, 0, 1, TEXT_COMPACTION, sb)
                                }
                            } else {
                                /* Mode latch performed by encodeBinary() */
                                if (autoECI) {
                                    encodeMultiECIBinary(input, p_, p_ + b, encodingMode, sb)
                                } else {
                                    encodeBinary(bytes, 0, bytes.size, encodingMode, sb)
                                }
                                encodingMode = BYTE_COMPACTION
                                textSubMode = SUBMODE_ALPHA
                                //Reset after latch
                            }
                            p_ += b
                        }
                    }
                }
        }

        return UTF32String(sb)
    }

    /**
     * Encode parts of the message using Text Compaction as described in ISO/IEC 15438:2001(E), chapter 4.4.2.
     *
     * @param input          the input value
     * @param startpos       the start position value within the message
     * @param count          the number value of characters to encode
     * @param sb             receives the encoded codewords value
     * @param initialSubmode should normally be SUBMODE_ALPHA
     *
     * @return the text submode value in which this method ends
     */
    private static func encodeText(
        input: ECIInput,
        startpos: Int64,
        count: Int64,
        sb: ArrayList<Char>,
        initialSubmode: Int64
    ): Int64 {
        var tmp: ArrayList<Char> = ArrayList<Char>()
        var submode: Int64 = initialSubmode
        var idx: Int64 = 0
        while (true) {
            if (input.isECI(startpos + idx)) {
                encodingECI(input.getECIValue(startpos + idx), sb)
                idx++
            } else {
                var ch: Char = input.charAt(startpos + idx)
                if (submode == SUBMODE_ALPHA) {
                    if (isAlphaUpper(ch)) {
                        if (ch == ' ') {
                            tmp.append(Char(26))
                            //space
                        } else {
                            tmp.append(Char(ch.hashCode() - 65))
                        }
                    } else {
                        if (isAlphaLower(ch)) {
                            submode = SUBMODE_LOWER
                            tmp.append(Char(27))
                            continue
                        } else if (isMixed(ch)) {
                            submode = SUBMODE_MIXED
                            tmp.append(Char(28))
                            continue
                        } else {
                            tmp.append(Char(29))

                            //ps
                            tmp.append(Char(PUNCTUATION[ch.hashCode()]))
                        }
                    }
                } else if (submode == SUBMODE_LOWER) {
                    if (isAlphaLower(ch)) {
                        if (ch == ' ') {
                            tmp.append(Char(26))
                            //space
                        } else {
                            tmp.append(Char(ch.hashCode() - 97))
                        }
                    } else {
                        if (isAlphaUpper(ch)) {
                            tmp.append(Char(27))

                            //as
                            tmp.append(Char(ch.hashCode() - 65))
                        } else if (isMixed(ch)) {
                            submode = SUBMODE_MIXED
                            tmp.append(Char(28))
                            continue
                        } else {
                            tmp.append(Char(29))

                            //ps
                            tmp.append(Char(PUNCTUATION[ch.hashCode()]))
                        }
                    }
                } else if (submode == SUBMODE_MIXED) {
                    if (isMixed(ch)) {
                        tmp.append(Char(MIXED[ch.hashCode()]))
                    } else {
                        if (isAlphaUpper(ch)) {
                            submode = SUBMODE_ALPHA
                            tmp.append(Char(28))
                            continue
                        } else if (isAlphaLower(ch)) {
                            submode = SUBMODE_LOWER
                            tmp.append(Char(27))
                            continue
                        } else {
                            if (startpos + idx + 1 < count && !input.isECI(startpos + idx + 1) && isPunctuation(
                                input.charAt(startpos + idx + 1))) {
                                submode = SUBMODE_PUNCTUATION
                                tmp.append(Char(25))
                                continue
                            }
                            tmp.append(Char(29))

                            //ps
                            tmp.append(Char(PUNCTUATION[ch.hashCode()]))
                        }
                    }
                } else {
                    if (isPunctuation(ch)) {
                        tmp.append(Char(PUNCTUATION[ch.hashCode()]))
                    } else {
                        submode = SUBMODE_ALPHA
                        tmp.append(Char(29))
                        continue
                    }
                }
                idx++
                if (idx >= count) {
                    break
                }
            }
        }
        var h: Char = '\u{00}'
        var str = UTF32String(tmp)
        var len: Int64 = str.charSize
        for (i in 0..len) {
            var odd: Bool = (i % 2) != 0
            if (odd) {
                h = Char((h.hashCode() * 30) + str[i].hashCode())
                sb.append(h)
            } else {
                h = str[i]
            }
        }
        if ((len % 2) != 0) {
            sb.append(Char((h.hashCode() * 30) + 29))
            //ps
        }
        return submode
    }

    /**
     * Encode all of the message value using Byte Compaction as described in ISO/IEC 15438:2001(E)
     *
     * @param input     the input value
     * @param startpos  the start position value within the message
     * @param count     the number value of bytes to encode
     * @param startmode the mode from which this method starts
     * @param sb        receives the encoded codewords
     */
    private static func encodeMultiECIBinary(
        input: ECIInput,
        startpos: Int64,
        count: Int64,
        startmode: Int64,
        sb: ArrayList<Char>
    ) {
        let end: Int64 = min(startpos + count, input.length())
        var localStart: Int64 = startpos
        while (true) {
            //encode all leading ECIs and advance localStart
            while (localStart < end && input.isECI(localStart)) {
                encodingECI(input.getECIValue(localStart), sb)
                localStart++
            }
            var localEnd: Int64 = localStart

            //advance end until before the next ECI
            while (localEnd < end && !input.isECI(localEnd)) {
                localEnd++
            }

            let localCount: Int64 = localEnd - localStart
            if (localCount <= 0) {
                break
            } else {
                //encode the segment
                if (localStart == startpos) {
                    startmode
                    encodeBinary(subBytes(input, localStart, localEnd), 0, localCount, startmode, sb)
                } else {
                    encodeBinary(subBytes(input, localStart, localEnd), 0, localCount, BYTE_COMPACTION, sb)
                }
                localStart = localEnd
            }
        }
    }

    public static func subBytes(input: ECIInput, start: Int64, end: Int64): Array<UInt8> {
        let count: Int64 = end - start
        var result: Array<UInt8> = Array<UInt8>(count, item: 0)
        for (i in start..end) {
            result[i - start] = UInt8(input.charAt(i).hashCode() & 0xff)
        }
        return result
    }

    /**
     * Encode parts of the message using Byte Compaction as described in ISO/IEC 15438:2001(E),
     * chapter 4.4.3. The Unicode characters will be converted to binary using the cp437 codepage.
     *
     * @param bytes     the message converted to a byte array
     * @param startpos  the start position within the message
     * @param count     the number of bytes to encode
     * @param startmode the mode from which this method starts
     * @param sb        receives the encoded codewords
     */
    private static func encodeBinary(
        bytes: Array<UInt8>,
        startpos: Int64,
        count: Int64,
        startmode: Int64,
        sb: ArrayList<Char>
    ) {
        if (count == 1 && startmode == TEXT_COMPACTION) {
            sb.append(Char(SHIFT_TO_BYTE))
        } else {
            if ((count % 6) == 0) {
                sb.append(Char(LATCH_TO_BYTE))
            } else {
                sb.append(Char(LATCH_TO_BYTE_PADDED))
            }
        }

        var idx: Int64 = startpos

        // Encode sixpacks
        if (count >= 6) {
            var chars: Array<Char> = Array<Char>(5, item: Char(0x00))
            while ((startpos + count - idx) >= 6) {
                var t: Int64 = 0
                for (i in 0..6) {
                    t <<= 8
                    t += bytes[idx + i].hashCode() & 0xff
                }
                for (i in 0..5) {
                    chars[i] = Char(t % 900)
                    t /= 900
                }
                for (i in chars.size - 1..=0 : -1) {
                    sb.append(chars[i])
                }
                idx += 6
            }
        }

        //Encode rest (remaining n<5 bytes if any)
        for (i in idx..startpos + count) {
            var ch: Int64 = bytes[i].hashCode() & 0xff
            sb.append(Char(ch))
        }
    }

    private static func encodeNumeric(input: ECIInput, startpos: Int64, count: Int64, sb: ArrayList<Char>) {
        var idx: Int64 = 0
        var tmp: ArrayList<Char> = ArrayList<Char>()
        var num900: BigInteger = BigInteger(900)
        var num0: BigInteger = BigInteger(0)
        while (idx < count) {
            tmp = ArrayList<Char>()
            var len: Int64 = min(44, count - idx)
            var part: String = "1" + input.subSequence(startpos + idx, startpos + idx + len).toString()
            var bigint: BigInteger = BigInteger(part)
            do {
                tmp.append(Char(Int32.parse((bigint % num900).getNumber())))
                bigint = bigint / num900
                var a = bigint.toString()
            } while (bigint != num0)

            //Reverse temporary string
            var str = UTF32String(tmp)
            for (i in str.charSize - 1..=0 : -1) {
                sb.append(str[i])
            }
            idx += len
        }
    }

    private static func isDigit(ch: Char): Bool {
        return ch >= '0' && ch <= '9'
    }

    private static func isAlphaUpper(ch: Char): Bool {
        return ch == ' ' || (ch >= 'A' && ch <= 'Z')
    }

    private static func isAlphaLower(ch: Char): Bool {
        return ch == ' ' || (ch >= 'a' && ch <= 'z')
    }

    private static func isMixed(ch: Char): Bool {
        return Int64(MIXED[ch.hashCode()]) != 128
    }

    private static func isPunctuation(ch: Char): Bool {
        return Int64(PUNCTUATION[ch.hashCode()]) != 128
    }

    private static func isText(ch: Char): Bool {
        return ch == '\t' || ch == '\n' || ch == '\r' || (ch.hashCode() >= 32 && ch.hashCode() <= 126)
    }

    /**
     * Determines the number of consecutive characters that are encodable using numeric compaction.
     *
     * @param input      the input
     * @param startpos the start position within the input
     * @return the requested character count
     */
    private static func determineConsecutiveDigitCount(input: ECIInput, startpos: Int64): Int64 {
        var count: Int64 = 0
        let len_: Int64 = input.length()
        var idx_: Int64 = startpos
        if (idx_ < len_) {
            while (idx_ < len_ && !input.isECI(idx_) && isDigit(input.charAt(idx_))) {
                count++
                idx_++
            }
        }
        return count
    }

    /**
     * Determines the number of consecutive characters that are encodable using text compaction.
     *
     * @param input      the input
     * @param startpos the start position within the input
     * @return the requested character count
     */
    private static func determineConsecutiveTextCount(input: ECIInput, startpos: Int64): Int64 {
        let len: Int64 = input.length()
        var idx_: Int64 = startpos
        while (idx_ < len) {
            var numericCount: Int64 = 0
            while (numericCount < 13 && idx_ < len && !input.isECI(idx_) && isDigit(input.charAt(idx_))) {
                numericCount++
                idx_++
            }
            if (numericCount >= 13) {
                return idx_ - startpos - numericCount
            }
            if (numericCount > 0) {
                continue
            }

            /* Check if character is encodable */
            if (input.isECI(idx_) || !isText(input.charAt(idx_))) {
                break
            }
            idx_++
        }
        return idx_ - startpos
    }

    /**
     * Determines the number of consecutive characters that are encodable using binary compaction.
     *
     * @param input    the input value 
     * @param startpos the start position value within the message
     * @param encoding the charset used to convert the message to a byte array
     * @return the requested character count value
     */
    private static func determineConsecutiveBinaryCount(input: ECIInput, startpos: Int64, encoding: MyCharset): Int64 {
        var encoder: ?CharsetEncoder = None
        if (encoding.flag == false) {
            encoder = None
        } else {
            encoder = encoding.newEncoder()
        }
        var len: Int64 = input.length()
        var idx_: Int64 = startpos
        while (idx_ < len) {
            var numericCount: Int64 = 0

            var i: Int64 = idx_
            while (numericCount < 13 && !input.isECI(i) && isDigit(input.charAt(i))) {
                numericCount++

                /* textCount++ */
                i = idx_ + numericCount
                if (i >= len) {
                    break
                }
            }
            if (numericCount >= 13) {
                return idx_ - startpos
            }

            if (let Some(e) <- encoder) {
                if (!e.canEncode(input.charAt(idx_))) {
                    @Assert(input is NoECIInput)

                    var ch: Char = input.charAt(idx_)
                    throw Qrcoder4cjWriterException("Non-encodable character detected: ${ch} (Unicode: ${ch.hashCode()})")
                }
            }
            idx_++
        }
        return idx_ - startpos
    }

    private static func encodingECI(eci: Int64, sb: ArrayList<Char>) {
        if (eci >= 0 && eci < 900) {
            sb.append(Char(ECI_CHARSET))
            sb.append(Char(eci))
        } else if (eci < 810900) {
            sb.append(Char(ECI_GENERAL_PURPOSE))
            sb.append(Char(eci / 900 - 1))
            sb.append(Char(eci % 900))
        } else if (eci < 811800) {
            sb.append(Char(ECI_USER_DEFINED))
            sb.append(Char(810900 - eci))
        } else {
            throw Qrcoder4cjWriterException("ECI number not in valid range from 0..811799, but was " + eci.toString())
        }
    }
}

class NoECIInput <: ECIInput {
    var input: UTF32String

    init(input: UTF32String) {
        this.input = input
    }

    public func length(): Int64 {
        return input.charSize
    }

    public func charAt(index: Int64): Char {
        return input[index]
    }

    public func isECI(_: Int64): Bool {
        return false
    }

    public func getECIValue(_: Int64): Int64 {
        return -1
    }

    public func haveNCharacters(index: Int64, n: Int64): Bool {
        return index + n <= input.charSize
    }

    public func subSequence(start: Int64, end: Int64): UTF32String {
        return input.substring(start, end - start)
    }

    public func toString(): String {
        return input.toString()
    }
}
