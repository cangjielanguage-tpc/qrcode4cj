/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package client.result

/**

 * A simple result type encapsulating a string that has no further
 * interpretation.
 */
public open class TextParsedResult <: ParsedResult {
    private let text: String
    private let language: String

    public init(text: String, language: String) {
        super(ParsedResultType.TEXT);
        this.text = text
        this.language = language
    }

    public func getText(): String {
        return text
    }

    public func getLanguage(): String {
        return language
    }

    public override func getDisplayResult(): String {
        return text
    }
}
