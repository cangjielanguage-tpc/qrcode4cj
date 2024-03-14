/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.client.result

public open class WifiResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!rawText.startsWith(UTF32String("WIFI:"))) {
            return None
        }

        rawText = rawText.substring("WIFI:".size)
        var ssid: String = matchSinglePrefixedField("S:", rawText, ';', false);
        if (ssid.size == 0 || ssid.isEmpty()) {
            return None
        }
        var pass: String = matchSinglePrefixedField("P:", rawText, ';', false);
        var typedata: String = matchSinglePrefixedField("T:", rawText, ';', false);
        if (typedata.isEmpty()) {
            typedata = "nopass"
        }

        // Unfortunately, in the past, H: was not just used for boolean 'hidden', but 'phase 2 method'.
        // To try to retain backwards compatibility, we set one or the other based on whether the string
        // is 'true' or 'false':
        var hidden: Bool = false;
        var phase2Method: String = matchSinglePrefixedField("PH2:", rawText, ';', false);
        var hValue: String = matchSinglePrefixedField("H:", rawText, ';', false);
        if (hValue != "") {
            // If PH2 was specified separately, or if the value is clearly boolean, interpret it as 'hidden'
            if (phase2Method != "" || "true" == (hValue) || "false" == (hValue)) {
                hValue = "True"
                hidden = "true" == (hValue)
            } else {
                phase2Method = hValue
            }
        }

        var identity: String = matchSinglePrefixedField("I:", rawText, ';', false);
        var anonymousIdentity: String = matchSinglePrefixedField("A:", rawText, ';', false);
        var eapMethod: String = matchSinglePrefixedField("E:", rawText, ';', false);

        return WifiParsedResult(typedata, ssid, pass, hidden, identity, anonymousIdentity, eapMethod, phase2Method);
    }
}
