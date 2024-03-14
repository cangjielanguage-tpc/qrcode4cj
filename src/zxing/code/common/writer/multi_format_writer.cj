/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.common.writer

import zxing.code.aztec.AztecWriter
import zxing.code.datamatrix.DataMatrixWriter
import zxing.code.oned.CodaBarWriter
import zxing.code.oned.Code128Writer
import zxing.code.oned.Code39Writer
import zxing.code.oned.Code93Writer
import zxing.code.oned.EAN13Writer
import zxing.code.oned.EAN8Writer
import zxing.code.oned.ITFWriter
import zxing.code.oned.UPCAWriter
import zxing.code.oned.UPCEWriter
import zxing.code.pdf417.PDF417Writer
import zxing.code.qrcode.QRCodeWriter
import zxing.code.common.*
from std import collection.*

/**
 * This is a factory class which finds the appropriate Writer subclass for the BarcodeFormat
 * requested and encodes the barcode with the supplied contents.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public open class MultiFormatWriter <: Writer {
    public override func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64
    ): BitMatrix {
        return encode(contents, format, width, height, HashMap<EncodeHintType, Any>())
    }

    public func encode(
        contents: String,
        format: BarcodeFormat,
        width: Int64,
        height: Int64,
        hints: HashMap<EncodeHintType, Any>
    ): BitMatrix {
        var writer: Writer
        match (format) {
            case EAN_8 => writer = EAN8Writer()
            case UPC_E => writer = UPCEWriter()
            case EAN_13 => writer = EAN13Writer()
            case UPC_A => writer = UPCAWriter()
            case QR_CODE => writer = QRCodeWriter()
            case CODE_39 => writer = Code39Writer()
            case CODE_93 => writer = Code93Writer()
            case CODE_128 => writer = Code128Writer()
            case ITF => writer = ITFWriter()
            case PDF_417 => writer = PDF417Writer()
            case CODABAR => writer = CodaBarWriter()
            case DATA_MATRIX => writer = DataMatrixWriter()
            case AZTEC => writer = AztecWriter()
            case _ => throw IllegalArgumentException("No encoder available for format " + format.toString())
        }
        return writer.encode(contents, format, width, height, hints)
    }
}
