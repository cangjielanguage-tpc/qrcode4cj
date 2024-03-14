/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.client.result


public abstract class AbstractDoCoMoResultParser <: ResultParser {
    static func matchDoCoMoPrefixedField(prefix: String, rawText: UTF32String): Array<String> {
        return matchPrefixedField(prefix, rawText, ';', true);
    }

    static func matchSingleDoCoMoPrefixedField(prefix: String, rawText: UTF32String, trim: Bool): String {
        return matchSinglePrefixedField(prefix, rawText, ';', trim);
    }
}
