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

// import zxing.code.common.FormatException

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 * @author Eduardo Castillejo, University of Deusto (eduardo.castillejo@deusto.es)
 */
class DecodedNumeric <: DecodedObject {
    private var firstDigit: Int64 = 0
    private var secondDigit: Int64 = 0

    static let FNC1: Int64 = 10;

    init(newPosition: Int64, firstDigit: Int64, secondDigit: Int64) {
        super(newPosition);

        if (firstDigit < 0 || firstDigit > 10 || secondDigit < 0 || secondDigit > 10) {
            throw FormatException.getFormatInstance();
        }

        this.firstDigit = firstDigit
        this.secondDigit = secondDigit
    }

    func getFirstDigit(): Int64 {
        return this.firstDigit;
    }

    func getSecondDigit(): Int64 {
        return this.secondDigit;
    }

    func getValue(): Int64 {
        return this.firstDigit * 10 + this.secondDigit
    }

    func isFirstDigitFNC1(): Bool {
        return this.firstDigit == FNC1
    }

    func isSecondDigitFNC1(): Bool {
        return this.secondDigit == FNC1
    }
}
