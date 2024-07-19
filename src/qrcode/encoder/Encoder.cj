/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.qrcode.encoder

import QRCode4cj.common.*
import QRCode4cj.common.reedsolomon.*
import QRCode4cj.qrcode.decoder.*
import std.convert.*
import std.collection.*
import QRCode4cj.tools.*
import std.math.*

public class Encoder {
    // The original table is defined in the table 5 of JISX0510:2004 (p.19).
    private static let ALPHANUMERIC_TABLE: Array<Int64> = [
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1, // 0x00-0x0f
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1, // 0x10-0x1f
        36,
        -1,
        -1,
        -1,
        37,
        38,
        -1,
        -1,
        -1,
        -1,
        39,
        40,
        -1,
        41,
        42,
        43, // 0x20-0x2f
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        44,
        -1,
        -1,
        -1,
        -1,
        -1, // 0x30-0x3f
        -1,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24, // 0x40-0x4f
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        32,
        33,
        34,
        35,
        -1,
        -1,
        -1,
        -1,
        -1 // 0x50-0x5f
    ]

    public static let DEFAULT_BYTE_MODE_ENCODING: MyCharset = StandardCharsets.ISO_8859_1;

    init() {}

    // The mask penalty calculation is complicated.  See Table 21 of JISX0510:2004 (p.45) for details.
    // Basically it applies four rules and summate all penalties.
    private static func calculateMaskPenalty(matrix: ByteMatrix): Int64 {
        var result = MaskUtil.applyMaskPenaltyRule1(matrix) + MaskUtil.applyMaskPenaltyRule2(matrix) +
            MaskUtil.applyMaskPenaltyRule3(matrix) + MaskUtil.applyMaskPenaltyRule4(matrix)
        return result
    }

    /**
     * @param content text to encode
     * @param ecLevel error correction level to use
     * @return QRCode representing the encoded QR code
     * @throws Qrcoder4cjWriterException if encoding can't succeed, because of for example invalid content or
     * configuration
     */
    public static func encode(content: String, ecLevel: ErrorCorrectionLevel): QRCode {
        return encode(content, ecLevel, HashMap<EncodeHintType, Any>());
    }

