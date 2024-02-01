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

package zxing.code.qrcode.decoder

import zxing.code.common.ChecksumException
import zxing.code.common.reedsolomon.GenericGF
import zxing.code.common.reedsolomon.ReedSolomonDecoder
import zxing.code.common.reedsolomon.ReedSolomonException

/**
 * <p>The main class which implements QR Code decoding -- as opposed to locating and extracting
 * the QR Code from an image.</p>
 *
 * @author Sean Owen
 */
public class Decoder {
    private let rsDecoder: ReedSolomonDecoder

    public init() {
        rsDecoder = ReedSolomonDecoder(GenericGF.QR_CODE_FIELD_256)
    }

    public func decode(image: Array<Array<Bool>>): DecoderResult {
        return decode(image, HashMap<DecodeHintType, Any>());
    }

    /**
     * <p>Convenience method that can decode a QR Code represented as a 2D array of booleans.
     * "true" is taken to mean a black module.</p>
     *
     * @param image booleans representing white/black QR Code modules
     * @param hints decoding hints that should be used to influence decoding
     * @return text and bytes encoded within the QR Code
     * @throws FormatException if the QR Code cannot be decoded
     * @throws ChecksumException if error correction fails
     */
    public func decode(image: Array<Array<Bool>>, hints: HashMap<DecodeHintType, Any>): DecoderResult {
        return decode(BitMatrix.parse(image), hints);
    }

    public func decode(bits: BitMatrix): DecoderResult {
        return decode(bits, HashMap<DecodeHintType, Any>());
    }

    /**
     * <p>Decodes a QR Code represented as a {@link BitMatrix}. A 1 or "true" is taken to mean a black module.</p>
     *
     * @param bits booleans representing white/black QR Code modules
     * @param hints decoding hints that should be used to influence decoding
     * @return text and bytes encoded within the QR Code
     * @throws FormatException if the QR Code cannot be decoded
     * @throws ChecksumException if error correction fails
     */
    public func decode(bits: BitMatrix, hints: HashMap<DecodeHintType, Any>): DecoderResult {
        // Construct a parser and read version, error-correction level
        var parser: BitMatrixParser = BitMatrixParser(bits);
        var fe: Option<FormatException> = None
        var ce: Option<ChecksumException> = None
        try {
            return decode(parser, hints);
        } catch (e: FormatException) {
            fe = e
        } catch (e: ChecksumException) {
            ce = e
        }

        try {
            // Revert the bit matrix
            parser.remask();

            // Will be attempting a mirrored reading of the version and format info.
            parser.setMirror(true);

            // Preemptively read the version.
            parser.readVersion();

            // Preemptively read the format information.
            parser.readFormatInformation();

            /*
             * Since we're here, this means we have successfully detected some kind
             * of version and format information when mirrored. This is a good sign,
             * that the QR code may be mirrored, and we should try once more with a
             * mirrored content.
             */
            // Prepare for a mirrored reading.
            parser.Mirror();

            let result: DecoderResult = decode(parser, hints);

            // Success! Notify the caller that the code was mirrored.
            result.setOther(QRCodeDecoderMetaData(true));
            return result
        } catch (e: FormatException | ChecksumException) {
            // Throw the exception from the original reading
            if (let Some(f) <- fe) {
                throw f
            }
            throw ce.getOrThrow();
            // If fe is null, this can't be
        }
    }

    private func decode(parser: BitMatrixParser, hints: HashMap<DecodeHintType, Any>): DecoderResult {
        let version: Version = parser.readVersion();
        let ecLevel: ErrorCorrectionLevel = parser.readFormatInformation().getErrorCorrectionLevel();

        // Read codewords
        let codewords: Array<Byte> = parser.readCodewords();

        // Separate into data blocks
        let dataBlocks: ArrayList<DataBlock> = DataBlock.getDataBlocks(codewords, version, ecLevel);

        // Count total number of data bytes
        var totalBytes: Int64 = 0;
        for (i in 0..dataBlocks.size) {
            totalBytes += dataBlocks[i].getNumDataCodewords()
        }
        var resultBytes: Array<Byte> = Array<Byte>(totalBytes, item: 0);
        var resultOffset: Int64 = 0;

        // Error-correct and copy data blocks together into a stream of bytes
        for (i in 0..dataBlocks.size) {
            let codewordBytes: Array<Byte> = dataBlocks[i].getCodewords();
            let numDataCodewords: Int64 = dataBlocks[i].getNumDataCodewords();
            correctErrors(codewordBytes, numDataCodewords);
            for (i in 0..numDataCodewords) {
                resultBytes[resultOffset] = codewordBytes[i]
                resultOffset++
            }
        }

        // Decode the contents of that stream of bytes
        return DecodedBitStreamParser.decode(resultBytes, version, ecLevel, hints);
    }

    /**
     * <p>Given data and error-correction codewords received, possibly corrupted by errors, attempts to
     * correct the errors in-place using Reed-Solomon error correction.</p>
     *
     * @param codewordBytes data and error correction codewords
     * @param numDataCodewords number of codewords that are data bytes
     * @throws ChecksumException if error correction fails
     */
    private func correctErrors(codewordBytes: Array<Byte>, numDataCodewords: Int64) {
        var codewordBytes_ = codewordBytes
        let numCodewords: Int64 = codewordBytes_.size;

        // First read into an array of ints
        var codewordsInts: Array<Int64> = Array<Int64>(numCodewords, item: 0);
        for (i in 0..numCodewords) {
            codewordsInts[i] = Int64(codewordBytes_[i]) & 0xFF
        }
        try {
            rsDecoder.decode(codewordsInts, codewordBytes_.size - numDataCodewords);
        } catch (ignored: ReedSolomonException) {
            throw ChecksumException.getChecksumInstance();
        }

        // Copy back into array of bytes -- only need to worry about the bytes that were data
        // We don't care about errors in the error-correction codewords
        for (i in 0..numDataCodewords) {
            codewordBytes_[i] = UInt8(codewordsInts[i])
        }
    }
}
