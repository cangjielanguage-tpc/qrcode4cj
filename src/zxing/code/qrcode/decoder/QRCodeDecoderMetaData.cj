/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.qrcode.decoder

import zxing.code.common.ResultPoint

/**
 * Meta-data container for QR Code decoding. Instances of this class may be used to convey information back to the
 * decoding caller. Callers are expected to process this.
 *
 * @see com.google.zxing.common.DecoderResult#getOther()
 */
public class QRCodeDecoderMetaData {
    private var mirrored: Bool

    init(mirrored: Bool) {
        this.mirrored = mirrored
    }

    /**
     * @return true if the QR Code was mirrored.
     */
    public func isMirrored(): Bool {
        return mirrored
    }

    /**
     * Apply the result points' order correction due to mirroring.
     *
     * @param points Array of points to apply mirror correction to.
     */
    public func applyMirroredCorrection(points: Array<ResultPoint>) {
        if (!mirrored || points.size < 3) {
            return;
        }
        let bottomLeft: ResultPoint = points[0]
        points[0] = points[2]
        points[2] = bottomLeft
        // No need to 'fix' top-left and alignment pattern.
    }
}
