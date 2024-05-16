/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package client.result

/**
 * A simple result type encapsulating a URI that has no further interpretation.
 */
public open class URIParsedResult <: ParsedResult {
    private var uri: String = String()
    private var title: String = String()
    private var flag: Bool = false
    public init() {
        super(ParsedResultType.URI)
    }
    public init(uri: String, title: String) {
        super(ParsedResultType.URI);
        this.uri = massageURI(uri)
        this.title = title
        this.flag = true
    }

    public func getURI(): String {
        return uri
    }

    public func getTitle(): String {
        return title
    }

    /**
     * @return true if the URI contains suspicious patterns that may suggest it intends to
     * mislead the user about its true nature
     * @deprecated see {@link URIResultParser#isPossiblyMaliciousURI(String)}
     */
    // @Deprecated
    public func isPossiblyMaliciousURI(): Bool {
        return URIResultParser.isPossiblyMaliciousURI(uri);
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        maybeAppend(title, result);
        maybeAppend(uri, result);
        return String(result);
    }

    /**
     * Transforms a string that represents a URI into something more proper, by adding or canonicalizing
     * the protocol.
     */
    private static func massageURI(uria: String): String {
        var uri = uria
        uri = uri.trim()
        var protocolEnd: Int64 = 0
        if (uri.indexOf(':'.toString()) != None) {
            protocolEnd = uri.indexOf(':'.toString()).getOrThrow()
        } else {
            protocolEnd = -1
        }
        if (protocolEnd < 0 || isColonFollowedByPortNumber(uri, protocolEnd)) {
            // No protocol, or found a colon, but it looks like it is after the host, so the protocol is still missing,
            // so assume http
            uri = "http://" + uri
        }
        return uri
    }

    private static func isColonFollowedByPortNumber(uri: String, protocolEnd: Int64): Bool {
        var uriin = UTF32String(uri)
        var start: Int64 = protocolEnd + 1
        var nextSlash = 0
        if (uriin.indexOf('/'.toString(), start: start) != None) {
            nextSlash = uriin.indexOf('/'.toString(), start: start).getOrThrow()
        } else {
            nextSlash = -1
        }
        if (nextSlash < 0) {
            nextSlash = uriin.charSize
        }
        return ResultParser.isSubstringOfDigits(uriin, start, nextSlash - start);
    }
}
