/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common


public enum EncodeHintType <: Hashable & Equatable<EncodeHintType> {
    /**
     * Specifies what degree of error correction to use, for example in QR Codes.
     * Type depends on the encoder. For example for QR codes it's type
     * {@link com.google.zxing.qrcode.decoder.ErrorCorrectionLevel ErrorCorrectionLevel}.
     * For Aztec it is of type {@link Integer}, representing the minimal percentage of error correction words.
     * For PDF417 it is of type {@link Integer}, valid values being 0 to 8.
     * In all cases, it can also be a {@link String} representation of the desired value as well.
     * Note: an Aztec symbol should have a minimum of 25% EC words.
     */
    | ERROR_CORRECTION
    /**
     * Specifies what character encoding to use where applicable (type {@link String})
     */
    | CHARACTER_SET
    /**
     * Specifies the matrix shape for Data Matrix (type {@link com.google.zxing.datamatrix.encoder.SymbolShapeHint})
     */
    | DATA_MATRIX_SHAPE

    | DATA_MATRIX_COMPACT
    /**
     * Specifies a minimum barcode size (type {@link Dimension}). Only applicable to Data Matrix now.
     *
     * @deprecated use width/height params in
     * {@link com.google.zxing.datamatrix.DataMatrixWriter#encode(String, BarcodeFormat, int, int)}
     */
    | MIN_SIZE
    /**
     * Specifies a maximum barcode size (type {@link Dimension}). Only applicable to Data Matrix now.
     *
     * @deprecated without replacement
     */
    | MAX_SIZE
    /**
     * Specifies margin, in pixels, to use when generating the barcode. The meaning can vary
     * by format for example it controls margin before and after the barcode horizontally for
     * most 1D formats. (Type {@link Integer}, or {@link String} representation of the integer value).
     */
    | MARGIN
    /**
     * Specifies whether to use compact mode for PDF417 (type {@link Boolean}, or "true" or "false"
     * {@link String} value).
     */
    | PDF417_COMPACT
    /**
     * Specifies what compaction mode to use for PDF417 (type
     * {@link com.google.zxing.pdf417.encoder.Compaction Compaction} or {@link String} value of one of its
     * enum values).
     */
    | PDF417_COMPACTION
    /**
     * Specifies the minimum and maximum number of rows and columns for PDF417 (type
     * {@link com.google.zxing.pdf417.encoder.Dimensions Dimensions}).
     */
    | PDF417_DIMENSIONS
    /**
     * Specifies whether to automatically insert ECIs when encoding PDF417 (type {@link Boolean}, or "true" or "false"
     * {@link String} value).
     * Please note that in that case, the most compact character encoding is chosen for characters in
     * the input that are not in the ISO-8859-1 character set. Based on experience, some scanners do not
     * support encodings like cp-1256 (Arabic). In such cases the encoding can be forced to UTF-8 by
     * means of the {@link #CHARACTER_SET} encoding hint.
     */
    | PDF417_AUTO_ECI
    /**
     * Specifies the required number of layers for an Aztec code.
     * A negative number (-1, -2, -3, -4) specifies a compact Aztec code.
     * 0 indicates to use the minimum number of layers (the default).
     * A positive number (1, 2, .. 32) specifies a normal (non-compact) Aztec code.
     * (Type {@link Integer}, or {@link String} representation of the integer value).
     */
    | AZTEC_LAYERS
    /**
     * Specifies the exact version of QR code to be encoded.
     * (Type {@link Integer}, or {@link String} representation of the integer value).
     */
    | QR_VERSION
    /**
     * Specifies the QR code mask pattern to be used. Allowed values are
     * 0..QRCode.NUM_MASK_PATTERNS-1. By default the code will automatically select
     * the optimal mask pattern.
     * * (Type {@link Integer}, or {@link String} representation of the integer value).
     */
    | QR_MASK_PATTERN
    /**
     * Specifies whether to use compact mode for QR code (type {@link Boolean}, or "true" or "false"
     * {@link String } value).
     * Please note that when compaction is performed, the most compact character encoding is chosen
     * for characters in the input that are not in the ISO-8859-1 character set. Based on experience|   * some scanners do not support encodings like cp-1256 (Arabic). In such cases the encoding can
     * be forced to UTF-8 by means of the {@link #CHARACTER_SET} encoding hint.
     */
    | QR_COMPACT
    /**
     * Specifies whether the data should be encoded to the GS1 standard (type {@link Boolean}, or "true" or "false"
     * {@link String } value).
     */
    | GS1_FORMAT
    /**
     * Forces which encoding will be used. Currently only used for Code-128 code sets (Type {@link String}).
     * Valid values are "A", "B", "C".
     * This option and {@link #CODE128_COMPACT} are mutually exclusive.
     */
    | FORCE_CODE_SET
    /**
     * Forces C40 encoding for data-matrix (type {@link Boolean}, or "true" or "false") {@link String } value). This
     * option and {@link #DATA_MATRIX_COMPACT} are mutually exclusive.
     */
    | FORCE_C40
    /**
     * Specifies whether to use compact mode for Code-128 code (type {@link Boolean}, or "true" or "false"
     * {@link String } value).
     * This can yield slightly smaller bar codes. This option and {@link #FORCE_CODE_SET} are mutually
     * exclusive.
     */
    | CODE128_COMPACT

