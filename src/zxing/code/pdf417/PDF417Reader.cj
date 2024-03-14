/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.pdf417

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
import zxing.code.common.DecoderResult
import zxing.code.multi.MultipleBarcodeReader
import zxing.code.pdf417.decoder.PDF417ScanningDecoder
import zxing.code.pdf417.detector.Detector
import zxing.code.pdf417.detector.PDF417DetectorResult
import zxing.code.pdf417.common.PDF417ResultMetadata
import zxing.code.pdf417.common.PDF417Common
from std import collection.*
from std import math.*

/**
 * This implementation can detect and decode PDF417 codes in an image.
 *
 * @author Guenther Grau
 */
public open class PDF417Reader <: Reader & MultipleBarcodeReader {
    private static var EMPTY_RESULT_ARRAY: Array<Result> = Array<Result>();
    public var flagReadSecond = 0
    public init() {
    }
    public init(flagRead: Int64) {
        flagReadSecond = flagRead
    }

    /**
     * Locates and decodes a PDF417 code in an image.
     *
     * @return a String representing the content encoded by the PDF417 code
     * @throws NotFoundException if a PDF417 code cannot be found,
     * @throws FormatException if a PDF417 cannot be decoded
     */
    public func decode(image: BinaryBitmap): Result {
        return decode(image, HashMap<DecodeHintType, Any>());
    }

    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        let result: Array<Result> = Decode(image, hints, false, flagReadSecond);
        if (result.size == 0 || result[0].flag == false) {
            throw NotFoundException.getNotFoundInstance()
        }
        return result[0]
    }

    public func decodeMultiple(image: BinaryBitmap): Array<Result> {
        return decodeMultiple(image, HashMap<DecodeHintType, Any>());
    }

    public func decodeMultiple(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Array<Result> {
        try {
            return Decode(image, hints, true, flagReadSecond);
        } catch (ignored: FormatException | ChecksumException) {
            throw NotFoundException.getNotFoundInstance();
        }
    }

    private static func Decode(
        image: BinaryBitmap,
        hints: HashMap<DecodeHintType, Any>,
        multiple: Bool,
        flagReadSecond: Int64
    ): Array<Result> {
        var results: ArrayList<Result> = ArrayList<Result>()
        let detectorResult: PDF417DetectorResult = Detector.detect(image, hints, multiple, flagReadSecond);

        var points = detectorResult.getPoints()
        for (i in 0..points.size) {
            var decoderResult: DecoderResult = PDF417ScanningDecoder.decode(
                detectorResult.getBits(),
                points[i][4],
                points[i][5],
                points[i][6],
                points[i][7],
                getMinCodewordWidth(points[i]),
                getMaxCodewordWidth(points[i])
            );
            var result: Result = Result(
                decoderResult.getText(),
                decoderResult.getRawBytes(),
                points[i],
                BarcodeFormat.PDF_417
            );
            result.putMetadata(ResultMetadataType.ERROR_CORRECTION_LEVEL, decoderResult.getECLevel());
            let pdf417ResultMetadata: PDF417ResultMetadata = (decoderResult.getOther() as PDF417ResultMetadata).
                getOrThrow()
            if (pdf417ResultMetadata.flag == true) {
                result.putMetadata(ResultMetadataType.PDF417_EXTRA_METADATA, pdf417ResultMetadata);
            }
            result.putMetadata(ResultMetadataType.ORIENTATION, detectorResult.getRotation());
            result.putMetadata(
                ResultMetadataType.SYMBOLOGY_IDENTIFIER,
                "]L" + decoderResult.getSymbologyModifier().toString()
            );
            results.append(result);
        }
        EMPTY_RESULT_ARRAY = results.toArray()
        return EMPTY_RESULT_ARRAY
    }

    private static func getMaxWidth(p1: ResultPoint, p2: ResultPoint): Int64 {
        if (p1.flag == false || p2.flag == false) {
            return 0
        }
        return Int64(abs(p1.getX() - p2.getX()))
    }

    private static func getMinWidth(p1: ResultPoint, p2: ResultPoint): Int64 {
        if (p1.flag == false || p2.flag == false) {
            return 0x7fffffff;
        }
        return Int64(abs(p1.getX() - p2.getX()))
    }

    private static func getMaxCodewordWidth(p: Array<ResultPoint>): Int64 {
        return max(
            max(
                getMaxWidth(p[0], p[4]),
                getMaxWidth(p[6], p[2]) * PDF417Common.MODULES_IN_CODEWORD / PDF417Common.MODULES_IN_STOP_PATTERN
            ),
            max(
                getMaxWidth(p[1], p[5]),
                getMaxWidth(p[7], p[3]) * PDF417Common.MODULES_IN_CODEWORD / PDF417Common.MODULES_IN_STOP_PATTERN
            )
        );
    }

    private static func getMinCodewordWidth(p: Array<ResultPoint>): Int64 {
        return min(
            min(
                getMinWidth(p[0], p[4]),
                getMinWidth(p[6], p[2]) * PDF417Common.MODULES_IN_CODEWORD / PDF417Common.MODULES_IN_STOP_PATTERN
            ),
            min(
                getMinWidth(p[1], p[5]),
                getMinWidth(p[7], p[3]) * PDF417Common.MODULES_IN_CODEWORD / PDF417Common.MODULES_IN_STOP_PATTERN
            )
        );
    }

    public func reset() {
        // nothing needs to be reset
    }
}
