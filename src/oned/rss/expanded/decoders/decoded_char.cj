/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded.decoders

class DecodedChar <: DecodedObject {
    private var value: Char = ' ';

    static var FNC1: Char = '$'; // It's not in Alphanumeric neither in ISO/IEC 646 charset

    init(newPosition: Int64, value: Char) {
        super(newPosition);
        this.value = value
    }

    func getValue(): Char {
        return this.value;
    }

    func isFNC1(): Bool {
        return this.value == FNC1
    }
}
