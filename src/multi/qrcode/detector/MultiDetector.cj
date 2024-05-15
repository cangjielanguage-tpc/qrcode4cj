package multi.qrcode.detector

import common.Qrcoder4cjReaderException
import common.DetectorResult
import qrcode.detector.Detector

/**
 * Encapsulates logic that can detect one or more QR Codes in an image, even if the QR Code
 * is rotated or skewed, or partially obscured.
 */
public class MultiDetector <: Detector {
    public init(image: BitMatrix) {
        super(image)
    }

    public func detectMulti(hints: HashMap<DecodeHintType, Any>): ArrayList<DetectorResult> {
        var image: BitMatrix = getImage()
        var resultPointCallback: ?ResultPointCallback = None
        if (hints.size > 0) {
            resultPointCallback = (hints.get(DecodeHintType.NEED_RESULT_POINT_CALLBACK) as ResultPointCallback).
                getOrThrow()
        }
        var finder: MultiFinderPatternFinder = MultiFinderPatternFinder(image, resultPointCallback)
        var infos: Array<FinderPatternInfo> = finder.findMulti(hints)

        if (infos.size == 0) {
            throw Qrcoder4cjNotFoundException.getNotFoundInstance()
        }

        var result: ArrayList<DetectorResult> = ArrayList<DetectorResult>()
        for (i in 0..infos.size) {
            try {
                result.append(processFinderPatternInfo(infos[i]))
            } catch (e: Qrcoder4cjReaderException) {
                // ignore
            }
        }

        return result
    }
}