    public static func encode(content: String, ecLevel: ErrorCorrectionLevel, hints: HashMap<EncodeHintType, Any>): QRCode {
        let contentUtf = UTF32String(content)
        var version: Version
        var headerAndDataBits: BitArray
        var mode: Mode

        let hasGS1FormatHint: Bool = hints.size != 0 && hints.contains(EncodeHintType.GS1_FORMAT) &&
            EncodeHintType.getHashMapValue(EncodeHintType.GS1_FORMAT, hints[EncodeHintType.GS1_FORMAT]) == "true"
        let hasCompactionHint: Bool = hints.size != 0 && hints.contains(EncodeHintType.QR_COMPACT) &&
            EncodeHintType.getHashMapValue(EncodeHintType.QR_COMPACT, hints[EncodeHintType.QR_COMPACT]) == "true"

        // Determine what character encoding has been specified by the caller, if any
        var encoding: MyCharset = DEFAULT_BYTE_MODE_ENCODING
        var hasEncodingHint: Bool = hints.size != 0 && hints.contains(EncodeHintType.CHARACTER_SET)
        if (hasEncodingHint) {
            encoding = MyCharset.forName(
                EncodeHintType.getHashMapValue(EncodeHintType.CHARACTER_SET, hints[EncodeHintType.CHARACTER_SET]))
        }

        if (hasCompactionHint) {
            mode = Mode.BYTE([8, 16, 16], 0x04)

            var priorityEncoding: MyCharset = if (encoding.equals(DEFAULT_BYTE_MODE_ENCODING)) {
                MyCharset();
            } else {
                encoding
            }
            var rn: ResultList = MinimalEncoder.encode(contentUtf, None, priorityEncoding, hasGS1FormatHint, ecLevel);

            headerAndDataBits = BitArray()
            rn.getBits(headerAndDataBits);
            version = rn.getVersion()
        } else {
            // Pick an encoding mode appropriate for the content. Note that this will not attempt to use
            // multiple modes / segments even if that were more efficient.
            mode = chooseMode(contentUtf, encoding)

            // This will store the header information, like mode and
            // length, as well as "header" segments like an ECI segment.
            var headerBits: BitArray = BitArray();

            // Append ECI segment if applicable
            if (mode == Mode.BYTE([8, 16, 16], 0x04) && hasEncodingHint) {
                var eci: Int64 = CharacterSetECI.getCharacterSetECI(encoding);
                appendECI(eci, headerBits);
            }

            // Append the FNC1 mode header for GS1 formatted data if applicable
            if (hasGS1FormatHint) {
                // GS1 formatted codes are prefixed with a FNC1 in first position mode header
                appendModeInfo(Mode.FNC1_FIRST_POSITION([0, 0, 0], 0x05), headerBits);
            }

            // (With ECI in place,) Write the mode marker
            appendModeInfo(mode, headerBits);

            // Collect data within the main segment, separately, to count its size if needed. Don't add it to
            // main payload yet.
            var dataBits: BitArray = BitArray();
            appendBytes(contentUtf, mode, dataBits, encoding);

            if (hints.size != 0 && hints.contains(EncodeHintType.QR_VERSION)) {
                var versionNumber: Int64 = Int64.parse(
                    EncodeHintType.getHashMapValue(EncodeHintType.QR_VERSION, hints[EncodeHintType.QR_VERSION]));
                version = Version.getVersionForNumber(versionNumber)
                var bitsNeeded: Int64 = calculateBitsNeeded(mode, headerBits, dataBits, version);
                if (!willFit(bitsNeeded, version, ecLevel)) {
                    throw Qrcoder4cjWriterException("Data too big for requested version");
                }
            } else {
                version = recommendVersion(ecLevel, mode, headerBits, dataBits)
            }

            headerAndDataBits = BitArray()
            headerAndDataBits.appendBitArray(headerBits);

            // Find "length" of main segment and write it
            let numLetters: Int64 = if (mode == Mode.BYTE([8, 16, 16], 0x04)) {
                dataBits.getSizeInBytes()
            } else {
                contentUtf.charSize
            }
            appendLengthInfo(numLetters, version, mode, headerAndDataBits);

            // Put data together into the overall payload
            headerAndDataBits.appendBitArray(dataBits);
        }

        var ecBlocks: ECBlocks = version.getECBlocksForLevel(ecLevel);
        var numDataBytes: Int64 = version.getTotalCodewords() - ecBlocks.getTotalECCodewords()

        // Terminate the bits properly.
        terminateBits(numDataBytes, headerAndDataBits);

        // Interleave data bits with error correction code.
        var finalBits: BitArray = interleaveWithECBytes(
            headerAndDataBits,
            version.getTotalCodewords(),
            numDataBytes,
            ecBlocks.getNumBlocks()
        );

        var qrCode: QRCode = QRCode();

        qrCode.setECLevel(ecLevel);
        qrCode.setMode(mode);
        qrCode.setVersion(version);

        //  Choose the mask pattern and set to "qrCode".
        var dimension: Int64 = version.getDimensionForVersion();
        var matrix: ByteMatrix = ByteMatrix(dimension, dimension);

        // Enable manual selection of the pattern to be used via hint
        var maskPattern: Int64 = -1;
        if (hints.size != 0 && hints.contains(EncodeHintType.QR_MASK_PATTERN)) {
            var hintMaskPattern: Int64 = Int64.parse(
                EncodeHintType.getHashMapValue(EncodeHintType.QR_MASK_PATTERN, hints[EncodeHintType.QR_MASK_PATTERN]));
            maskPattern = if (QRCode.isValidMaskPattern(hintMaskPattern)) {
                hintMaskPattern
            } else {
                -1
            }
        }

        if (maskPattern == -1) {
            maskPattern = chooseMaskPattern(finalBits, ecLevel, version, matrix)
        }
        qrCode.setMaskPattern(maskPattern);

        /* Build the matrix and set it to "qrCode". */
        MatrixUtil.buildMatrix(finalBits, ecLevel, version, maskPattern, matrix);
        qrCode.setMatrix(matrix);

        return qrCode
    }

