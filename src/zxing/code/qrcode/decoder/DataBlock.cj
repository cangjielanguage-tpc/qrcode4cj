/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.qrcode.decoder

/**
 * <p>Encapsulates a block of data within a QR Code. QR Codes may split their data into
 * multiple blocks, each of which is a unit of data and error-correction codewords. Each
 * is represented by an instance of this class.</p>
 *
 * @author Sean Owen
 */
class DataBlock {
    private var numDataCodewords: Int64
    private var codewords: Array<Byte>

    private init(numDataCodewords: Int64, codewords: Array<Byte>) {
        this.numDataCodewords = numDataCodewords
        this.codewords = codewords
    }

    /**
     * <p>When QR Codes use multiple data blocks, they are actually interleaved.
     * That is, the first byte of data block 1 to n is written, then the second bytes, and so on. This
     * method will separate the data into original blocks.</p>
     *
     * @param rawCodewords bytes as read directly from the QR Code
     * @param version version of the QR Code
     * @param ecLevel error-correction level of the QR Code
     * @return DataBlocks containing original bytes, "de-interleaved" from representation in the
     * QR Code
     */
    static func getDataBlocks(rawCodewords: Array<Byte>, version: Version, ecLevel: ErrorCorrectionLevel): ArrayList<DataBlock> {
        if (rawCodewords.size != version.getTotalCodewords()) {
            throw IllegalArgumentException();
        }

        // Figure out the number and size of data blocks used by this version and
        // error correction level
        let ecBlocks: ECBlocks = version.getECBlocksForLevel(ecLevel);

        // First count the total number of data blocks
        var totalBlocks: Int64 = 0;
        var ecBlockArray: Array<ECB> = ecBlocks.getECBlocks();
        for (i in 0..ecBlockArray.size) {
            totalBlocks += ecBlockArray[i].getCount()
        }

        // Now establish DataBlocks of the appropriate size and number of data codewords
        var result: ArrayList<DataBlock> = ArrayList<DataBlock>();
        var numResultBlocks: Int64 = 0;
        for (j in 0..ecBlockArray.size) {
            let ecBlockCount: Int64 = ecBlockArray[j].getCount();
            for (i in 0..ecBlockCount) {
                let numDataCodewords: Int64 = ecBlockArray[j].getDataCodewords();
                let numBlockCodewords: Int64 = ecBlocks.getECCodewordsPerBlock() + numDataCodewords

                result.append(DataBlock(numDataCodewords, Array<Byte>(numBlockCodewords, item: 0)))
                numResultBlocks++
            }
        }

        // All blocks have the same amount of data, except that the last n
        // (where n may be 0) have 1 more byte. Figure out where these start.
        let shorterBlocksTotalCodewords: Int64 = result[0].codewords.size;
        var longerBlocksStartAt: Int64 = result.size - 1
        longerBlocksStartAt = exgetDataBlocks(longerBlocksStartAt, shorterBlocksTotalCodewords, result)

        let shorterBlocksNumDataCodewords: Int64 = shorterBlocksTotalCodewords - ecBlocks.getECCodewordsPerBlock()

        // The last elements of result may be 1 element longer;
        // first fill out as many elements as all of them have
        var rawCodewordsOffset: Int64 = 0;
        for (i in 0..shorterBlocksNumDataCodewords) {
            for (j in 0..numResultBlocks) {
                result[j].codewords[i] = rawCodewords[rawCodewordsOffset]
                rawCodewordsOffset++
            }
        }

        // Fill out the last data block in the longer ones
        for (j in longerBlocksStartAt..numResultBlocks) {
            result[j].codewords[shorterBlocksNumDataCodewords] = rawCodewords[rawCodewordsOffset]
            rawCodewordsOffset++
        }

        // Now add in error correction blocks
        let max: Int64 = result[0].codewords.size;
        for (i in shorterBlocksNumDataCodewords..max) {
            for (j in 0..numResultBlocks) {
                let iOffset: Int64 = getiOffset(i, j, longerBlocksStartAt)
                result[j].codewords[iOffset] = rawCodewords[rawCodewordsOffset]
                rawCodewordsOffset++
            }
        }

        return result
    }

    static func exgetDataBlocks(longerBlocksStartAt: Int64, shorterBlocksTotalCodewords: Int64,
        result: ArrayList<DataBlock>): Int64 {
        var longerBlocksStartAt_p = longerBlocksStartAt
        while (longerBlocksStartAt_p >= 0) {
            let numCodewords: Int64 = result[longerBlocksStartAt_p].codewords.size;
            if (numCodewords == shorterBlocksTotalCodewords) {
                break
            }
            longerBlocksStartAt_p--
        }
        longerBlocksStartAt_p++
        return longerBlocksStartAt_p
    }

    private static func getiOffset(i: Int64, j: Int64, longerBlocksStartAt: Int64): Int64 {
        if (j < longerBlocksStartAt) {
            return i
        } else {
            return i + 1
        }
    }

    func getNumDataCodewords(): Int64 {
        return numDataCodewords
    }

    func getCodewords(): Array<Byte> {
        return codewords
    }
}
