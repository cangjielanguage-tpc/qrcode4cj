/*
 * Copyright 2008 ZXing authors
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

package zxing.code.oned

/**
 * <p>Implements decoding of the UPC-A format.</p>
 *
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */
public open class UPCAReader <: UPCEANReader {
    private let ean13Reader: UPCEANReader = EAN13Reader();

    public override func decodeRow(
        rowNumber: Int64,
        row: BitArray,
        startGuardRange: Array<Int64>,
        hints: HashMap<DecodeHintType, Any>
    ): Result {
        return maybeReturnResult(ean13Reader.decodeRow(rowNumber, row, startGuardRange, hints));
    }

    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        return maybeReturnResult(ean13Reader.decodeRow(rowNumber, row, hints));
    }

    public override func decode(image: BinaryBitmap): Result {
        return maybeReturnResult(ean13Reader.decode(image));
    }

    public override func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        return maybeReturnResult(ean13Reader.decode(image, hints));
    }

    public override func getBarcodeFormat(): BarcodeFormat {
        return BarcodeFormat.UPC_A;
    }

    protected override func decodeMiddle(row: BitArray, startRange: Array<Int64>, resultString: ArrayList<Char>): Int64 {
        return ean13Reader.decodeMiddle(row, startRange, resultString);
    }

    private func maybeReturnResult(result: Result): Result {
        var text: UTF32String = UTF32String(result.getText());
        if (text[0] == '0') {
            var upcaResult: Result = Result(
                text.substring(0, 1).toString(),
                Array<UInt8>(),
                result.getResultPoints(),
                BarcodeFormat.UPC_A
            );
            if (!result.getResultMetadata().isEmpty()) {
                upcaResult.putAllMetadata(result.getResultMetadata());
            }
            return upcaResult
        } else {
            throw FormatException.getFormatInstance();
        }
    }
}
