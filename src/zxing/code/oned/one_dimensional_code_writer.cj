/*
 * Copyright 2011 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

from std import regex.*

/**
 * <p>Encapsulates functionality and implementation that is common to one-dimensional barcodes.</p>
 *
 * @author dsbnatut@gmail.com (Kazuki Nishiura)
 */
public abstract class OneDimensionalCodeWriter <: Writer {
    private static let NUMERIC: Regex = Regex("[0-9]+")

    /**
     * Encode the contents to boolean array expression of one-dimensional barcode.
     * Start code and end code should be included in result, and side margins should not be included.
     *
     * @param contents barcode contents to encode
     * @return a {@code boolean[]} of horizontal pixels (false = white, true = black)
     */
    public func encode(contents: String): Array<Bool>

    /**
     * Can be overwritten if the encode requires to read the hints map. Otherwise it defaults to {@code encode}.
     * @param contents barcode contents to encode
     * @param hints encoding hints
     * @return a {@code boolean[]} of horizontal pixels (false = white, true = black)
     */
    public open func encode(contents: String, hints: HashMap<EncodeHintType, Any>): Array<Bool> {
        return encode(contents)
    }

    public open func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix {
        return encode(contents, format, width, height, HashMap<EncodeHintType, Any>())
    }

    /**
     * Encode the contents following specified format.
     * {@code width} and {@code height} are required size. This method may return bigger size
     * {@code BitMatrix} when specified size is too small. The user can set both {@code width} and
     * {@code height} to zero to get minimum size barcode. If negative value is set to {@code width}
     * or {@code height}, {@code IllegalArgumentException} is thrown.
     */
    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix {
        if (contents.isEmpty()) {
            throw IllegalArgumentException("Found empty contents")
        }

        if (width < 0 || height < 0) {
            throw IllegalArgumentException("Negative size is not allowed. Input: ${width} x ${ height}")
        }
        var supportedFormats: ArrayList<BarcodeFormat> = getSupportedWriteFormats()
        var flag_fand: Bool = false
        for (i in 0..supportedFormats.size) {
            if (supportedFormats[i] == format) {
                flag_fand = true
            }
        }
        if (supportedFormats.size != 0 && !flag_fand) {
            throw IllegalArgumentException(
                "Can only encode AZTEC,CODABAR,CODE_39,CODE_93,CODE_128,DATA_MATRIX,EAN_8,EAN_13,ITF,MAXICODE,PDF_417,QR_CODE,RSS_14,RSS_EXPANDED,UPC_A,UPC_E,UPC_EAN_EXTENSION, but got ${format.toString()}"
            )
        }
        var sidesMargin: Int64 = getDefaultMargin()
        if (hints.size != 0 && hints.contains(EncodeHintType.MARGIN)) {
            let data = hints.get(EncodeHintType.MARGIN) as String
            sidesMargin = Int64.parse(data.getOrThrow())
        }

        var code: Array<Bool> = encode(contents, hints)
        return renderResult(code, width, height, sidesMargin)
    }

    protected open func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        return ArrayList<BarcodeFormat>()
    }

    /**
     * @return a byte array of horizontal pixels (0 = white, 1 = black)
     */
    private static func renderResult(code: Array<Bool>, width: Int64, height: Int64, sidesMargin: Int64): BitMatrix {
        var inputWidth: Int64 = code.size

        // Add quiet zone on both sides.
        var fullWidth: Int64 = inputWidth + sidesMargin
        var outputWidth: Int64 = max(width, fullWidth)
        var outputHeight: Int64 = max(1, height)

        var multiple: Int64 = outputWidth / fullWidth
        var leftPadding: Int64 = (outputWidth - (inputWidth * multiple)) / 2

        var output: BitMatrix = BitMatrix(outputWidth, outputHeight)
        var inputX: Int64 = 0
        var outputX: Int64 = leftPadding
        while (inputX < inputWidth) {
            if (code[inputX]) {
                output.setRegion(outputX, 0, multiple, outputHeight)
            }
            inputX++
            outputX += multiple
        }
        return output
    }

    /**
     * @param contents string to check for numeric characters
     * @throws IllegalArgumentException if input contains characters other than digits 0-9.
     */
    protected static func checkNumeric(contents: String) {
        let matchData = NUMERIC.matcher(contents).fullMatch()
        if (let None <- matchData) {
            throw IllegalArgumentException("Input should only contain digits 0-9")
        }
    }

    /**
     * @param target encode black/white pattern into this array
     * @param pos position to start encoding at in {@code target}
     * @param pattern lengths of black/white runs to encode
     * @param startColor starting color - false for white, true for black
     * @return the number of elements added to target.
     */
    protected static func appendPattern(target: Array<Bool>, posin: Int64, pattern: Array<Int64>, startColor: Bool): Int64 {
        var pos: Int64 = posin
        var color: Bool = startColor
        var numAdded: Int64 = 0
        for (i in 0..pattern.size) {
            for (j in 0..pattern[i]) {
                target[pos] = color
                pos++
            }
            numAdded += pattern[i]
            color = !color
            // flip color after each segment
        }
        return numAdded
    }

    public open func getDefaultMargin(): Int64 {
        // CodaBar spec requires a side margin to be more than ten times wider than narrow space.
        // This seems like a decent idea for a default for all formats.
        return 10
    }
}
