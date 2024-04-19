/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package qrcode.encoder

class BlockPair {
    private var dataBytes: Array<Byte>
    private var errorCorrectionBytes: Array<Byte>

    init(data: Array<Byte>, errorCorrection: Array<Byte>) {
        dataBytes = data
        errorCorrectionBytes = errorCorrection
    }

    public func getDataBytes(): Array<Byte> {
        return dataBytes
    }

    public func getErrorCorrectionBytes(): Array<Byte> {
        return errorCorrectionBytes
    }
}
