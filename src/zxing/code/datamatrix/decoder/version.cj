/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.datamatrix.decoder

import zxing.code.common.FormatException

public class ECBlocks {
    private let ecCodewords: Int64
    private let ecBlocks: Array<ECB>

    init(ecCodewords: Int64, ecBlocks: Array<ECB>) {
        this.ecCodewords = ecCodewords
        this.ecBlocks = ecBlocks
    }

    private init(ecCodewords: Int64, ecBlocks1: ECB, ecBlocks2: ECB) {
        this.ecCodewords = ecCodewords
        this.ecBlocks = [ecBlocks1, ecBlocks2]
    }

    func getECCodewords(): Int64 {
        return ecCodewords
    }

    func getECBlocks(): Array<ECB> {
        return ecBlocks
    }
}

/**
 * <p>Encapsulates the parameters for one error-correction block in one symbol version.
 * This includes the number of data codewords, and the number of times a block with these
 * parameters is used consecutively in the Data Matrix code version's format.</p>
 */
public class ECB {
    private let count: Int64
    private let dataCodewords: Int64

    init(count: Int64, dataCodewords: Int64) {
        this.count = count
        this.dataCodewords = dataCodewords
    }

    func getCount(): Int64 {
        return count
    }

    func getDataCodewords(): Int64 {
        return dataCodewords
    }
}

/**
 * The Version object encapsulates attributes about a particular
 * size Data Matrix Code.
 */
public class Version {
    private static let VERSIONS: Array<Version> = buildVersions();

    private let versionNumber: Int64
    private let symbolSizeRows: Int64
    private let symbolSizeColumns: Int64
    private let dataRegionSizeRows: Int64
    private let dataRegionSizeColumns: Int64
    private let ecBlocks: ECBlocks
    private let totalCodewords: Int64

    init(
        versionNumber: Int64,
        symbolSizeRows: Int64,
        symbolSizeColumns: Int64,
        dataRegionSizeRows: Int64,
        dataRegionSizeColumns: Int64,
        ecBlocks: ECBlocks
    ) {
        this.versionNumber = versionNumber
        this.symbolSizeRows = symbolSizeRows
        this.symbolSizeColumns = symbolSizeColumns
        this.dataRegionSizeRows = dataRegionSizeRows
        this.dataRegionSizeColumns = dataRegionSizeColumns
        this.ecBlocks = ecBlocks

        // Calculate the total number of codewords
        var total: Int64 = 0;
        var ecCodewords: Int64 = ecBlocks.getECCodewords();
        var ecbArray: Array<ECB> = ecBlocks.getECBlocks();

        for (i in 0..ecbArray.size) {
            total += ecbArray[i].getCount() * (ecbArray[i].getDataCodewords() + ecCodewords)
        }
        this.totalCodewords = total
    }

    public func getVersionNumber(): Int64 {
        return versionNumber
    }

    public func getSymbolSizeRows(): Int64 {
        return symbolSizeRows
    }

    public func getSymbolSizeColumns(): Int64 {
        return symbolSizeColumns
    }

    public func getDataRegionSizeRows(): Int64 {
        return dataRegionSizeRows
    }

    public func getDataRegionSizeColumns(): Int64 {
        return dataRegionSizeColumns
    }

    public func getTotalCodewords(): Int64 {
        return totalCodewords
    }

    func getECBlocks(): ECBlocks {
        return ecBlocks
    }

    /**
     * <p>Deduces version information from Data Matrix dimensions.</p>
     *
     * @param numRows Number of rows in modules
     * @param numColumns Number of columns in modules
     * @return Version for a Data Matrix Code of those dimensions
     * @throws FormatException if dimensions do correspond to a valid Data Matrix size
     */
    public static func getVersionForDimensions(numRows: Int64, numColumns: Int64): Version {
        if ((numRows & 0x01) != 0 || (numColumns & 0x01) != 0) {
            throw FormatException.getFormatInstance();
        }

        for (i in 0..VERSIONS.size) {
            if (VERSIONS[i].symbolSizeRows == numRows && VERSIONS[i].symbolSizeColumns == numColumns) {
                return VERSIONS[i]
            }
        }

        throw FormatException.getFormatInstance();
    }

    /**
     * <p>Encapsulates a set of error-correction blocks in one symbol version. Most versions will
     * use blocks of differing sizes within one version, so, this encapsulates the parameters for
     * each set of blocks. It also holds the number of error-correction codewords per block since it
     * will be the same across all blocks within one version.</p>
     */
    public func toString(): String {
        return versionNumber.toString();
    }

