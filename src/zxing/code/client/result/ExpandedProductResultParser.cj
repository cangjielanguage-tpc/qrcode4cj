/*
 * Copyright (C) 2010 ZXing authors
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

/*
 * These authors would like to acknowledge the Spanish Ministry of Industry,
 * Tourism and Trade, for the support in the project TSI020301-2008-2
 * "PIRAmIDE: Personalizable Interactions with Resources on AmI-enabled
 * Mobile Dynamic Environments", led by Treelogic
 * ( http://www.treelogic.com/ ):
 *
 * http://www.piramidepse.com/
 */

package zxing.code.client.result

from std import core.*

/**
 * Parses strings of digits that represent a RSS Extended code.
 *
 * @author Antonio Manuel Benjumea Conde, Servinform, S.A.
 * @author Agustín Delgado, Servinform, S.A.
 */
public open class ExpandedProductResultParser <: ResultParser {
    public func parse(result: Result): ?ParsedResult {
        var format: BarcodeFormat = result.getBarcodeFormat();
        if (format != BarcodeFormat.RSS_EXPANDED) {
            // ExtendedProductParsedResult NOT created. Not a RSS Expanded barcode
            return None
        }
        var rawText: UTF32String = getMassagedText(result);

        var productID: String = "";
        var sscc: String = "";
        var lotNumber: String = "";
        var productionDate: String = "";
        var packagingDate: String = "";
        var bestBeforeDate: String = "";
        var expirationDate: String = "";
        var weight: String = "";
        var weightType: String = "";
        var weightIncrement: String = "";
        var price: String = "";
        var priceIncrement: String = "";
        var priceCurrency: String = "";
        var uncommonAIs: HashMap<String, String> = HashMap<String, String>();

        var i: Int64 = 0;

        while (i < rawText.charSize) {
            var ai: UTF32String = findAIvalue(i, rawText);
            if (ai == UTF32String("")) {
                // Error. Code doesn't match with RSS expanded pattern
                // ExtendedProductParsedResult NOT created. Not match with RSS Expanded pattern
                throw IllegalArgumentException("Invalid input: code doesn't match with RSS expanded pattern.")
            }
            i += ai.charSize + 2
            var value: UTF32String = findValue(i, rawText);
            i += value.charSize

            match (ai.toString()) {
                case "00" => sscc = value.toString()

                case "01" => productID = value.toString()

                case "10" => lotNumber = value.toString()

                case "11" => productionDate = value.toString()

                case "13" => packagingDate = value.toString()

                case "15" => bestBeforeDate = value.toString()

                case "17" => expirationDate = value.toString()

                case "3100" | "3101" | "3102" | "3103" | "3104" | "3105" | "3106" | "3107" | "3108" | "3109" =>
                    weight = value.toString()
                    weightType = ExpandedProductParsedResult.KILOGRAM
                    weightIncrement = ai.substring(3).toString()
                case "3200" | "3201" | "3202" | "3203" | "3204" | "3205" | "3206" | "3207" | "3208" | "3209" =>
                    weight = value.toString()
                    weightType = ExpandedProductParsedResult.POUND
                    weightIncrement = ai.substring(3).toString()
                case "3920" | "3921" | "3922" | "3923" =>
                    price = value.toString()
                    priceIncrement = ai.substring(3).toString()
                case "3930" | "3931" | "3932" | "3933" =>
                    if (value.charSize < 4) {
                        // The value must have more of 3 symbols (3 for currency and
                        // 1 at least for the price)
                        // ExtendedProductParsedResult NOT created. Not match with RSS Expanded pattern
                        return None
                    }
                    price = value.substring(3).toString()
                    priceCurrency = value.substring(0, 3).toString()
                    priceIncrement = ai.substring(3).toString()
                case _ => // No match with common AIs
                            uncommonAIs.put(ai.toString(), value.toString());
            }
        }

        return ExpandedProductParsedResult(
            rawText.toString(),
            productID,
            sscc,
            lotNumber,
            productionDate,
            packagingDate,
            bestBeforeDate,
            expirationDate,
            weight,
            weightType,
            weightIncrement,
            price,
            priceIncrement,
            priceCurrency,
            uncommonAIs
        );
    }

    private static func findAIvalue(i: Int64, rawText: UTF32String): UTF32String {
        var c: Char = rawText.get(i);

        // First character must be a open parenthesis.If not, ERROR
        if (c != '(') {
            return UTF32String("");
        }

        var rawTextAux: UTF32String = rawText.substring(i + 1);

        var buf: ArrayList<Char> = ArrayList<Char>();
        for (index in 0..rawTextAux.charSize) {
            var currentChar: Char = rawTextAux.get(index);
            if (currentChar == ')') {
                return UTF32String(buf);
            }
            if (currentChar < '0' || currentChar > '9') {
                return UTF32String("");
            }
            buf.append(currentChar);
        }
        return UTF32String(buf);
    }

    private static func findValue(i: Int64, rawText: UTF32String): UTF32String {
        var buf: ArrayList<Char> = ArrayList<Char>();
        var rawTextAux: UTF32String = rawText.substring(i);

        for (index in 0..rawTextAux.charSize) {
            var c: Char = rawTextAux.get(index);
            if (c == '(') {
                // We look for a new AI. If it doesn't exist (ERROR), we continue
                // with the iteration
                if (findAIvalue(index, rawTextAux) != UTF32String("")) {
                    break
                }
                buf.append('(');
            } else {
                buf.append(c);
            }
        }
        return UTF32String(buf);
    }
}
