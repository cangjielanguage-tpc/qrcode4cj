package zxing.code.maxicode

import zxing.code.common.BarcodeFormat
import zxing.code.common.BinaryBitmap
import zxing.code.common.ChecksumException
import zxing.code.common.DecodeHintType
import zxing.code.common.FormatException
import zxing.code.common.NotFoundException
import zxing.code.common.Reader
import zxing.code.common.Result
import zxing.code.common.ResultMetadataType
import zxing.code.common.ResultPoint
import zxing.code.common.BitMatrix
import zxing.code.common.DecoderResult
import zxing.code.maxicode.decoder.Decoder
from std import math.*
from std import collection.*
from charset import charset.tools.UTF32String

/**
 * This implementation can detect and decode a MaxiCode in an image.
 */
public class MaxiCodeReader <: Reader {
    private static let NO_POINTS: Array<ResultPoint> = Array<ResultPoint>()
    private static let MATRIX_WIDTH: Int64 = 30
    private static let MATRIX_HEIGHT: Int64 = 33

    private var decoder: Decoder = Decoder()

    /**
     * Locates and decodes a MaxiCode in an image.
     *
     * @return a String representing the content encoded by the MaxiCode
     * @throws NotFoundException if a MaxiCode cannot be found
     * @throws FormatException if a MaxiCode cannot be decoded
     * @throws ChecksumException if error correction fails
     */
    public func decode(image: BinaryBitmap): Result {
        return decode(image, HashMap<DecodeHintType, Any>())
    }

    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        // Note that MaxiCode reader effectively always assumes PURE_BARCODE mode
        // and can't detect it in an image
        var bits: BitMatrix = extractPureBits(image.getBlackMatrix())
        var decoderResult: DecoderResult = decoder.decode(bits, hints)
        var result: Result = Result(
            decoderResult.getText(),
            decoderResult.getRawBytes(),
            NO_POINTS,
            BarcodeFormat.MAXICODE
        )

        var ecLevel: String = decoderResult.getECLevel()
        if (!ecLevel.isEmpty()) {
            result.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, ecLevel)
        }
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
        var enclosingRectangle: Array<Int64> = (image.getEnclosingRectangle())
        if (enclosingRectangle.size == 0) {
            throw NotFoundException.getNotFoundInstance()
        }

        var left: Int64 = enclosingRectangle[0]
        var top: Int64 = enclosingRectangle[1]
        var width: Int64 = enclosingRectangle[2]
        var height: Int64 = enclosingRectangle[3]

        // Now just read off the bits
        var bits: BitMatrix = BitMatrix(MATRIX_WIDTH, MATRIX_HEIGHT)
        for (y in 0..MATRIX_HEIGHT) {
            var iy: Int64 = math.min(top + (y * height + height / 2) / MATRIX_HEIGHT, height - 1)
            for (x in 0..MATRIX_WIDTH) {
                // srowen: I don't quite understand why the formula below is necessary, but it
                // can walk off the image if left + width = the right boundary. So cap it.
                var ix: Int64 = left + min(
                    (x * width + width / 2 + (y & 0x01) * width / 2) / MATRIX_WIDTH,
                    width - 1
                )
                if (image.get(ix, iy)) {
                    bits.set(x, y)
                }
            }
        }
        return bits
    }
}
