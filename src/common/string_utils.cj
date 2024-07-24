/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common

import std.collection.*
import QRCode4cj.tools.*

public class StringUtils {
    public static let PLATFORM_DEFAULT_ENCODING: MyCharset = MyCharset.forName("UTF-8");
    public static let SHIFT_JIS_CHARSET: MyCharset = MyCharset.forName("Shift_JIS");
    public static var GB2312_CHARSET: MyCharset = MyCharset.forName("GB18030")
    public static let UTF_16: MyCharset = MyCharset.forName("UTF-16BE");

    private static let EUC_JP: MyCharset = MyCharset.forName("EUC_JP");
    private static let ASSUME_SHIFT_JIS: Bool = SHIFT_JIS_CHARSET.equals(PLATFORM_DEFAULT_ENCODING) || EUC_JP.equals(
        PLATFORM_DEFAULT_ENCODING)

    // Retained for ABI compatibility with earlier versions
    public static let SHIFT_JIS = "SJIS";
    public static let GB2312 = "GB2312";

    init() {
        var gb2312Charset: MyCharset = MyCharset()
        try {
            gb2312Charset = MyCharset.forName("GB18030")
        } catch (ucee: Exception) {
            // Can happen on some embedded JREs?
            gb2312Charset = MyCharset()
        }
        GB2312_CHARSET = gb2312Charset
    }

    /**
     * @param bytes bytes encoding a string, whose encoding should be guessed
     * @param hints decode hints if applicable
     * @return name of guessed encoding; at the moment will only guess one of:
     * "SJIS", "UTF-8", "ISO8859_1", or the platform default encoding if none
     * of these can possibly be correct
     */
    public static func guessEncoding(bytes: Array<Byte>, hints: HashMap<DecodeHintType, Any>) {
        let c: MyCharset = guessCharset(bytes, hints);
        if (c.equals(SHIFT_JIS_CHARSET)) {
            return "SJIS";
        }
        if (c.equals(StandardCharsets.UTF_8)) {
            return "UTF-8";
        }
        if (c.equals(StandardCharsets.ISO_8859_1)) {
            return "ISO8859_1";
        }
        return c.name();
    }

