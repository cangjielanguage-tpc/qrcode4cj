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
public open class Qrcoder4cjFormatException <: Qrcoder4cjReaderException {
    public init() {
        super()
    }

    public init(msg: String) {
        super(msg)
    }

    public static func getFormatInstance(): Qrcoder4cjFormatException {
        return Qrcoder4cjFormatException()
    }

    public static func getFormatInstance(ex: Exception): Qrcoder4cjFormatException {
        return Qrcoder4cjFormatException(ex.toString())
    }

    public func toString(): String {
        return "Qrcoder4cjFormatException: " + message
    }
}