    /**
     * Decides the smallest version value of QR code that will contain all of the provided data.
     *
     * @throws Qrcoder4cjWriterException if the data cannot fit in any version value
     */
    private static func recommendVersion(
        ecLevel: ErrorCorrectionLevel,
        mode: Mode,
        headerBits: BitArray,
        dataBits: BitArray
    ): Version {
        // Hard part: need to know version to know how many bits length takes. But need to know how many
        // bits it takes to know version. First we take a guess at version by assuming version will be
        // the minimum, 1:
        var provisionalBitsNeeded: Int64 = calculateBitsNeeded(
            mode,
            headerBits,
            dataBits,
            Version.getVersionForNumber(1)
        );
        var provisionalVersion: Version = chooseVersion(provisionalBitsNeeded, ecLevel);

        // Use that guess to calculate the right version. I am still not sure this works in 100% of cases.
        var bitsNeeded: Int64 = calculateBitsNeeded(mode, headerBits, dataBits, provisionalVersion);
        return chooseVersion(bitsNeeded, ecLevel);
    }

    private static func calculateBitsNeeded(mode: Mode, headerBits: BitArray, dataBits: BitArray, version: Version): Int64 {
        return headerBits.getSize() + mode.getCharacterCountBits(version) + dataBits.getSize()
    }

    /**
     * @return the code point of the table used in alphanumeric mode or
     * -1 if there is no corresponding code in the table.
     */
    public static func getAlphanumericCode(code: Int64): Int64 {
        if (code < ALPHANUMERIC_TABLE.size) {
            return ALPHANUMERIC_TABLE[code]
        }
        return -1;
    }

    public static func chooseMode(content: String): Mode {
        return chooseMode(UTF32String(content), None);
    }

    /**
     * Choose the best mode by examining the content. Note that 'encoding' is used as a hint;
     * if it is Shift_JIS, and the input is only double-byte Kanji, then we return {@link Mode#KANJI}.
     */
    private static func chooseMode(content: UTF32String, encoding: ?MyCharset): Mode {
        var flag: Bool = if (let Some(e) <- encoding) {
            true
        } else {
            false
        }
        if (flag && StringUtils.SHIFT_JIS_CHARSET.equals(encoding.getOrThrow()) && isOnlyDoubleByteKanji(content)) {
            // Choose Kanji mode if all input are double-byte characters
            return Mode.KANJI([8, 10, 12], 0x08);
        }
        var hasNumeric: Bool = false;
        var hasAlphanumeric: Bool = false;
        for (i in 0..content.size) {
            var c: Rune = content[i]
            if (c >= r'0' && c <= r'9') {
                hasNumeric = true
            } else if (getAlphanumericCode(c.hashCode()) != -1) {
                hasAlphanumeric = true
            } else {
                return Mode.BYTE([8, 16, 16], 0x04);
            }
        }
        if (hasAlphanumeric) {
            return Mode.ALPHANUMERIC([9, 11, 13], 0x02);
        }
        if (hasNumeric) {
            return Mode.NUMERIC([10, 12, 14], 0x01);
        }
        return Mode.BYTE([8, 16, 16], 0x04);
    }

    static func isOnlyDoubleByteKanji(content: UTF32String): Bool {
        var bytes: Array<UInt8> = StringUtils.SHIFT_JIS_CHARSET.newEncoder().getBytes(content)

        /*StringUtils.SHIFT_JIS_CHARSET*/
        var length: Int64 = bytes.size;
        if (length % 2 != 0) {
            return false;
        }

        for (i in 0..length : 2) {
            var byte1: Int64 = Int64(bytes[i]) & 0xFF
            if ((byte1 < 0x81 || byte1 > 0x9F) && (byte1 < 0xE0 || byte1 > 0xEB)) {
                return false;
            }
        }

        return true;
    }

