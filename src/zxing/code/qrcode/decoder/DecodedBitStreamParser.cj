/*
 * Copyright 2007 ZXing authors
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

package zxing.code.qrcode.decoder

import zxing.code.common.DecodeHintType
import zxing.code.common.BitSource
import zxing.code.common.CharacterSetECI
import zxing.code.common.DecoderResult
import zxing.code.common.StringUtils
import zxing.code.common.MyCharset

/**
 * <p>QR Codes can encode text as bits in one of several modes, and can use multiple modes
 * in one QR Code. This class decodes the bits back into text.</p>
 *
 * <p>See ISO 18004:2006, 6.4.3 - 6.4.7</p>
 *
 * @author Sean Owen
 */
public class DecodedBitStreamParser {
    /**
     * See ISO 18004:2006, 6.4.4 Table 5
     */
    private static let ALPHANUMERIC_CHARS: Array<Char> = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:".toRuneArray();
    private static let GB2312_SUBSET: Int64 = 1;

    init() {}

    public static func decode(
        bytes: Array<Byte>,
        version: Version,
        ecLevel: ?ErrorCorrectionLevel,
        hints: HashMap<DecodeHintType, Any>
    ): DecoderResult {
        let bits: BitSource = BitSource(bytes);
        var result: ArrayList<Char> = ArrayList<Char>();
        var byteSegments: ArrayList<Array<Byte>> = ArrayList<Array<Byte>>(1);
        var symbolSequence: Int64 = -1;
        var parityData: Int64 = -1;
        var symbologyModifier: Int64

        try {
            var currentCharacterSetECI: ?CharacterSetECI = None
            var fc1InEffect: Bool = false;
            var hasFNC1first: Bool = false;
            var hasFNC1second: Bool = false;
            var mode: Mode
            do {
                // While still another segment to read...
                if (bits.available() < 4) {
                    // OK, assume we're done. Really, a TERMINATOR mode should have been recorded here
                    mode = Mode.TERMINATOR([0, 0, 0], 0x00)
                } else {
                    mode = Mode.forBits(bits.readBits(4))
                    // mode is encoded by 4 bits
                }
                match (mode) {
                    case TERMINATOR(x, y) => ()

                    case FNC1_FIRST_POSITION(x, y) =>
                        hasFNC1first = true

                        // symbology detection
                        // We do little with FNC1 except alter the parsed result a bit according to the spec
                        fc1InEffect = true

                    case FNC1_SECOND_POSITION(x, y) =>
                        hasFNC1second = true

                        // symbology detection
                        // We do little with FNC1 except alter the parsed result a bit according to the spec
                        fc1InEffect = true

                    case STRUCTURED_APPEND(x, y) =>
                        if (bits.available() < 16) {
                            throw FormatException.getFormatInstance();
                        }

                        // sequence number and parity is added later to the result metadata
                        // Read next 8 bits (symbol sequence #) and 8 bits (parity data), then continue
                        symbolSequence = bits.readBits(8)
                        parityData = bits.readBits(8)

                    case ECI(x, y) =>
                        // Count doesn't apply to ECI
                        var value: Int64 = parseECIValue(bits);
                        currentCharacterSetECI = CharacterSetECI.getCharacterSetECIByValue(value)

                        if (let Some(c) <- currentCharacterSetECI) {}
                        else {
                            throw FormatException.getFormatInstance();
                        }
                    case HANZI(x, y) =>
                        // First handle Hanzi mode which does not start with character count
                        // Chinese mode contains a sub set indicator right after mode indicator
                        let subset: Int64 = bits.readBits(4);
                        let countHanzi: Int64 = bits.readBits(mode.getCharacterCountBits(version));
                        if (subset == GB2312_SUBSET) {
                            decodeHanziSegment(bits, result, countHanzi);
                        }
                    case _ =>
                        // "Normal" QR code modes:
                        // How many characters will follow, encoded in this mode?
                        let count: Int64 = bits.readBits(mode.getCharacterCountBits(version));
                        match (mode) {
                            case NUMERIC(x, y) => decodeNumericSegment(bits, result, count);

                            case ALPHANUMERIC(x, y) => decodeAlphanumericSegment(bits, result, count, fc1InEffect);

                            case BYTE(x, y) => decodeByteSegment(
                                bits,
                                result,
                                count,
                                currentCharacterSetECI,
                                byteSegments,
                                hints
                            );

                            case KANJI(x, y) => decodeKanjiSegment(bits, result, count);

                            case _ => throw FormatException.getFormatInstance();
                        }
                }
            } while (mode != Mode.TERMINATOR([0, 0, 0], 0x00))

            if (let Some(c) <- currentCharacterSetECI) {
                if (hasFNC1first) {
                    symbologyModifier = 4
                } else if (hasFNC1second) {
                    symbologyModifier = 6
                } else {
                    symbologyModifier = 2
                }
            } else {
                if (hasFNC1first) {
                    symbologyModifier = 3
                } else if (hasFNC1second) {
                    symbologyModifier = 5
                } else {
                    symbologyModifier = 1
                }
            }
        } catch (iae: IllegalArgumentException) {
            // from readBits() calls
            throw FormatException.getFormatInstance();
        }

        return DecoderResult(
            bytes,
            String(result),
            if (byteSegments.isEmpty()) {
                ArrayList<Array<Byte>>();
            } else {
                byteSegments
            },
            if (let Some(e) <- ecLevel) {
                e.toString()
            } else {
                String();
            },
            symbolSequence,
            parityData,
            symbologyModifier
        );
    }

