package aztec.encoder

import common.reedsolomon.GenericGF
import common.reedsolomon.ReedSolomonEncoder
import common.StandardCharsets
import common.MyCharset

/**
 * Generates Aztec 2D barcodes.
 *
 * @author Rustam Abdullaev
 */
public class Encoder {
    public static var DEFAULT_EC_PERCENT: Int64 = 33 // default minimal percentage of error check words
    public static var DEFAULT_AZTEC_LAYERS: Int64 = 0
    private static var MAX_NB_BITS: Int64 = 32
    private static var MAX_NB_BITS_COMPACT: Int64 = 4

    private static var WORD_SIZE: Array<Int64> = [
        4,
        6,
        6,
        8,
        8,
        8,
        8,
        8,
        8,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12,
        12
    ]

    private init() {}

    /**
     * Encodes the given string content as an Aztec symbol (without ECI code)
     *
     * @param data input data string; must be encodable as ISO/IEC 8859-1 (Latin-1)
     * @return Aztec symbol matrix with metadata
     */
    public static func encode(data: String): AztecCode {
        return encode(StandardCharsets.ISO_8859_1.newEncoder().getBytes(UTF32String(data)));
    }

    /**
     * Encodes the given string content as an Aztec symbol (without ECI code)
     *
     * @param data input data string; must be encodable as ISO/IEC 8859-1 (Latin-1)
     * @param minECCPercent minimal percentage of error check words (According to ISO/IEC 24778:2008,
     * a minimum of 23% + 3 words is recommended)
     * @param userSpecifiedLayers if non-zero, a user-specified value for the number of layers
     * @return Aztec symbol matrix with metadata
     */
    public static func encode(data: String, minECCPercent: Int64, userSpecifiedLayers: Int64): AztecCode {
        return encode(
            StandardCharsets.ISO_8859_1.newEncoder().getBytes(UTF32String(data)),
            minECCPercent,
            userSpecifiedLayers,
            MyCharset() /*null*/
        )
    }

    /**
     * Encodes the given string content as an Aztec symbol
     *
     * @param data input data string
     * @param minECCPercent minimal percentage of error check words (According to ISO/IEC 24778:2008,
     * a minimum of 23% + 3 words is recommended)
     * @param userSpecifiedLayers if non-zero, a user-specified value for the number of layers
     * @param charset character set in which to encode string using ECI; if null, no ECI code
     * will be inserted, and the string must be encodable as ISO/IEC 8859-1
     * (Latin-1), the default encoding of the symbol.
     * @return Aztec symbol matrix with metadata
     */
    public static func encode(data: UTF32String, minECCPercent: Int64, userSpecifiedLayers: Int64, charset: MyCharset): AztecCode {
        var bytes: Array<UInt8> = charset.newEncoder().getBytes(data);
        return encode(bytes, minECCPercent, userSpecifiedLayers, charset)
    }

    /**
     * Encodes the given binary content as an Aztec symbol (without ECI code)
     *
     * @param data input data string
     * @return Aztec symbol matrix with metadata
     */
    public static func encode(data: Array<UInt8>): AztecCode {
        return encode(data, DEFAULT_EC_PERCENT, DEFAULT_AZTEC_LAYERS, MyCharset() /*null*/ )
    }

    /**
     * Encodes the given binary content as an Aztec symbol (without ECI code)
     *
     * @param data input data string
     * @param minECCPercent minimal percentage of error check words (According to ISO/IEC 24778:2008,
     * a minimum of 23% + 3 words is recommended)
     * @param userSpecifiedLayers if non-zero, a user-specified value for the number of layers
     * @return Aztec symbol matrix with metadata
     */
    public static func encode(data: Array<UInt8>, minECCPercent: Int64, userSpecifiedLayers: Int64): AztecCode {
        return encode(data, minECCPercent, userSpecifiedLayers, MyCharset() /*null*/ )
    }

