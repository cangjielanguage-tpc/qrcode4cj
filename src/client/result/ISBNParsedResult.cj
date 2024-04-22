/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package client.result

/**
 * Represents a parsed result that encodes a product ISBN number.
 */
public open class ISBNParsedResult <: ParsedResult {
    private var isbn: String = String()
    private var flag: Bool = false
    init() {
        super(ParsedResultType.ISBN)
    }
    init(isbn: String) {
        super(ParsedResultType.ISBN);
        this.isbn = isbn
        this.flag = true
    }

    public func getISBN(): String {
        return isbn
    }

    public func getDisplayResult(): String {
        return isbn
    }
}