    private static func chooseMaskPattern(
        bits: BitArray,
        ecLevel: ErrorCorrectionLevel,
        version: Version,
        matrix: ByteMatrix
    ): Int64 {
        var minPenalty: Int64 = Int64.Max;

        // Lower penalty is better.
        var bestMaskPattern: Int64 = -1;

        // We try all mask patterns to choose the best one.
        var masknum: Int64 = QRCode.NUM_MASK_PATTERNS;
        for (maskPattern in 0..masknum) {
            MatrixUtil.buildMatrix(bits, ecLevel, version, maskPattern, matrix);
            var penalty: Int64 = calculateMaskPenalty(matrix);
            if (penalty < minPenalty) {
                minPenalty = penalty
                bestMaskPattern = maskPattern
            }
        }
        return bestMaskPattern
    }

    private static func chooseVersion(numInputBits: Int64, ecLevel: ErrorCorrectionLevel): Version {
        for (versionNum in 1..=40) {
            var version: Version = Version.getVersionForNumber(versionNum);
            if (willFit(numInputBits, version, ecLevel)) {
                return version
            }
        }
        throw Qrcoder4cjWriterException("Data too big");
    }

    /**
     * @return true if the number of input bits will fit in a code with the specified version and
     * error correction level.
     */
    static func willFit(numInputBits: Int64, version: Version, ecLevel: ErrorCorrectionLevel): Bool {
        // In the following comments, we use numbers of Version 7-H.
        // numBytes = 196
        var numBytes: Int64 = version.getTotalCodewords();

        // getNumECBytes = 130
        var ecBlocks: ECBlocks = version.getECBlocksForLevel(ecLevel);
        var numEcBytes: Int64 = ecBlocks.getTotalECCodewords();

        // getNumDataBytes = 196 - 130 = 66
        var numDataBytes: Int64 = numBytes - numEcBytes
        var totalInputBytes: Int64 = (numInputBits + 7) / 8
        return numDataBytes >= totalInputBytes
    }

    /**
     * Terminate bits as described in 8.4.8 and 8.4.9 of JISX0510:2004 (p.24).
     */
    public static func terminateBits(numDataBytes: Int64, bits: BitArray) {
        var capacity: Int64 = numDataBytes * 8
        if (bits.getSize() > capacity) {
            throw Qrcoder4cjWriterException(
                "data bits cannot fit in the QR Code" + bits.getSize().toString() + " > " + capacity.toString());
        }

        // Append Mode.TERMINATE if there is enough space (value is 0000)
        var bistitem: Int64 = 0;
        while (bistitem < 4 && bits.getSize() < capacity) {
            bits.appendBit(false);
            bistitem++
        }

        // Append termination bits. See 8.4.8 of JISX0510:2004 (p.24) for details.
        // If the last byte isn't 8-bit aligned, we'll add padding bits.
        var numBitsInLastByte: Int64 = bits.getSize() & 0x07
        if (numBitsInLastByte > 0) {
            for (i in numBitsInLastByte..8) {
                bits.appendBit(false);
            }
        }

        // If we have more space, we'll fill the space with padding patterns defined in 8.4.9 (p.24).
        var numPaddingBytes: Int64 = numDataBytes - bits.getSizeInBytes()

        for (i in 0..numPaddingBytes) {
            bits.appendBits(
                if ((i & 0x01) == 0) {
                    0xEC
                } else {
                    0x11
                },
                8
            );
        }
        if (bits.getSize() != capacity) {
            throw Qrcoder4cjWriterException("Bits size does not equal capacity");
        }
    }

