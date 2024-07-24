/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.datamatrix.encoder

public interface Encoder {
    func getEncodingMode(): Int64

    func encode(context: EncoderContext): Unit
}