    /**
     * See specification GBT 18284-2000
     */
    @OverflowWrapping
    private static func decodeHanziSegment(
        bits: BitSource,
        result: ArrayList<Char>,
        count: Int64
    ) {
        var count_: Int64 = count

        if (StringUtils.GB2312_CHARSET == MyCharset()) {
            // Not supported without charset support
            throw FormatException.getFormatInstance();
        }

        // Don't crash trying to read more bits than we have available.
        if (count_ * 13 > bits.available()) {
            throw FormatException.getFormatInstance();
        }

        // Each character will require 2 bytes. Read the characters as 2-byte pairs
        // and decode as GB2312 afterwards
        let bufferSize: Int64 = 2i64 * count_
        var buffer: Array<Byte> = Array<Byte>(bufferSize, item: 0);
        var offset: Int64 = 0;
        while (count_ > 0) {
            // Each 13 bits encodes a 2-byte character
            let twoBytes: Int64 = bits.readBits(13);
            var assembledTwoBytes: Int64 = ((twoBytes / 0x060) << 8) | (twoBytes % 0x060)
            if (assembledTwoBytes < 0x00A00) {
                // In the 0xA1A1 to 0xAAFE range
                assembledTwoBytes += 0x0A1A1
            } else {
                // In the 0xB0A1 to 0xFAFE range
                assembledTwoBytes += 0x0A6A1
            }
            buffer[offset] = UInt8((assembledTwoBytes >> 8) & 0xFF)
            buffer[offset + 1] = UInt8(assembledTwoBytes & 0xFF)
            offset += 2
            count_--
        }

        result.appendAll(StringUtils.GB2312_CHARSET.newDecoder().decode(buffer).toRuneArray())
    }

    @OverflowWrapping
    private static func decodeKanjiSegment(
        bits: BitSource,
        result: ArrayList<Char>,
        count: Int64
    ) {
        var count_ = count

        // Don't crash trying to read more bits than we have available.
        if ((count_ * 13) > bits.available()) {
            throw FormatException.getFormatInstance();
        }

        // Each character will require 2 bytes. Read the characters as 2-byte pairs
        // and decode as Shift_JIS afterwards
        let bufferSize: Int64 = 2i64 * count_
        var buffer: Array<Byte> = Array<Byte>(bufferSize, item: 0);
        var offset: Int64 = 0;
        while (count_ > 0) {
            // Each 13 bits encodes a 2-byte character
            let twoBytes: Int64 = bits.readBits(13);
            var assembledTwoBytes: Int64 = ((twoBytes / 0x0C0) << 8) | (twoBytes % 0x0C0)
            if (assembledTwoBytes < 0x01F00) {
                // In the 0x8140 to 0x9FFC range
                assembledTwoBytes += 0x08140
            } else {
                // In the 0xE040 to 0xEBBF range
                assembledTwoBytes += 0x0C140
            }
            buffer[offset] = UInt8(assembledTwoBytes >> 8)
            buffer[offset + 1] = UInt8(assembledTwoBytes)
            offset += 2
            count_--
        }

        result.appendAll(StringUtils.SHIFT_JIS_CHARSET.newDecoder().decode(buffer).toRuneArray())
    }

