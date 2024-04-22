/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package client.result

/**
 * Represents a parsed result that encodes wifi network information, like SSID and password.
 *
 * @author Vikram Aggarwal
 */
public open class WifiParsedResult <: ParsedResult {
    private var ssid: String = String()
    private var networkEncryption: String = String()
    private var password: String = String()
    private var hidden: Bool = false
    private var identity: String = String()
    private var anonymousIdentity: String = String()
    private var eapMethod: String = String()
    private var phase2Method: String = String()
    private var flag: Bool = false
    public init() {
        super(ParsedResultType.WIFI)
    }
    public func WifiParsedResult(networkEncryption: String, ssid: String, password: String) {
        (networkEncryption, ssid, password, false)
    }

    public func WifiParsedResult(networkEncryption: String, ssid: String, password: String, hidden: Bool) {
        (networkEncryption, ssid, password, hidden, "", "", "", "")
    }

    public init(
        networkEncryption: String,
        ssid: String,
        password: String,
        hidden: Bool,
        identity: String,
        anonymousIdentity: String,
        eapMethod: String,
        phase2Method: String
    ) {
        super(ParsedResultType.WIFI);
        this.ssid = ssid
        this.networkEncryption = networkEncryption
        this.password = password
        this.hidden = hidden
        this.identity = identity
        this.anonymousIdentity = anonymousIdentity
        this.eapMethod = eapMethod
        this.phase2Method = phase2Method
        this.flag = true
    }

    public func getSsid(): String {
        return ssid
    }

    public func getNetworkEncryption(): String {
        return networkEncryption
    }

    public func getPassword(): String {
        return password
    }

    public func isHidden(): Bool {
        return hidden
    }

    public func getIdentity(): String {
        return identity
    }

    public func getAnonymousIdentity(): String {
        return anonymousIdentity
    }

    public func getEapMethod(): String {
        return eapMethod
    }

    public func getPhase2Method(): String {
        return phase2Method
    }

    public override func getDisplayResult(): String {
        var result: ArrayList<Char> = ArrayList<Char>();
        maybeAppend(ssid, result);
        maybeAppend(networkEncryption, result);
        maybeAppend(password, result);
        maybeAppend(hidden.toString(), result);
        return String(result);
    }
}
