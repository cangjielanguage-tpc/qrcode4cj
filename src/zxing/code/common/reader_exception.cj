/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.common

from std import os.*

public open class ReaderException <: Exception {
    public init() {
        super()
    }
    public init(msg: String) {
        super(msg)
    }
}
