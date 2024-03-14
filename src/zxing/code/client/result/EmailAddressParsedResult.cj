/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.client.result

/**
 * Represents a parsed result that encodes an email message including recipients, subject
 * and body text.
 *
 * @author Sean Owen
 */
public open class EmailAddressParsedResult <: ParsedResult {
    private var tos: Array<String> = Array<String>()
    private var ccs: Array<String> = Array<String>()
    private var bccs: Array<String> = Array<String>()
    private var subject: String = String()
    private var body: String = String()
    public var flag: Bool = false
    public init() {
        super(ParsedResultType.EMAIL_ADDRESS)
    }

    init(to: String) {
        this([to], [], [], "", "");
        this.flag = true
    }

    init(
        tos: Array<String>,
        ccs: Array<String>,
        bccs: Array<String>,
        subject: String,
        body: String
    ) {
        super(ParsedResultType.EMAIL_ADDRESS);
        this.tos = tos
        this.ccs = ccs
        this.bccs = bccs
        this.subject = subject
        this.body = body
        this.flag = true
    }

    /**
     * @return first elements of {@link #getTos()} or {@code null} if none
     * @deprecated use {@link #getTos()}
     */
    public func getEmailAddress(): String {
        if (tos.size == 0) {
            return ""
        } else {
            return tos[0]
        }
    }

    public func getTos(): Array<String> {
        return tos
    }

    public func getCCs(): Array<String> {
        return ccs
    }

    public func getBCCs(): Array<String> {
        return bccs
    }

    public func getSubject(): String {
        return subject
    }

    public func getBody(): String {
        return body
    }

    /**
     * @return "mailto:"
     * @deprecated without replacement
     */
    public func getMailtoURI(): String {
        return "mailto:"
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        maybeAppend(tos, result);
        maybeAppend(ccs, result);
        maybeAppend(bccs, result);
        maybeAppend(subject, result);
        maybeAppend(body, result);
        return String(result);
    }
}
