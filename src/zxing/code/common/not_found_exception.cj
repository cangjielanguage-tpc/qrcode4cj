/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.common

/**
 * Thrown when a barcode was not found in the image. It might have been
 * partially detected but could not be confirmed.
 *
 * @author Sean Owen
 */
public open class Qrcoder4cjNotFoundException <: Qrcoder4cjReaderException {
    public init() {
        super()
    }

    public init(msg: String) {
        super(msg)
    }

    public static func getNotFoundInstance(): Qrcoder4cjNotFoundException {
        return Qrcoder4cjNotFoundException()
    }

    public func toString(): String {
        return "Qrcoder4cjNotFoundException: " + message
    }
}
