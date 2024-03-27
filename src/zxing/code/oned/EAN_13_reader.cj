/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

/**
 * Implements decoding of the EAN-13 format.
 */
public open class EAN13Reader <: UPCEANReader {
    // For an EAN-13 barcode, the first digit is represented by the parities used
    // to encode the next six digits, according to the table below. For example,
    // if the barcode is 5 123456 789012 then the value of the first digit is
    // signified by using odd for '1', even for '2', even for '3', odd for '4',
    // odd for '5', and even for '6'.
    //
    //                Parity of next 6 digits
    //    Digit   0     1     2     3     4     5
    //       0    Odd   Odd   Odd   Odd   Odd   Odd
    //       1    Odd   Odd   Even  Odd   Even  Even
    //       2    Odd   Odd   Even  Even  Odd   Even
    //       3    Odd   Odd   Even  Even  Even  Odd
    //       4    Odd   Even  Odd   Odd   Even  Even
    //       5    Odd   Even  Even  Odd   Odd   Even
    //       6    Odd   Even  Even  Even  Odd   Odd
    //       7    Odd   Even  Odd   Even  Odd   Even
    //       8    Odd   Even  Odd   Even  Even  Odd
    //       9    Odd   Even  Even  Odd   Even  Odd
    //
    // Note that the encoding for '0' uses the same parity as a UPC barcode. Hence
    // a UPC barcode can be converted to an EAN-13 barcode by prepending a 0.
    //
    // The encoding is represented by the following array, which is a bit pattern
    // using Odd = 0 and Even = 1. For example, 5 is represented by:
    //
    //              Odd Even Even Odd Odd Even
    // in binary:
    //                0    1    1   0   0    1   == 0x19
    //
    static let FIRST_DIGIT_ENCODINGS: Array<Int64> = [0x00, 0x0B, 0x0D, 0xE, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A]

    private let decodeMiddleCounters: Array<Int64>

    public init() {
        decodeMiddleCounters = Array<Int64>(4, item: 0)
    }

    protected override func decodeMiddle(row: BitArray, startRange: Array<Int64>, resultString: ArrayList<Char>): Int64 {
        var counters: Array<Int64> = decodeMiddleCounters
        counters[0] = 0
        counters[1] = 0
        counters[2] = 0
        counters[3] = 0
        var end: Int64 = row.getSize();
        var rowOffset: Int64 = startRange[1]

        var lgPatternFound: Int64 = 0;

        var x = 0;
        while (x < 6 && rowOffset < end) {
            var bestMatch: Int64 = decodeDigit(row, counters, rowOffset, L_AND_G_PATTERNS);
            resultString.append(Char('0'.hashCode() + bestMatch % 10));

            for (i in 0..counters.size) {
                rowOffset += counters[i]
            }
            if (bestMatch >= 10) {
                lgPatternFound |= 1 << (5 - x)
            }
            x++;
        }

        determineFirstDigit(resultString, lgPatternFound);

        var middleRange: Array<Int64> = findGuardPattern(row, rowOffset, true, MIDDLE_PATTERN);
        rowOffset = middleRange[1]

        x = 0
        while (x < 6 && rowOffset < end) {
            var bestMatch: Int64 = decodeDigit(row, counters, rowOffset, L_PATTERNS);
            resultString.append(Char('0'.hashCode() + bestMatch));

            for (i in 0..counters.size) {
                rowOffset += counters[i]
            }
            x++;
        }

        return rowOffset
    }

    public override func getBarcodeFormat(): BarcodeFormat {
        return BarcodeFormat.EAN_13;
    }

    /**
     * Based on pattern of odd-even ('L' and 'G') patterns used to encoded the explicitly-encoded
     * digits in a barcode, determines the implicitly encoded first digit and adds it to the
     * result string.
     *
     * @param resultString string to insert decoded first digit into
     * @param lgPatternFound int whose bits indicates the pattern of odd/even L/G patterns used to
     * encode digits
     * @throws NotFoundException if first digit cannot be determined
     */
    private static func determineFirstDigit(resultString: ArrayList<Char>, lgPatternFound: Int64) {
        for (d in 0..10) {
            if (lgPatternFound == FIRST_DIGIT_ENCODINGS[d]) {
                resultString.insert(0, Char('0'.hashCode() + d));
                return;
            }
        }
        throw NotFoundException.getNotFoundInstance();
    }
}
