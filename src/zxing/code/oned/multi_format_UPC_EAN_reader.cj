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
 * <p>A reader that can read all available UPC/EAN formats. If a caller wants to try to
 * read all such formats, it is most efficient to use this implementation rather than invoke
 * individual readers.</p>
 *
 * @author Sean Owen
 */
public open class MultiFormatUPCEANReader <: OneDReader {
    private static let EMPTY_READER_ARRAY: Array<UPCEANReader> = Array<UPCEANReader>()

    private let readers: Array<UPCEANReader>

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

        var readers: ArrayList<UPCEANReader> = ArrayList<UPCEANReader>();
        if (possibleFormats.size != 0) {
            if (possibleFormats.contains(BarcodeFormat.EAN_13)) {
                readers.append(EAN13Reader());
            } else if (possibleFormats.contains(BarcodeFormat.UPC_A)) {
                readers.append(UPCAReader());
            }
            if (possibleFormats.contains(BarcodeFormat.EAN_8)) {
                readers.append(EAN8Reader());
            }
            if (possibleFormats.contains(BarcodeFormat.UPC_E)) {
                readers.append(UPCEReader());
            }
        }
        if (readers.isEmpty()) {
            readers.append(EAN13Reader());

            // UPC-A is covered by EAN-13
            readers.append(EAN8Reader());
            readers.append(UPCEReader());
        }
        this.readers = readers.toArray()
    }

    public func decodeRow(rowNumber: Int64, row: BitArray, hints: HashMap<DecodeHintType, Any>): Result {
        // Compute this location once and reuse it on multiple implementations
        var startGuardPattern: Array<Int64> = UPCEANReader.findStartGuardPattern(row);

        for (i in 0..readers.size) {
            try {
                var result: Result = readers[i].decodeRow(rowNumber, row, startGuardPattern, hints);

                // Special case: a 12-digit code encoded in UPC-A is identical to a "0"
                // followed by those 12 digits encoded as EAN-13. Each will recognize such a code,
                // UPC-A as a 12-digit string and EAN-13 as a 13-digit string starting with "0".
                // Individually these are correct and their readers will both read such a code
                // and correctly call it EAN-13, or UPC-A, respectively.
                //
                // In this case, if we've been looking for both types, we'd like to call it
                // a UPC-A code. But for efficiency we only run the EAN-13 decoder to also read
                // UPC-A. So we special case it here, and convert an EAN-13 result to a UPC-A
                // result if appropriate.
                //
                // But, don't return UPC-A if UPC-A was not a requested format!
                var ean13MayBeUPCA: Bool = result.getBarcodeFormat() == BarcodeFormat.EAN_13 &&
                    Char(result.getText()[0]) == '0'

                var possibleFormats: ArrayList<BarcodeFormat>
                if (hints.size == 0) {
                    possibleFormats = ArrayList<BarcodeFormat>()
                } else {
                    if (let Some(hints_one) <- hints.get(DecodeHintType.POSSIBLE_FORMATS)) {
                        possibleFormats = ArrayList<BarcodeFormat>((hints_one as BarcodeFormat).getOrThrow())
                    } else {
                        possibleFormats = ArrayList<BarcodeFormat>()
                    }
                }

                var canReturnUPCA: Bool = possibleFormats.isEmpty() || possibleFormats.contains(BarcodeFormat.UPC_A)

                if (ean13MayBeUPCA && canReturnUPCA) {
                    // Transfer the metadata across
                    var resultUPCA: Result = Result(
                        result.getText()[Range<Int64>(1, result.getText().size, 1, true, true, false)],
                        result.getRawBytes(),
                        result.getResultPoints(),
                        BarcodeFormat.UPC_A
                    );
                    resultUPCA.putAllMetadata(result.getResultMetadata());
                    return resultUPCA
                }
                return result
            } catch (ignored: ReaderException) {
                // continue
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
