/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package aztec

from std import convert.*
from std import collection.*
from std import math.*
import common.BarcodeFormat
import common.EncodeHintType
import common.Writer
import aztec.encoder.AztecCode
import aztec.encoder.Encoder
import common.BitMatrix
import common.MyCharset
import qrcode.decoder.ErrorCorrectionLevel

public class AztecWriter <: Writer {
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix {
        var hints: HashMap<EncodeHintType, EncodeHintType>
        return encode(contents, format, width, height, HashMap<EncodeHintType, Any>())
    }

    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix {
        var charset: MyCharset = MyCharset();
        var eccPercent = Encoder.DEFAULT_EC_PERCENT
        var layers = Encoder.DEFAULT_AZTEC_LAYERS
        if (hints.size > 0) {
            if (hints.contains(EncodeHintType.CHARACTER_SET)) {
                var charsetName = hints[EncodeHintType.CHARACTER_SET] as String
                charset = MyCharset.forName(charsetName.getOrThrow())
            }
            if (hints.contains(EncodeHintType.ERROR_CORRECTION)) {
                eccPercent = Int64.parse(
                    if (hints[EncodeHintType.ERROR_CORRECTION] is Int64) {
                        (hints[EncodeHintType.ERROR_CORRECTION] as Int64).getOrThrow().toString()
                    } else if (hints[EncodeHintType.ERROR_CORRECTION] is String) {
                        (hints[EncodeHintType.ERROR_CORRECTION] as String).getOrThrow()
                    } else {
                        (hints[EncodeHintType.ERROR_CORRECTION] as ErrorCorrectionLevel).getOrThrow().toString()
                    }
                )
            }
            if (hints.contains(EncodeHintType.AZTEC_LAYERS)) {
                layers = Int64.parse(
                    EncodeHintType.getHashMapValue(EncodeHintType.AZTEC_LAYERS, hints[EncodeHintType.AZTEC_LAYERS]))
            }
        }
        return encode(contents, format, width, height, charset, eccPercent, layers)
    }

    private func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        charset: MyCharset,
        eccPercent: Int64,
        layers: Int64
    ): BitMatrix {
        if (format != BarcodeFormat.AZTEC) {
            throw IllegalArgumentException("Can only encode AZTEC, but got ${format}");
        }
        var aztec: AztecCode = Encoder.encode(UTF32String(contents), eccPercent, layers, charset)
        return renderResult(aztec, width, height)
    }

    private static func renderResult(code: AztecCode, width: Int64, height: Int64) {
        var input: BitMatrix = code.getMatrix()
        if (input.getWidth() == 0 || input.getHeight() == 0) {
            throw IllegalArgumentException()
        }
        var inputWidth: Int64 = input.getWidth()
        var inputHeight: Int64 = input.getHeight()
        var outputWidth: Int64 = max(width, inputWidth)
        var outputHeight: Int64 = max(height, inputHeight)

        var multiple: Int64 = min(outputWidth / inputWidth, outputHeight / inputHeight)
        var leftPadding: Int64 = (outputWidth - (inputWidth * multiple)) / 2
        var topPadding: Int64 = (outputHeight - (inputHeight * multiple)) / 2

        var output: BitMatrix = BitMatrix(outputWidth, outputHeight)

        var inputY: Int64 = 0
        var outputY: Int64 = topPadding

        while (inputY < inputHeight) {
            var inputX: Int64 = 0
            var outputX: Int64 = leftPadding
            while (inputX < inputWidth) {
                if (input.get(inputX, inputY)) {
                    output.setRegion(outputX, outputY, multiple, multiple)
                }

                inputX++
                outputX += multiple
            }
            inputY++
            outputY += multiple
        }

        return output
    }
}
