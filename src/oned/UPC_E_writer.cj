/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned

/**
 * This object renders an UPC-E code as a BitMatrix.
 */
public open class UPCEWriter <: UPCEANWriter {
    private static let CODE_WIDTH: Int64 = 3 + // start guard
    (7 * 6) + // bars
    6

    // end guard
    protected override func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        var returnData: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        returnData.append(BarcodeFormat.UPC_E)
        return returnData
    }

    public override func encode(contentsin: String): Array<Bool> {
        var contents: UTF32String = UTF32String(contentsin)
        var length: Int64 = contents.charSize;

        match (length) {
            case 7 =>
                // No check digit present, calculate it and add it
                var check: Int64 = 0
                try {
                    check = UPCEANReader.getStandardUPCEANChecksum(UPCEReader.convertUPCEtoUPCA(contents))
                } catch (fe: Qrcoder4cjFormatException) {
                    throw IllegalArgumentException(fe.toString());
                }
                contents += UTF32String(check.toString())
            case 8 => try {
                if (!UPCEANReader.checkStandardUPCEANChecksum(UPCEReader.convertUPCEtoUPCA(contents))) {
                    throw IllegalArgumentException("Contents do not pass checksum");
                }
            } catch (ignored: Qrcoder4cjFormatException) {
                throw IllegalArgumentException("Illegal contents");
            }
            case _ => throw IllegalArgumentException(
                "Requested contents should be 7 or 8 digits long, but got ${length}");
        }

        checkNumeric(contents.toString());

        var firstDigit: Int64 = -1
        if (contents[0].isAsciiNumber()) {
            firstDigit = contents.get(0).hashCode() - 48
        }

        if (firstDigit != 0 && firstDigit != 1) {
            throw IllegalArgumentException("Number system must be 0 or 1");
        }

        var checkDigit: Int64 = -1
        if (contents[7].isAsciiNumber()) {
            checkDigit = contents.get(7).hashCode() - 48
        }

        var parities: Int64 = UPCEReader.NUMSYS_AND_CHECK_DIGIT_PATTERNS[firstDigit][checkDigit]
        var result: Array<Bool> = Array<Bool>(CODE_WIDTH, item: false)

        var pos: Int64 = appendPattern(result, 0, UPCEANReader.START_END_PATTERN, true);
        for (i in 1..7) {
            var digit: Int64 = -1
            if (contents[i].isAsciiNumber()) {
                digit = contents.get(i).hashCode() - 48
            }

            if ((parities >> (6 - i) & 1) == 1) {
                digit += 10
            }
            pos += appendPattern(result, pos, UPCEANReader.L_AND_G_PATTERNS[digit], false)
        }

        appendPattern(result, pos, UPCEANReader.END_PATTERN, false);

        return result
    }
}
