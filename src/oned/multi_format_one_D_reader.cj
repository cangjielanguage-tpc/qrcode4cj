/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned

import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.math.*
import QRCode4cj.oned.rss.*
import QRCode4cj.oned.rss.expanded.*

public open class MultiFormatOneDReader <: OneDReader {
    private static let EMPTY_ONED_ARRAY: Array<OneDReader> = Array<OneDReader>()

    private var readers: Array<OneDReader> = Array<OneDReader>()

    public init(hints: HashMap<DecodeHintType, Any>) {
        var possibleFormats: ArrayList<BarcodeFormat>
        if (hints.size == 0) {
            possibleFormats = ArrayList<BarcodeFormat>()
        } else {
            if (let Some(possibleFormatsData) <- hints.get(DecodeHintType.POSSIBLE_FORMATS)) {
                possibleFormats = ArrayList<BarcodeFormat>([(possibleFormatsData as BarcodeFormat).getOrThrow()])
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
                readers.add(MultiFormatUPCEANReader(hints));
            }
            if (possibleFormats.contains(BarcodeFormat.CODE_39)) {
                readers.add(Code39Reader(useCode39CheckDigit));
            }
            if (possibleFormats.contains(BarcodeFormat.CODE_93)) {
                readers.add(Code93Reader());
            }
            if (possibleFormats.contains(BarcodeFormat.CODE_128)) {
                readers.add(Code128Reader());
            }
            if (possibleFormats.contains(BarcodeFormat.ITF)) {
                readers.add(ITFReader());
            }
            if (possibleFormats.contains(BarcodeFormat.CODABAR)) {
                readers.add(CodaBarReader());
            }
            if (possibleFormats.contains(BarcodeFormat.RSS_14)) {
                readers.add(RSS14Reader());
            }
            if (possibleFormats.contains(BarcodeFormat.RSS_EXPANDED)) {
                readers.add(RSSExpandedReader());
            }
        }
        if (readers.isEmpty()) {
            readers.add(MultiFormatUPCEANReader(hints));
            appendReader(readers)
        }
        this.readers = readers.toArray()
    }

    static func appendReader(readers: ArrayList<OneDReader>) {
        readers.add(Code39Reader());
        readers.add(CodaBarReader());
        readers.add(Code93Reader());
        readers.add(Code128Reader());
        readers.add(ITFReader());
        readers.add(RSS14Reader());
        readers.add(RSSExpandedReader());
    }

    public override func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        for (i in 0..readers.size) {
            try {
                var result = readers[i].decodeRow(rowNumber, row, hints);
                return result
            } catch (re: Qrcoder4cjReaderException) {
                if (Thread.currentThread.hasPendingCancellation) {
                    return Result()
                }
            }
        }
        throw Qrcoder4cjNotFoundException.getNotFoundInstance();
    }

    public override func reset() {
        for (i in 0..readers.size) {
            readers[i].reset();
        }
    }
}