    public func GetEncodeHintTypeNum(result: EncodeHintType): Int64 {
        match (result) {
            case ERROR_CORRECTION => return 0
            case CHARACTER_SET => return 1
            case DATA_MATRIX_SHAPE => return 2
            case DATA_MATRIX_COMPACT => return 3
            case MIN_SIZE => return 4
            case MAX_SIZE => return 5
            case MARGIN => return 6
            case PDF417_COMPACT => return 7
            case PDF417_COMPACTION => return 8
            case PDF417_DIMENSIONS => return 9
            case PDF417_AUTO_ECI => return 10
            case AZTEC_LAYERS => return 11
            case QR_VERSION => return 12
            case QR_MASK_PATTERN => return 13
            case QR_COMPACT => return 14
            case GS1_FORMAT => return 15
            case FORCE_CODE_SET => return 16
            case FORCE_C40 => return 17
            case CODE128_COMPACT => return 18
        }
    }

    public operator func ==(right: EncodeHintType): Bool {
        if (GetEncodeHintTypeNum(right) == GetEncodeHintTypeNum(this)) {
            true;
        } else {
            false;
        }
    }

    public operator func !=(right: EncodeHintType): Bool {
        if (GetEncodeHintTypeNum(right) != GetEncodeHintTypeNum(this)) {
            true;
        } else {
            false;
        }
    }

    public func hashCode(): Int64 {
        return GetEncodeHintTypeNum(this);
    }

    public static func getHashMapValue(key: EncodeHintType, value: Any): String {
        match (key) {
            case MARGIN | AZTEC_LAYERS | QR_VERSION | QR_MASK_PATTERN => return if (value is Int64) {
                (value as Int64).getOrThrow().toString()
            } else {
                (value as String).getOrThrow()
            }
            case CHARACTER_SET | FORCE_CODE_SET => return (value as String).getOrThrow()
            case DATA_MATRIX_SHAPE => return "DATA_MATRIX_SHAPE"
            case DATA_MATRIX_COMPACT | PDF417_COMPACT | PDF417_AUTO_ECI | QR_COMPACT | GS1_FORMAT | FORCE_C40 | CODE128_COMPACT => return if (value is Bool) {
                (value as Bool).getOrThrow().toString()
            } else {
                (value as String).getOrThrow()
            }
            case MIN_SIZE => return "MIN_SIZE"
            case MAX_SIZE => return "MAX_SIZE"

            case PDF417_COMPACTION => return "PDF417_COMPACTION"
            case PDF417_DIMENSIONS => return "PDF417_DIMENSIONS"
            case ERROR_CORRECTION => return "ERROR_CORRECTION"
        }
    }
}
