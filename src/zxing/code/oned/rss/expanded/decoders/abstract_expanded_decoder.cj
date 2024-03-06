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

package zxing.code.oned.rss.expanded.decoders

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
public abstract class AbstractExpandedDecoder {
    private var information: BitArray = BitArray()
    private var generalDecoder: GeneralAppIdDecoder = GeneralAppIdDecoder(information)

    init(information: BitArray) {
        this.information = information
        this.generalDecoder = GeneralAppIdDecoder(information)
    }

    protected func getInformation(): BitArray {
        return information
    }

    protected func getGeneralDecoder(): GeneralAppIdDecoder {
        return generalDecoder
    }

    public func parseInformation(): String
    public static func createDecoder(information: BitArray): AbstractExpandedDecoder {
        if (information.get(1)) {
            return AI01AndOtherAIs(information);
        }
        if (!information.get(2)) {
            return AnyAIDecoder(information);
        }

        var fourBitEncodationMethod: Int64 = GeneralAppIdDecoder.extractNumericValueFromBitArrayStatic(information, 1, 4
        );

        if (fourBitEncodationMethod == 4) {
            return AI013103decoder(information);
        } else if (fourBitEncodationMethod == 5) {
            return AI01320xDecoder(information);
        }
        var fiveBitEncodationMethod: Int64 = GeneralAppIdDecoder.extractNumericValueFromBitArrayStatic(information, 1, 5
        );
        if (fiveBitEncodationMethod == 12) {
            return AI01392xDecoder(information);
        } else if (fiveBitEncodationMethod == 13) {
            return AI01393xDecoder(information);
        }
        var sevenBitEncodationMethod: Int64 = GeneralAppIdDecoder.extractNumericValueFromBitArrayStatic(
            information,
            1,
            7
        );
        if (sevenBitEncodationMethod == 56) {
            return AI013x0x1xDecoder(information, "310", "11");
        } else if (sevenBitEncodationMethod == 57) {
            return AI013x0x1xDecoder(information, "320", "11");
        } else if (sevenBitEncodationMethod == 58) {
            return AI013x0x1xDecoder(information, "310", "13");
        } else if (sevenBitEncodationMethod == 59) {
            return AI013x0x1xDecoder(information, "320", "13");
        } else if (sevenBitEncodationMethod == 60) {
            return AI013x0x1xDecoder(information, "310", "15");
        } else if (sevenBitEncodationMethod == 61) {
            return AI013x0x1xDecoder(information, "320", "15");
        } else if (sevenBitEncodationMethod == 62) {
            return AI013x0x1xDecoder(information, "310", "17");
        } else if (sevenBitEncodationMethod == 63) {
            return AI013x0x1xDecoder(information, "320", "17");
        }
        throw Exception("unknown decoder: ${information}");
    }
}
