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

/**
 * <p>Parses an "smsto:" URI result, whose format is not standardized but appears to be like:
 * {@code smsto:number(:body)}.</p>
 *
 * <p>This actually also parses URIs starting with "smsto:", "mmsto:", "SMSTO:", and
 * "MMSTO:", and treats them all the same way, and effectively converts them to an "sms:" URI
 * for purposes of forwarding to the platform.</p>
 *
 * @author Sean Owen
 */
public open class SMSTOMMSTOResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!(rawText.startsWith(UTF32String("smsto:")) || rawText.startsWith(UTF32String("SMSTO:")) ||
            rawText.startsWith(UTF32String("mmsto:")) || rawText.startsWith(UTF32String("MMSTO:")))) {
            return None
        }

        // Thanks to dominik.wild for suggesting this enhancement to support
        // smsto:number:body URIs
        var number: UTF32String = rawText.substring(6);
        var body: UTF32String = UTF32String("");
        var bodyStart = number.indexOf(':'.toString());
        if (bodyStart != None) {
            body = number.substring(bodyStart.getOrThrow() + 1)
            number = number.substring(0, bodyStart.getOrThrow())
        }
        return SMSParsedResult(number.toString(), "", "", body.toString());
    }
}
