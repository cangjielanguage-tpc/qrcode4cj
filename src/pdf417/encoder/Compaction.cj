/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package pdf417.encoder

/**
 * Represents possible PDF417 barcode compaction types.
 */
public enum Compaction <: ToString {
    | AUTO
    | TEXT
    | BYTE
    | NUMERIC

    public static func valueOf(str: String): Compaction {
        match (str) {
            case "AUTO" => return AUTO
            case "TEXT" => return TEXT
            case "BYTE" => return BYTE
            case "NUMERIC" => return NUMERIC
            case _ => throw ArithmeticException();
        }
    }

    public func toString(): String {
        match (this) {
            case AUTO => return "AUTO";
            case TEXT => return "TEXT";
            case BYTE => return "BYTE";
            case NUMERIC => return "NUMERIC";
        }
    }
}
