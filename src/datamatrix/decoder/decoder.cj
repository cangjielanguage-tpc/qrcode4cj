/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.datamatrix.decoder

import std.collection.*
import QRCode4cj.common.*
import QRCode4cj.common.reedsolomon.GenericGF
import QRCode4cj.common.reedsolomon.ReedSolomonDecoder
import QRCode4cj.common.reedsolomon.Qrcoder4cjReedSolomonException

/**
 * The main class which implements Data Matrix Code decoding -- as opposed to locating and extracting
 * the Data Matrix Code from an image.
 */
public class Decoder {
    private let rsDecoder: ReedSolomonDecoder

    public init() {
        rsDecoder = ReedSolomonDecoder(GenericGF.DATA_MATRIX_FIELD_256)
    }

    /**
     * <p>Convenience method that can decode a Data Matrix Code represented as a 2D array of booleans.
     * "true" is taken to mean a black module.</p>
     *
     * @param image booleans representing white/black Data Matrix Code modules
     * @return text and bytes encoded within the Data Matrix Code
     * @throws Qrcoder4cjFormatException if the Data Matrix Code cannot be decoded
     * @throws Qrcoder4cjChecksumException if error correction fails
     */
    public func decode(image: Array<Bool>): DecoderResult {
        return decode(BitMatrix.parse(image));
    }

    /**
     * <p>Decodes a Data Matrix Code represented as a {@link BitMatrix}. A 1 or "true" is taken
     * to mean a black module.</p>
     *
     * @param bits booleans representing white/black Data Matrix Code modules
     * @return text and bytes encoded within the Data Matrix Code
     * @throws Qrcoder4cjFormatException if the Data Matrix Code cannot be decoded
     * @throws Qrcoder4cjChecksumException if error correction fails
     */
    public func decode(bits: BitMatrix): DecoderResult {
        // Construct a parser and read version, error-correction level
        var parser: BitMatrixParser = BitMatrixParser(bits);
        var version: Version = parser.getVersion();

        // Read codewords
        var codewords: Array<UInt8> = parser.readCodewords();

        // Separate into data blocks
        var dataBlocks: ArrayList<DataBlock> = DataBlock.getDataBlocks(codewords, version);

        // Count total number of data bytes
        var totalBytes: Int64 = 0;

        for (i in 0..dataBlocks.size) {
            totalBytes += dataBlocks[i].getNumDataCodewords()
        }
        var resultBytes: Array<UInt8> = Array<UInt8>(totalBytes, item: 0)

        var dataBlocksCount: Int64 = dataBlocks.size;

        // Error-correct and copy data blocks together into a stream of bytes
        for (j in 0..dataBlocksCount) {
            var dataBlock: DataBlock = dataBlocks[j]
            var codewordBytes: Array<UInt8> = dataBlock.getCodewords();
            var numDataCodewords: Int64 = dataBlock.getNumDataCodewords();
            correctErrors(codewordBytes, numDataCodewords);

            for (i in 0..numDataCodewords) {
                // De-interlace data blocks.
                resultBytes[i * dataBlocksCount + j] = codewordBytes[i]
            }
        }

        // Decode the contents of that stream of bytes
        return DecodedBitStreamParser.decode(resultBytes);
    }

    /**
     * <p>Given data and error-correction codewords received, possibly corrupted by errors, attempts to
     * correct the errors in-place using Reed-Solomon error correction.</p>
     *
     * @param codewordBytes data and error correction codewords
     * @param numDataCodewords number of codewords that are data bytes
     * @throws Qrcoder4cjChecksumException if error correction fails
     */
    private func correctErrors(codewordBytes: Array<UInt8>, numDataCodewords: Int64) {
        let numCodewords: Int64 = codewordBytes.size;

        // First read into an array of ints
        var codewordsInts: Array<Int64> = Array<Int64>(numCodewords, item: 0)

        for (i in 0..numCodewords) {
            codewordsInts[i] = Int64(codewordBytes[i]) & 0xFF
        }
        try {
            rsDecoder.decode(codewordsInts, codewordBytes.size - numDataCodewords);
        } catch (ignored: Qrcoder4cjReedSolomonException) {
            throw Qrcoder4cjChecksumException.getChecksumInstance();
        }

        // Copy back into array of bytes -- only need to worry about the bytes that were data
        // We don't care about errors in the error-correction codewords
        for (i in 0..numDataCodewords) {
            codewordBytes[i] = UInt8(codewordsInts[i])
        }
    }
}
