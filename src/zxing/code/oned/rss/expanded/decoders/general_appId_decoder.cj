/*
 * Copyright (C) 2010 ZXing authors
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

/*
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", led by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 * http://www.piramidepse.com/
 */

package zxing.code.oned.rss.expanded.decoders

import zxing.code.common.*

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
public class GeneralAppIdDecoder {
    private var information: BitArray = BitArray();
    private var current: CurrentParsingState = CurrentParsingState();
    private var buffer: ArrayList<Char> = ArrayList<Char>();

    init(information: BitArray) {
        this.information = information
    }

    func decodeAllCodes(buff: ArrayList<Char>, initialPosition: Int64): String {
        var currentPosition: Int64 = initialPosition
        var remaining: String = String();
        do {
            var info: DecodedInformation = this.decodeGeneralPurposeField(currentPosition, remaining);

            var parsedFields: UTF32String = FieldParser.parseFieldsInGeneralPurpose(UTF32String(info.getNewString()));
            if (parsedFields != UTF32String()) {
                buff.appendAll(parsedFields.toRuneArray());
            }
            if (info.isRemaining()) {
                if (let Some(value) <- info.getRemainingValue()) {
                    remaining = value.toString()
                } else {
                    remaining = String()
                }
            } else {
                remaining = String()
            }

            if (currentPosition == info.getNewPosition()) { // No step forward!
                break
            }
            currentPosition = info.getNewPosition()
        } while (true)

        return String(buff);
    }

    private func isStillNumeric(pos: Int64): Bool {
        // It's numeric if it still has 7 positions
        // and one of the first 4 bits is "1".
        if (pos + 7 > this.information.getSize()) {
            return pos + 4 <= this.information.getSize()
        }

        for (i in pos..pos + 3) {
            if (this.information.get(i)) {
                return true;
            }
        }

        return this.information.get(pos + 3);
    }

    private func decodeNumeric(pos: Int64): DecodedNumeric {
        if (pos + 7 > this.information.getSize()) {
            var numeric: Int64 = extractNumericValueFromBitArray(pos, 4);
            if (numeric == 0) {
                return DecodedNumeric(this.information.getSize(), DecodedNumeric.FNC1, DecodedNumeric.FNC1);
            }
            return DecodedNumeric(this.information.getSize(), numeric - 1, DecodedNumeric.FNC1);
        }
        var numeric: Int64 = extractNumericValueFromBitArray(pos, 7);

        var digit1: Int64 = (numeric - 8) / 11
        var digit2: Int64 = (numeric - 8) % 11

        return DecodedNumeric(pos + 7, digit1, digit2);
    }

    func extractNumericValueFromBitArray(pos: Int64, bits: Int64): Int64 {
        return extractNumericValueFromBitArrayStatic(this.information, pos, bits);
    }

    static func extractNumericValueFromBitArrayStatic(information: BitArray, pos: Int64, bits: Int64): Int64 {
        var value: Int64 = 0;

        for (i in 0..bits) {
            if (information.get(pos + i)) {
                value |= 1 << (bits - i - 1)
            }
        }

        return value
    }

    func decodeGeneralPurposeField(pos: Int64, remaining: String): DecodedInformation {
        this.buffer = ArrayList<Char>()

        if (!remaining.isEmpty()) {
            this.buffer.appendAll(remaining.toRuneArray());
        }

        this.current.setPosition(pos);

        var lastDecoded: DecodedInformation = parseBlocks();
        if (lastDecoded.isRemaining()) {
            return DecodedInformation(
                this.current.getPosition(),
                String(this.buffer),
                lastDecoded.getRemainingValue()
            )
        }
        return DecodedInformation(this.current.getPosition(), String(this.buffer));
    }

    private func parseBlocks(): DecodedInformation {
        var isFinished: Bool = false;
        var result: BlockParsedResult = BlockParsedResult();
        do {
            var initialPosition: Int64 = current.getPosition();

            if (current.isAlpha()) {
                result = parseAlphaBlock()
                isFinished = result.isFinished()
            } else if (current.isIsoIec646()) {
                result = parseIsoIec646Block()
                isFinished = result.isFinished()
            } else { // it must be numeric
                result = parseNumericBlock()
                isFinished = result.isFinished()
            }

            var positionChanged: Bool = initialPosition != current.getPosition()
            if (!positionChanged && !isFinished) {
                break
            }
        } while (!isFinished)

        return result.getDecodedInformation();
    }