    private static func decodeByteSegment(
        bits: BitSource,
        result: ArrayList<Char>,
        count: Int64,
        currentCharacterSetECI: ?CharacterSetECI,
        byteSegments: ArrayList<Array<Byte>>,
        hints: HashMap<DecodeHintType, Any>
    ) {

        // Don't crash trying to read more bits than we have available.
        if ((Int64(8) * count) > bits.available()) {
            throw FormatException.getFormatInstance();
        }

        var readBytes: Array<Byte> = Array<Byte>(count, item: 0);
        for (i in 0..count) {
            let bitItem: Int64 = bits.readBits(8);
            readBytes[i] = UInt8(bitItem)
        }
        var encoding: MyCharset

        if (let Some(c) <- currentCharacterSetECI) {
            encoding = c.getCharset()
        } else {
            // The spec isn't clear on this mode; see
            // section 6.4.5: t does not say which encoding to assuming
            // upon decoding. I have seen ISO-8859-1 used as well as
            // Shift_JIS -- without anything like an ECI designator to
            // give a hint.
            encoding = StringUtils.guessCharset(readBytes, hints)
        }

        result.appendAll(encoding.newDecoder().decode(readBytes).toRuneArray())
        byteSegments.append(readBytes);
    }

    private static func toAlphaNumericChar(value: Int64): Char {
        let arraySize: Int64 = ALPHANUMERIC_CHARS.size;
        if (value >= arraySize) {
            throw FormatException.getFormatInstance();
        }
        return ALPHANUMERIC_CHARS[value]
    }

    private static func decodeAlphanumericSegment(
        bits: BitSource,
        result: ArrayList<Char>,
        count: Int64,
        fc1InEffect: Bool
    ) {
        var count_: Int64 = count

        // Read two characters at a time
        let start: Int64 = result.size;
        while (count_ > 1) {
            if (bits.available() < 11) {
                throw FormatException.getFormatInstance();
            }

            let nextTwoCharsBits: Int64 = bits.readBits(11);
            result.append(toAlphaNumericChar(nextTwoCharsBits / 45));
            result.append(toAlphaNumericChar(nextTwoCharsBits % 45));
            count_ -= 2
        }
        if (count_ == 1) {
            // special case: one character left
            if (bits.available() < 6) {
                throw FormatException.getFormatInstance();
            }
            result.append(toAlphaNumericChar(bits.readBits(6)));
        }

        // See section 6.4.8.1, 6.4.8.2
        if (fc1InEffect) {
            // We need to massage the result a bit if in an FNC1 mode:
            for (i in start..result.size) {
                if (result.get(i).getOrThrow() == '%') {
                    if (i < result.size - 1 && result.get(i + 1).getOrThrow() == '%') {
                        // %% is rendered as %
                        result.remove(i + 1);
                    } else {
                        // In alpha mode, % should be converted to FNC1 separator 0x1D
                        result.remove(i);
                        result.insert(i, Char(0x1D))
                    }
                }
            }
        }
    }

    private static func decodeNumericSegment(
        bits: BitSource,
        result: ArrayList<Char>,
        count: Int64
    ) {
        var count_: Int64 = count

        // Read three digits at a time
        while (count_ >= 3) {
            // Each 10 bits encodes three digits
            if (bits.available() < 10) {
                throw FormatException.getFormatInstance();
            }
            let threeDigitsBits: Int64 = bits.readBits(10);
            if (threeDigitsBits >= 1000) {
                throw FormatException.getFormatInstance();
            }
            result.append(toAlphaNumericChar(threeDigitsBits / 100));
            result.append(toAlphaNumericChar((threeDigitsBits / 10) % 10));
            result.append(toAlphaNumericChar(threeDigitsBits % 10));
            count_ -= 3
        }
        if (count_ == 2) {
            // Two digits left over to read, encoded in 7 bits
            if (bits.available() < 7) {
                throw FormatException.getFormatInstance();
            }
            let twoDigitsBits: Int64 = bits.readBits(7);
            if (twoDigitsBits >= 100) {
                throw FormatException.getFormatInstance();
            }
            result.append(toAlphaNumericChar(twoDigitsBits / 10));
            result.append(toAlphaNumericChar(twoDigitsBits % 10));
        } else if (count_ == 1) {
            // One digit left over to read
            if (bits.available() < 4) {
                throw FormatException.getFormatInstance();
            }
            let digitBits: Int64 = bits.readBits(4);
            if (digitBits >= 10) {
                throw FormatException.getFormatInstance();
            }
            result.append(toAlphaNumericChar(digitBits));
        }
    }

    private static func parseECIValue(bits: BitSource): Int64 {
        var firstByte: Int64 = bits.readBits(8);
        if ((firstByte & 0x80) == 0) {
            // just one byte

            return firstByte & 0x7F
        }
        if ((firstByte & 0xC0) == 0x80) {
            // two bytes
            var secondByte: Int64 = bits.readBits(8);

            return ((firstByte & 0x3F) << 8) | secondByte
        }
        if ((firstByte & 0xE0) == 0xC0) {
            // three bytes
            var secondThirdBytes: Int64 = bits.readBits(16);

            return ((firstByte & 0x1F) << 16) | secondThirdBytes
        }

        throw FormatException.getFormatInstance();
    }
}
