/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.common

public open class WriterException <: Exception {
    public init() {
        super("NotFoundException")
    }

    public init(message: String) {
        super("WriterException: ${message}");
    }

    public init(cause: Exception) {
        super(cause.toString())
    }
}