    /**
     * Get number of data bytes and number of error correction bytes for block id "blockID". Store
     * the result in "numDataBytesInBlock", and "numECBytesInBlock_". See table 12 in 8.5.1 of
     * JISX0510:2004 (p.30)
     */
    public static func getNumDataBytesAndNumECBytesForBlockID(
        numTotalBytes: Int64,
        numDataBytes: Int64,
        numRSBlocks: Int64,
        blockID: Int64,
        numDataBytesInBlock: Array<Int64>,
        numECBytesInBlock_: Array<Int64>
    ) {
        if (blockID >= numRSBlocks) {
            throw Qrcoder4cjWriterException("Block ID too large");
        }

        // numRsBlocksInGroup2 = 196 % 5 = 1
        var numRsBlocksInGroup2: Int64 = numTotalBytes % numRSBlocks

        // numRsBlocksInGroup1 = 5 - 1 = 4
        var numRsBlocksInGroup1: Int64 = numRSBlocks - numRsBlocksInGroup2

        // numTotalBytesInGroup1 = 196 / 5 = 39
        var numTotalBytesInGroup1: Int64 = numTotalBytes / numRSBlocks

        // numTotalBytesInGroup2 = 39 + 1 = 40
        var numTotalBytesInGroup2: Int64 = numTotalBytesInGroup1 + 1

        // numDataBytesInGroup1 = 66 / 5 = 13
        var numDataBytesInGroup1: Int64 = numDataBytes / numRSBlocks

        // numDataBytesInGroup2 = 13 + 1 = 14
        var numDataBytesInGroup2: Int64 = numDataBytesInGroup1 + 1

        // numEcBytesInGroup1 = 39 - 13 = 26
        var numEcBytesInGroup1: Int64 = numTotalBytesInGroup1 - numDataBytesInGroup1

        // numEcBytesInGroup2 = 40 - 14 = 26
        var numEcBytesInGroup2: Int64 = numTotalBytesInGroup2 - numDataBytesInGroup2

        // Sanity checks.
        // 26 = 26
        if (numEcBytesInGroup1 != numEcBytesInGroup2) {
            throw Qrcoder4cjWriterException("EC bytes mismatch");
        }

        // 5 = 4 + 1.
        if (numRSBlocks != numRsBlocksInGroup1 + numRsBlocksInGroup2) {
            throw Qrcoder4cjWriterException("RS blocks mismatch");
        }

        // 196 = (13 + 26) * 4 + (14 + 26) * 1
        if (numTotalBytes != ((numDataBytesInGroup1 + numEcBytesInGroup1) * numRsBlocksInGroup1) + ((numDataBytesInGroup2 +
            numEcBytesInGroup2) * numRsBlocksInGroup2)) {
            throw Qrcoder4cjWriterException("Total bytes mismatch");
        }

        if (blockID < numRsBlocksInGroup1) {
            numDataBytesInBlock[0] = numDataBytesInGroup1
            numECBytesInBlock_[0] = numEcBytesInGroup1
        } else {
            numDataBytesInBlock[0] = numDataBytesInGroup2
            numECBytesInBlock_[0] = numEcBytesInGroup2
        }
    }

