/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package qrcode.decoder

from std import collection.*

public class BitMatrixParser {
    public var bitMatrix: BitMatrix
    public var parsedVersion: ?Version = None
    public var parsedFormatInfo: ?FormatInformation = None
    public var mirror: Bool = false;

    /**
     * @param bitMatrix BitMatrix to parse
     * @throws Qrcoder4cjFormatException if dimension is not >= 21 and 1 mod 4
     */
    public init(bitMatrix: BitMatrix) {
        let dimension: Int64 = bitMatrix.getHeight();
        if (dimension < 21 || (dimension & 0x03) != 1) {
            throw Qrcoder4cjFormatException.getFormatInstance();
        }
        this.bitMatrix = bitMatrix
    }

    /**
     * Reads format information from one of its two locations within the QR Code.
     *
     * @return FormatInformation encapsulating the QR Code's format info
     * @throws Qrcoder4cjFormatException if both format information locations cannot be parsed as
     * the valid encoding of format information
     */
    public func readFormatInformation(): FormatInformation {
        if (let Some(parse) <- parsedFormatInfo) {
            return parse
        }

        // Read top-left format info bits
        var formatInfoBits1: Int64 = 0;
        for (i in 0..6) {
            formatInfoBits1 = copyBit(i, 8, formatInfoBits1)
        }

        /* .. and skip a bit in the timing pattern ... */ 
        formatInfoBits1 = copyBit(7, 8, formatInfoBits1)
        formatInfoBits1 = copyBit(8, 8, formatInfoBits1)
        formatInfoBits1 = copyBit(8, 7, formatInfoBits1)

        /* .. and skip a bit in the timing pattern ... */ 
        for (j in 5..=0 : -1) {
            formatInfoBits1 = copyBit(8, j, formatInfoBits1)
        }

        // Read the top-right/bottom-left pattern too
        let dimension: Int64 = bitMatrix.getHeight();
        var formatInfoBits2: Int64 = 0;

        var jMin: Int64 = dimension - 7
        for (j in dimension - 1..=jMin : -1) {
            formatInfoBits2 = copyBit(8, j, formatInfoBits2)
        }

        let dimensionStart: Int64 = dimension - 8
        for (i in dimensionStart..dimension) {
            formatInfoBits2 = copyBit(i, 8, formatInfoBits2)
        }

        parsedFormatInfo = FormatInformation.decodeFormatInformation(formatInfoBits1, formatInfoBits2)

        if (let Some(parse) <- parsedFormatInfo) {
            return parse
        }

        throw Qrcoder4cjFormatException.getFormatInstance();
    }

    /**
     * Reads version information from one of its two locations within the QR Code.
     *
     * @return Version encapsulating the QR Code's version
     * @throws Qrcoder4cjFormatException if both version information locations cannot be parsed as
     * the valid encoding of version information
     */
    public func readVersion(): Version {
        let dimension: Int64 = bitMatrix.getHeight();

        let provisionalVersion: Int64 = (dimension - 17) / 4
        if (provisionalVersion <= 6) {
            return Version.getVersionForNumber(provisionalVersion);
        }

        // Read top-right version info: 3 wide by 6 tall
        var versionBits: Int64 = 0;
        let ijMin: Int64 = dimension - 11
        for (j in 5..=0 : -1) {
            for (i in dimension - 9..=ijMin : -1) {
                versionBits = copyBit(i, j, versionBits)
            }
        }

        var theParsedVersion: ?Version = Version.decodeVersionInformation(versionBits);
        if (let Some(t) <- theParsedVersion) {
            if (t.getDimensionForVersion() == dimension) {
                parsedVersion = t

                return t
            }
        }

        // Hmm, failed. Try bottom left: 6 wide by 3 tall
        versionBits = 0
        for (i in 5..=0 : -1) {
            for (j in dimension - 9..=ijMin : -1) {
                versionBits = copyBit(i, j, versionBits)
            }
        }

        theParsedVersion = Version.decodeVersionInformation(versionBits)
        if (let Some(t) <- theParsedVersion) {
            if (t.getDimensionForVersion() == dimension) {
                parsedVersion = t

                return t
            }
        }
        throw Qrcoder4cjFormatException.getFormatInstance();
    }

