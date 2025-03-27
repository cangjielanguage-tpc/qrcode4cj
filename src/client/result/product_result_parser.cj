/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.client.result

import QRCode4cj.oned.UPCEReader
import QRCode4cj.common.*
import QRCode4cj.tools.*

/**
 * Parses strings of digits that represent a UPC code.
 */
public open class ProductResultParser <: ResultParser {
    // Treat all UPC and EAN variants as UPCs, in the sense that they are all product barcodes.
    public override func parse(result: Result): ?ParsedResult {
        var format: BarcodeFormat = result.getBarcodeFormat();
        if (!(format == BarcodeFormat.UPC_A || format == BarcodeFormat.UPC_E || format == BarcodeFormat.EAN_8 ||
            format == BarcodeFormat.EAN_13)) {
            return None
        }
        var rawText: UTF32String = getMassagedText(result);
        if (!isStringOfDigits(rawText.toString(), rawText.charSize)) {
            return None
        }

        // Not actually checking the checksum again here    
        var normalizedProductID: String

        // Expand UPC-E for purposes of searching
        if (format == BarcodeFormat.UPC_E && rawText.charSize == 8) {
            normalizedProductID = UPCEReader.convertUPCEtoUPCA(rawText).toString()
        } else {
            normalizedProductID = rawText.toString()
        }
        return ProductParsedResult(rawText.toString(), normalizedProductID);
    }
}
