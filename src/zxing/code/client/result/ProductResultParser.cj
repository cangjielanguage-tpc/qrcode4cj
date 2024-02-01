/*
 * Copyright 2007 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package zxing.code.client.result

import zxing.code.oned.UPCEReader

/**
 * Parses strings of digits that represent a UPC code.
 *
 * @author dswitkin@google.com (Daniel Switkin)
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