    public func copyBit(i: Int64, j: Int64, versionBits: Int64): Int64 {
        var bit: Bool = if (mirror) {
            bitMatrix.get(j, i)
        } else {
            bitMatrix.get(i, j)
        }
        return if (bit) {
            (versionBits << 1) | 0x1
        } else {
            versionBits << 1
        }
    }

    /**
     * Reads the bits in the {@link BitMatrix} representing the finder pattern in the
     * correct order in order to reconstruct the codewords bytes contained within the
     * QR Code.
     *
     * @return bytes encoded within the QR Code
     * @throws Qrcoder4cjFormatException if the exact number of bytes expected is not read
     */
    public func readCodewords(): Array<UInt8> {
        let formatInfo: FormatInformation = readFormatInformation();
        let version: Version = readVersion();

        // Get the data mask for the format used in this QR Code. This will exclude
        // some bits from reading as we wind through the bit matrix.
        let dataMask: DataMask = DataMask.values()[Int64(formatInfo.getDataMask())]
        let dimension: Int64 = bitMatrix.getHeight();
        dataMask.unmaskBitMatrix(bitMatrix, dimension);

        let functionPattern: BitMatrix = version.buildFunctionPattern();

        var readingUp: Bool = true;
        var result: Array<UInt8> = Array<UInt8>(version.getTotalCodewords(), item: 0);
        var resultOffset: Int64 = 0;
        var currentByte: Int64 = 0;
        var bitsRead: Int64 = 0;

        // Read columns in pairs, from right to left
        var j: Int64 = dimension - 1
        while (j > 0) {
            if (j == 6) {
                // Skip whole column with vertical alignment pattern;
                // saves time and makes the other code proceed more cleanly
                j--
            }

            // Read alternatingly from bottom to top then top to bottom
            for (count in 0..dimension) {
                let i: Int64 = if (readingUp) {
                    dimension - 1 - count
                } else {
                    count
                }
                for (col in 0..2) {
                    /* Ignore bits covered by the function pattern */ 
                    if (!functionPattern.get(j - col, i)) {
                        /* Read a bit */
                        bitsRead++
                        currentByte <<= 1
                        if (bitMatrix.get(j - col, i)) {
                            currentByte |= 1
                        }

                        /* If we've made a whole byte, save it off */
                        if (bitsRead == 8) {
                            result[resultOffset] = UInt8(currentByte)

                            resultOffset++
                            bitsRead = 0
                            currentByte = 0
                        }
                    }
                }
            }
            readingUp = !readingUp

            // readingUp = !readingUp; // switch directions
            j = j - 2
        }

        if (resultOffset != version.getTotalCodewords()) {
            throw Qrcoder4cjFormatException.getFormatInstance();
        }

        return result
    }

    /**
     * Revert the mask removal done while reading the code words. The bit matrix should revert to its original state.
     */
    public func remask() {
        if (let Some(p) <- parsedFormatInfo) {
            let dataMask: DataMask = DataMask.values()[Int64(p.getDataMask())]
            let dimension: Int64 = bitMatrix.getHeight();
            dataMask.unmaskBitMatrix(bitMatrix, dimension);
        }
        return; // We have no format information, and have no data mask
    }

    /**
     * Prepare the parser for a mirrored operation.
     * This flag has effect only on the readFormatInformation() and the
     * readVersion(). Before proceeding with readCodewords() the
     * mirror() method should be called.
     *
     * @param mirror Whether to read version and format information mirrored.
     */
    public func setMirror(mirror: Bool) {
        parsedVersion = None
        parsedFormatInfo = None
        this.mirror = mirror
    }

    /** Mirror the bit matrix in order to attempt a second reading. */
    public func Mirror() {
        let width: Int64 = bitMatrix.getWidth();
        let heigth: Int64 = bitMatrix.getHeight();
        for (x in 0..width) {
            let start: Int64 = x + 1
            for (y in start..heigth) {
                if (bitMatrix.get(x, y) != bitMatrix.get(y, x)) {
                    bitMatrix.flip(y, x);
                    bitMatrix.flip(x, y);
                }
            }
        }
    }
}
