/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common.reader

import QRCode4cj.aztec.AztecReader
import QRCode4cj.datamatrix.DataMatrixReader
import QRCode4cj.maxicode.MaxiCodeReader
import QRCode4cj.oned.MultiFormatOneDReader
import QRCode4cj.pdf417.PDF417Reader
import QRCode4cj.qrcode.QRCodeReader
import QRCode4cj.common.*
import std.collection.*

/**
 * MultiFormatReader is a convenience class and the main entry point into the library for most uses.
 * By default it attempts to decode all barcode formats that the library supports. Optionally, you
 * can provide a hints object to request different behavior, for example only decoding QR codes.
 */
public open class MultiFormatReader <: Reader {
    private static var EMPTY_READER_ARRAY: ArrayList<Reader> = ArrayList<Reader>()

    private var hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>()
    private var readers: ArrayList<Reader> = ArrayList<Reader>();

    public init() {}

    /**
     * This version of decode honors the intent of Reader.decode(BinaryBitmap) in that it
     * passes null as a hint to the decoders. However, that makes it inefficient to call repeatedly.
     * Use setHints() followed by decodeWithState() for continuous scan applications.
     *
     * @param image The pixel data to decode
     * @return The contents of the image
     * @throws Qrcoder4cjNotFoundException Any errors which occurred
     */
    @OverflowThrowing
    public func decode(image: BinaryBitmap): Result {
        setHints(HashMap<DecodeHintType, Any>())
        return decodeInternal(image)
    }

    /**
     * Decode an image using the hints provided. Does not honor existing state.
     *
     * @param image The pixel data to decode
     * @param hints The hints to use, clearing the previous state.
     * @return The contents of the image
     * @throws Qrcoder4cjNotFoundException Any errors which occurred
     */
    @OverflowThrowing
    public func decode(image: BinaryBitmap, hints: HashMap<DecodeHintType, Any>): Result {
        setHints(hints)
        let returndata = decodeInternal(image)
        return returndata
    }

    /**
     * Decode an image using the state set up by calling setHints() previously. Continuous scan
     * clients will get a <b>large</b> speed increase by using this instead of decode().
     *
     * @param image The pixel data to decode
     * @return The contents of the image
     * @throws Qrcoder4cjNotFoundException Any errors which occurred
     */
    @OverflowThrowing
    public func decodeWithState(image: BinaryBitmap): Result {
        // Make sure to set up the default state so we don't crash
        if (readers.size == 0) {
            setHints(HashMap<DecodeHintType, Any>())
        }
        return decodeInternal(image)
    }

    /**
     * This method adds state to the MultiFormatReader. By setting the hints once, subsequent calls
     * to decodeWithState(image) can reuse the same set of readers without reallocating memory. This
     * is important for performance in continuous scan clients.
     *
     * @param hints The set of hints to use for subsequent calls to decode(image)
     */
    public func setHints(hints: HashMap<DecodeHintType, Any>) {
        this.hints = hints

        let tryHarder: Bool = hints.size != 0 && hints.contains(DecodeHintType.TRY_HARDER)

        var formats: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        if (hints.size == 0) {
            if (let Some(possibleFormatsData) <- hints.get(DecodeHintType.POSSIBLE_FORMATS)) {
                formats = ArrayList<BarcodeFormat>([(possibleFormatsData as BarcodeFormat).getOrThrow()])
            } else {
                formats = ArrayList<BarcodeFormat>()
            }
        }

        var readers: ArrayList<Reader> = ArrayList<Reader>()
        if (formats.size != 0) {
            var addOneDReader: Bool = formats.contains(BarcodeFormat.UPC_A) || formats.contains(BarcodeFormat.UPC_E) ||
                formats.contains(BarcodeFormat.EAN_13) || formats.contains(BarcodeFormat.EAN_8) || formats.contains(
                BarcodeFormat.CODABAR) || formats.contains(BarcodeFormat.CODE_39) || formats.contains(
                BarcodeFormat.CODE_93) || formats.contains(BarcodeFormat.CODE_128) || formats.contains(
                BarcodeFormat.ITF) || formats.contains(BarcodeFormat.RSS_14) || formats.contains(
                BarcodeFormat.RSS_EXPANDED)

            // Put 1D readers upfront in "normal" mode
            extracsetHints(addOneDReader, tryHarder, readers, hints, formats)

            // At end in "try harder" mode
            if (addOneDReader && tryHarder) {
                readers.add(MultiFormatOneDReader(hints))
            }

            if (formats.contains(BarcodeFormat.PDF_417)) {
                readers.add(PDF417Reader(2))
            }
        }
        if (readers.isEmpty()) {
            if (!tryHarder) {
                readers.add(MultiFormatOneDReader(hints))
            }

            readers.add(QRCodeReader())
            readers.add(DataMatrixReader())
            readers.add(AztecReader())
            readers.add(PDF417Reader())
            readers.add(MaxiCodeReader())

            if (tryHarder) {
                readers.add(MultiFormatOneDReader(hints))
            }

            readers.add(PDF417Reader(2))
        }
        this.readers = readers
        EMPTY_READER_ARRAY = this.readers
    }

    public func extracsetHints(addOneDReader: Bool, tryHarder: Bool, readers: ArrayList<Reader>,
        hints: HashMap<DecodeHintType, Any>, formats: ArrayList<BarcodeFormat>) {
        if (addOneDReader && !tryHarder) {
            readers.add(MultiFormatOneDReader(hints))
        }
        if (formats.contains(BarcodeFormat.QR_CODE)) {
            readers.add(QRCodeReader())
        }
        if (formats.contains(BarcodeFormat.DATA_MATRIX)) {
            readers.add(DataMatrixReader())
        }
        if (formats.contains(BarcodeFormat.AZTEC)) {
            readers.add(AztecReader())
        }
        if (formats.contains(BarcodeFormat.PDF_417)) {
            readers.add(PDF417Reader())
        }
        if (formats.contains(BarcodeFormat.MAXICODE)) {
            readers.add(MaxiCodeReader())
        }
    }

    public func reset() {
        if (readers.size != 0) {
            for (i in 0..readers.size) {
                readers[i].reset()
            }
        }
    }

    private func decodeInternal(image: BinaryBitmap): Result {
        if (readers.size != 0) {
            for (i in 0..readers.size) {
                try {
                    let returndata = readers[i].decode(image, hints)
                    return returndata
                } catch (re: Qrcoder4cjReaderException) {
                    // continue
                }
            }
            if (hints.size != 0 && hints.contains(DecodeHintType.ALSO_INVERTED)) {
                // Calling all readers again with inverted image
                image.getBlackMatrix().flip()
                for (j in 0..readers.size) {
                    try {
                        let returndata = readers[j].decode(image, hints)
                        return returndata
                    } catch (re: Qrcoder4cjReaderException) {
                        // continue
                    }
                }
            }
        }
        throw Qrcoder4cjNotFoundException.getNotFoundInstance()
    }
}
