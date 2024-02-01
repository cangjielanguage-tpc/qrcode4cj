package zxing.code.multi.qrcode

import zxing.code.common.BarcodeFormat
import zxing.code.common.BinaryBitmap
import zxing.code.common.DecodeHintType
import zxing.code.common.NotFoundException
import zxing.code.common.ReaderException
import zxing.code.common.Result
import zxing.code.common.ResultMetadataType
import zxing.code.common.ResultPoint
import zxing.code.common.DecoderResult
import zxing.code.common.DetectorResult
import zxing.code.multi.MultipleBarcodeReader
import zxing.code.multi.qrcode.detector.MultiDetector
import zxing.code.qrcode.QRCodeReader
import zxing.code.qrcode.decoder.QRCodeDecoderMetaData
from charset import charset.tools.UTF32String
from std import math.*
from std import collection.*
from std import io.*

public class QRCodeMultiReader <: QRCodeReader & MultipleBarcodeReader {
    private static var NO_POINTS: Array<ResultPoint> = Array<ResultPoint>();

    private static func SAComparator(a: Result, b: Result): Ordering {
        var aNumber: Int64
        var bNumber: Int64
        if (a.getResultMetadata().contains(ResultMetadataType.STRUCTURED_APPEND_SEQUENCE)) {
            aNumber = (a.getResultMetadata()[ResultMetadataType.STRUCTURED_APPEND_SEQUENCE] as Int64).getOrThrow()
        } else {
            aNumber = 0
        }

        if (b.getResultMetadata().contains(ResultMetadataType.STRUCTURED_APPEND_SEQUENCE)) {
            bNumber = (b.getResultMetadata()[ResultMetadataType.STRUCTURED_APPEND_SEQUENCE] as Int64).getOrThrow()
        } else {
            bNumber = 0
        }

        return aNumber.compare(bNumber)
    }

    public static func processStructuredAppend(results: Array<Result>): Array<Result> {
        var newResults: ArrayList<Result> = ArrayList<Result>()
        var saResults: ArrayList<Result> = ArrayList<Result>()
        for (resultN in 0..results.size) {
            var result: Result = results[resultN]
            if (result.getResultMetadata().contains(ResultMetadataType.STRUCTURED_APPEND_SEQUENCE)) {
                saResults.append(result)
            } else {
                newResults.append(result)
            }
        }
        if (saResults.size == 0) {
            return results
        }

        // sort and concatenate the SA list items
        saResults.sortBy(SAComparator, stable: true)
        var newText: ArrayList<Char> = ArrayList<Char>()
        var newRawBytes: ByteArrayStream = ByteArrayStream()
        var newByteSegment: ByteArrayStream = ByteArrayStream()
        for (saResultN in 0..saResults.size) {
            var saResult: Result = saResults[saResultN]
            newText.appendAll(saResult.getText().toRuneArray())
            var saBytes: Array<UInt8> = saResult.getRawBytes()
            newRawBytes.write(saBytes)

            if (saResult.getResultMetadata().contains(ResultMetadataType.BYTE_SEGMENTS)) {
                var byteSegments: ArrayList<Array<UInt8>> = (saResult.getResultMetadata().get(
                    ResultMetadataType.BYTE_SEGMENTS) as ArrayList<Array<UInt8>>).getOrThrow()
                if (byteSegments.size != 0) {
                    for (segmentN in 0..byteSegments.size) {
                        var segment: Array<UInt8> = Array<UInt8>(byteSegments[segmentN])
                        newByteSegment.write(segment)
                    }
                }
            }
        }

        var newResult: Result = Result(String(newText), newRawBytes.bytes(), NO_POINTS, BarcodeFormat.QR_CODE)
        if (newByteSegment.length > 0) {
            newResult.putMetadata(ResultMetadataType.BYTE_SEGMENTS, newByteSegment.bytes())
        }
        newResults.append(newResult)
        return newResults.toArray()
    }

    private static var EMPTY_RESULT_ARRAY: Array<Result> = Array<Result>();

    public func decodeMultiple(image: BinaryBitmap): Array<Result> {
        return decodeMultiple(image, HashMap<DecodeHintType, Any>())
    }

    public func decodeMultiple(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Array<Result> {
        var results: ArrayList<Result> = ArrayList<Result>()
        var detectorResults: ArrayList<DetectorResult> = MultiDetector(image.getBlackMatrix()).detectMulti(hints)
        for (detectorResultN in 0..detectorResults.size) {
            var detectorResult: DetectorResult = detectorResults[detectorResultN]
            try {
                var decoderResult: DecoderResult = getDecoder().decode(detectorResult.getBits(), hints)
                var points: Array<ResultPoint> = detectorResult.getPoints()

                // If the code was mirrored: swap the bottom-left and the top-right points.
                if (decoderResult.getOther() is QRCodeDecoderMetaData) {
                    (decoderResult.getOther() as QRCodeDecoderMetaData).getOrThrow().applyMirroredCorrection(points)
                }
                var result: Result = Result(
                    decoderResult.getText(),
                    decoderResult.getRawBytes(),
                    points,
                    BarcodeFormat.QR_CODE
                )
                var byteSegments: ArrayList<Array<UInt8>> = decoderResult.getByteSegments()
                if (byteSegments.size > 0) {
                    result.putMetadata(ResultMetadataType.BYTE_SEGMENTS, byteSegments)
                }
                var ecLevel: String = decoderResult.getECLevel()
                if (!ecLevel.isEmpty()) {
                    result.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, ecLevel)
                }
                if (decoderResult.hasStructuredAppend()) {
                    result.putMetadata(
                        ResultMetadataType.STRUCTURED_APPEND_SEQUENCE,
                        decoderResult.getStructuredAppendSequenceNumber()
                    )
                    result.putMetadata(
                        ResultMetadataType.STRUCTURED_APPEND_PARITY,
                        decoderResult.getStructuredAppendParity()
                    )
                }
                results.append(result)
            } catch (re: ReaderException) {
                // ignore and continue
            }
        }
        if (results.size == 0) {
            return results.toArray()
        } else {
            return processStructuredAppend(results.toArray())
        }
    }
}