    /**
     * Encodes the given binary content as an Aztec symbol
     *
     * @param data input data string
     * @param minECCPercent minimal percentage of error check words (According to ISO/IEC 24778:2008,
     * a minimum of 23% + 3 words is recommended)
     * @param userSpecifiedLayers if non-zero, a user-specified value for the number of layers
     * @param charset character set to mark using ECI; if null, no ECI code will be inserted, and the
     * default encoding of ISO/IEC 8859-1 will be assuming by readers.
     * @return Aztec symbol matrix with metadata
     */
    public static func encode(data: Array<UInt8>, minECCPercent: Int64, userSpecifiedLayers: Int64, charset: MyCharset): AztecCode {

        // High-level encode
        var bits: BitArray = HighLevelEncoder(data, charset).encode()

        // stuff bits and choose symbol size
        var eccBits: Int64 = bits.getSize() * minECCPercent / 100 + 11
        var totalSizeBits: Int64 = bits.getSize() + eccBits
        var compact: Bool = false;
        var layers: Int64 = 0;
        var totalBitsInLayer: Int64 = 0;
        var wordSize: Int64 = 0;
        var stuffedBits: BitArray = BitArray()
        if (userSpecifiedLayers != DEFAULT_AZTEC_LAYERS) {
            compact = userSpecifiedLayers < 0
            layers = abs(userSpecifiedLayers)
            var bitsNum = MAX_NB_BITS
            if (compact) {
                bitsNum = MAX_NB_BITS_COMPACT
            }
            if (layers > bitsNum) {
                throw IllegalArgumentException("Illegal value ${userSpecifiedLayers} for layers")
            }
            totalBitsInLayer = TotalBitsInLayer(layers, compact)
            wordSize = WORD_SIZE[layers]
            var usableBitsInLayers: Int64 = totalBitsInLayer - (totalBitsInLayer % wordSize)
            stuffedBits = stuffBits(bits, wordSize)
            if (stuffedBits.getSize() + eccBits > usableBitsInLayers) {
                throw IllegalArgumentException("Data to large for user specified layer")
            }
            if (compact && stuffedBits.getSize() > wordSize * 64) {
                // Compact format only allows 64 data words, though C4 can hold more words than that
                throw IllegalArgumentException("Data to large for user specified layer")
            }
        } else {
            wordSize = 0
            stuffedBits = BitArray()

            // We look at the possible table sizes in the order Compact1, Compact2, Compact3,
            // Compact4, Normal4,...  Normal(i) for i < 4 isn't typically used since Compact(i+1)
            // is the same size, but has more data.
            var i0 = 0
            while (true) {
                if (i0 > MAX_NB_BITS) {
                    throw IllegalArgumentException("Data too large for an Aztec code");
                }
                compact = (i0 <= 3)
                if (compact) {
                    layers = i0 + 1
                } else {
                    layers = i0
                }
                totalBitsInLayer = TotalBitsInLayer(layers, compact)
                if (totalSizeBits > totalBitsInLayer) {
                    i0++
                    continue
                }

                // [Re]stuff the bits if this is the first opportunity, or if the
                // wordSize has changed
                if (stuffedBits.getSize() == 0 || wordSize != WORD_SIZE[layers]) {
                    wordSize = WORD_SIZE[layers]
                    stuffedBits = stuffBits(bits, wordSize)
                }
                var usableBitsInLayers: Int64 = totalBitsInLayer - (totalBitsInLayer % wordSize)
                if (compact && stuffedBits.getSize() > wordSize * 64) {
                    // Compact format only allows 64 data words, though C4 can hold more words than that
                    i0++
                    continue
                }
                if (stuffedBits.getSize() + eccBits <= usableBitsInLayers) {
                    break
                }

                i0++
            }
        }
        var messageBits: BitArray = generateCheckWords(stuffedBits, totalBitsInLayer, wordSize)

        // generate mode message
        var messageSizeInWords: Int64 = stuffedBits.getSize() / wordSize
        var modeMessage: BitArray = generateModeMessage(compact, layers, messageSizeInWords)

        // allocate symbol
        var baseMatrixSize: Int64 = 14 + layers * 4 // not including alignment lines
        if (compact) {
            baseMatrixSize = 11 + layers * 4
        }
        var alignmentMap: Array<Int64> = Array<Int64>(baseMatrixSize, item: 0)
        var matrixSize: Int64
        if (compact) {
            // no alignment marks in compact mode, alignmentMap is a no-op
            matrixSize = baseMatrixSize
            for (i in 0..alignmentMap.size) {
                alignmentMap[i] = i
            }
        } else {
            matrixSize = baseMatrixSize + 1 + 2 * ((baseMatrixSize / 2 - 1) / 15)
            var origCenter: Int64 = baseMatrixSize / 2
            var center: Int64 = matrixSize / 2
            for (i in 0..origCenter) {
                var newOffset: Int64 = i + i / 15
                alignmentMap[origCenter - i - 1] = center - newOffset - 1
                alignmentMap[origCenter + i] = center + newOffset + 1
            }
        }
        var matrix: BitMatrix = BitMatrix(matrixSize)

        // draw data bits
        var rowOffset: Int64 = 0
        for (i in 0..layers) {
            var rowSize: Int64 = (layers - i) * 4 + 12
            if (compact) {
                rowSize = (layers - i) * 4 + 9
            }
            for (j in 0..rowSize) {
                var columnOffset: Int64 = j * 2
                for (k in 0..2) {
                    if (messageBits.get(rowOffset + columnOffset + k)) {
                        matrix.set(alignmentMap[i * 2 + k], alignmentMap[i * 2 + j])
                    }
                    if (messageBits.get(rowOffset + rowSize * 2 + columnOffset + k)) {
                        matrix.set(alignmentMap[i * 2 + j], alignmentMap[baseMatrixSize - 1 - i * 2 - k])
                    }
                    if (messageBits.get(rowOffset + rowSize * 4 + columnOffset + k)) {
                        matrix.set(
                            alignmentMap[baseMatrixSize - 1 - i * 2 - k],
                            alignmentMap[baseMatrixSize - 1 - i * 2 - j]
                        )
                    }
                    if (messageBits.get(rowOffset + rowSize * 6 + columnOffset + k)) {
                        matrix.set(alignmentMap[baseMatrixSize - 1 - i * 2 - j], alignmentMap[i * 2 + k])
                    }
                }
            }
            rowOffset += rowSize * 8
        }

        // draw mode message
        drawModeMessage(matrix, compact, matrixSize, modeMessage)

        // draw alignment marks
        if (compact) {
            drawBullsEye(matrix, matrixSize / 2, 5)
        } else {
            drawBullsEye(matrix, matrixSize / 2, 7)
            var i1: Int64 = 0
            var j1: Int64 = 0
            while (i1 < baseMatrixSize / 2 - 1) {
                var k1: Int64 = (matrixSize / 2) & 1
                while (k1 < matrixSize) {
                    matrix.set(matrixSize / 2 - j1, k1)
                    matrix.set(matrixSize / 2 + j1, k1)
                    matrix.set(k1, matrixSize / 2 - j1)
                    matrix.set(k1, matrixSize / 2 + j1)
                    k1 += 2
                }
                i1 += 15
                j1 += 16
            }
        }

        var aztec: AztecCode = AztecCode()
        aztec.setCompact(compact)
        aztec.setSize(matrixSize)
        aztec.setLayers(layers)
        aztec.setCodeWords(messageSizeInWords)
        aztec.setMatrix(matrix)

        return aztec
    }

