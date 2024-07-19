/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417

import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.BinaryBitmap
import QRCode4cj.common.Qrcoder4cjChecksumException
import QRCode4cj.common.DecodeHintType
import QRCode4cj.common.Qrcoder4cjFormatException
import QRCode4cj.common.Qrcoder4cjNotFoundException
import QRCode4cj.common.Reader
import QRCode4cj.common.Result
import QRCode4cj.common.ResultMetadataType
import QRCode4cj.common.ResultPoint
import QRCode4cj.common.DecoderResult
import QRCode4cj.multi.MultipleBarcodeReader
import QRCode4cj.pdf417.decoder.PDF417ScanningDecoder
import QRCode4cj.pdf417.detector.Detector
import QRCode4cj.pdf417.detector.PDF417DetectorResult
import QRCode4cj.pdf417.common.PDF417ResultMetadata
import QRCode4cj.pdf417.common.PDF417Common
import std.collection.*
import std.math.*

/**
 * This implementation can detect and decode PDF417 codes in an image.
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
     * @throws Qrcoder4cjNotFoundException if a PDF417 code cannot be found,
     * @throws Qrcoder4cjFormatException if a PDF417 cannot be decoded
     */
    public func decode(image: BinaryBitmap): Result {
        return decode(image, HashMap<DecodeHintType, Any>());
    }

    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        let result: Array<Result> = Decode(image, hints, false, flagReadSecond);
        if (result.size == 0 || result[0].flag == false) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }
        return result[0]
    }

    public func decodeMultiple(image: BinaryBitmap): Array<Result> {
        return decodeMultiple(image, HashMap<DecodeHintType, Any>());
    }

    public func decodeMultiple(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Array<Result> {
        try {
            return Decode(image, hints, true, flagReadSecond);
        } catch (ignored: Qrcoder4cjFormatException | Qrcoder4cjChecksumException) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance();
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
