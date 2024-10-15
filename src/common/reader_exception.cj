/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.common

public open class Qrcoder4cjReaderException <: Exception {
    public init() {
        super()
    }
    public init(msg: String) {
        super(msg)
    }

    public open func toString(): String {
        return "Qrcoder4cjReaderException: " + message
    }
}
