/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package datamatrix.encoder

class DataMatrixSymbolInfo144 <: SymbolInfo {
    init() {
        super(false, 1558, 620, 22, 22, 36, -1, 62);
    }

    public func getInterleavedBlockCount(): Int64 {
        return 10;
    }

    public func getDataLengthForInterleavedBlock(index: Int64): Int64 {
        if (index <= 8) {
            return 156
        } else {
            return 155
        }
    }
}