    /**
     * Interleave "bits" with corresponding error correction bytes. On success, store the result in "result".
     * The interleave rule is complicated. See 8.6 of JISX0510:2004 (p.37) for details.
     */
    public static func interleaveWithECBytes(bits: BitArray, numTotalBytes: Int64, numDataBytes: Int64,
        numRSBlocks: Int64): BitArray {

        // "bits" must have "getNumDataBytes" bytes of data.
        if (bits.getSizeInBytes() != numDataBytes) {
            throw Qrcoder4cjWriterException("Number of bits and data bytes does not match");
        }

        // Step 1.  Divide data bytes into blocks and generate error correction bytes for them. We'll
        // store the divided data bytes blocks and error correction bytes blocks into "blocks".
        var dataBytesOffset: Int64 = 0;
        var maxNumDataBytes: Int64 = 0;
        var maxNumEcBytes: Int64 = 0;

        // Since, we know the number of reedsolmon blocks, we can initialize the vector with the number.
        var blocks: ArrayList<BlockPair> = ArrayList<BlockPair>(numRSBlocks);

        for (i in 0..numRSBlocks) {
            var numDataBytesInBlock: Array<Int64> = Array<Int64>(1, item: 0)
            var numEcBytesInBlock: Array<Int64> = Array<Int64>(1, item: 0)
            getNumDataBytesAndNumECBytesForBlockID(numTotalBytes, numDataBytes, numRSBlocks, i, numDataBytesInBlock,
                numEcBytesInBlock);

            var size: Int64 = numDataBytesInBlock[0]
            var dataBytes: Array<UInt8> = Array<UInt8>(size, item: 0)
            bits.toBytes(8 * dataBytesOffset, dataBytes, 0, size);
            var ecBytes: Array<UInt8> = generateECBytes(dataBytes, numEcBytesInBlock[0]);
            blocks.append(BlockPair(dataBytes, ecBytes));

            maxNumDataBytes = max(maxNumDataBytes, size)
            maxNumEcBytes = max(maxNumEcBytes, ecBytes.size)
            dataBytesOffset += numDataBytesInBlock[0]
        }
        if (numDataBytes != dataBytesOffset) {
            throw Qrcoder4cjWriterException("Data bytes does not match offset");
        }

        var result: BitArray = BitArray();

        // First, place data blocks.
        for (i in 0..maxNumDataBytes) {
            for (j in 0..blocks.size) {
                var dataBytes: Array<UInt8> = blocks[j].getDataBytes();
                if (i < dataBytes.size) {
                    result.appendBits(Int64(dataBytes[i]), 8);
                }
            }
        }

        // Then, place error correction blocks.
        for (i in 0..maxNumEcBytes) {
            for (j in 0..blocks.size) {
                var ecBytes: Array<UInt8> = blocks[j].getErrorCorrectionBytes();
                if (i < ecBytes.size) {
                    result.appendBits(Int64(ecBytes[i]), 8);
                }
            }
        }
        if (numTotalBytes != result.getSizeInBytes()) { // Should be same.
            throw Qrcoder4cjWriterException(
                "Interleaving error: " + numTotalBytes.toString() + " and " + result.getSizeInBytes().toString() +
                " differ.");
        }

        return result
    }

    public static func generateECBytes(dataBytes: Array<UInt8>, numEcBytesInBlock: Int64): Array<UInt8> {
        var numDataBytes: Int64 = dataBytes.size;
        var toEncode: Array<Int64> = Array<Int64>(numDataBytes + numEcBytesInBlock, item: 0);

        for (i in 0..numDataBytes) {
            toEncode[i] = Int64(dataBytes[i]) & 0xFF
        }
        ReedSolomonEncoder(GenericGF.QR_CODE_FIELD_256).encode(toEncode, numEcBytesInBlock);

        var ecBytes: Array<UInt8> = Array<UInt8>(numEcBytesInBlock, item: 0)

        for (i in 0..numEcBytesInBlock) {
            ecBytes[i] = UInt8(toEncode[numDataBytes + i])
        }
        return ecBytes
    }

    /**
     * Append mode info. On success, store the result in "bits".
     */
    public static func appendModeInfo(mode: Mode, bits: BitArray) {
        bits.appendBits(mode.getBits(), 4);
    }

    /**
     * Append length info. On success, store the result in "bits".
     */
    public static func appendLengthInfo(numLetters: Int64, version: Version, mode: Mode, bits: BitArray) {
        var numBits: Int64 = mode.getCharacterCountBits(version);
        if (numLetters >= (1 << numBits)) {
            throw Qrcoder4cjWriterException(numLetters.toString() + " is bigger than " + ((1 << numBits) - 1).toString());
        }
        bits.appendBits(numLetters, numBits);
    }

