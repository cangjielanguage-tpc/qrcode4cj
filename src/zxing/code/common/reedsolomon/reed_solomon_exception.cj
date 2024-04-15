/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.common.reedsolomon

public class Qrcoder4cjReedSolomonException <: Exception {
    public Qrcoder4cjReedSolomonException(message: String) {
        super(message)
    }

    public func toString(): String {
        return "Qrcoder4cjReedSolomonException: " + message
    }
}
