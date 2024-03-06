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

package zxing.code.qrcode

import zxing.code.common.BinaryBitmap
import zxing.code.common.ChecksumException
import zxing.code.common.FormatException
import zxing.code.common.NotFoundException
import zxing.code.common.Reader
import zxing.code.common.Result
import zxing.code.common.ResultMetadataType
import zxing.code.common.ResultPoint
import zxing.code.common.DecoderResult
import zxing.code.common.DetectorResult
import zxing.code.qrcode.decoder.Decoder
import zxing.code.qrcode.decoder.QRCodeDecoderMetaData
import zxing.code.qrcode.detector.Detector

/**
 * This implementation can detect and decode QR Codes in an image.
 *
 * @author Sean Owen
 */
public open class QRCodeReader <: Reader {
    private static let NO_POINTS = Array<ResultPoint>();
    private let decodeReader: Decoder = Decoder();

    protected func getDecoder(): Decoder {
        return decodeReader
    }

    /**
     * Locates and decodes a QR code in an image.
     *
     * @return a String representing the content encoded by the QR code
     * @throws NotFoundException if a QR code cannot be found
     * @throws FormatException if a QR code cannot be decoded
     * @throws ChecksumException if error correction fails
     */
    public func decode(image: BinaryBitmap): Result {
        return decode(image, HashMap<DecodeHintType, Any>());
    }

    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        var decoderResult: DecoderResult
        var points = Array<ResultPoint>();
        if (hints.size != 0 && hints.contains(DecodeHintType.PURE_BARCODE)) {
            let bits: BitMatrix = extractPureBits(image.getBlackMatrix());
            decoderResult = decodeReader.decode(bits, hints)
            points = NO_POINTS
        } else {
            let detectorResult: DetectorResult = Detector(image.getBlackMatrix()).detect(hints);
            decoderResult = decodeReader.decode(detectorResult.getBits(), hints)
            points = detectorResult.getPoints()
        }

        // If the code was mirrored: swap the bottom-left and the top-right points.
        if (decoderResult.getOther() is QRCodeDecoderMetaData) {
            (decoderResult as QRCodeDecoderMetaData).getOrThrow().applyMirroredCorrection(points);
        }

        let result: Result = Result(decoderResult.getText(), decoderResult.getRawBytes(), points, BarcodeFormat.QR_CODE);
        let byteSegments = decoderResult.getByteSegments();
        if (byteSegments.size != 0) {
            result.putMetadata(ResultMetadataType.BYTE_SEGMENTS, byteSegments);
        }
        let ecLevel: String = decoderResult.getECLevel();
        if (!ecLevel.isEmpty()) {
            result.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, ecLevel);
        }
        if (decoderResult.hasStructuredAppend()) {
            result.putMetadata(
                ResultMetadataType.STRUCTURED_APPEND_SEQUENCE,
                decoderResult.getStructuredAppendSequenceNumber()
            );
            result.putMetadata(
                ResultMetadataType.STRUCTURED_APPEND_PARITY,
                decoderResult.getStructuredAppendParity()
            );
        }
        result.putMetadata(
            ResultMetadataType.SYMBOLOGY_IDENTIFIER,
            "]Q" + decoderResult.getSymbologyModifier().toString()
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
        let leftTopBlack: Array<Int64> = image.getTopLeftOnBit();
        let rightBottomBlack: Array<Int64> = image.getBottomRightOnBit();
        if (leftTopBlack.size == 0 || rightBottomBlack.size == 0) {
            throw NotFoundException.getNotFoundInstance();
        }

        let modulesize: Float32 = moduleSize(leftTopBlack, image);

        var top: Int64 = leftTopBlack[1]
        var bottom: Int64 = rightBottomBlack[1]
        var left: Int64 = leftTopBlack[0]
        var right: Int64 = rightBottomBlack[0]

        // Sanity check!
        if (left >= right || top >= bottom) {
            throw NotFoundException.getNotFoundInstance();
        }

        if (bottom - top != right - left) {
            // Special case, where bottom-right module wasn't black so we found something else in the last row
            // Assume it's a square, so use height as the width
            right = left + (bottom - top)
            if (right >= image.getWidth()) {
                // Abort if that would not make sense -- off image
                throw NotFoundException.getNotFoundInstance();
            }
        }

        var pointx = Float32(right - left + 1) / modulesize
        var pointy = Float32(bottom - top + 1) / modulesize

        var pointx_o = round(pointx)
        var pointy_o = round(pointy)

        var pointx_d = Int64(pointx) % 2
        var pointx_f = pointx - Float32(Int64(pointx))
        if (pointx_d == 0 && pointx_f == 0.5) {
            pointx_o = pointx_o + 1.0
        }

        var pointy_d = Int64(pointy) % 2
        var pointy_f = pointy - Float32(Int64(pointy))
        if (pointy_d == 0 && pointy_f == 0.5) {
            pointy_o = pointy_o + 1.0
        }

        var matrixWidth: Int64 = Int64(pointx_o)
        var matrixHeight: Int64 = Int64(pointy_o)

        if (matrixWidth <= 0 || matrixHeight <= 0) {
            throw NotFoundException.getNotFoundInstance();
        }
        if (matrixHeight != matrixWidth) {
            // Only possibly decode square regions
            throw NotFoundException.getNotFoundInstance();
        }

        // Push in the "border" by half the module width so that we start
        // sampling in the middle of the module. Just in case the image is a
        // little off, this will help recover.
        var nudge: Int64 = Int64(modulesize / 2.0f32)
        top += nudge
        left += nudge

        // But careful that this does not sample off the edge
        // "right" is the farthest-right valid pixel location -- right+1 is not necessarily
        // This is positive by how much the inner x loop below would be too large
        var nudgedTooFarRight: Int64 = left + Int64((matrixWidth - 1) * Int64(modulesize)) - right
        if (nudgedTooFarRight > 0) {
            if (nudgedTooFarRight > nudge) {
                throw NotFoundException.getNotFoundInstance();
            }
            left -= nudgedTooFarRight
        }

        // See logic above
        var nudgedTooFarDown: Int64 = top + Int64((matrixHeight - 1) * Int64(modulesize)) - bottom
        if (nudgedTooFarDown > 0) {
            if (nudgedTooFarDown > nudge) {
                // Neither way fits; abort
                throw NotFoundException.getNotFoundInstance();
            }
            top -= nudgedTooFarDown
        }

        // Now just read off the bits
        var bits: BitMatrix = BitMatrix(matrixWidth, matrixHeight);
        for (y in 0..matrixHeight) {
            let iOffset: Int64 = top + Int64(y * Int64(modulesize))
            for (x in 0..matrixWidth) {
                if (image.get(left + (x * Int64(modulesize)), iOffset)) {
                    bits.set(x, y);
                }
            }
        }
        return bits
    }

    private static func moduleSize(leftTopBlack: Array<Int64>, image: BitMatrix): Float32 {
        let height: Int64 = image.getHeight();
        let width: Int64 = image.getWidth();
        var x: Int64 = leftTopBlack[0]
        var y: Int64 = leftTopBlack[1]
        var inBlack: Bool = true;
        var transitions: Int64 = 0;
        while (x < width && y < height) {
            if (inBlack != image.get(x, y)) {
                transitions++
                if (transitions == 5) {
                    break
                }
                inBlack = !inBlack
            }
            x++
            y++
        }
        if (x == width || y == height) {
            throw NotFoundException.getNotFoundInstance();
        }
        return Float32(x - leftTopBlack[0]) / 7.0f32
    }
}
