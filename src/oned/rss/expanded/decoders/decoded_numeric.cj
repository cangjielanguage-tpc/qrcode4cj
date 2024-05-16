/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded.decoders

// import common.Qrcoder4cjFormatException

class DecodedNumeric <: DecodedObject {
    private var firstDigit: Int64 = 0
    private var secondDigit: Int64 = 0

    static let FNC1: Int64 = 10;

    init(newPosition: Int64, firstDigit: Int64, secondDigit: Int64) {
        super(newPosition);

        if (firstDigit < 0 || firstDigit > 10 || secondDigit < 0 || secondDigit > 10) {
            throw Qrcoder4cjFormatException.getFormatInstance();
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
