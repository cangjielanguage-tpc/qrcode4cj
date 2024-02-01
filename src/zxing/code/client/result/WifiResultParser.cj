/*
 * Copyright 2010 ZXing authors
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
 * <p>Parses a WIFI configuration string. Strings will be of the form:</p>
 *
 * <p>{@code WIFI:T:[network type];S:[network SSID];P:[network password];H:[hidden?];;}</p>
 *
 * <p>For WPA2 enterprise (EAP), strings will be of the form:</p>
 *
 * <p>{@code WIFI:T:WPA2-EAP;S:[network SSID];H:[hidden?];E:[EAP method];PH2:[Phase 2 method];A:[anonymous identity];I:[username];P:[password];;}</p>
 *
 * <p>"EAP method" can e.g. be "TTLS" or "PWD" or one of the other fields in <a href="https://developer.android.com/reference/android/net/wifi/WifiEnterpriseConfig.Eap.html">WifiEnterpriseConfig.Eap</a> and "Phase 2 method" can e.g. be "MSCHAPV2" or any of the other fields in <a href="https://developer.android.com/reference/android/net/wifi/WifiEnterpriseConfig.Phase2.html">WifiEnterpriseConfig.Phase2</a></p>
 *
 * <p>The fields can appear in any order. Only "S:" is required.</p>
 *
 * @author Vikram Aggarwal
 * @author Sean Owen
 * @author Steffen Kieß
 */
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