    private func parseNumericBlock(): BlockParsedResult {
        while (isStillNumeric(current.getPosition())) {
            var numeric: DecodedNumeric = decodeNumeric(current.getPosition());
            current.setPosition(numeric.getNewPosition());

            if (numeric.isFirstDigitFNC1()) {
                var information: DecodedInformation
                if (numeric.isSecondDigitFNC1()) {
                    information = DecodedInformation(current.getPosition(), String(buffer))
                } else {
                    information = DecodedInformation(current.getPosition(), String(buffer), numeric.getSecondDigit())
                }
                return BlockParsedResult(information, true);
            }
            buffer.appendAll(numeric.getFirstDigit().toString().toRuneArray());

            if (numeric.isSecondDigitFNC1()) {
                var information: DecodedInformation = DecodedInformation(current.getPosition(), String(buffer));
                return BlockParsedResult(information, true);
            }
            buffer.appendAll(numeric.getSecondDigit().toString().toRuneArray());
        }

        if (isNumericToAlphaNumericLatch(current.getPosition())) {
            current.setAlpha();
            current.incrementPosition(4);
        }
        return BlockParsedResult();
    }

    private func parseIsoIec646Block(): BlockParsedResult {
        while (isStillIsoIec646(current.getPosition())) {
            var iso: DecodedChar = decodeIsoIec646(current.getPosition());
            current.setPosition(iso.getNewPosition());

            if (iso.isFNC1()) {
                var information: DecodedInformation = DecodedInformation(current.getPosition(), String(buffer));
                return BlockParsedResult(information, true);
            }
            buffer.append(iso.getValue());
        }

        if (isAlphaOr646ToNumericLatch(current.getPosition())) {
            current.incrementPosition(3);
            current.setNumeric();
        } else if (isAlphaTo646ToAlphaLatch(current.getPosition())) {
            if (current.getPosition() + 5 < this.information.getSize()) {
                current.incrementPosition(5);
            } else {
                current.setPosition(this.information.getSize());
            }

            current.setAlpha();
        }
        return BlockParsedResult();
    }

    private func parseAlphaBlock(): BlockParsedResult {
        while (isStillAlpha(current.getPosition())) {
            var alpha: DecodedChar = decodeAlphanumeric(current.getPosition());
            current.setPosition(alpha.getNewPosition());

            if (alpha.isFNC1()) {
                var information: DecodedInformation = DecodedInformation(current.getPosition(), String(buffer));
                return BlockParsedResult(information, true);
                //end of the char block
            }

            buffer.append(alpha.getValue());
        }

        if (isAlphaOr646ToNumericLatch(current.getPosition())) {
            current.incrementPosition(3);
            current.setNumeric();
        } else if (isAlphaTo646ToAlphaLatch(current.getPosition())) {
            if (current.getPosition() + 5 < this.information.getSize()) {
                current.incrementPosition(5);
            } else {
                current.setPosition(this.information.getSize());
            }

            current.setIsoIec646();
        }
        return BlockParsedResult();
    }

    private func isStillIsoIec646(pos: Int64): Bool {
        if (pos + 5 > this.information.getSize()) {
            return false;
        }

        var fiveBitValue: Int64 = extractNumericValueFromBitArray(pos, 5);
        if (fiveBitValue >= 5 && fiveBitValue < 16) {
            return true;
        }

        if (pos + 7 > this.information.getSize()) {
            return false;
        }

        var sevenBitValue: Int64 = extractNumericValueFromBitArray(pos, 7);
        if (sevenBitValue >= 64 && sevenBitValue < 116) {
            return true;
        }

        if (pos + 8 > this.information.getSize()) {
            return false;
        }

        var eightBitValue: Int64 = extractNumericValueFromBitArray(pos, 8);
        return eightBitValue >= 232 && eightBitValue < 253
    }

