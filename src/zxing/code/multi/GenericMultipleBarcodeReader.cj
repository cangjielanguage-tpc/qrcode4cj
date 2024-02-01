package zxing.code.multi

import zxing.code.common.ReaderException

/**
 * <p>Attempts to locate multiple barcodes in an image by repeatedly decoding portion of the image.
 * After one barcode is found, the areas left, above, right and below the barcode's
 * {@link ResultPoint}s are scanned, recursively.</p>
 *
 * <p>A caller may want to also employ {@link ByQuadrantReader} when attempting to find multiple
 * 2D barcodes, like QR Codes, in an image, where the presence of multiple barcodes might prevent
 * detecting any one of them.</p>
 *
 * <p>That is, instead of passing a {@link Reader} a caller might pass
 * {@code new ByQuadrantReader(reader)}.</p>
 *
 * @author Sean Owen
 */
public class GenericMultipleBarcodeReader <: MultipleBarcodeReader {
    private static var MIN_DIMENSION_TO_RECUR: Int64 = 100
    private static var MAX_DEPTH: Int64 = 4

    let EMPTY_RESULT_ARRAY: Array<Result> = []

    private var delegate: Reader

    public init(delegate: Reader) {
        this.delegate = delegate
    }

    public func decodeMultiple(image: BinaryBitmap): Array<Result> {
        return decodeMultiple(image, HashMap<DecodeHintType, Any>())
    }

    public func decodeMultiple(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Array<Result> {
        var results: ArrayList<Result> = ArrayList<Result>()
        doDecodeMultiple(image, hints, results, 0, 0, 0)
        if (results.size == 0) {
            throw NotFoundException.getNotFoundInstance()
        }
        return results.toArray()
    }

    private func doDecodeMultiple(
        image: BinaryBitmap,
        hints: HashMap<DecodeHintType, Any>,
        results: ArrayList<Result>,
        xOffset: Int64,
        yOffset: Int64,
        currentDepth: Int64
    ): Unit {
        if (currentDepth > MAX_DEPTH) {
            return
        }

        var result: Result
        try {
            result = delegate.decode(image, hints)
        } catch (ignored: ReaderException) {
            return
        }
        var alreadyFound: Bool = false
        for (i in 0..results.size) {
            if (results[i].getText() == (result.getText())) {
                alreadyFound = true
                break
            }
        }
        if (!alreadyFound) {
            results.append(translateResultPoints(result, xOffset, yOffset))
        }
        var resultPoints: Array<ResultPoint> = result.getResultPoints()
        if (resultPoints.size == 0) {
            return
        }
        var width: Int64 = image.getWidth()
        var height: Int64 = image.getHeight()
        var minX: Float64 = Float64(width)
        var minY: Float64 = Float64(height)
        var maxX: Float64 = 0.0f64
        var maxY: Float64 = 0.0f64
        for (pointN in 0..resultPoints.size) {
            var point: ResultPoint = resultPoints[pointN]
            if (point.equals(ResultPoint())) {
                continue
            }
            var x: Float64 = Float64(point.getX())
            var y: Float64 = Float64(point.getY())
            if (x < minX) {
                minX = x
            }
            if (y < minY) {
                minY = y
            }
            if (x > maxX) {
                maxX = x
            }
            if (y > maxY) {
                maxY = y
            }
        }

        // Decode left of barcode
        if (minX > Float64(MIN_DIMENSION_TO_RECUR)) {
            doDecodeMultiple(
                image.crop(0, 0, Int64(minX), height),
                hints,
                results,
                xOffset,
                yOffset,
                currentDepth + 1
            )
        }

        // Decode above barcode
        if (minY > Float64(MIN_DIMENSION_TO_RECUR)) {
            doDecodeMultiple(
                image.crop(0, 0, width, Int64(minY)),
                hints,
                results,
                xOffset,
                yOffset,
                currentDepth + 1
            )
        }

        // Decode right of barcode
        if (maxX < Float64(width - MIN_DIMENSION_TO_RECUR)) {
            doDecodeMultiple(
                image.crop(Int64(maxX), 0, width - Int64(maxX), height),
                hints,
                results,
                xOffset + Int64(maxX),
                yOffset,
                currentDepth + 1
            )
        }

        // Decode below barcode
        if (maxY < Float64(height - MIN_DIMENSION_TO_RECUR)) {
            doDecodeMultiple(
                image.crop(0, Int64(maxY), width, height - Int64(maxY)),
                hints,
                results,
                xOffset,
                yOffset + Int64(maxY),
                currentDepth + 1
            )
        }
    }

    private static func translateResultPoints(result: Result, xOffset: Int64, yOffset: Int64): Result {
        var oldResultPoints: Array<ResultPoint> = result.getResultPoints()
        if (oldResultPoints.size == 0) {
            return result
        }
        var newResultPoints: Array<ResultPoint> = Array<ResultPoint>(oldResultPoints.size) {i => ResultPoint()}
        for (i in 0..oldResultPoints.size) {
            var oldPoint: ResultPoint = oldResultPoints[i]
            if (oldPoint.equals(ResultPoint(0.0, 0.0))) {
                newResultPoints[i] = ResultPoint(oldPoint.getX() + Float32(xOffset), oldPoint.getY() + Float32(yOffset))
            }
        }
        var newResult: Result = Result(
            result.getText(),
            result.getRawBytes(),
            result.getNumBits(),
            newResultPoints,
            result.getBarcodeFormat(),
            result.getTimestamp()
        )
        newResult.putAllMetadata(result.getResultMetadata())
        return newResult
    }
}
