/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package zxing.code.datamatrix.decoder

import zxing.code.common.BitMatrix

/**
 * @author bbrown@google.com (Brian Brown)
 */
class BitMatrixParser {
    private var mappingBitMatrix: BitMatrix
    private var readMappingMatrix: BitMatrix
    private var version: Version

    /**
     * @param bitMatrix {@link BitMatrix} to parse
     * @throws FormatException if dimension is < 8 or > 144 or not 0 mod 2
     */
    init(bitMatrix: BitMatrix) {
        var dimension: Int64 = bitMatrix.getHeight();
        if (dimension < 8 || dimension > 144 || (dimension & 0x01) != 0) {
            throw FormatException.getFormatInstance();
        }

        version = readVersion(bitMatrix)
        this.mappingBitMatrix = BitMatrix()

        this.readMappingMatrix = BitMatrix()
        this.mappingBitMatrix = extractDataRegion(bitMatrix)
        this.readMappingMatrix = BitMatrix(this.mappingBitMatrix.getWidth(), this.mappingBitMatrix.getHeight())
    }

    func getVersion(): Version {
        return version
    }

    /**
     * <p>Creates the version object based on the dimension of the original bit matrix from
     * the datamatrix code.</p>
     *
     * <p>See ISO 16022:2006 Table 7 - ECC 200 symbol attributes</p>
     *
     * @param bitMatrix Original {@link BitMatrix} including alignment patterns
     * @return {@link Version} encapsulating the Data Matrix Code's "version"
     * @throws FormatException if the dimensions of the mapping matrix are not valid
     * Data Matrix dimensions.
     */
    private static func readVersion(bitMatrix: BitMatrix): Version {
        var numRows: Int64 = bitMatrix.getHeight();
        var numColumns: Int64 = bitMatrix.getWidth();
        return Version.getVersionForDimensions(numRows, numColumns);
    }

    /**
     * <p>Reads the bits in the {@link BitMatrix} representing the mapping matrix (No alignment patterns)
     * in the correct order in order to reconstitute the codewords bytes contained within the
     * Data Matrix Code.</p>
     *
     * @return bytes encoded within the Data Matrix Code
     * @throws FormatException if the exact number of bytes expected is not read
     */
    func readCodewords(): Array<UInt8> {
        var result = Array<Byte>(version.getTotalCodewords(), item: 0)
        var resultOffset: Int64 = 0;

        var row: Int64 = 4;
        var column: Int64 = 0;

        var numRows: Int64 = mappingBitMatrix.getHeight();
        var numColumns: Int64 = mappingBitMatrix.getWidth();

        var corner1Read: Bool = false;
        var corner2Read: Bool = false;
        var corner3Read: Bool = false;
        var corner4Read: Bool = false;

        // Read all of the codewords
        do {
            // Check the four corner cases
            if ((row == numRows) && (column == 0) && !corner1Read) {
                result[resultOffset] = UInt8(readCorner1(numRows, numColumns))
                resultOffset++
                row -= 2
                column += 2
                corner1Read = true
            } else if ((row == numRows - 2) && (column == 0) && ((numColumns & 0x03) != 0) && !corner2Read) {
                result[resultOffset] = UInt8(readCorner2(numRows, numColumns))
                resultOffset++
                row -= 2
                column += 2
                corner2Read = true
            } else if ((row == numRows + 4) && (column == 2) && ((numColumns & 0x07) == 0) && !corner3Read) {
                result[resultOffset] = UInt8(readCorner3(numRows, numColumns))
                resultOffset++
                row -= 2
                column += 2
                corner3Read = true
            } else if ((row == numRows - 2) && (column == 0) && ((numColumns & 0x07) == 4) && !corner4Read) {
                result[resultOffset] = UInt8(readCorner4(numRows, numColumns))
                resultOffset++
                row -= 2
                column += 2
                corner4Read = true
            } else {
                // Sweep upward diagonally to the right
                do {
                    if ((row < numRows) && (column >= 0) && !readMappingMatrix.get(column, row)) {
                        result[resultOffset] = UInt8(readUtah(row, column, numRows, numColumns))
                        resultOffset++
                    }
                    row -= 2
                    column += 2
                } while ((row >= 0) && (column < numColumns))
                row += 1
                column += 3

                // Sweep downward diagonally to the left
                do {
                    if ((row >= 0) && (column < numColumns) && !readMappingMatrix.get(column, row)) {
                        result[resultOffset] = UInt8(readUtah(row, column, numRows, numColumns))
                        resultOffset++
                    }
                    row += 2
                    column -= 2
                } while ((row < numRows) && (column >= 0))
                row += 3
                column += 1
            }
        } while ((row < numRows) || (column < numColumns))

        if (resultOffset != version.getTotalCodewords()) {
            throw FormatException.getFormatInstance();
        }

        return result
    }

