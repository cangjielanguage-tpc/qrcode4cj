/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

public open class MultiFormatOneDReader <: OneDReader {
    private static let EMPTY_ONED_ARRAY: Array<OneDReader> = Array<OneDReader>()

    private var readers: Array<OneDReader> = Array<OneDReader>()

    public init(hints: HashMap<DecodeHintType, Any>) {
        var possibleFormats: ArrayList<BarcodeFormat>
        if (hints.size == 0) {
            possibleFormats = ArrayList<BarcodeFormat>()
        } else {
            if (let Some(possibleFormatsData) <- hints.get(DecodeHintType.POSSIBLE_FORMATS)) {
                possibleFormats = ArrayList<BarcodeFormat>((possibleFormatsData as BarcodeFormat).getOrThrow())
            } else {
                possibleFormats = ArrayList<BarcodeFormat>()
            }
        }

        var useCode39CheckDigit: Bool = !hints.isEmpty() &&
            (hints.get(DecodeHintType.POSSIBLE_FORMATS) as BarcodeFormat) != Option<BarcodeFormat>.None
        var readers: ArrayList<OneDReader> = ArrayList<OneDReader>();
        if (!possibleFormats.isEmpty()) {
            if (possibleFormats.contains(BarcodeFormat.EAN_13) || possibleFormats.contains(BarcodeFormat.UPC_A) ||
                possibleFormats.contains(BarcodeFormat.EAN_8) || possibleFormats.contains(BarcodeFormat.UPC_E)) {
                readers.append(MultiFormatUPCEANReader(hints));
            }
            if (possibleFormats.contains(BarcodeFormat.CODE_39)) {
                readers.append(Code39Reader(useCode39CheckDigit));
            }
            if (possibleFormats.contains(BarcodeFormat.CODE_93)) {
                readers.append(Code93Reader());
            }
            if (possibleFormats.contains(BarcodeFormat.CODE_128)) {
                readers.append(Code128Reader());
            }
            if (possibleFormats.contains(BarcodeFormat.ITF)) {
                readers.append(ITFReader());
            }
            if (possibleFormats.contains(BarcodeFormat.CODABAR)) {
                readers.append(CodaBarReader());
            }
            if (possibleFormats.contains(BarcodeFormat.RSS_14)) {
                readers.append(RSS14Reader());
            }
            if (possibleFormats.contains(BarcodeFormat.RSS_EXPANDED)) {
                readers.append(RSSExpandedReader());
            }
        }
        if (readers.isEmpty()) {
            readers.append(MultiFormatUPCEANReader(hints));
            appendReader(readers)
        }
        this.readers = readers.toArray()
    }

    static func appendReader(readers: ArrayList<OneDReader>) {
        readers.append(Code39Reader());
        readers.append(CodaBarReader());
        readers.append(Code93Reader());
        readers.append(Code128Reader());
        readers.append(ITFReader());
        readers.append(RSS14Reader());
        readers.append(RSSExpandedReader());
    }

    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        for (i in 0..readers.size) {
            try {
                var result = readers[i].decodeRow(rowNumber, row, hints);
                return result
            } catch (re: ReaderException) {
                if (Thread.currentThread.hasPendingCancellation) {
                    return Result()
                }
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }

    public override func reset() {
        for (i in 0..readers.size) {
            readers[i].reset();
        }
    }
}
