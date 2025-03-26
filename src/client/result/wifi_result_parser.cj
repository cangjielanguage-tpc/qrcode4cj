/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.client.result

import QRCode4cj.tools.*
import QRCode4cj.common.*

public open class WifiResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var rawText: UTF32String = getMassagedText(result);
        if (!rawText.startsWith(UTF32String("WIFI:"))) {
            return None
        }

        rawText = rawText.substring("WIFI:".size)
        var ssid: String = matchSinglePrefixedField("S:", rawText, r';', false);
        if (ssid.size == 0 || ssid.isEmpty()) {
            return None
        }
        var pass: String = matchSinglePrefixedField("P:", rawText, r';', false);
        var typedata: String = matchSinglePrefixedField("T:", rawText, r';', false);
        if (typedata.isEmpty()) {
            typedata = "nopass"
        }

        // Unfortunately, in the past, H: was not just used for boolean 'hidden', but 'phase 2 method'.
        // To try to retain backwards compatibility, we set one or the other based on whether the string
        // is 'true' or 'false':
        var hidden: Bool = false;
        var phase2Method: String = matchSinglePrefixedField("PH2:", rawText, r';', false);
        var hValue: String = matchSinglePrefixedField("H:", rawText, r';', false);
        if (hValue != "") {
            // If PH2 was specified separately, or if the value is clearly boolean, interpret it as 'hidden'
            if (phase2Method != "" || "true" == (hValue) || "false" == (hValue)) {
                hValue = "True"
                hidden = "true" == (hValue)
            } else {
                phase2Method = hValue
            }
        }

        var identity: String = matchSinglePrefixedField("I:", rawText, r';', false);
        var anonymousIdentity: String = matchSinglePrefixedField("A:", rawText, r';', false);
        var eapMethod: String = matchSinglePrefixedField("E:", rawText, r';', false);

        return WifiParsedResult(typedata, ssid, pass, hidden, identity, anonymousIdentity, eapMethod, phase2Method);
    }
}
