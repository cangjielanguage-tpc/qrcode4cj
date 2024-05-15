/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded.decoders

class DecodedInformation <: DecodedObject {
    private var newString: String = String()
    private var remainingValue: ?Int64 = Option<Int64>.None
    private var remaining: Bool = false

    init(newPosition: Int64, newString: String) {
        super(newPosition);
        this.newString = newString
        this.remaining = false
        this.remainingValue = Option<Int64>.None
    }

    init(newPosition: Int64, newString: String, remainingValue: Option<Int64>) {
        super(newPosition);
        this.remaining = true
        this.remainingValue = remainingValue
        this.newString = newString
    }

    func getNewString(): String {
        return this.newString;
    }

    func isRemaining(): Bool {
        return this.remaining;
    }

    func getRemainingValue(): Option<Int64> {
        return this.remainingValue;
    }
}
