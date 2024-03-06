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

from charset import charset.tools.UTF32String

/**
 * Represents a parsed result that encodes an SMS message, including recipients, subject
 * and body text.
 *
 * @author Sean Owen
 */
public open class SMSParsedResult <: ParsedResult {
    private var numbers: Array<String> = Array<String>()
    private var vias: Array<String> = Array<String>()
    private var subject: String = String()
    private var body: String = String()
    private var flag: Bool = false
    init() {
        super(ParsedResultType.SMS)
    }
    public init(number: String, via: String, subject: String, body: String) {
        super(ParsedResultType.SMS);
        this.numbers = [number]
        this.vias = [via]
        this.subject = subject
        this.body = body
    }

    public init(numbers: Array<String>, vias: Array<String>, subject: String, body: String) {
        super(ParsedResultType.SMS);
        this.numbers = numbers
        this.vias = vias
        this.subject = subject
        this.body = body
        this.flag = true
    }

    public func getSMSURI(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        result.appendAll("sms:".toRuneArray());
        var first: Bool = true;
        for (i in 0..numbers.size) {
            if (first) {
                first = false
            } else {
                result.append(',');
            }
            result.appendAll(numbers[i].toRuneArray());
            if (vias.size != 0 && !vias[i].isEmpty()) {
                result.appendAll(";via=".toRuneArray());
                result.appendAll(vias[i].toRuneArray());
            }
        }
        var hasBody: Bool = body != ""
        var hasSubject: Bool = subject != ""
        if (hasBody || hasSubject) {
            result.append('?');
            if (hasBody) {
                result.appendAll("body=".toRuneArray());
                result.appendAll(body.toRuneArray());
            }
            if (hasSubject) {
                if (hasBody) {
                    result.append('&');
                }
                result.appendAll("subject=".toRuneArray());
                result.appendAll(subject.toRuneArray());
            }
        }
        return String(result);
    }

    public func getNumbers(): Array<String> {
        return numbers
    }

    public func getVias(): Array<String> {
        return vias
    }

    public func getSubject(): String {
        return subject
    }

    public func getBody(): String {
        return body
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        maybeAppend(numbers, result);
        maybeAppend(subject, result);
        maybeAppend(body, result);
        return String(result);
    }
}
