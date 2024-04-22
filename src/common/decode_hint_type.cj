/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package common

public enum DecodeHintType <: Hashable & Equatable<DecodeHintType> {
    /**
     * Unspecified, application-specific hint. Maps to an unspecified {@link Any}.
     */
    | OTHER
    /**
     * Image is a pure monochrome image of a barcode. Doesn't matter what it maps to
     * use {@link Boolean#TRUE}.
     */
    | PURE_BARCODE
    /**
     * Image is known to be of one of a few possible formats.
     * Maps to a {@link List} of {@link BarcodeFormat}s.
     */
    | POSSIBLE_FORMATS
    /**
     * Spend more time to try to find a barcode optimize for accuracy, not speed.
     * Doesn't matter what it maps to use {@link Boolean#TRUE}.
     */
    | TRY_HARDER
    /**
     * Specifies what character encoding to use when decoding, where applicable (type String)
     */
    | CHARACTER_SET
    /**
     * Allowed lengths of encoded data -- reject anything else. Maps to an {@code int[]}.
     */
    | ALLOWED_LENGTHS
    /**
     * Assume Code 39 codes employ a check digit. Doesn't matter what it maps to
     * use {@link Boolean#TRUE}.
     */
    | ASSUME_CODE_39_CHECK_DIGIT
    /**
     * Assume the barcode is being processed as a GS1 barcode, and modify behavior as needed.
     * For example this affects FNC1 handling for Code 128 (aka GS1-128). Doesn't matter what it maps to
     * use {@link Boolean#TRUE}.
     */
    | ASSUME_GS1
    /**
     * If true, return the start and end digits in a Codabar barcode instead of stripping them. They
     * are alpha, whereas the rest are numeric. By default, they are stripped, but this causes them
     * to not be. Doesn't matter what it maps to use {@link Boolean#TRUE}.
     */
    | RETURN_CODABAR_START_END
    /**
     * The caller needs to be notified via callback when a possible {@link ResultPoint}
     * is found. Maps to a {@link ResultPointCallback}.
     */
    | NEED_RESULT_POINT_CALLBACK
    /**
     * Allowed extension lengths for EAN or UPC barcodes. Other formats will ignore this.
     * Maps to an {@code int[]} of the allowed extension lengths, for example [2], [5], or [2, 5].
     * If it is optional to have an extension, do not set this hint. If this is set,
     * and a UPC or EAN barcode is found but an extension is not, then no result will be returned
     * at all.
     */
    | ALLOWED_EAN_EXTENSIONS
    /**
     * If true, also tries to decode as inverted image. All configured decoders are simply called a
     * second time with an inverted image. Doesn't matter what it maps to use {@link Boolean#TRUE}.
     */
    | ALSO_INVERTED

    // End of enumeration values.

    /**
     * Data type the hint is expecting.
     * Among the possible values the {@link Void} stands out as being used for
     * hints that do not expect a value to be supplied (flag hints). Such hints
     * will possibly have their value ignored, or replaced by a
     * {@link Boolean#TRUE}. Hint suppliers should probably use
     * {@link Boolean#TRUE} as directed by the actual hint documentation.
     */
    public func GetDecodeHintTypeNum(result: DecodeHintType): Int64 {
        match (result) {
            case OTHER => return 0
            case PURE_BARCODE => return 1
            case POSSIBLE_FORMATS => return 2
            case TRY_HARDER => return 3
            case CHARACTER_SET => return 4
            case ALLOWED_LENGTHS => return 5
            case ASSUME_CODE_39_CHECK_DIGIT => return 6
            case ASSUME_GS1 => return 7
            case RETURN_CODABAR_START_END => return 8
            case NEED_RESULT_POINT_CALLBACK => return 9
            case ALLOWED_EAN_EXTENSIONS => return 10
            case ALSO_INVERTED => return 11
        }
    }

    public operator func ==(right: DecodeHintType): Bool {
        if (GetDecodeHintTypeNum(right) == GetDecodeHintTypeNum(this)) {
            true;
        } else {
            false;
        }
    }

    public operator func !=(right: DecodeHintType): Bool {
        if (GetDecodeHintTypeNum(right) != GetDecodeHintTypeNum(this)) {
            true;
        } else {
            false;
        }
    }

    public func hashCode(): Int64 {
        return GetDecodeHintTypeNum(this);
    }
}