    /**
     * See ISO 16022:2006 5.5.1 Table 7
     */
    private static func buildVersions(): Array<Version> {
        return [
            Version(
                1,
                10,
                10,
                8,
                8,
                ECBlocks(5, [ECB(1, 3)])
            ),
            Version(
                2,
                12,
                12,
                10,
                10,
                ECBlocks(7, [ECB(1, 5)])
            ),
            Version(
                3,
                14,
                14,
                12,
                12,
                ECBlocks(10, [ECB(1, 8)])
            ),
            Version(
                4,
                16,
                16,
                14,
                14,
                ECBlocks(12, [ECB(1, 12)])
            ),
            Version(
                5,
                18,
                18,
                16,
                16,
                ECBlocks(14, [ECB(1, 18)])
            ),
            Version(
                6,
                20,
                20,
                18,
                18,
                ECBlocks(18, [ECB(1, 22)])
            ),
            Version(
                7,
                22,
                22,
                20,
                20,
                ECBlocks(20, [ECB(1, 30)])
            ),
            Version(
                8,
                24,
                24,
                22,
                22,
                ECBlocks(24, [ECB(1, 36)])
            ),
            Version(
                9,
                26,
                26,
                24,
                24,
                ECBlocks(28, [ECB(1, 44)])
            ),
            Version(
                10,
                32,
                32,
                14,
                14,
                ECBlocks(36, [ECB(1, 62)])
            ),
            Version(
                11,
                36,
                36,
                16,
                16,
                ECBlocks(42, [ECB(1, 86)])
            ),
            Version(
                12,
                40,
                40,
                18,
                18,
                ECBlocks(48, [ECB(1, 114)])
            ),
            Version(
                13,
                44,
                44,
                20,
                20,
                ECBlocks(56, [ECB(1, 144)])
            ),
            Version(
                14,
                48,
                48,
                22,
                22,
                ECBlocks(68, [ECB(1, 174)])
            ),
            Version(
                15,
                52,
                52,
                24,
                24,
                ECBlocks(42, [ECB(2, 102)])
            ),
            Version(
                16,
                64,
                64,
                14,
                14,
                ECBlocks(56, [ECB(2, 140)])
            ),
            Version(
                17,
                72,
                72,
                16,
                16,
                ECBlocks(36, [ECB(4, 92)])
            ),
            Version(
                18,
                80,
                80,
                18,
                18,
                ECBlocks(48, [ECB(4, 114)])
            ),
            Version(
                19,
                88,
                88,
                20,
                20,
                ECBlocks(56, [ECB(4, 144)])
            ),
            Version(
                20,
                96,
                96,
                22,
                22,
                ECBlocks(68, [ECB(4, 174)])
            ),
            Version(
                21,
                104,
                104,
                24,
                24,
                ECBlocks(56, [ECB(6, 136)])
            ),
            Version(
                22,
                120,
                120,
                18,
                18,
                ECBlocks(68, [ECB(6, 175)])
            ),
            Version(
                23,
                132,
                132,
                20,
                20,
                ECBlocks(62, [ECB(8, 163)])
            ),
            Version(
                24,
                144,
                144,
                22,
                22,
                ECBlocks(62, [ECB(8, 156), ECB(2, 155)])
            ),
            Version(
                25,
                8,
                18,
                6,
                16,
                ECBlocks(7, [ECB(1, 5)])
            ),
            Version(
                26,
                8,
                32,
                6,
                14,
                ECBlocks(11, [ECB(1, 10)])
            ),
            Version(
                27,
                12,
                26,
                10,
                24,
                ECBlocks(14, [ECB(1, 16)])
            ),
            Version(
                28,
                12,
                36,
                10,
                16,
                ECBlocks(18, [ECB(1, 22)])
            ),
            Version(
                29,
                16,
                36,
                14,
                16,
                ECBlocks(24, [ECB(1, 32)])
            ),
            Version(
                30,
                16,
                48,
                14,
                22,
                ECBlocks(28, [ECB(1, 49)])
            ),
            // extended forms as specified in
            // ISO 21471:2020 (DMRE) 5.5.1 Table 7
            Version(
                31,
                8,
                48,
                6,
                22,
                ECBlocks(15, [ECB(1, 18)])
            ),
            Version(
                32,
                8,
                64,
                6,
                14,
                ECBlocks(18, [ECB(1, 24)])
            ),
            Version(
                33,
                8,
                80,
                6,
                18,
                ECBlocks(22, [ECB(1, 32)])
            ),
            Version(
                34,
                8,
                96,
                6,
                22,
                ECBlocks(28, [ECB(1, 38)])
            ),
            Version(
                35,
                8,
                120,
                6,
                18,
                ECBlocks(32, [ECB(1, 49)])
            ),
            Version(
                36,
                8,
                144,
                6,
                22,
                ECBlocks(36, [ECB(1, 63)])
            ),
            Version(
                37,
                12,
                64,
                10,
                14,
                ECBlocks(27, [ECB(1, 43)])
            ),
            Version(
                38,
                12,
                88,
                10,
                20,
                ECBlocks(36, [ECB(1, 64)])
            ),
            Version(
                39,
                16,
                64,
                14,
                14,
                ECBlocks(36, [ECB(1, 62)])
            ),
            Version(
                40,
                20,
                36,
                18,
                16,
                ECBlocks(28, [ECB(1, 44)])
            ),
            Version(
                41,
                20,
                44,
                18,
                20,
                ECBlocks(34, [ECB(1, 56)])
            ),
            Version(
                42,
                20,
                64,
                18,
                14,
                ECBlocks(42, [ECB(1, 84)])
            ),
            Version(
                43,
                22,
                48,
                20,
                22,
                ECBlocks(38, [ECB(1, 72)])
            ),
            Version(
                44,
                24,
                48,
                22,
                22,
                ECBlocks(41, [ECB(1, 80)])
            ),
            Version(
                45,
                24,
                64,
                22,
                14,
                ECBlocks(46, [ECB(1, 108)])
            ),
            Version(
                46,
                26,
                40,
                24,
                18,
                ECBlocks(38, [ECB(1, 70)])
            ),
            Version(
                47,
                26,
                48,
                24,
                22,
                ECBlocks(42, [ECB(1, 90)])
            ),
            Version(
                48,
                26,
                64,
                24,
                14,
                ECBlocks(50, [ECB(1, 118)])
            )
        ]
    }
}