    /**
     * Append "bytes" in "mode" mode (encoding) into "bits". On success, store the result in "bits".
     */
    public static func appendBytes(content: UTF32String, mode: Mode, bits: BitArray, encoding: MyCharset) {
        match (mode) {
            case NUMERIC(x, y) => appendNumericBytes(content, bits);
            case ALPHANUMERIC(x, y) => appendAlphanumericBytes(content, bits);
            case BYTE(x, y) => append8BitBytes(content, bits, encoding);
            case KANJI(x, y) => appendKanjiBytes(content, bits);
            case _ => throw Qrcoder4cjWriterException("Invalid mode: " + mode.toString());
        }
    }

    public static func appendNumericBytes(content: UTF32String, bits: BitArray) {
        var length: Int64 = content.size;
        var i: Int64 = 0;
        while (i < length) {
            var num1: Int64 = content[i].hashCode() - r'0'.hashCode()

            if (i + 2 < length) {
                // Encode three numeric letters in ten bits.
                var num2: Int64 = content[i + 1].hashCode() - r'0'.hashCode()
                var num3: Int64 = content[i + 2].hashCode() - r'0'.hashCode()
                bits.appendBits(num1 * 100 + num2 * 10 + num3, 10);
                i += 3
            } else if (i + 1 < length) {
                // Encode two numeric letters in seven bits.
                var num2_: Int64 = content[i + 1].hashCode() - r'0'.hashCode()
                bits.appendBits(num1 * 10 + num2_, 7);
                i += 2
            } else {
                /* Encode one numeric letter in four bits. */
                bits.appendBits(num1, 4);
                i++
            }
        }
    }

    public static func appendAlphanumericBytes(content: UTF32String, bits: BitArray) {
        var length: Int64 = content.size;
        var i: Int64 = 0;
        while (i < length) {
            var code1: Int64 = getAlphanumericCode(content[i].hashCode());
            if (code1 == -1) {
                throw Qrcoder4cjWriterException();
            }
            if (i + 1 < length) {
                var code2: Int64 = getAlphanumericCode(content[i + 1].hashCode());
                if (code2 == -1) {
                    throw Qrcoder4cjWriterException();
                }

                /* Encode two alphanumeric letters in 11 bits. */
                bits.appendBits(code1 * 45 + code2, 11);
                i += 2
            } else {
                /* Encode one alphanumeric letter in six bits. */
                bits.appendBits(code1, 6);
                i++
            }
        }
    }

    public static func append8BitBytes(content: UTF32String, bits: BitArray, _: MyCharset) {
        for (i in content.toString().toArray()) {
            bits.appendBits(Int64(i), 8);
        }
    }

    public static func appendKanjiBytes(content: UTF32String, bits: BitArray) {
        var bytes: Array<UInt8> = StringUtils.SHIFT_JIS_CHARSET.newEncoder().getBytes(content);

        /*StringUtils.SHIFT_JIS_CHARSET*/
        if (bytes.size % 2 != 0) {
            throw Qrcoder4cjWriterException("Kanji byte size not even");
        }
        var maxI: Int64 = bytes.size - 1

        // bytes.length must be even
        for (i in 0..maxI : 2) {
            var byte1: Int64 = bytes[i].hashCode() & 0xFF
            var byte2: Int64 = bytes[i + 1].hashCode() & 0xFF
            var code: Int64 = (byte1 << 8) | byte2
            var subtracted: Int64 = -1;
            if (code >= 0x8140 && code <= 0x9ffc) {
                subtracted = code - 0x8140
            } else if (code >= 0xe040 && code <= 0xebbf) {
                subtracted = code - 0xc140
            }
            if (subtracted == -1) {
                throw Qrcoder4cjWriterException("Invalid byte sequence");
            }
            var encoded: Int64 = ((subtracted >> 8) * 0xc0) + (subtracted & 0xff)
            bits.appendBits(encoded, 13);
        }
    }

    private static func appendECI(eci: Int64, bits: BitArray) {
        bits.appendBits(Mode.ECI([0, 0, 0], 0x07).getBits(), 4);

        // This is correct for values up to 127, which is all we need now.
        bits.appendBits(eci, 8);
    }
}
