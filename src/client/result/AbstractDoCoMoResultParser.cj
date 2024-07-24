/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.client.result

import QRCode4cj.tools.*

public abstract class AbstractDoCoMoResultParser <: ResultParser {
    static func matchDoCoMoPrefixedField(prefix: String, rawText: UTF32String): Array<String> {
        return matchPrefixedField(prefix, rawText, r';', true);
    }

    static func matchSingleDoCoMoPrefixedField(prefix: String, rawText: UTF32String, trim: Bool): String {
        return matchSinglePrefixedField(prefix, rawText, r';', trim);
    }
}