    private static func drawBullsEye(matrix: BitMatrix, center: Int64, size: Int64) {
        var i: Int64 = 0
        while (i < size) {
            var j: Int64 = center - i
            while (j <= center + i) {
                matrix.set(j, center - i)
                matrix.set(j, center + i)
                matrix.set(center - i, j)
                matrix.set(center + i, j)
                j++
            }
            i += 2
        }
        matrix.set(center - size, center - size)
        matrix.set(center - size + 1, center - size)
        matrix.set(center - size, center - size + 1)
        matrix.set(center + size, center - size)
        matrix.set(center + size, center - size + 1)
        matrix.set(center + size, center + size - 1)
    }

    public static func generateModeMessage(compact: Bool, layers: Int64, messageSizeInWords: Int64): BitArray {
        var modeMessage: BitArray = BitArray()
        if (compact) {
            modeMessage.appendBits(layers - 1, 2)
            modeMessage.appendBits(messageSizeInWords - 1, 6)
            modeMessage = generateCheckWords(modeMessage, 28, 4)
        } else {
            modeMessage.appendBits(layers - 1, 5)
            modeMessage.appendBits(messageSizeInWords - 1, 11)
            modeMessage = generateCheckWords(modeMessage, 40, 4)
        }
        return modeMessage
    }

