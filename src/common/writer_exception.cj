/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package common

public open class Qrcoder4cjWriterException <: Exception {
    public init() {
        super()
    }

    public init(message: String) {
        super(message);
    }

    public init(cause: Exception) {
        super(cause.toString())
    }

    public func toString(): String {
        return "Qrcoder4cjWriterException: " + message
    }
}
