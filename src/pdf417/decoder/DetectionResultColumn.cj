/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.pdf417.decoder

import std.format.*

open class DetectionResultColumn <: ToString {
    private static let MAX_NEARBY_DISTANCE: Int64 = 5

    private let boundingBox: BoundingBox
    private let codewords: Array<Codeword>
    public var flag = false;

    init() {
        this.boundingBox = BoundingBox()
        codewords = Array<Codeword>()
    }

    init(boundingBox: BoundingBox) {
        this.flag = true
        this.boundingBox = BoundingBox(boundingBox)
        codewords = Array<Codeword>(boundingBox.getMaxY() - boundingBox.getMinY() + 1, item: Codeword())
    }

    func getCodewordNearby(imageRow: Int64): Codeword {
        var codeword: Codeword = getCodeword(imageRow);
        if (codeword.flag) {
            return codeword
        }

        for (i in 1..MAX_NEARBY_DISTANCE) {
            var nearImageRow: Int64 = imageRowToCodewordIndex(imageRow) - i
            if (nearImageRow >= 0) {
                codeword = codewords[nearImageRow]
                if (codeword.flag) {
                    return codeword
                }
            }
            nearImageRow = imageRowToCodewordIndex(imageRow) + i
            if (nearImageRow < codewords.size) {
                codeword = codewords[nearImageRow]
                if (codeword.flag) {
                    return codeword
                }
            }
        }
        return Codeword()
    }

    func imageRowToCodewordIndex(imageRow: Int64): Int64 {
        return imageRow - boundingBox.getMinY()
    }

    func setCodeword(imageRow: Int64, codeword: Codeword) {
        codewords[imageRowToCodewordIndex(imageRow)] = codeword
    }

    func getCodeword(imageRow: Int64): Codeword {
        return codewords[imageRowToCodewordIndex(imageRow)]
    }

    func getBoundingBox(): BoundingBox {
        return boundingBox
    }

    func getCodewords(): Array<Codeword> {
        return codewords
    }

    public open func toString(): String {
        var row: Int64 = 0
        var outString = String();
        for (i in 0..codewords.size) {
            if (codewords[i].flag) {
                outString += row.format("3") + ": " + codewords[i].getRowNumber().format("3") + "|" +
                    codewords[i].getValue().format("3") + "\n"
                row++
            } else {
                outString += row.format("3") + "    |   \n"
                row++
                continue
            }
        }
        return outString
    }
}
