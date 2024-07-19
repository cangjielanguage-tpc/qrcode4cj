/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned.rss.expanded.decoders

class DecodedChar <: DecodedObject {
    private var value: Rune = r' ';

    static var FNC1: Rune = r'$'; // It's not in Alphanumeric neither in ISO/IEC 646 charset

    init(newPosition: Int64, value: Rune) {
        super(newPosition);
        this.value = value
    }

    func getValue(): Rune {
        return this.value;
    }

    func isFNC1(): Bool {
        return this.value == FNC1
    }
}
