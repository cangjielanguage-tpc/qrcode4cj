/*
 * Copyright 2011 ZXing authors
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

package zxing.code.oned

from charset import charset.tools.UTF32String

/**
 * This class renders CodaBar as {@code boolean[]}.
 *
 * @author dsbnatut@gmail.com (Kazuki Nishiura)
 */
public open class CodaBarWriter <: OneDimensionalCodeWriter {
    private static let START_END_CHARS: Array<Char> = ['A', 'B', 'C', 'D']
    private static let ALT_START_END_CHARS: Array<Char> = ['T', 'N', '*', 'E']
    private static let CHARS_WHICH_ARE_TEN_LENGTH_EACH_AFTER_DECODED: Array<Char> = ['/', ':', '+', '.']
    private static let DEFAULT_GUARD: Char = START_END_CHARS[0]

    protected override func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        var returnData: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        returnData.append(BarcodeFormat.CODABAR)
        return returnData
    }

    public override func encode(contentsin: String): Array<Bool> {
        var contents: UTF32String = UTF32String(contentsin)
        contents = exencode(contents, contentsin)

        // The start character and the end character are decoded to 10 length each.
        var resultLength: Int64 = 20;
        for (i in 1..contents.charSize - 1) {
            if (contents.get(i).isAsciiNumber() || contents.get(i) == '-' || contents.get(i) == '$') {
                resultLength += 9
            } else if (CodaBarReader.arrayContains(CHARS_WHICH_ARE_TEN_LENGTH_EACH_AFTER_DECODED, contents.get(i))) {
                resultLength += 10
            } else {
                throw IllegalArgumentException("Cannot encode : '" + contents.get(i).toString() + '\''.toString())
            }
        }

        // A blank is placed between each character.
        resultLength += contents.charSize - 1

        var result: Array<Bool> = Array<Bool>(resultLength, item: false)
        var position: Int64 = 0;
        for (index in 0..contents.charSize) {
            var c: Char = contents.get(index).toAsciiUpperCase();
            if (index == 0 || index == contents.charSize - 1) {
                // The start/end chars are not in the CodaBarReader.ALPHABET_STRING.
                c = exencode2(c, contents, index)
            }
            var code: Int64 = 0;

            for (i in 0..CodaBarReader.ALPHABET_STRING.size) {
                // Found any, because I checked above.
                if (c == CodaBarReader.ALPHABET_STRING[i]) {
                    code = CodaBarReader.CHARACTER_ENCODINGS[i]
                    break
                }
            }
            var color: Bool = true;
            var counter: Int64 = 0;
            var bit: Int64 = 0;
            while (bit < 7) { // A character consists of 7 digit.
                result[position] = color
                position++
                if (((code >> (6 - bit)) & 1) == 0 || counter == 1) {
                    color = !color

                    // Flip the color.
                    bit++
                    counter = 0
                } else {
                    counter++
                }
            }
            if (index < contents.charSize - 1) {
                result[position] = false
                position++
            }
        }

        return result
    }

    private func exencode2(c: Char, contents: UTF32String, index: Int64): Char {
        match (c) {
            case 'T' => return 'A'
            case 'N' => return 'B'
            case '*' => return 'C'
            case 'E' => return 'D'
            case _ => return contents.get(index).toAsciiUpperCase()
        }
    }

    private func exencode(contents: UTF32String, contentsin: String): UTF32String {
        var contents_p = contents
        if (contents_p.charSize < 2) {
            // Can't have a start/end guard, so tentatively add default guards
            contents_p = UTF32String(DEFAULT_GUARD.toString() + contentsin + DEFAULT_GUARD.toString())
        } else {
            // Verify input and calculate decoded length.
            var firstChar: Char = contents_p.get(0).toAsciiUpperCase();
            var lastChar: Char = contents_p.get(contents_p.charSize - 1).toAsciiUpperCase();
            var startsNormal: Bool = CodaBarReader.arrayContains(START_END_CHARS, firstChar);
            var endsNormal: Bool = CodaBarReader.arrayContains(START_END_CHARS, lastChar);
            var startsAlt: Bool = CodaBarReader.arrayContains(ALT_START_END_CHARS, firstChar);
            var endsAlt: Bool = CodaBarReader.arrayContains(ALT_START_END_CHARS, lastChar);
            if (startsNormal) {
                if (!endsNormal) {
                    throw IllegalArgumentException("Invalid start/end guards: " + contents_p.toString());
                }
            // else already has valid start/end
            } else if (startsAlt) {
                if (!endsAlt) {
                    throw IllegalArgumentException("Invalid start/end guards: " + contents_p.toString());
                }
            // else already has valid start/end
            } else {
                // Doesn't start with a guard
                if (endsNormal || endsAlt) {
                    throw IllegalArgumentException("Invalid start/end guards: " + contents_p.toString());
                }

                // else doesn't end with guard either, so add a default
                contents_p = UTF32String(DEFAULT_GUARD.toString() + contents_p.toString() + DEFAULT_GUARD.toString())
            }
        }
        return contents_p
    }
}
