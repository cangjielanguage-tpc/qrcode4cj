/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned

/**
 * Implements decoding of the UPC-A format.
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
            throw Qrcoder4cjFormatException.getFormatInstance();
        }
    }
}
