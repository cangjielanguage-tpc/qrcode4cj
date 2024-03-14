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
public open class NotFoundException <: ReaderException {
    public init() {
        super("NotFoundException")
    }

    public init(msg: String) {
        super("NotFoundException: ${msg}")
    }

    public static func getNotFoundInstance(): NotFoundException {
        return NotFoundException()
    }
}
