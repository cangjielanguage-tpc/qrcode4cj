package multi

import common.BinaryBitmap
import common.Qrcoder4cjChecksumException
import common.DecodeHintType
import common.Qrcoder4cjFormatException
import common.Qrcoder4cjNotFoundException
import common.Reader
import common.Result
import common.ResultPoint

public class ByQuadrantReader <: Reader {
    private var delegate: Reader
    public init(delegate: Reader) {
        this.delegate = delegate
    }

    public override func decode(image: BinaryBitmap): Result {
        return decode(image, HashMap<DecodeHintType, Any>())
    }

    public override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        var width: Int64 = image.getWidth()
        var height: Int64 = image.getHeight()
        var halfWidth: Int64 = width / 2
        var halfHeight: Int64 = height / 2

        try {
            // No need to call makeAbsolute as results will be relative to original top left here
            return delegate.decode(image.crop(0, 0, halfWidth, halfHeight), hints)
        } catch (re: Qrcoder4cjNotFoundException) {
            // continue
        }

        try {
            var result: Result = delegate.decode(image.crop(halfWidth, 0, halfWidth, halfHeight), hints)
            makeAbsolute(result.getResultPoints(), halfWidth, 0)
            return result
        } catch (re: Qrcoder4cjNotFoundException) {
            // continue
        }

        try {
            var result: Result = delegate.decode(image.crop(0, halfHeight, halfWidth, halfHeight), hints)
            makeAbsolute(result.getResultPoints(), 0, halfHeight)
            return result
        } catch (re: Qrcoder4cjNotFoundException) {
            // continue
        }

        try {
            var result: Result = delegate.decode(image.crop(halfWidth, halfHeight, halfWidth, halfHeight), hints)
            makeAbsolute(result.getResultPoints(), halfWidth, halfHeight)
            return result
        } catch (re: Qrcoder4cjNotFoundException) {
            // continue
        }

        var quarterWidth: Int64 = halfWidth / 2
        var quarterHeight: Int64 = halfHeight / 2
        var center: BinaryBitmap = image.crop(quarterWidth, quarterHeight, halfWidth, halfHeight)
        var result: Result = delegate.decode(center, hints)
        makeAbsolute(result.getResultPoints(), quarterWidth, quarterHeight)
        return result
    }

    public func reset() {
        delegate.reset()
    }

    private func makeAbsolute(points: Array<ResultPoint>, leftOffset: Int64, topOffset: Int64) {
        if (points.size != 0) {
            for (i in 0..points.size) {
                var relative: ResultPoint = points[i]
                if (!relative.equals(ResultPoint(0.0, 0.0))) {
                    points[i] = ResultPoint(relative.getX() + Float32(leftOffset), relative.getY() + Float32(topOffset))
                }
            }
        }
    }
}
