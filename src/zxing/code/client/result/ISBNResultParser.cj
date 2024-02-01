/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package zxing.code.client.result

import zxing.code.common.BarcodeFormat

/**
 * Parses strings of digits that represent a ISBN.
 *
 * @author jbreiden@google.com (Jeff Breidenbach)
 */
public open class ISBNResultParser <: ResultParser {
    /**
     * See <a href="http://www.bisg.org/isbn-13/for.dummies.html">ISBN-13 For Dummies</a>
     */
    public func parse(result: Result): ?ParsedResult {
        var format: BarcodeFormat = result.getBarcodeFormat();
        if (format != BarcodeFormat.EAN_13) {
            return None
        }
        var rawText: UTF32String = getMassagedText(result);
        var length: Int64 = rawText.charSize;
        if (length != 13) {
            return None
        }
        if (!rawText.startsWith(UTF32String("978")) && !rawText.startsWith(UTF32String("979"))) {
            return None
        }

        return ISBNParsedResult(rawText.toString());
    }
}
