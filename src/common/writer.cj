/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common

import std.collection.*

public interface Writer {
    /**
     * Encode a barcode using the default settings.
     * @param contents The contents to encode in the barcode
     * @param format The barcode format to generate
     * @param width The preferred width in pixels
     * @param height The preferred height in pixels
     * @return {@link BitMatrix} representing encoded barcode image
     * @throws Qrcoder4cjWriterException if contents cannot be encoded legally in a format
     */
    func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix

    /**
     * @param contents The contents to encode in the barcode
     * @param format The barcode format to generate
     * @param width The preferred width in pixels
     * @param height The preferred height in pixels
     * @param hints Additional parameters to supply to the encoder
     * @return {@link BitMatrix} representing encoded barcode image
     * @throws Qrcoder4cjWriterException if contents cannot be encoded legally in a format
     */
    func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix
}
