/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned

import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.math.*

/**
 * This object renders a UPC-A code as a BitMatrix.
 */
public open class UPCAWriter <: Writer {
    private let subWriter: EAN13Writer = EAN13Writer();

    public func encode(contents: String, format: BarcodeFormat, width: Int64, height: Int64): BitMatrix {
        return encode(contents, format, width, height, HashMap<EncodeHintType, Any>());
    }

    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix {
        if (format != BarcodeFormat.UPC_A) {
            throw IllegalArgumentException("Can only encode UPC-A, but got ${format}");
        }

        // Transform a UPC-A code into the equivalent EAN-13 code and write it that way
        return subWriter.encode("0" + contents, BarcodeFormat.EAN_13, width, height, hints);
    }
}
