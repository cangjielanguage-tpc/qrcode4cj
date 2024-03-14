/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.datamatrix.encoder

import zxing.code.common.Dimension

/**
 * Symbol info table for DataMatrix.
 *
 * @version $Id$
 */
public open class SymbolInfo {
    public static let PROD_SYMBOLS: Array<SymbolInfo> = [
        SymbolInfo(false, 3, 5, 8, 8, 1),
        SymbolInfo(false, 5, 7, 10, 10, 1),
        /*rect*/ SymbolInfo(true, 5, 7, 16, 6, 1),
        SymbolInfo(false, 8, 10, 12, 12, 1),
        /*rect*/ SymbolInfo(true, 10, 11, 14, 6, 2),
        SymbolInfo(false, 12, 12, 14, 14, 1),
        /*rect*/ SymbolInfo(true, 16, 14, 24, 10, 1),
        SymbolInfo(false, 18, 14, 16, 16, 1),
        SymbolInfo(false, 22, 18, 18, 18, 1),
        /*rect*/ SymbolInfo(true, 22, 18, 16, 10, 2),
        SymbolInfo(false, 30, 20, 20, 20, 1),
        /*rect*/ SymbolInfo(true, 32, 24, 16, 14, 2),
        SymbolInfo(false, 36, 24, 22, 22, 1),
        SymbolInfo(false, 44, 28, 24, 24, 1),
        /*rect*/ SymbolInfo(true, 49, 28, 22, 14, 2),
        SymbolInfo(false, 62, 36, 14, 14, 4),
        SymbolInfo(false, 86, 42, 16, 16, 4),
        SymbolInfo(false, 114, 48, 18, 18, 4),
        SymbolInfo(false, 144, 56, 20, 20, 4),
        SymbolInfo(false, 174, 68, 22, 22, 4),
        SymbolInfo(false, 204, 84, 24, 24, 4, 102, 42),
        SymbolInfo(false, 280, 112, 14, 14, 16, 140, 56),
        SymbolInfo(false, 368, 144, 16, 16, 16, 92, 36),
        SymbolInfo(false, 456, 192, 18, 18, 16, 114, 48),
        SymbolInfo(false, 576, 224, 20, 20, 16, 144, 56),
        SymbolInfo(false, 696, 272, 22, 22, 16, 174, 68),
        SymbolInfo(false, 816, 336, 24, 24, 16, 136, 56),
        SymbolInfo(false, 1050, 408, 18, 18, 36, 175, 68),
        SymbolInfo(false, 1304, 496, 20, 20, 36, 163, 62),
        DataMatrixSymbolInfo144()
    ]

    public static var symbols: Array<SymbolInfo> = PROD_SYMBOLS

    private let rectangular: Bool
    private let dataCapacity: Int64
    private let errorCodewords: Int64
    public let matrixWidth: Int64
    public let matrixHeight: Int64
    private let dataRegions: Int64
    private let rsBlockData: Int64
    private let rsBlockError: Int64

    /**
     * Overrides the symbol info set used by this class. Used for testing purposes.
     *
     * @param override the symbol info set to use
     */
    public static func overrideSymbolSet(ride: Array<SymbolInfo>) {
        symbols = ride
    }

    public init(
        rectangular: Bool,
        dataCapacity: Int64,
        errorCodewords: Int64,
        matrixWidth: Int64,
        matrixHeight: Int64,
        dataRegions: Int64
    ) {
        this(
            rectangular,
            dataCapacity,
            errorCodewords,
            matrixWidth,
            matrixHeight,
            dataRegions,
            dataCapacity,
            errorCodewords
        );
    }

    init(
        rectangular: Bool,
        dataCapacity: Int64,
        errorCodewords: Int64,
        matrixWidth: Int64,
        matrixHeight: Int64,
        dataRegions: Int64,
        rsBlockData: Int64,
        rsBlockError: Int64
    ) {
        this.rectangular = rectangular
        this.dataCapacity = dataCapacity
        this.errorCodewords = errorCodewords
        this.matrixWidth = matrixWidth
        this.matrixHeight = matrixHeight
        this.dataRegions = dataRegions
        this.rsBlockData = rsBlockData
        this.rsBlockError = rsBlockError
    }

    public static func lookup(dataCodewords: Int64): ?SymbolInfo {
        return lookup(dataCodewords, SymbolShapeHint.FORCE_NONE, true);
    }

