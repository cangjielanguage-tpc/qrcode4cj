/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package aztec

import common.BinaryBitmap
import common.DecodeHintType
import common.Qrcoder4cjFormatException
import common.Qrcoder4cjNotFoundException
import common.Reader
import common.Result
import common.ResultMetadataType
import common.ResultPoint
import common.ResultPointCallback
import tools.System
import aztec.decoder.Decoder
import aztec.detector.Detector
import aztec.common.AztecDetectorResult
import common.DecoderResult
import tools.UTF32String

public class AztecReader <: Reader {
    public override func decode(image: BinaryBitmap): Result {
        return decode(image, HashMap<DecodeHintType, Any>());
    }

    public override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        var notFoundException: ?Qrcoder4cjNotFoundException = None
        var formatException: ?Qrcoder4cjFormatException = None
        var detector: Detector = Detector(image.getBlackMatrix())
        var points: Array<ResultPoint> = Array<ResultPoint>()
        var decoderResult: ?DecoderResult = None
        try {
            var detectorResult: AztecDetectorResult = detector.detect(false)
            points = detectorResult.getPoints()
            decoderResult = Decoder().decode(detectorResult)
        } catch (e: Qrcoder4cjNotFoundException) {
            notFoundException = e
        } catch (e: Qrcoder4cjFormatException) {
            formatException = e
        }
        if (let Some(d) <- decoderResult) {}
        else {
            try {
                var detectorResult: AztecDetectorResult = detector.detect(true)
                points = detectorResult.getPoints()
                decoderResult = Decoder().decode(detectorResult)
            } catch (e: Qrcoder4cjNotFoundException | Qrcoder4cjFormatException) {
                throwdecode(e, notFoundException, formatException)
            }
        }

        if (hints.size != 0 && hints.contains(DecodeHintType.NEED_RESULT_POINT_CALLBACK)) {
            var rpcb: ?ResultPointCallback = hints[DecodeHintType.NEED_RESULT_POINT_CALLBACK] as ResultPointCallback
            if (let Some(r) <- rpcb) {
                for (point in 0..points.size) {
                    r.foundPossibleResultPoint(points[point])
                }
            }
        }

        var result: Result = Result(decoderResult.getOrThrow().getText(), decoderResult.getOrThrow().getRawBytes(),
            decoderResult.getOrThrow().getNumBits(), points, BarcodeFormat.AZTEC, System.currentTimeMillis())
        var byteSegments: ArrayList<Array<UInt8>> = decoderResult.getOrThrow().getByteSegments();
        if (byteSegments.size != 0) {
            result.putMetadata(ResultMetadataType.BYTE_SEGMENTS, byteSegments)
        }
        var ecLevel: String = decoderResult.getOrThrow().getECLevel()
        if (!ecLevel.isEmpty()) {
            result.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, ecLevel)
        }
        result.putMetadata(
            ResultMetadataType.SYMBOLOGY_IDENTIFIER,
            "]z" + decoderResult.getOrThrow().getSymbologyModifier().toString()
        )

        return result
    }

    private func throwdecode(e: Exception, notFoundException: ?Qrcoder4cjNotFoundException, formatException: ?Qrcoder4cjFormatException) {
        if (let Some(n) <- notFoundException) {
            throw Qrcoder4cjNotFoundException()
        }
        if (let Some(n) <- formatException) {
            throw Qrcoder4cjFormatException()
        }
        throw e
    }

    public override func reset() {
        // do nothing
    }
}
