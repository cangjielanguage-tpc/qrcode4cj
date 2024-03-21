package zxing.code.maxicode.decoder

import zxing.code.common.ChecksumException
import zxing.code.common.DecodeHintType
import zxing.code.common.FormatException
import zxing.code.common.BitMatrix
import zxing.code.common.DecoderResult
import zxing.code.common.reedsolomon.GenericGF
import zxing.code.common.reedsolomon.ReedSolomonDecoder
import zxing.code.common.reedsolomon.ReedSolomonException
import zxing.code.tools.System
from std import collection.*

//import java.util.Map;

/**
 * The main class which implements MaxiCode decoding -- as opposed to locating and extracting
 * the MaxiCode from an image.
 */
public class Decoder {
    private static var ALL: Int64 = 0
    private static var EVEN: Int64 = 1
    private static var ODD: Int64 = 2

    private var rsDecoder: ReedSolomonDecoder

    public init() {
        this.rsDecoder = ReedSolomonDecoder(GenericGF.MAXICODE_FIELD_64)
    }

    public func decode(bits: BitMatrix): DecoderResult {
        return decode(bits, HashMap<DecodeHintType, Any>())
    }

    public func decode(bits: BitMatrix, _: HashMap<DecodeHintType, Any>): DecoderResult {
        var parser: BitMatrixParser = BitMatrixParser(bits)
        var codewords: Array<UInt8> = parser.readCodewords()

        correctErrors(codewords, 0, 10, 10, ALL)
        var mode = codewords[0] & 0x0F
        var datawords: Array<UInt8> = Array<UInt8>()
        match (mode) {
            case 2 | 3 | 4 =>
                correctErrors(codewords, 20, 84, 40, EVEN)
                correctErrors(codewords, 20, 84, 40, ODD)
                datawords = Array<UInt8>(94, item: 0)
            case 5 =>
                correctErrors(codewords, 20, 68, 56, EVEN)
                correctErrors(codewords, 20, 68, 56, ODD)
                datawords = Array<UInt8>(78, item: 0)
            case _ => throw FormatException.getFormatInstance()
        }
        System.arraycopy(codewords, 0, datawords, 0, 10)
        System.arraycopy(codewords, 20, datawords, 10, datawords.size - 10)

        return DecodedBitStreamParser.decode(datawords, Int64(mode))
    }

    private func correctErrors(
        codewordBytes: Array<UInt8>,
        start: Int64,
        dataCodewords: Int64,
        ecCodewords: Int64,
        mode: Int64
    ) {
        var codewords: Int64 = dataCodewords + ecCodewords

        // in EVEN or ODD mode only half the codewords
        var divisor: Int64 = 2
        if (mode == ALL) {
            divisor = 1
        }

        // First read into an array of ints
        var codewordsInts: Array<Int64> = Array<Int64>(codewords / divisor, item: 0)
        for (i in 0..codewords) {
            if ((mode == ALL) || (i % 2 == (mode - 1))) {
                codewordsInts[i / divisor] = Int64(UInt8(codewordBytes[i + start])) & 0xFF
            }
        }
        try {
            rsDecoder.decode(codewordsInts, ecCodewords / divisor)
        } catch (ignored: ReedSolomonException) {
            throw ChecksumException.getChecksumInstance()
        }

        // Copy back into array of bytes -- only need to worry about the bytes that were data
        // We don't care about errors in the error-correction codewords
        for (i in 0..dataCodewords) {
            if ((mode == ALL) || (i % 2 == (mode - 1))) {
                codewordBytes[i + start] = UInt8(codewordsInts[i / divisor])
            }
        }
    }
}