    public static func lookup(dataCodewords: Int64, shape: SymbolShapeHint): ?SymbolInfo {
        return lookup(dataCodewords, shape, true);
    }

    public static func lookup(dataCodewords: Int64, allowRectangular: Bool, fail: Bool): ?SymbolInfo {
        let shape: SymbolShapeHint
        if (allowRectangular) {
            shape = SymbolShapeHint.FORCE_NONE
        } else {
            shape = SymbolShapeHint.FORCE_SQUARE
        }

        return lookup(dataCodewords, shape, fail);
    }

    private static func lookup(dataCodewords: Int64, shape: SymbolShapeHint, fail: Bool): ?SymbolInfo {
        return lookup(dataCodewords, shape, None, None, fail);
    }

    public static func lookup(
        dataCodewords: Int64,
        shape: SymbolShapeHint,
        minSize: ?Dimension,
        maxSize: ?Dimension,
        fail: Bool
    ): ?SymbolInfo {
        for (i in 0..symbols.size) {
            if (shape == SymbolShapeHint.FORCE_SQUARE && symbols[i].rectangular) {
                continue
            }
            if (shape == SymbolShapeHint.FORCE_RECTANGLE && !symbols[i].rectangular) {
                continue
            }
            var minFlag = false;
            if (let Some(m) <- minSize) {
                minFlag = true
            }

            if (minFlag && (symbols[i].getSymbolWidth() < minSize.getOrThrow().getWidth() ||
                symbols[i].getSymbolHeight() < minSize.getOrThrow().getHeight())) {
                continue
            }

            var maxFlag = false
            if (let Some(m) <- maxSize) {
                maxFlag = true
            }

            if (maxFlag && (symbols[i].getSymbolWidth() > maxSize.getOrThrow().getWidth() ||
                symbols[i].getSymbolHeight() > maxSize.getOrThrow().getHeight())) {
                continue
            }
            if (dataCodewords <= symbols[i].dataCapacity) {
                return symbols[i]
            }
        }
        if (fail) {
            throw IllegalArgumentException(
                "Can't find a symbol arrangement that matches the message. Data codewords: " + dataCodewords.toString());
        }
        return None
    }

    public func getHorizontalDataRegions(): Int64 {
        match (dataRegions) {
            case 1 => return 1;
            case 2 => return 2;
            case 4 => return 2;
            case 16 => return 4;
            case 36 => return 6;
            case _ => throw IllegalArgumentException("Cannot handle this number of data regions");
        }
    }

    public func getVerticalDataRegions(): Int64 {
        match (dataRegions) {
            case 1 => return 1;
            case 2 => return 1;
            case 4 => return 2;
            case 16 => return 4;
            case 36 => return 6;
            case _ => throw IllegalArgumentException("Cannot handle this number of data regions");
        }
    }

    public func getSymbolDataWidth(): Int64 {
        return getHorizontalDataRegions() * matrixWidth
    }

    public func getSymbolDataHeight(): Int64 {
        return getVerticalDataRegions() * matrixHeight
    }

    public func getSymbolWidth(): Int64 {
        return getSymbolDataWidth() + (getHorizontalDataRegions() * 2)
    }

    public func getSymbolHeight(): Int64 {
        return getSymbolDataHeight() + (getVerticalDataRegions() * 2)
    }

    public func getCodewordCount(): Int64 {
        return dataCapacity + errorCodewords
    }

    public open func getInterleavedBlockCount(): Int64 {
        return dataCapacity / rsBlockData
    }

    public func getDataCapacity(): Int64 {
        return dataCapacity
    }

    public func getErrorCodewords(): Int64 {
        return errorCodewords
    }

    public open func getDataLengthForInterleavedBlock(index: Int64): Int64 {
        return rsBlockData
    }

    public func getErrorLengthForInterleavedBlock(index: Int64): Int64 {
        return rsBlockError
    }

    public func toString(): String {
        return (if (rectangular) {
            "Rectangular Symbol:"
        } else {
            "Square Symbol:"
        }) + " data region " + matrixWidth.toString() + "x" + matrixHeight.toString() + ", symbol size " +
            getSymbolWidth().toString() + "x" + getSymbolHeight().toString() + ", symbol data size " +
            getSymbolDataWidth().toString() + "x" + getSymbolDataHeight().toString() + ", codewords " +
            dataCapacity.toString() + "+" + errorCodewords.toString()
    }
}
