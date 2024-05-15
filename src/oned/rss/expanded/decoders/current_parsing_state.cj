/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded.decoders

enum State {
    | NUMERIC
    | ALPHA
    | ISO_IEC_646
}

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
