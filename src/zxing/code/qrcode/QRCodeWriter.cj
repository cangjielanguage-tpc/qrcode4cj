/*
 * Copyright 2008 ZXing authors
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

package zxing.code.qrcode

from std import convert.*
import zxing.code.common.BarcodeFormat
import zxing.code.common.EncodeHintType
import zxing.code.common.Writer
import zxing.code.common.WriterException
import zxing.code.common.BitMatrix
import zxing.code.common.DecodeHintType
import zxing.code.qrcode.encoder.ByteMatrix
import zxing.code.qrcode.decoder.ErrorCorrectionLevel
import zxing.code.qrcode.encoder.Encoder
import zxing.code.qrcode.encoder.QRCode
from std import collection.*
from std import math.*

/**
 * This object renders a QR Code as a BitMatrix 2D array of greyscale values.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public class QRCodeWriter <: Writer {
    private static var QUIET_ZONE_SIZE: Int64 = 4;

    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix {
        return encode(contents, format, width, height, HashMap<EncodeHintType, Any>());
    }

    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix {
        if (contents.isEmpty()) {
            throw IllegalArgumentException("Found empty contents");
        }

        if (format != BarcodeFormat.QR_CODE) {
            throw IllegalArgumentException("Can only encode QR_CODE, but got " + format.toString());
        }

        if (width < 0 || height < 0) {
            throw IllegalArgumentException(
                "Requested dimensions are too small: " + width.toString() + "x" + height.toString());
        }

        var errorCorrectionLevel: ErrorCorrectionLevel = ErrorCorrectionLevel.L(0x01);
        var quietZone: Int64 = QUIET_ZONE_SIZE
        if (hints.size != 0) {
            if (hints.contains(EncodeHintType.ERROR_CORRECTION)) {
                errorCorrectionLevel = ErrorCorrectionLevel.valueOf(
                    if (hints[EncodeHintType.ERROR_CORRECTION] is Int64) {
                        (hints[EncodeHintType.ERROR_CORRECTION] as Int64).getOrThrow().toString()
                    } else if (hints[EncodeHintType.ERROR_CORRECTION] is String) {
                        (hints[EncodeHintType.ERROR_CORRECTION] as String).getOrThrow()
                    } else {
                        (hints[EncodeHintType.ERROR_CORRECTION] as ErrorCorrectionLevel).getOrThrow().toString()
                    }
                )
            }
            if (hints.contains(EncodeHintType.MARGIN)) {
                quietZone = Int64.parse(
                    EncodeHintType.getHashMapValue(EncodeHintType.MARGIN, hints[EncodeHintType.MARGIN]))
            }
        }

        let code: QRCode = Encoder.encode(contents, errorCorrectionLevel, hints);
        return renderResult(code, width, height, quietZone);
    }

    // Note that the input matrix uses 0 == white, 1 == black, while the output matrix uses
    // 0 == black, 255 == white (i.e. an 8 bit greyscale bitmap).
    private static func renderResult(code: QRCode, width: Int64, height: Int64, quietZone: Int64): BitMatrix {
        let input: ByteMatrix = code.getMatrix();

        let inputWidth: Int64 = input.getWidth();
        let inputHeight: Int64 = input.getHeight();
        let qrWidth: Int64 = inputWidth + (quietZone * 2)
        let qrHeight: Int64 = inputHeight + (quietZone * 2)
        let outputWidth: Int64 = max(width, qrWidth);
        let outputHeight: Int64 = max(height, qrHeight);

        let multiple: Int64 = min(outputWidth / qrWidth, outputHeight / qrHeight);

        // Padding includes both the quiet zone and the extra white pixels to accommodate the requested
        // dimensions. For example, if input is 25x25 the QR will be 33x33 including the quiet zone.
        // If the requested size is 200x160, the multiple will be 4, for a QR of 132x132. These will
        // handle all the padding from 100x100 (the actual QR) up to 200x160.
        let leftPadding: Int64 = (outputWidth - (inputWidth * multiple)) / 2
        let topPadding: Int64 = (outputHeight - (inputHeight * multiple)) / 2

        let output: BitMatrix = BitMatrix(outputWidth, outputHeight);

        var outputY: Int64 = topPadding
        for (inputY in 0..inputHeight) {
            // Write the contents of this row of the barcode
            var outputX: Int64 = leftPadding
            for (inputX in 0..inputWidth) {
                if (input.get(inputX, inputY) == 1) {
                    output.setRegion(outputX, outputY, multiple, multiple);
                }

                outputX += multiple
            }

            outputY += multiple
        }

        return output
    }
}
