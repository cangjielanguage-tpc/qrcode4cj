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
 * Represents a parsed result that encodes a telephone number.
 *
 * @author Sean Owen
 */
public open class TelParsedResult <: ParsedResult {
    private var number: String = String()
    private var telURI: String = String()
    private var title: String = String()
    private var flag: Bool = false
    public init() {
        super(ParsedResultType.TEL)
    }
    public init(number: String, telURI: String, title: String) {
        super(ParsedResultType.TEL);
        this.number = number
        this.telURI = telURI
        this.title = title
        this.flag = true
    }

    public func getNumber(): String {
        return number
    }

    public func getTelURI(): String {
        return telURI
    }

    public func getTitle(): String {
        return title
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        maybeAppend(number, result);
        maybeAppend(title, result);
        return String(result);
    }
}
