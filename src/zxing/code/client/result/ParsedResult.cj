/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.client.result

/**
 * <p>Abstract class representing the result of decoding a barcode, as more than
 * a String -- as some type of structured data. This might be a subclass which represents
 * a URL, or an e-mail address. {@link ResultParser#parseResult(com.google.zxing.Result)} will turn a raw
 * decoded string into the most appropriate type of structured representation.</p>
 *
 * <p>Thanks to Jeff Griffin for proposing rewrite of these classes that relies less
 * on exception-based mechanisms during parsing.</p>
 *
 * @author Sean Owen
 */
public abstract class ParsedResult {
    private let thistype: ParsedResultType

    protected init(thistype: ParsedResultType) {
        this.thistype = thistype
    }

    public func getType(): ParsedResultType {
        return thistype
    }

    public open func getDisplayResult(): String {
        return ""
    }

    public func toString(): String {
        return getDisplayResult();
    }

    public static func maybeAppend(value: String, result: ArrayList<Char>) {
        if (value != "" && !value.isEmpty()) {
            // Don't add a newline before the first value
            if (result.size > 0) {
                result.append('\n');
            }
            result.appendAll(value.toRuneArray());
        }
    }

    public static func maybeAppend(values: Array<String>, result: ArrayList<Char>) {
        if (values != []) {
            for (value in values) {
                maybeAppend(value, result);
            }
        }
    }
}
