/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.multi.qrcode

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.BinaryBitmap
import QRCode4cj.common.DecodeHintType
import QRCode4cj.common.Qrcoder4cjNotFoundException
import QRCode4cj.common.Qrcoder4cjReaderException
import QRCode4cj.common.Result
import QRCode4cj.common.ResultMetadataType
import QRCode4cj.common.ResultPoint
import QRCode4cj.common.DecoderResult
import QRCode4cj.common.DetectorResult
import QRCode4cj.multi.MultipleBarcodeReader
import QRCode4cj.multi.qrcode.detector.MultiDetector
import QRCode4cj.qrcode.QRCodeReader
import QRCode4cj.qrcode.decoder.QRCodeDecoderMetaData
import QRCode4cj.tools.UTF32String
import std.math.*
import std.collection.*
import std.io.*

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
                saResults.add(result)
            } else {
                newResults.add(result)
            }
        }
        if (saResults.size == 0) {
            return results
        }

        // sort and concatenate the SA list items
        saResults.sortBy(stable: true, comparator: SAComparator)
        var newText: ArrayList<Rune> = ArrayList<Rune>()
        var newRawBytes: ByteBuffer = ByteBuffer()
        var newByteSegment: ByteBuffer = ByteBuffer()
        for (saResultN in 0..saResults.size) {
            var saResult: Result = saResults[saResultN]
            newText.add(all:saResult.getText().toRuneArray())
            var saBytes: Array<UInt8> = saResult.getRawBytes()
            newRawBytes.write(saBytes)

            if (saResult.getResultMetadata().contains(ResultMetadataType.BYTE_SEGMENTS)) {
                var byteSegments: ArrayList<Array<UInt8>> = (saResult.getResultMetadata().get(
                    ResultMetadataType.BYTE_SEGMENTS) as ArrayList<Array<UInt8>>).getOrThrow()
                if (byteSegments.size != 0) {
                    for (segmentN in 0..byteSegments.size) {
                        var segment: Array<UInt8> = byteSegments[segmentN]
                        newByteSegment.write(segment)
                    }
                }
            }
        }

        var newResult: Result = Result(String(newText), newRawBytes.bytes(), NO_POINTS, BarcodeFormat.QR_CODE)
        if (newByteSegment.length > 0) {
            newResult.putMetadata(ResultMetadataType.BYTE_SEGMENTS, newByteSegment.bytes())
        }
        newResults.add(newResult)
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
                results.add(result)
            } catch (re: Qrcoder4cjReaderException) {
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