    /**
     * <p>Reads a bit of the mapping matrix accounting for boundary wrapping.</p>
     *
     * @param row Row to read in the mapping matrix
     * @param column Column to read in the mapping matrix
     * @param numRows Number of rows in the mapping matrix
     * @param numColumns Number of columns in the mapping matrix
     * @return value of the given bit in the mapping matrix
     */
    private func readModule(row: Int64, column: Int64, numRows: Int64, numColumns: Int64): Bool {
        // Adjust the row and column indices based on boundary wrapping
        var row2 = row
        var column2 = column
        if (row2 < 0) {
            row2 += numRows
            column2 += 4 - ((numRows + 4) & 0x07)
        }
        if (column2 < 0) {
            column2 += numColumns
            row2 += 4 - ((numColumns + 4) & 0x07)
        }
        if (row2 >= numRows) {
            row2 -= numRows
        }
        readMappingMatrix.set(column2, row2);
        return mappingBitMatrix.get(column2, row2);
    }

    /**
     * <p>Reads the 8 bits of the standard Utah-shaped pattern.</p>
     *
     * <p>See ISO 16022:2006, 5.8.1 Figure 6</p>
     *
     * @param row Current row in the mapping matrix, anchored at the 8th bit (LSB) of the pattern
     * @param column Current column in the mapping matrix, anchored at the 8th bit (LSB) of the pattern
     * @param numRows Number of rows in the mapping matrix
     * @param numColumns Number of columns in the mapping matrix
     * @return byte from the utah shape
     */
    private func readUtah(row: Int64, column: Int64, numRows: Int64, numColumns: Int64): Int64 {
        var currentByte: Int64 = 0;
        if (readModule(row - 2, column - 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(row - 2, column - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(row - 1, column - 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(row - 1, column - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(row - 1, column, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(row, column - 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(row, column - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(row, column, numRows, numColumns)) {
            currentByte |= 1
        }

        return currentByte
    }

    /**
     * <p>Reads the 8 bits of the special corner condition 1.</p>
     *
     * <p>See ISO 16022:2006, Figure F.3</p>
     *
     * @param numRows Number of rows in the mapping matrix
     * @param numColumns Number of columns in the mapping matrix
     * @return byte from the Corner condition 1
     */
    private func readCorner1(numRows: Int64, numColumns: Int64): Int64 {
        var currentByte: Int64 = 0;
        if (readModule(numRows - 1, 0, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(numRows - 1, 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(numRows - 1, 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(1, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(2, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(3, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }

        return currentByte
    }

    /**
     * <p>Reads the 8 bits of the special corner condition 2.</p>
     *
     * <p>See ISO 16022:2006, Figure F.4</p>
     *
     * @param numRows Number of rows in the mapping matrix
     * @param numColumns Number of columns in the mapping matrix
     * @return byte from the Corner condition 2
     */
    private func readCorner2(numRows: Int64, numColumns: Int64): Int64 {
        var currentByte: Int64 = 0;
        if (readModule(numRows - 3, 0, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(numRows - 2, 0, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(numRows - 1, 0, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 4, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 3, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(1, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }

        return currentByte
    }

    /**
     * <p>Reads the 8 bits of the special corner condition 3.</p>
     *
     * <p>See ISO 16022:2006, Figure F.5</p>
     *
     * @param numRows Number of rows in the mapping matrix
     * @param numColumns Number of columns in the mapping matrix
     * @return byte from the Corner condition 3
     */
    private func readCorner3(numRows: Int64, numColumns: Int64): Int64 {
        var currentByte: Int64 = 0;
        if (readModule(numRows - 1, 0, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(numRows - 1, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 3, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(1, numColumns - 3, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(1, numColumns - 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(1, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }

        return currentByte
    }

    /**
     * <p>Reads the 8 bits of the special corner condition 4.</p>
     *
     * <p>See ISO 16022:2006, Figure F.6</p>
     *
     * @param numRows Number of rows in the mapping matrix
     * @param numColumns Number of columns in the mapping matrix
     * @return byte from the Corner condition 4
     */
    private func readCorner4(numRows: Int64, numColumns: Int64): Int64 {
        var currentByte: Int64 = 0;
        if (readModule(numRows - 3, 0, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(numRows - 2, 0, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(numRows - 1, 0, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 2, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(0, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(1, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(2, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }
        currentByte <<= 1
        if (readModule(3, numColumns - 1, numRows, numColumns)) {
            currentByte |= 1
        }

        return currentByte
    }

    /**
     * <p>Extracts the data region from a {@link BitMatrix} that contains
     * alignment patterns.</p>
     *
     * @param bitMatrix Original {@link BitMatrix} with alignment patterns
     * @return BitMatrix that has the alignment patterns removed
     */
    private func extractDataRegion(bitMatrix: BitMatrix): BitMatrix {
        var symbolSizeRows: Int64 = version.getSymbolSizeRows();
        var symbolSizeColumns: Int64 = version.getSymbolSizeColumns();

        if (bitMatrix.getHeight() != symbolSizeRows) {
            throw IllegalArgumentException("Dimension of bitMatrix must match the version size");
        }

        var dataRegionSizeRows: Int64 = version.getDataRegionSizeRows();
        var dataRegionSizeColumns: Int64 = version.getDataRegionSizeColumns();

        let numDataRegionsRow = symbolSizeRows / dataRegionSizeRows
        let numDataRegionsColumn = symbolSizeColumns / dataRegionSizeColumns

        var sizeDataRegionRow: Int64 = numDataRegionsRow * dataRegionSizeRows
        var sizeDataRegionColumn: Int64 = numDataRegionsColumn * dataRegionSizeColumns

        var bitMatrixWithoutAlignment: BitMatrix = BitMatrix(sizeDataRegionColumn, sizeDataRegionRow);

        for (dataRegionRow in 0..numDataRegionsRow) {
            var dataRegionRowOffset: Int64 = dataRegionRow * dataRegionSizeRows

            for (dataRegionColumn in 0..numDataRegionsColumn) {
                var dataRegionColumnOffset: Int64 = dataRegionColumn * dataRegionSizeColumns

                for (i in 0..dataRegionSizeRows) {
                    let readRowOffset: Int64 = dataRegionRow * (dataRegionSizeRows + 2) + 1 + i
                    let writeRowOffset: Int64 = dataRegionRowOffset + i

                    for (j in 0..dataRegionSizeColumns) {
                        let readColumnOffset: Int64 = dataRegionColumn * (dataRegionSizeColumns + 2) + 1 + j
                        if (bitMatrix.get(readColumnOffset, readRowOffset)) {
                            let writeColumnOffset: Int64 = dataRegionColumnOffset + j
                            bitMatrixWithoutAlignment.set(writeColumnOffset, writeRowOffset);
                        }
                    }
                }
            }
        }

        return bitMatrixWithoutAlignment
    }
}
