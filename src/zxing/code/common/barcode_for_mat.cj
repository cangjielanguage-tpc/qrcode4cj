/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.common

public enum BarcodeFormat <: ToString & Equatable<BarcodeFormat> {
    /** Aztec 2D barcode format. */
    | AZTEC
    /** CODABAR 1D format. */
    | CODABAR
    /** Code 39 1D format. */
    | CODE_39
    /** Code 93 1D format. */
    | CODE_93
    /** Code 128 1D format. */
    | CODE_128
    /** Data Matrix 2D barcode format. */
    | DATA_MATRIX
    /** EAN-8 1D format. */
    | EAN_8
    /** EAN-13 1D format. */
    | EAN_13
    /** ITF (Interleaved Two of Five) 1D format. */
    | ITF
    /** MaxiCode 2D barcode format. */
    | MAXICODE
    /** PDF417 format. */
    | PDF_417
    /** QR Code 2D barcode format. */
    | QR_CODE
    /** RSS 14 */
    | RSS_14
    /** RSS EXPANDED */
    | RSS_EXPANDED
    /** UPC-A 1D format. */
    | UPC_A
    /** UPC-E 1D format. */
    | UPC_E
    /** UPC/EAN extension format. Not a stand-alone format. */
    | UPC_EAN_EXTENSION
    | NONE

    public operator func ==(right: BarcodeFormat): Bool {
        if (right.toString() == this.toString()) {
            true;
        } else {
            false;
        }
    }

    public operator func !=(right: BarcodeFormat): Bool {
        if (right.toString() != this.toString()) {
            true;
        } else {
            false;
        }
    }

    public func toString(): String {
        match (this) {
            case AZTEC => return "AZTEC";
            case CODABAR => return "CODABAR";
            case CODE_39 => return "CODE_39";
            case CODE_93 => return "CODE_93";
            case CODE_128 => return "CODE_128";
            case DATA_MATRIX => return "DATA_MATRIX";
            case EAN_8 => return "EAN_8";
            case EAN_13 => return "EAN_13";
            case ITF => return "ITF";
            case MAXICODE => return "MAXICODE";
            case PDF_417 => return "PDF_417";
            case QR_CODE => return "QR_CODE";
            case RSS_14 => return "RSS_14";
            case RSS_EXPANDED => return "RSS_EXPANDED";
            case UPC_A => return "UPC_A";
            case UPC_E => return "UPC_E";
            case UPC_EAN_EXTENSION => return "UPC_EAN_EXTENSION";
            case NONE => return "NONE"
        }
    }
}
