/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.common

public interface ResultPointCallback {
    func foundPossibleResultPoint(point: ResultPoint): Unit
}
