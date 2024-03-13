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

package zxing.code.datamatrix

from std import convert.*
import zxing.code.common.BarcodeFormat
import zxing.code.common.EncodeHintType
import zxing.code.common.Writer
import zxing.code.common.BitMatrix
import zxing.code.common.MyCharset
import zxing.code.datamatrix.encoder.DefaultPlacement
import zxing.code.common.Dimension
import zxing.code.datamatrix.encoder.ErrorCorrection
import zxing.code.datamatrix.encoder.HighLevelEncoder
import zxing.code.datamatrix.encoder.MinimalEncoder
import zxing.code.datamatrix.encoder.SymbolInfo
import zxing.code.datamatrix.encoder.SymbolShapeHint
import zxing.code.qrcode.encoder.ByteMatrix
from charset import charset.tools.UTF32String
from std import collection.*
from std import math.*

/**
 * This object renders a Data Matrix code as a BitMatrix 2D array of greyscale values.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Guillaume Le Biller Added to zxing lib.
 */
public class DataMatrixWriter <: Writer {
    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix {
        return encode(contents, format, width, height, HashMap<EncodeHintType, Any>());
    }

    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64,
        hints: HashMap<EncodeHintType, Any>): BitMatrix {
        if (contents.isEmpty()) {
            throw IllegalArgumentException("Found empty contents");
        }

        if (format != BarcodeFormat.DATA_MATRIX) {
            throw IllegalArgumentException("Can only encode DATA_MATRIX, but got " + format.toString());
        }

        if (width < 0 || height < 0) {
            throw IllegalArgumentException(
                "Requested dimensions can't be negative: " + width.toString() + "x" + height.toString());
        }

        // Try to get force shape & min / max size
        var shape: SymbolShapeHint = SymbolShapeHint.FORCE_NONE;
        var minSize: ?Dimension = None
        var maxSize: ?Dimension = None
        if (hints.size != 0) {
            (shape, minSize, maxSize) = exencode(shape, minSize, maxSize, hints)
        }

        //1. step: Data encodation
        var encoded: UTF32String

        let hasCompactionHint = hints.size != 0 && hints.contains(EncodeHintType.DATA_MATRIX_COMPACT) && Bool.parse(
            EncodeHintType.getHashMapValue(EncodeHintType.DATA_MATRIX_COMPACT, hints[EncodeHintType.DATA_MATRIX_COMPACT]
        ))
        if (hasCompactionHint) {
            let hasGS1FormatHint = hints.contains(EncodeHintType.GS1_FORMAT) && Bool.parse(
                EncodeHintType.getHashMapValue(EncodeHintType.GS1_FORMAT, hints[EncodeHintType.GS1_FORMAT]))

            var charset: MyCharset
            var hasEncodingHint: Bool = hints.contains(EncodeHintType.CHARACTER_SET);
            if (hasEncodingHint) {
                charset = MyCharset.forName(
                    EncodeHintType.getHashMapValue(EncodeHintType.CHARACTER_SET, hints[EncodeHintType.CHARACTER_SET]))
            } else {
                charset = MyCharset()
            }
            encoded = MinimalEncoder.encodeHighLevel(UTF32String(contents), charset,
                if (hasGS1FormatHint) {
                0x1D
            } else {
                -1
            }, shape)
        } else {
            let hasForceC40Hint = hints.size != 0 && hints.contains(EncodeHintType.FORCE_C40) && Bool.parse(
                EncodeHintType.getHashMapValue(EncodeHintType.FORCE_C40, hints[EncodeHintType.FORCE_C40]))
            encoded = HighLevelEncoder.encodeHighLevel(UTF32String(contents), shape, minSize, maxSize, hasForceC40Hint)
        }

        var symbolInfo: ?SymbolInfo = SymbolInfo.lookup(encoded.charSize, shape, minSize, maxSize, true);

        //2. step: ECC generation
        var codewords: String = ErrorCorrection.encodeECC200(encoded, symbolInfo.getOrThrow());

        //3. step: Module placement in Matrix
        let placement = DefaultPlacement(codewords, symbolInfo.getOrThrow().getSymbolDataWidth(),
            symbolInfo.getOrThrow().getSymbolDataHeight());
        placement.place();

        //4. step: low-level encoding
        var a = encodeLowLevel(placement, symbolInfo.getOrThrow(), width, height);

        return a
    }

    private func exencode(shape: SymbolShapeHint, minSize: ?Dimension, maxSize: ?Dimension,
        hints: HashMap<EncodeHintType, Any>): (SymbolShapeHint, ?Dimension, ?Dimension) {
        var shape_p = shape
        var minSize_p = minSize
        var maxSize_p = maxSize
        if (hints.contains(EncodeHintType.DATA_MATRIX_SHAPE)) {
            var requestedShape: ?SymbolShapeHint = hints.get(EncodeHintType.DATA_MATRIX_SHAPE).getOrThrow() as SymbolShapeHint
            if (let Some(t) <- requestedShape) {
                shape_p = t
            }
        }

        if (hints.contains(EncodeHintType.MIN_SIZE)) {
            var requestedMinSize: ?Dimension = hints.get(EncodeHintType.MIN_SIZE).getOrThrow() as Dimension
            if (let Some(t) <- requestedMinSize) {
                minSize_p = t
            }
        }

        if (hints.contains(EncodeHintType.MAX_SIZE)) {
            var requestedMaxSize: ?Dimension = hints.get(EncodeHintType.MAX_SIZE).getOrThrow() as Dimension
            if (let Some(t) <- requestedMaxSize) {
                maxSize_p = t
            }
        }
        return (shape_p, minSize_p, maxSize_p)
    }

    /**
     * Encode the given symbol info to a bit matrix.
     *
     * @param placement  The DataMatrix placement.
     * @param symbolInfo The symbol info to encode.
     * @return The bit matrix generated.
     */
    private static func encodeLowLevel(placement: DefaultPlacement, symbolInfo: SymbolInfo, width: Int64, height: Int64): BitMatrix {
        var symbolWidth: Int64 = symbolInfo.getSymbolDataWidth();
        var symbolHeight: Int64 = symbolInfo.getSymbolDataHeight();

        var matrix: ByteMatrix = ByteMatrix(symbolInfo.getSymbolWidth(), symbolInfo.getSymbolHeight());

        var matrixY: Int64 = 0;

        for (y in 0..symbolHeight) {
            // Fill the top edge with alternate 0 / 1
            var matrixX: Int64
            if ((y % symbolInfo.matrixHeight) == 0) {
                matrixX = 0
                for (x in 0..symbolInfo.getSymbolWidth()) {
                    matrix.set(matrixX, matrixY, (x % 2) == 0);
                    matrixX++
                }
                matrixY++
            }
            matrixX = 0

            for (x in 0..symbolWidth) {
                // Fill the right edge with full 1
                if ((x % symbolInfo.matrixWidth) == 0) {
                    matrix.set(matrixX, matrixY, true);
                    matrixX++
                }
                matrix.set(matrixX, matrixY, placement.getBit(x, y));
                matrixX++

                // Fill the right edge with alternate 0 / 1
                if ((x % symbolInfo.matrixWidth) == symbolInfo.matrixWidth - 1) {
                    matrix.set(matrixX, matrixY, (y % 2) == 0);
                    matrixX++
                }
            }
            matrixY++

            // Fill the bottom edge with full 1
            if ((y % symbolInfo.matrixHeight) == symbolInfo.matrixHeight - 1) {
                matrixX = 0
                for (x in 0..symbolInfo.getSymbolWidth()) {
                    matrix.set(matrixX, matrixY, true);
                    matrixX++
                }
                matrixY++
            }
        }

        return convertByteMatrixToBitMatrix(matrix, width, height);
    }

    /**
     * Convert the ByteMatrix to BitMatrix.
     *
     * @param reqHeight The requested height of the image (in pixels) with the Datamatrix code
     * @param reqWidth The requested width of the image (in pixels) with the Datamatrix code
     * @param matrix The input matrix.
     * @return The output matrix.
     */
    private static func convertByteMatrixToBitMatrix(matrix: ByteMatrix, reqWidth: Int64, reqHeight: Int64): BitMatrix {
        let matrixWidth: Int64 = matrix.getWidth();
        let matrixHeight: Int64 = matrix.getHeight();
        let outputWidth: Int64 = max(reqWidth, matrixWidth);
        let outputHeight: Int64 = max(reqHeight, matrixHeight);

        let multiple = min(outputWidth / matrixWidth, outputHeight / matrixHeight);

        var leftPadding = (outputWidth - (matrixWidth * multiple)) / 2
        var topPadding = (outputHeight - (matrixHeight * multiple)) / 2

        var output: BitMatrix

        // remove padding if requested width and height are too small
        if (reqHeight < matrixHeight || reqWidth < matrixWidth) {
            leftPadding = 0
            topPadding = 0
            output = BitMatrix(matrixWidth, matrixHeight)
        } else {
            output = BitMatrix(reqWidth, reqHeight)
        }

        output.clear();
        var inputY = 0;
        var outputY = topPadding
        while (inputY < matrixHeight) {
            // Write the contents of this row of the bytematrix
            var inputX = 0;
            var outputX = leftPadding
            while (inputX < matrixWidth) {
                if (matrix.get(inputX, inputY) == 1) {
                    output.setRegion(outputX, outputY, multiple, multiple);
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