    private func decodeIsoIec646(pos: Int64): DecodedChar {
        var fiveBitValue: Int64 = extractNumericValueFromBitArray(pos, 5);
        if (fiveBitValue == 15) {
            return DecodedChar(pos + 5, DecodedChar.FNC1);
        }

        if (fiveBitValue >= 5 && fiveBitValue < 15) {
            return DecodedChar(pos + 5, Char('0'.hashCode() + fiveBitValue - 5));
        }

        var sevenBitValue: Int64 = extractNumericValueFromBitArray(pos, 7);

        if (sevenBitValue >= 64 && sevenBitValue < 90) {
            return DecodedChar(pos + 7, Char(sevenBitValue + 1));
        }

        if (sevenBitValue >= 90 && sevenBitValue < 116) {
            return DecodedChar(pos + 7, Char(sevenBitValue + 7));
        }

        var eightBitValue: Int64 = extractNumericValueFromBitArray(pos, 8);
        var c: Char = ' ';
        match (eightBitValue) {
            case 232 => c = '!'
            case 233 => c = '"'
            case 234 => c = '%'
            case 235 => c = '&'
            case 236 => c = '\''
            case 237 => c = '('
            case 238 => c = ')'
            case 239 => c = '*'
            case 240 => c = '+'
            case 241 => c = ','
            case 242 => c = '-'
            case 243 => c = '.'
            case 244 => c = '/'
            case 245 => c = ':'
            case 246 => c = ';'
            case 247 => c = '<'
            case 248 => c = '='
            case 249 => c = '>'
            case 250 => c = '?'
            case 251 => c = '_'
            case 252 => c = ' '
            case _ => throw FormatException.getFormatInstance();
        }
        return DecodedChar(pos + 8, c);
    }

    private func isStillAlpha(pos: Int64): Bool {
        if (pos + 5 > this.information.getSize()) {
            return false;
        }

        // We now check if it's a valid 5-bit value (0..9 and FNC1)
        var fiveBitValue: Int64 = extractNumericValueFromBitArray(pos, 5);
        if (fiveBitValue >= 5 && fiveBitValue < 16) {
            return true;
        }

        if (pos + 6 > this.information.getSize()) {
            return false;
        }

        var sixBitValue: Int64 = extractNumericValueFromBitArray(pos, 6);
        return sixBitValue >= 16 && sixBitValue < 63
        // 63 not included
    }

    private func decodeAlphanumeric(pos: Int64): DecodedChar {
        var fiveBitValue: Int64 = extractNumericValueFromBitArray(pos, 5);
        if (fiveBitValue == 15) {
            return DecodedChar(pos + 5, DecodedChar.FNC1);
        }

        if (fiveBitValue >= 5 && fiveBitValue < 15) {
            return DecodedChar(pos + 5, Char('0'.hashCode() + fiveBitValue - 5));
        }

        var sixBitValue: Int64 = extractNumericValueFromBitArray(pos, 6);

        if (sixBitValue >= 32 && sixBitValue < 58) {
            return DecodedChar(pos + 6, Char(sixBitValue + 33));
        }

        var c: Char = ' ';
        match (sixBitValue) {
            case 58 => c = '*'
            case 59 => c = ','
            case 60 => c = '-'
            case 61 => c = '.'
            case 62 => c = '/'
            case _ => throw Exception("Decoding invalid alphanumeric value: ${sixBitValue}");
        }
        return DecodedChar(pos + 6, c);
    }

    private func isAlphaTo646ToAlphaLatch(pos: Int64): Bool {
        if (pos + 1 > this.information.getSize()) {
            return false;
        }

        var i = 0;
        while (i < 5 && i + pos < this.information.getSize()) {
            if (i == 2) {
                if (!this.information.get(pos + 2)) {
                    return false;
                }
            } else if (this.information.get(pos + i)) {
                return false;
            }
            i++;
        }

        return true;
    }

    private func isAlphaOr646ToNumericLatch(pos: Int64): Bool {
        // Next is alphanumeric if there are 3 positions and they are all zeros
        if (pos + 3 > this.information.getSize()) {
            return false;
        }

        for (i in pos..pos + 3) {
            if (this.information.get(i)) {
                return false;
            }
        }
        return true;
    }

    private func isNumericToAlphaNumericLatch(pos: Int64): Bool {
        // Next is alphanumeric if there are 4 positions and they are all zeros, or
        // if there is a subset of this just before the end of the symbol
        if (pos + 1 > this.information.getSize()) {
            return false;
        }

        var i = 0;
        while (i < 4 && i + pos < this.information.getSize()) {
            if (this.information.get(pos + i)) {
                return false;
            }
            i++
        }
        return true;
    }
}
