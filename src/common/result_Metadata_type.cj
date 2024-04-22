/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package common

/**
 * Represents some type of metadata about the result of the decoding that the decoder
 * wishes to communicate back to the caller.
 *
 * @author Sean Owen
 */
public enum ResultMetadataType <: Equatable<ResultMetadataType> & Hashable & ToString {
    /**
     * Unspecified, application-specific metadata. Maps to an unspecified {@link Any}.
     */
    | OTHER
    /**
     * Denotes the likely approximate orientation of the barcode in the image. This value
     * is given as degrees rotated clockwise from the normal, upright orientation.
     * For example a 1D barcode which was found by reading top-to-bottom would be
     * said to have orientation "90". This key maps to an {@link Integer} whose
     * value is in the range [0,360).
     */
    | ORIENTATION
    /**
     * <p>2D barcode formats typically encode text, but allow for a sort of 'byte mode'
     * which is sometimes used to encode binary data. While {@link Result} makes available
     * the complete raw bytes in the barcode for these formats, it does not offer the bytes
     * from the byte segments alone.</p>
     *
     * <p>This maps to a {@link java.util.List} of byte arrays corresponding to the
     * raw bytes in the byte segments in the barcode, in order.</p>
     */
    | BYTE_SEGMENTS
    /**
     * Error correction level used, if applicable. The value type depends on the
     * format, but is typically a String.
     */
    | ERROR_CORRECTION_LEVEL
    /**
     * For some periodicals, indicates the issue number as an {@link Integer}.
     */
    | ISSUE_NUMBER
    /**
     * For some products, indicates the suggested retail price in the barcode as a
     * formatted {@link String}.
     */
    | SUGGESTED_PRICE
    /**
     * For some products, the possible country of manufacture as a {@link String} denoting the
     * ISO country code. Some map to multiple possible countries, like "US/CA".
     */
    | POSSIBLE_COUNTRY
    /**
     * For some products, the extension text
     */
    | UPC_EAN_EXTENSION
    /**
     * PDF417-specific metadata
     */
    | PDF417_EXTRA_METADATA
    /**
     * If the code format supports structured append and the current scanned code is part of one then the
     * sequence number is given with it.
     */
    | STRUCTURED_APPEND_SEQUENCE
    /**
     * If the code format supports structured append and the current scanned code is part of one then the
     * parity is given with it.
     */
    | STRUCTURED_APPEND_PARITY
    /**
     * Barcode Symbology Identifier.
     * Note: According to the GS1 specification the identifier may have to replace a leading FNC1/GS character
     * when prepending to the barcode content.
     */
    | SYMBOLOGY_IDENTIFIER

    public func GetResultMetadataTypeNum(result: ResultMetadataType): Int64 {
        match (result) {
            case OTHER => return 0;
            case ORIENTATION => return 1;
            case BYTE_SEGMENTS => return 2;
            case ERROR_CORRECTION_LEVEL => return 3;
            case ISSUE_NUMBER => return 4;
            case SUGGESTED_PRICE => return 5;
            case POSSIBLE_COUNTRY => return 6;
            case UPC_EAN_EXTENSION => return 7;
            case PDF417_EXTRA_METADATA => return 8;
            case STRUCTURED_APPEND_SEQUENCE => return 9;
            case STRUCTURED_APPEND_PARITY => return 10;
            case SYMBOLOGY_IDENTIFIER => return 11;
        }
    }

    public operator func ==(right: ResultMetadataType): Bool {
        if (GetResultMetadataTypeNum(right) == GetResultMetadataTypeNum(this)) {
            true;
        } else {
            false;
        }
    }

    public operator func !=(right: ResultMetadataType): Bool {
        if (GetResultMetadataTypeNum(right) != GetResultMetadataTypeNum(this)) {
            true;
        } else {
            false;
        }
    }

    public func hashCode(): Int64 {
        return GetResultMetadataTypeNum(this);
    }

    public func toString(): String {
        match (this) {
            case OTHER => return "OTHER";
            case ORIENTATION => return "ORIENTATION";
            case BYTE_SEGMENTS => return "BYTE_SEGMENTS";
            case ERROR_CORRECTION_LEVEL => return "ERROR_CORRECTION_LEVEL";
            case ISSUE_NUMBER => return "ISSUE_NUMBER";
            case SUGGESTED_PRICE => return "SUGGESTED_PRICE";
            case POSSIBLE_COUNTRY => return "POSSIBLE_COUNTRY";
            case UPC_EAN_EXTENSION => return "UPC_EAN_EXTENSION";
            case PDF417_EXTRA_METADATA => return "PDF417_EXTRA_METADATA";
            case STRUCTURED_APPEND_SEQUENCE => return "STRUCTURED_APPEND_SEQUENCE";
            case STRUCTURED_APPEND_PARITY => return "STRUCTURED_APPEND_PARITY";
            case SYMBOLOGY_IDENTIFIER => return "SYMBOLOGY_IDENTIFIER";
        }
    }

    public func valueOf(data: String): ResultMetadataType {
        if (data == "OTHER") {
            return OTHER
        } else if (data == "ORIENTATION") {
            return ORIENTATION
        } else if (data == "BYTE_SEGMENTS") {
            return BYTE_SEGMENTS
        } else if (data == "ERROR_CORRECTION_LEVEL") {
            return ERROR_CORRECTION_LEVEL
        } else if (data == "ISSUE_NUMBER") {
            return ISSUE_NUMBER
        } else if (data == "SUGGESTED_PRICE") {
            return SUGGESTED_PRICE
        } else if (data == "POSSIBLE_COUNTRY") {
            return POSSIBLE_COUNTRY
        } else if (data == "UPC_EAN_EXTENSION") {
            return UPC_EAN_EXTENSION
        } else if (data == "PDF417_EXTRA_METADATA") {
            return PDF417_EXTRA_METADATA
        } else if (data == "STRUCTURED_APPEND_SEQUENCE") {
            return STRUCTURED_APPEND_SEQUENCE
        } else if (data == "STRUCTURED_APPEND_PARITY") {
            return STRUCTURED_APPEND_PARITY
        } else {
            return SYMBOLOGY_IDENTIFIER
        }
    }
}
