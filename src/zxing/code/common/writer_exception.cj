/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.common

public open class Qrcoder4cjWriterException <: Exception {
    public init() {
        super("Qrcoder4cjWriterException")
    }

    public init(message: String) {
        super("Qrcoder4cjWriterException: ${message}");
    }

    public init(cause: Exception) {
        super(cause.toString())
    }
}
