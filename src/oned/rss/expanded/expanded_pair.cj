/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned.rss.expanded

import oned.rss.*

public class ExpandedPair {
    private var leftChar: ?DataCharacter
    private var rightChar: ?DataCharacter
    private var finderPattern: ?FinderPattern

    public init(leftChar: ?DataCharacter, rightChar: ?DataCharacter, finderPattern: ?FinderPattern) {
        this.leftChar = leftChar
        this.rightChar = rightChar
        this.finderPattern = finderPattern
    }

    func getLeftChar(): ?DataCharacter {
        return this.leftChar;
    }

    func getRightChar(): ?DataCharacter {
        return this.rightChar;
    }

    public func getFinderPattern(): ?FinderPattern {
        return this.finderPattern;
    }

    func mustBeLast(): Bool {
        if (let None <- rightChar) {
            true
        } else {
            false
        }
    }

    public func toString(): String {
        var str: String = ""
        if (let None <- finderPattern) {
            str = "null"
        } else {
            str = finderPattern.getOrThrow().getValue().toString()
        }
        return "[ ${leftChar.getOrThrow().toString()} , ${rightChar.getOrThrow().toString()} : ${str} ]"
    }

    public func equals(o: Any): Bool {
        if (let None <- (o as ExpandedPair)) {
            return false;
        }
        var that: ExpandedPair = (o as ExpandedPair).getOrThrow()

        if (let None <- that.leftChar) {
            return false;
        }
        if (let None <- that.rightChar) {
            return false;
        }

        if (let None <- that.finderPattern) {
            return false;
        }

        if (let None <- leftChar) {
            return false;
        }
        if (let None <- rightChar) {
            return false;
        }

        if (let None <- finderPattern) {
            return false;
        }

        let flag1 = that.leftChar.getOrThrow().equals(leftChar.getOrThrow())
        let flag2 = that.rightChar.getOrThrow().equals(rightChar.getOrThrow())
        let flag3 = that.finderPattern.getOrThrow().equals(finderPattern.getOrThrow())
        return flag1 && flag2 && flag3
    }

    public func hashCode(): Int64 {
        return leftChar.getOrThrow().hashCode() ^ rightChar.getOrThrow().hashCode() ^
            finderPattern.getOrThrow().hashCode()
    }
}
