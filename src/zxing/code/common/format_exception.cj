/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.common

/**
 * Thrown when a barcode was successfully detected, but some aspect of
 * the content did not conform to the barcode's format rules. This could have
 * been due to a mis-detection.
 *
 * @author Sean Owen
 */
public open class FormatException <: ReaderException {
    public init() {
        super("FormatException")
    }

    public init(msg: String) {
        super("FormatException: ${msg}")
    }

    public static func getFormatInstance(): FormatException {
        return FormatException()
    }

    public static func getFormatInstance(ex: Exception): FormatException {
        return FormatException(ex.toString())
    }
}
