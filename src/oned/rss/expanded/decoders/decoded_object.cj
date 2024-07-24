/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

abstract class DecodedObject {
    private var newPosition: Int64 = 0

    init(newPosition: Int64) {
        this.newPosition = newPosition
    }

    func getNewPosition(): Int64 {
        return this.newPosition;
    }
}
