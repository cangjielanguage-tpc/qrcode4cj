/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.datamatrix

import std.collection.*
import QRCode4cj.common.*
import QRCode4cj.datamatrix.decoder.Decoder
import QRCode4cj.datamatrix.detector.Detector

/**
 * This implementation can detect and decode Data Matrix codes in an image.
 */
public class DataMatrixReader <: Reader {
    private static let NO_POINTS: Array<ResultPoint> = Array<ResultPoint>();

    private let decoder: Decoder = Decoder();

    /**
     * Locates and decodes a Data Matrix code in an image.
     *
     * @return a String representing the content encoded by the Data Matrix code
     * @throws Qrcoder4cjNotFoundException if a Data Matrix code cannot be found
     * @throws Qrcoder4cjFormatException if a Data Matrix code cannot be decoded
     * @throws Qrcoder4cjChecksumException if error correction fails
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
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var moduleSize: Int64 = moduleSize(leftTopBlack, image);

        var top: Int64 = leftTopBlack[1]
        var bottom: Int64 = rightBottomBlack[1]
        var left: Int64 = leftTopBlack[0]
        var right: Int64 = rightBottomBlack[0]

        var matrixWidth: Int64 = (right - left + 1) / moduleSize
        var matrixHeight: Int64 = (bottom - top + 1) / moduleSize
        if (matrixWidth <= 0 || matrixHeight <= 0) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
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
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }

        var moduleSize: Int64 = x - leftTopBlack[0]
        if (moduleSize == 0) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
        }
        return moduleSize
    }
}
