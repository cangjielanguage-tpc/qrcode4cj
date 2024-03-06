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

enum State {
    | NUMERIC
    | ALPHA
    | ISO_IEC_646
}

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
class CurrentParsingState {
    private var position: Int64 = 0
    private var encoding: State = NUMERIC

    init() {
        this.position = 0
        this.encoding = State.NUMERIC
    }

    func getPosition(): Int64 {
        return position
    }

    func setPosition(position: Int64) {
        this.position = position
    }

    func incrementPosition(delta: Int64) {
        position += delta
    }

    func isAlpha(): Bool {
        match (this.encoding) {
            case State.ALPHA => return true;
            case _ => return false;
        }
    }

    func isNumeric(): Bool {
        match (this.encoding) {
            case State.NUMERIC => return true;
            case _ => return false;
        }
    }

    func isIsoIec646(): Bool {
        match (this.encoding) {
            case State.ISO_IEC_646 => return true;
            case _ => return false;
        }
    }

    func setNumeric() {
        this.encoding = State.NUMERIC
    }

    func setAlpha() {
        this.encoding = State.ALPHA
    }

    func setIsoIec646() {
        this.encoding = State.ISO_IEC_646
    }
}
