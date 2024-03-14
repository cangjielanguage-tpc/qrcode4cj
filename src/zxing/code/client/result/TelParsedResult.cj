/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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
