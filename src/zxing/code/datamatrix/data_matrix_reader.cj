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

package zxing.code.datamatrix

import zxing.code.common.BinaryBitmap
import zxing.code.common.ChecksumException
import zxing.code.common.DecodeHintType
import zxing.code.common.FormatException
import zxing.code.common.NotFoundException
import zxing.code.common.Reader
import zxing.code.common.Result
import zxing.code.common.ResultMetadataType
import zxing.code.common.ResultPoint
import zxing.code.common.DecoderResult
import zxing.code.common.DetectorResult
import zxing.code.datamatrix.decoder.Decoder
import zxing.code.datamatrix.detector.Detector

/**
 * This implementation can detect and decode Data Matrix codes in an image.
 *
 * @author bbrown@google.com (Brian Brown)
 */
public class DataMatrixReader <: Reader {
    private static let NO_POINTS: Array<ResultPoint> = Array<ResultPoint>();

    private let decoder: Decoder = Decoder();

    /**
     * Locates and decodes a Data Matrix code in an image.
     *
     * @return a String representing the content encoded by the Data Matrix code
     * @throws NotFoundException if a Data Matrix code cannot be found
     * @throws FormatException if a Data Matrix code cannot be decoded
     * @throws ChecksumException if error correction fails
     */
    public func decode(image: BinaryBitmap): Result {
        return decode(image, HashMap<DecodeHintType, Any>());
    }

    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        var decoderResult: DecoderResult
        var points: Array<ResultPoint>
        if (hints.size != 0 && hints.contains(DecodeHintType.PURE_BARCODE)) {
            var bits: BitMatrix = extractPureBits(image.getBlackMatrix());
            decoderResult = decoder.decode(bits)
            points = NO_POINTS
        } else {
            var detectorResult: DetectorResult = Detector(image.getBlackMatrix()).detect();
            decoderResult = decoder.decode(detectorResult.getBits())
            points = detectorResult.getPoints()
        }
        var result: Result = Result(
            decoderResult.getText(),
            decoderResult.getRawBytes(),
            points,
            BarcodeFormat.DATA_MATRIX
        );
        var byteSegments: ArrayList<Array<UInt8>> = decoderResult.getByteSegments();
        if (byteSegments.size != 0) {
            result.putMetadata(ResultMetadataType.BYTE_SEGMENTS, byteSegments);
        }
        var ecLevel: String = decoderResult.getECLevel();
        if (!ecLevel.isEmpty()) {
            result.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, ecLevel);
        }
        result.putMetadata(
            ResultMetadataType.SYMBOLOGY_IDENTIFIER,
            "]d" + decoderResult.getSymbologyModifier().toString()
        );
        return result
    }

    public func reset() {
        // do nothing
    }

    /**
     * This method detects a code in a "pure" image -- that is, pure monochrome image
     * which contains only an unrotated, unskewed, image of a code, with some white border
     * around it. This is a specialized method that works exceptionally fast in this special
     * case.
     */
    private static func extractPureBits(image: BitMatrix): BitMatrix {
        var leftTopBlack: Array<Int64> = image.getTopLeftOnBit();
        var rightBottomBlack: Array<Int64> = image.getBottomRightOnBit();
        if (leftTopBlack.size == 0 || rightBottomBlack.size == 0) {
            throw NotFoundException.getNotFoundInstance();
        }

        var moduleSize: Int64 = moduleSize(leftTopBlack, image);

        var top: Int64 = leftTopBlack[1]
        var bottom: Int64 = rightBottomBlack[1]
        var left: Int64 = leftTopBlack[0]
        var right: Int64 = rightBottomBlack[0]

        var matrixWidth: Int64 = (right - left + 1) / moduleSize
        var matrixHeight: Int64 = (bottom - top + 1) / moduleSize
        if (matrixWidth <= 0 || matrixHeight <= 0) {
            throw NotFoundException.getNotFoundInstance();
        }

        // Push in the "border" by half the module width so that we start
        // sampling in the middle of the module. Just in case the image is a
        // little off, this will help recover.
        var nudge: Int64 = moduleSize / 2
        top += nudge
        left += nudge

        // Now just read off the bits
        var bits: BitMatrix = BitMatrix(matrixWidth, matrixHeight);

        for (y in 0..matrixHeight) {
            var iOffset: Int64 = top + y * moduleSize

            for (x in 0..matrixWidth) {
                if (image.get(left + x * moduleSize, iOffset)) {
                    bits.set(x, y);
                }
            }
        }
        return bits
    }

    private static func moduleSize(leftTopBlack: Array<Int64>, image: BitMatrix): Int64 {
        var width: Int64 = image.getWidth();
        var x: Int64 = leftTopBlack[0]
        var y: Int64 = leftTopBlack[1]
        while (x < width && image.get(x, y)) {
            x++
        }
        if (x == width) {
            throw NotFoundException.getNotFoundInstance();
        }

        var moduleSize: Int64 = x - leftTopBlack[0]
        if (moduleSize == 0) {
            throw NotFoundException.getNotFoundInstance();
        }
        return moduleSize
    }
}
