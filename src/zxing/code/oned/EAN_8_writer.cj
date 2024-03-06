/*
 * Copyright 2009 ZXing authors
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

/**
 * This object renders an EAN8 code as a {@link BitMatrix}.
 *
 * @author aripollak@gmail.com (Ari Pollak)
 */
public open class EAN8Writer <: UPCEANWriter {
    private static let CODE_WIDTH: Int64 = 3 + // start guard
        (7 * 4) + // left bars
        5 + // middle guard
    (7 * 4) + // right bars
    3

    // end guard
    protected override func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        var returnData: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        returnData.append(BarcodeFormat.EAN_8)
        return returnData
    }

    /**
     * @return a byte array of horizontal pixels (false = white, true = black)
     */
    public override func encode(contentsin: String): Array<Bool> {
        var contents: UTF32String = UTF32String(contentsin)
        var length: Int64 = contents.charSize

        match (length) {
            case 7 =>
                // No check digit present, calculate it and add it
                var check: Int64
                try {
                    check = UPCEANReader.getStandardUPCEANChecksum(contents)
                } catch (fe: FormatException) {
                    throw IllegalArgumentException(fe.toString());
                }
                contents = contents + UTF32String(check.toString())

            case 8 => try {
                if (!UPCEANReader.checkStandardUPCEANChecksum(contents)) {
                    throw IllegalArgumentException("Contents do not pass checksum");
                }
            } catch (ignored: FormatException) {
                throw IllegalArgumentException("Illegal contents");
            }
            case _ => throw IllegalArgumentException(
                "Requested contents should be 7 or 8 digits long, but got ${length}");
        }

        checkNumeric(contents.toString());

        var result: Array<Bool> = Array<Bool>(CODE_WIDTH, item: false)
        var pos: Int64 = 0;

        pos += appendPattern(result, pos, UPCEANReader.START_END_PATTERN, true)

        for (i in 0..4) {
            var digit: Int64 = -1
            if (contents[i].isAsciiNumber()) {
                digit = contents.get(i).hashCode() - 48
            }
            pos += appendPattern(result, pos, UPCEANReader.L_PATTERNS[digit], false)
        }

        pos += appendPattern(result, pos, UPCEANReader.MIDDLE_PATTERN, false)

        for (i in 4..8) {
            // var digit: Int64 = Character.digit(contents.get(i).getOrThrow(), 10);
            var digit: Int64 = -1
            if (contents[i].isAsciiNumber()) {
                digit = contents.get(i).hashCode() - 48
            }
            pos += appendPattern(result, pos, UPCEANReader.L_PATTERNS[digit], true)
        }
        appendPattern(result, pos, UPCEANReader.START_END_PATTERN, true);

        return result
    }
}
