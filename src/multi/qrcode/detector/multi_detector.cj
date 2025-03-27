/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.multi.qrcode.detector

import QRCode4cj.qrcode.detector.*
import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.math.*

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
                result.add(processFinderPatternInfo(infos[i]))
            } catch (e: Qrcoder4cjReaderException) {
                // ignore
            }
        }

        return result
    }
}
