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

package zxing.code.oned.rss.expanded

import zxing.code.oned.rss.*

/**
 * @author Pablo Orduña, University of Deusto (pablo.orduna@deusto.es)
 */
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
