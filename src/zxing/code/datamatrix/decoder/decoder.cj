/*
 * Copyright 2007 ZXing authors
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

package zxing.code.datamatrix.decoder

import zxing.code.common.ChecksumException
import zxing.code.common.reedsolomon.GenericGF
import zxing.code.common.reedsolomon.ReedSolomonDecoder
import zxing.code.common.reedsolomon.ReedSolomonException

/**
 * <p>The main class which implements Data Matrix Code decoding -- as opposed to locating and extracting
 * the Data Matrix Code from an image.</p>
 *
 * @author bbrown@google.com (Brian Brown)
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
     * @throws FormatException if the Data Matrix Code cannot be decoded
     * @throws ChecksumException if error correction fails
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
     * @throws FormatException if the Data Matrix Code cannot be decoded
     * @throws ChecksumException if error correction fails
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
     * @throws ChecksumException if error correction fails
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
        } catch (ignored: ReedSolomonException) {
            throw ChecksumException.getChecksumInstance();
        }

        // Copy back into array of bytes -- only need to worry about the bytes that were data
        // We don't care about errors in the error-correction codewords
        for (i in 0..numDataCodewords) {
            codewordBytes[i] = UInt8(codewordsInts[i])
        }
    }
}
