/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.pdf417

from std import convert.*
import zxing.code.common.EncodeHintType
import zxing.code.common.Writer
import zxing.code.common.Qrcoder4cjWriterException
import zxing.code.common.BitMatrix
import zxing.code.common.MyCharset
import zxing.code.pdf417.encoder.Compaction
import zxing.code.pdf417.encoder.Dimensions
import zxing.code.pdf417.encoder.PDF417
import zxing.code.qrcode.decoder.ErrorCorrectionLevel
import zxing.code.tools.UTF32String

public open class PDF417Writer <: Writer {
    /**
     * default white space (margin) around the code
     */
    private static let WHITE_SPACE: Int64 = 30

    /**
     * default error correction level
     */
    private static let DEFAULT_ERROR_CORRECTION_LEVEL: Int64 = 2

    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64,
        hints: HashMap<EncodeHintType, Any>): BitMatrix {
        if (format != BarcodeFormat.PDF_417) {
            throw IllegalArgumentException("Can only encode PDF_417, but got " + format.toString());
        }

        var encoder: PDF417 = PDF417()
        var margin: Int64 = WHITE_SPACE
        var errorCorrectionLevel: Int64 = DEFAULT_ERROR_CORRECTION_LEVEL
        var autoECI: Bool = false

        if (hints.size != 0) {
            if (hints.contains(EncodeHintType.PDF417_COMPACT)) {
                encoder.setCompact(
                    Bool.parse(
                    EncodeHintType.getHashMapValue(EncodeHintType.PDF417_COMPACT, hints[EncodeHintType.PDF417_COMPACT]))
                );
            }
            if (hints.contains(EncodeHintType.PDF417_COMPACTION)) {
                exencode(hints, encoder)
            }
            if (hints.contains(EncodeHintType.PDF417_DIMENSIONS)) {
                var dimensions: Dimensions = (hints[EncodeHintType.PDF417_DIMENSIONS] as Dimensions).getOrThrow();
                encoder.setDimensions(dimensions.getMaxCols(), dimensions.getMinCols(), dimensions.getMaxRows(),
                    dimensions.getMinRows());
            }
            if (hints.contains(EncodeHintType.MARGIN)) {
                margin = Int64.parse(EncodeHintType.getHashMapValue(EncodeHintType.MARGIN, hints[EncodeHintType.MARGIN])
                )
            }
            if (hints.contains(EncodeHintType.ERROR_CORRECTION)) {
                errorCorrectionLevel = Int64.parse(
                    if (hints[EncodeHintType.ERROR_CORRECTION] is Int64) {
                    (hints[EncodeHintType.ERROR_CORRECTION] as Int64).getOrThrow().toString()
                } else if (hints[EncodeHintType.ERROR_CORRECTION] is String) {
                    (hints[EncodeHintType.ERROR_CORRECTION] as String).getOrThrow()
                } else {
                    (hints[EncodeHintType.ERROR_CORRECTION] as ErrorCorrectionLevel).getOrThrow().toString()
                })
            }
            if (hints.contains(EncodeHintType.CHARACTER_SET)) {
                var encoding: MyCharset = MyCharset.forName(
                    EncodeHintType.getHashMapValue(EncodeHintType.CHARACTER_SET, hints[EncodeHintType.CHARACTER_SET]));
                encoder.setEncoding(encoding);
            }
            autoECI = hints.contains(EncodeHintType.PDF417_AUTO_ECI) && Bool.parse(
                EncodeHintType.getHashMapValue(EncodeHintType.PDF417_AUTO_ECI, hints[EncodeHintType.PDF417_AUTO_ECI]))
        }

        return bitMatrixFromEncoder(encoder, UTF32String(contents), errorCorrectionLevel, width, height, margin, autoECI
        );
    }

    private func exencode(hints: HashMap<EncodeHintType, Any>, encoder: PDF417) {
        let compaction = if (hints[EncodeHintType.PDF417_COMPACTION] is Compaction) {
            (hints[EncodeHintType.PDF417_COMPACTION] as Compaction).getOrThrow()
        } else {
            Compaction.valueOf((hints[EncodeHintType.PDF417_COMPACTION] as String).getOrThrow())
        }
        encoder.setCompaction(
            Compaction.valueOf(
                EncodeHintType.getHashMapValue(
                    EncodeHintType.PDF417_COMPACTION,
                    hints[EncodeHintType.PDF417_COMPACTION]
                )
            )
        );
    }

    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64
    ): BitMatrix {
        return encode(contents, format, width, height, HashMap<EncodeHintType, Any>());
    }

    /**
     * Takes encoder, accounts for width/height, and retrieves bit matrix
     */
    private static func bitMatrixFromEncoder(
        encoder: PDF417,
        contents: UTF32String,
        errorCorrectionLevel: Int64,
        width: Int64,
        height: Int64,
        margin: Int64,
        autoECI: Bool
    ): BitMatrix {
        encoder.generateBarcodeLogic(contents, errorCorrectionLevel, autoECI);

        let aspectRatio: Int64 = 4
        var originalScale: Array<Array<UInt8>> = encoder.getBarcodeMatrix().getOrThrow().getScaledMatrix(1, aspectRatio);
        var rotated: Bool = false
        if ((height > width) != (originalScale[0].size < originalScale.size)) {
            originalScale = rotateArray(originalScale)
            rotated = true
        }

        let scaleX: Int64 = width / originalScale[0].size
        let scaleY: Int64 = height / originalScale.size
        let scale: Int64 = min(scaleX, scaleY);

        if (scale > 1) {
            var scaledMatrix: Array<Array<UInt8>> = encoder.getBarcodeMatrix().getOrThrow().getScaledMatrix(
                scale,
                scale * aspectRatio
            );
            if (rotated) {
                scaledMatrix = rotateArray(scaledMatrix)
            }
            return bitMatrixFromBitArray(scaledMatrix, margin);
        }
        return bitMatrixFromBitArray(originalScale, margin);
    }

    /**
     * This takes an array holding the values of the PDF 417
     *
     * @param input a byte array of information with 0 is black, and 1 is white
     * @param margin border around the barcode
     * @return BitMatrix of the input
     */
    private static func bitMatrixFromBitArray(input: Array<Array<UInt8>>, margin: Int64): BitMatrix {
        // Creates the bit matrix with extra space for whitespace
        var output: BitMatrix = BitMatrix(input[0].size + 2 * margin, input.size + 2 * margin);
        output.clear();
        var yOutput: Int64 = output.getHeight() - margin - 1
        for (y in 0..input.size) {
            var inputY: Array<UInt8> = input[y]
            for (x in 0..input[0].size) {
                // Zero is white in the byte matrix
                if (inputY[x] == 1) {
                    output.set(x + margin, yOutput);
                }
            }
            yOutput--
        }
        return output
    }

    /**
     * Takes and rotates the it 90 degrees
     */
    private static func rotateArray(bitarray: Array<Array<UInt8>>): Array<Array<UInt8>> {
        var temp: Array<Array<UInt8>> = Array<Array<UInt8>>(
            bitarray[0].size,
            {int: Int64 => Array<UInt8>(bitarray.size, item: 0)}
        )
        let bit_size = bitarray[0].size
        for (ii in 0..bitarray.size) {
            let bit_one = bitarray[ii]
            // This makes the direction consistent on screen when rotating the
            // screen;
            let inverseii: Int64 = bitarray.size - ii - 1
            for (jj in 0..bit_size) {
                temp[jj][inverseii] = bit_one[jj]
            }
        }
        return temp
    }
}
