/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package multi

from std import collection.*

/**
 * Implementation of this interface attempt to read several barcodes from one image.
 */
public interface MultipleBarcodeReader {
    func decodeMultiple(image: BinaryBitmap): Array<Result>

    func decodeMultiple(
        image: BinaryBitmap,
        hints: HashMap<DecodeHintType, Any>
    ): Array<Result>
}
