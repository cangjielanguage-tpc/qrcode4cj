/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.
 */
public open class UPCEANWriter <: OneDimensionalCodeWriter {
    public open func encode(_: String): Array<Bool> {
        Array<Bool>()
    }

    public override func getDefaultMargin(): Int64 {
        // Use a different default more appropriate for UPC/EAN
        return 9;
    }
}
