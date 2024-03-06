/*
 * Copyright 2010 ZXing authors
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
 * <p>Parses an "smtp:" URI result, whose format is not standardized but appears to be like:
 * {@code smtp[:subject[:body]]}.</p>
 *
 * @author Sean Owen
 */
public open class SMTPResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!(rawText.startsWith(UTF32String("smtp:")) || rawText.startsWith(UTF32String("SMTP:")))) {
            return None
        }
        var emailAddress: UTF32String = rawText.substring(5);
        var subject: UTF32String = UTF32String()
        var body: UTF32String = UTF32String()
        var colon = emailAddress.indexOf(':'.toString());
        if (colon != None) {
            subject = emailAddress.substring(colon.getOrThrow() + 1)
            emailAddress = emailAddress.substring(0, colon.getOrThrow())
            colon = subject.indexOf(':'.toString())
            if (colon != None) {
                body = subject.substring(colon.getOrThrow() + 1)
                subject = subject.substring(0, colon.getOrThrow())
            }
        }
        return EmailAddressParsedResult(
            Array<String>([emailAddress.toString()]),
            Array<String>(),
            Array<String>(),
            subject.toString(),
            body.toString()
        );
    }
}