    private static func drawModeMessage(matrix: BitMatrix, compact: Bool, matrixSize: Int64, modeMessage: BitArray) {
        var center: Int64 = matrixSize / 2
        if (compact) {
            for (i in 0..7) {
                var offset: Int64 = center - 3 + i
                if (modeMessage.get(i)) {
                    matrix.set(offset, center - 5)
                }
                if (modeMessage.get(i + 7)) {
                    matrix.set(center + 5, offset)
                }
                if (modeMessage.get(20 - i)) {
                    matrix.set(offset, center + 5)
                }
                if (modeMessage.get(27 - i)) {
                    matrix.set(center - 5, offset)
                }
            }
        } else {
            for (i in 0..10) {
                var offset: Int64 = center - 5 + i + i / 5
                if (modeMessage.get(i)) {
                    matrix.set(offset, center - 7)
                }
                if (modeMessage.get(i + 10)) {
                    matrix.set(center + 7, offset)
                }
                if (modeMessage.get(29 - i)) {
                    matrix.set(offset, center + 7)
                }
                if (modeMessage.get(39 - i)) {
                    matrix.set(center - 7, offset)
                }
            }
        }
    }

    private static func generateCheckWords(bitArray: BitArray, totalBits: Int64, wordSize: Int64): BitArray {
        // bitArray is guaranteed to be a multiple of the wordSize, so no padding needed
        var messageSizeInWords: Int64 = bitArray.getSize() / wordSize
        var rs: ReedSolomonEncoder = ReedSolomonEncoder(getGF(wordSize))
        var totalWords: Int64 = totalBits / wordSize
        var messageWords: Array<Int64> = bitsToWords(bitArray, wordSize, totalWords)
        rs.encode(messageWords, totalWords - messageSizeInWords)
        var startPad: Int64 = totalBits % wordSize
        var messageBits: BitArray = BitArray()
        messageBits.appendBits(0, startPad)
        for (i in 0..messageWords.size) {
            messageBits.appendBits(messageWords[i], wordSize)
        }
        return messageBits
    }

    private static func bitsToWords(stuffedBits: BitArray, wordSize: Int64, totalWords: Int64): Array<Int64> {
        var message: Array<Int64> = Array<Int64>(totalWords, item: 0)
        var i: Int64
        var n: Int64 = stuffedBits.getSize() / wordSize
        for (i in 0..n) {
            var value: Int64 = 0
            for (j in 0..wordSize) {
                if (stuffedBits.get(i * wordSize + j)) {
                    value |= (1 << wordSize - j - 1)
                } else {
                    value |= 0
                }
            }
            message[i] = value
        }
        return message
    }

    private static func getGF(wordSize: Int64): GenericGF {
        match (wordSize) {
            case 4 => return GenericGF.AZTEC_PARAM
            case 6 => return GenericGF.AZTEC_DATA_6
            case 8 => return GenericGF.AZTEC_DATA_8
            case 10 => return GenericGF.AZTEC_DATA_10
            case 12 => return GenericGF.AZTEC_DATA_12
            case _ => throw IllegalArgumentException("Unsupported word size ${wordSize}")
        }
    }

    public static func stuffBits(bits: BitArray, wordSize: Int64): BitArray {
        var out: BitArray = BitArray()

        var n: Int64 = bits.getSize()
        var mask: Int64 = (1 << wordSize) - 2
        var i = 0
        while (i < n) {
            var word: Int64 = 0
            for (j in 0..wordSize) {
                if (i + j >= n || bits.get(i + j)) {
                    word |= 1 << (wordSize - 1 - j)
                }
            }
            if ((word & mask) == mask) {
                out.appendBits(word & mask, wordSize)
                i--
            } else if ((word & mask) == 0) {
                out.appendBits(word | 1, wordSize)
                i--
            } else {
                out.appendBits(word, wordSize)
            }
            i += wordSize
        }
        return out
    }

    private static func TotalBitsInLayer(layers: Int64, compact: Bool): Int64 {
        if (compact) {
            return (88 + 16 * layers) * layers
        } else {
            return (112 + 16 * layers) * layers
        }
    }
}