    /**
     * @param bytes bytes encoding a string, whose encoding should be guessed
     * @param hints decode hints if applicable
     * @return MyCharset of guessed encoding; at the moment will only guess one of:
     * {@link #SHIFT_JIS_CHARSET}, {@link StandardCharsets#UTF_8},
     * {@link StandardCharsets#ISO_8859_1}, {@link StandardCharsets#UTF_16},
     * or the platform default encoding if
     * none of these can possibly be correct
     */
    public static func guessCharset(bytes: Array<Byte>, hints: HashMap<DecodeHintType, Any>): MyCharset {
        if (hints.size > 0 && hints.contains(DecodeHintType.CHARACTER_SET)) {
            let name = hints.get(DecodeHintType.CHARACTER_SET).getOrThrow() as String

            return MyCharset.forName(name.getOrThrow())
        }

        // First try UTF-16, assuming anything with its BOM is UTF-16
        if (bytes.size > 2 && ((bytes[0] == 0xFE && bytes[1] == 0xFF) || (bytes[0] == 0xFF && bytes[1] == 0xFE))) {
            let CURRENT_ENDIAN: Endian = Endian.Platform
            let returndata: MyCharset = match (CURRENT_ENDIAN) {
                case Endian.Big => return StandardCharsets.UTF_16BE
                case _ => return StandardCharsets.UTF_16LE
            }
        }

        // For now, merely tries to distinguish ISO-8859-1, UTF-8 and Shift_JIS,
        // which should be by far the most common encodings.
        let length: Int64 = bytes.size;
        var canBeISO88591: Bool = true;
        var canBeShiftJIS_: Bool = true;
        var canBeUTF8_: Bool = true;
        var utf8BytesLeft: Int64 = 0;
        var utf2BytesChars: Int64 = 0;
        var utf3BytesChars: Int64 = 0;
        var utf4BytesChars: Int64 = 0;
        var sjisBytesLeft: Int64 = 0;
        var sjisKatakanaChars: Int64 = 0;
        var sjisCurKatakanaWordLength: Int64 = 0;
        var sjisCurDoubleBytesWordLength: Int64 = 0;
        var sjisMaxKatakanaWordLength: Int64 = 0;
        var sjisMaxDoubleBytesWordLength: Int64 = 0;
        var isoHighOther: Int64 = 0;

        var utf8bom: Bool = bytes.size > 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF

        var i = 0;
        while (i < length && (canBeISO88591 || canBeShiftJIS_ || canBeUTF8_)) {
            var value_: Int64 = Int64(bytes[i]) & 0xFF

            // UTF-8 stuff
            if (canBeUTF8_) {
                if (utf8BytesLeft > 0) {
                    if ((value_ & 0x80) == 0) {
                        canBeUTF8_ = false
                    } else {
                        utf8BytesLeft--
                    }
                } else if ((value_ & 0x80) != 0) {
                    if ((value_ & 0x40) == 0) {
                        canBeUTF8_ = false
                    } else {
                        utf8BytesLeft++
                        if ((value_ & 0x20) == 0) {
                            utf2BytesChars++
                        } else {
                            utf8BytesLeft++
                            if ((value_ & 0x10) == 0) {
                                utf3BytesChars++
                            } else {
                                utf8BytesLeft++
                                if ((value_ & 0x08) == 0) {
                                    utf4BytesChars++
                                } else {
                                    canBeUTF8_ = false
                                }
                            }
                        }
                    }
                }
            }

            /* ISO-8859-1 stuff */
            if (canBeISO88591) {
                if (value_ > 0x7F && value_ < 0xA0) {
                    canBeISO88591 = false
                } else if (value_ > 0x9F && (value_ < 0xC0 || value_ == 0xD7 || value_ == 0xF7)) {
                    isoHighOther++
                }
            }

            /* Shift_JIS stuff */
            if (canBeShiftJIS_) {
                if (sjisBytesLeft > 0) {
                    if (value_ < 0x40 || value_ == 0x7F || value_ > 0xFC) {
                        canBeShiftJIS_ = false
                    } else {
                        sjisBytesLeft--
                    }
                } else if (value_ == 0x80 || value_ == 0xA0 || value_ > 0xEF) {
                    canBeShiftJIS_ = false
                } else if (value_ > 0xA0 && value_ < 0xE0) {
                    sjisKatakanaChars++
                    sjisCurDoubleBytesWordLength = 0
                    sjisCurKatakanaWordLength++
                    if (sjisCurKatakanaWordLength > sjisMaxKatakanaWordLength) {
                        sjisMaxKatakanaWordLength = sjisCurKatakanaWordLength
                    }
                } else if (value_ > 0x7F) {
                    sjisBytesLeft++

                    sjisCurKatakanaWordLength = 0
                    sjisCurDoubleBytesWordLength++
                    if (sjisCurDoubleBytesWordLength > sjisMaxDoubleBytesWordLength) {
                        sjisMaxDoubleBytesWordLength = sjisCurDoubleBytesWordLength
                    }
                } else {
                    sjisCurKatakanaWordLength = 0
                    sjisCurDoubleBytesWordLength = 0
                }
            }
            i++
        }

        if (canBeUTF8_ && utf8BytesLeft > 0) {
            canBeUTF8_ = false
        }
        if (canBeShiftJIS_ && sjisBytesLeft > 0) {
            canBeShiftJIS_ = false
        }

        /* Easy -- if there is BOM or at least 1 valid not-single byte character (and no evidence it can't be UTF-8), done */
        if (canBeUTF8_ && (utf8bom || utf2BytesChars + utf3BytesChars + utf4BytesChars > 0)) {
            return StandardCharsets.UTF_8;
        }

        /* Easy -- if assuming Shift_JIS or >= 3 valid consecutive not-ascii characters (and no evidence it can't be), done */
        if (canBeShiftJIS_ && (ASSUME_SHIFT_JIS || sjisMaxKatakanaWordLength >= 3 || sjisMaxDoubleBytesWordLength >= 3)) {
            return SHIFT_JIS_CHARSET
        }

        /*
         * Distinguishing Shift_JIS and ISO-8859-1 can be a little tough for short words. The crude heuristic is:
         * - If we saw
         *   - only two consecutive katakana chars in the whole text, or
         *   - at least 10% of bytes that could be "upper" not-alphanumeric Latin1,
         * - then we conclude Shift_JIS, else ISO-8859-1
         */
        if (canBeISO88591 && canBeShiftJIS_) {
            if ((sjisMaxKatakanaWordLength == 2 && sjisKatakanaChars == 2) || isoHighOther * 10 >= length) {
                return SHIFT_JIS_CHARSET
            } else {
                return StandardCharsets.ISO_8859_1
            }
        }

        /* Otherwise, try in order ISO-8859-1, Shift JIS, UTF-8 and fall back to default platform encoding */
        if (canBeISO88591) {
            return StandardCharsets.ISO_8859_1;
        }
        if (canBeShiftJIS_) {
            return SHIFT_JIS_CHARSET
        }
        if (canBeUTF8_) {
            return StandardCharsets.UTF_8;
        }

        /* Otherwise, we take a wild guess with platform encoding */
        return PLATFORM_DEFAULT_ENCODING
    }
}
