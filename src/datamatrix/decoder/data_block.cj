/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.datamatrix.decoder

import std.collection.*
import std.overflow.*

/**
 * Encapsulates a block of data within a Data Matrix Code. Data Matrix Codes may split their data into
 * multiple blocks, each of which is a unit of data and error-correction codewords. Each
 * is represented by an instance of this class.
 */
class DataBlock {
    private let numDataCodewords: Int64
    private let codewords: Array<UInt8>

    init(numDataCodewords: Int64, codewords: Array<UInt8>) {
        this.numDataCodewords = numDataCodewords
        this.codewords = codewords
    }

    /**
     * <p>When Data Matrix Codes use multiple data blocks, they actually interleave the bytes of each of them.
     * That is, the first byte of data block 1 to n is written, then the second bytes, and so on. This
     * method will separate the data into original blocks.</p>
     *
     * @param rawCodewords bytes as read directly from the Data Matrix Code
     * @param version version of the Data Matrix Code
     * @return DataBlocks containing original bytes, "de-interleaved" from representation in the
     * Data Matrix Code
     */
    static func getDataBlocks(rawCodewords: Array<UInt8>, version: Version): ArrayList<DataBlock> {
        // Figure out the number and size of data blocks used by this version

        var ecBlocks: ECBlocks = version.getECBlocks();

        // First count the total number of data blocks
        var totalBlocks: Int64 = 0;
        var ecBlockArray: Array<ECB> = ecBlocks.getECBlocks();

        for (i in 0..ecBlockArray.size) {
            totalBlocks += ecBlockArray[i].getCount()
        }

        // Now establish DataBlocks of the appropriate size and number of data codewords
        var result: ArrayList<DataBlock> = ArrayList<DataBlock>()
        var numResultBlocks: Int64 = 0;

        for (j in 0..ecBlockArray.size) {
            for (i in 0..ecBlockArray[j].getCount()) {
                var numDataCodewords: Int64 = ecBlockArray[j].getDataCodewords();
                var numBlockCodewords: Int64 = ecBlocks.getECCodewords() + numDataCodewords

                //result[numResultBlocks] = DataBlock(numDataCodewords, Array<Byte>(numBlockCodewords, item: 0))
                result.append(DataBlock(numDataCodewords, Array<Byte>(numBlockCodewords, item: 0)));
                numResultBlocks++
            }
        }

        // All blocks have the same amount of data, except that the last n
        // (where n may be 0) have 1 less byte. Figure out where these start.
        // TODO(bbrown): There is only one case where there is a difference for Data Matrix for size 144
        var longerBlocksTotalCodewords: Int64 = result[0].codewords.size;

        var longerBlocksNumDataCodewords: Int64 = longerBlocksTotalCodewords - ecBlocks.getECCodewords()
        var shorterBlocksNumDataCodewords: Int64 = longerBlocksNumDataCodewords - 1

        // The last elements of result may be 1 element shorter for 144 matrix
        // first fill out as many elements as all of them have minus 1
        var rawCodewordsOffset: Int64 = 0;

        for (i in 0..shorterBlocksNumDataCodewords) {
            for (j in 0..numResultBlocks) {
                result[j].codewords[i] = rawCodewords[rawCodewordsOffset]
                rawCodewordsOffset++
            }
        }

        // Fill out the last data block in the longer ones
        let specialVersion = version.getVersionNumber() == 24

        var numLongerBlocks: Int64
        if (specialVersion) {
            numLongerBlocks = 8
        } else {
            numLongerBlocks = numResultBlocks
        }

        for (j in 0..numLongerBlocks) {
            result[j].codewords[longerBlocksNumDataCodewords - 1] = rawCodewords[rawCodewordsOffset]
            rawCodewordsOffset++
        }

        rawCodewordsOffset = ExgetDataBlocks(result, longerBlocksNumDataCodewords, specialVersion, numResultBlocks,
            rawCodewords, rawCodewordsOffset)

        if (rawCodewordsOffset != rawCodewords.size) {
            throw IllegalArgumentException();
        }

        return result
    }

    static func ExgetDataBlocks(result: ArrayList<DataBlock>, longerBlocksNumDataCodewords: Int64, specialVersion: Bool,
        numResultBlocks: Int64, rawCodewords: Array<UInt8>, rawCodewordsOffset: Int64): Int64 {
        var rawCodewordsOffset_p = rawCodewordsOffset
        var max: Int64 = result[0].codewords.size;

        var jOffset: Int64
        var iOffset: Int64
        for (i in longerBlocksNumDataCodewords..max) {
            for (j in 0..numResultBlocks) {
                if (specialVersion) {
                    jOffset = (j + 8).throwingMod(numResultBlocks)
                } else {
                    jOffset = j
                }
                if (specialVersion && jOffset > 7) {
                    iOffset = i - 1
                } else {
                    iOffset = i
                }

                result[jOffset].codewords[iOffset] = rawCodewords[rawCodewordsOffset_p]
                rawCodewordsOffset_p++
            }
        }
        return rawCodewordsOffset_p
    }

    func getNumDataCodewords(): Int64 {
        return numDataCodewords
    }

    func getCodewords(): Array<UInt8> {
        return codewords
    }
}
