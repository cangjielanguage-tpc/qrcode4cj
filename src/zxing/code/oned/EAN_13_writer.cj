/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * This object renders an EAN13 code as a BitMatrix.
 */
public open class EAN13Writer <: UPCEANWriter {
    private static let CODE_WIDTH: Int64 = 3 + // start guard
        (7 * 6) + // left bars
        5 + // middle guard
        (7 * 6) + // right bars
        3

    // end guard
    protected func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        var returnData: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        returnData.append(BarcodeFormat.EAN_13)
        return returnData
    }

    public func encode(contentsin: String): Array<Bool> {
        var contentsinutf32 = UTF32String(contentsin)
        var length: Int64 = contentsinutf32.charSize
        match (length) {
            case 12 =>
                // No check digit present, calculate it and add it
                var check: Int64
                try {
                    check = UPCEANReader.getStandardUPCEANChecksum(contentsinutf32)
                } catch (fe: FormatException) {
                    throw IllegalArgumentException(fe.toString());
                }
                contentsinutf32 += UTF32String(check.toString())

            case 13 => try {
                if (!UPCEANReader.checkStandardUPCEANChecksum(contentsinutf32)) {
                    throw IllegalArgumentException("Contents do not pass checksum");
                }
            } catch (ignored: FormatException) {
                throw IllegalArgumentException("Illegal contents");
            }

            case _ => throw IllegalArgumentException(
                "Requested contents should be 12 or 13 digits long, but got ${length}");
        }

        checkNumeric(contentsinutf32.toString());

        var firstDigit: Int64 = -1
        if (contentsinutf32[0].isAsciiNumber()) {
            firstDigit = contentsinutf32.get(0).hashCode() - 48
        }

        var parities: Int64 = EAN13Reader.FIRST_DIGIT_ENCODINGS[firstDigit]
        var result: Array<Bool> = Array<Bool>(CODE_WIDTH, item: false)
        var pos: Int64 = 0;

        pos += appendPattern(result, pos, UPCEANReader.START_END_PATTERN, true)
        for (i in 1..7) {
            var digit: Int64 = -1
            if (contentsinutf32[i].isAsciiNumber()) {
                digit = contentsinutf32.get(i).hashCode() - 48
            }

            if ((parities >> (6 - i) & 1) == 1) {
                digit += 10
            }
            pos += appendPattern(result, pos, UPCEANReader.L_AND_G_PATTERNS[digit], false)
        }

        pos += appendPattern(result, pos, UPCEANReader.MIDDLE_PATTERN, false)

        pos = getPos(pos, result, contentsinutf32)

        appendPattern(result, pos, UPCEANReader.START_END_PATTERN, true);

        return result
    }

    private static func getPos(pos: Int64, result: Array<Bool>, contentsinutf32: UTF32String): Int64 {
        var pos_p = pos
        for (i in 7..13) {
            var digit: Int64 = -1
            if (contentsinutf32[i].isAsciiNumber()) {
                digit = contentsinutf32.get(i).hashCode() - 48
            }
            pos_p += appendPattern(result, pos_p, UPCEANReader.L_PATTERNS[digit], true)
        }
        return pos_p
    }
}
