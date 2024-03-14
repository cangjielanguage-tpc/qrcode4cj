/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.datamatrix.encoder

public class ASCIIEncoder <: Encoder {
    public func getEncodingMode(): Int64 {
        return HighLevelEncoder.ASCII_ENCODATION;
    }

    public func encode(context: EncoderContext) {
        //step B
        var n: Int64 = HighLevelEncoder.determineConsecutiveDigitCount(context.getMessage(), context.pos);
        if (n >= 2) {
            context.writeCodeword(
                encodeASCIIDigits(
                    context.getMessage()[context.pos],
                    context.getMessage()[context.pos + 1]
                )
            );
            context.pos += 2
        } else {
            var c: Char = context.getCurrentChar();
            var newMode: Int64 = HighLevelEncoder.lookAheadTest(context.getMessage(), context.pos, getEncodingMode());
            if (newMode != getEncodingMode()) {
                if (newMode == HighLevelEncoder.BASE256_ENCODATION) {
                    context.writeCodeword(HighLevelEncoder.LATCH_TO_BASE256);
                    context.signalEncoderChange(HighLevelEncoder.BASE256_ENCODATION);
                    return;
                } else if (newMode == HighLevelEncoder.C40_ENCODATION) {
                    context.writeCodeword(HighLevelEncoder.LATCH_TO_C40);
                    context.signalEncoderChange(HighLevelEncoder.C40_ENCODATION);
                    return;
                } else if (newMode == HighLevelEncoder.X12_ENCODATION) {
                    context.writeCodeword(HighLevelEncoder.LATCH_TO_ANSIX12);
                    context.signalEncoderChange(HighLevelEncoder.X12_ENCODATION);
                } else if (newMode == HighLevelEncoder.TEXT_ENCODATION) {
                    context.writeCodeword(HighLevelEncoder.LATCH_TO_TEXT);
                    context.signalEncoderChange(HighLevelEncoder.TEXT_ENCODATION);
                } else if (newMode == HighLevelEncoder.EDIFACT_ENCODATION) {
                    context.writeCodeword(HighLevelEncoder.LATCH_TO_EDIFACT);
                    context.signalEncoderChange(HighLevelEncoder.EDIFACT_ENCODATION);
                } else {
                    throw IllegalArgumentException("Illegal mode: " + newMode.toString());
                }
            } else if (HighLevelEncoder.isExtendedASCII(c)) {
                context.writeCodeword(HighLevelEncoder.UPPER_SHIFT);
                context.writeCodeword(Char(c.hashCode() - 128 + 1));
                context.pos++
            } else {
                context.writeCodeword(Char(c.hashCode() + 1));
                context.pos++
            }
        }
    }

    private static func encodeASCIIDigits(digit1: Char, digit2: Char): Char {
        let digit3: UInt32 = UInt32(digit2)
        if (HighLevelEncoder.isDigit(digit1) && HighLevelEncoder.isDigit(digit2)) {
            let num = (UInt32(digit1) - 48) * 10 + (digit3 - 48)
            return Char(num + 130)
        }
        throw IllegalArgumentException("not digits: " + digit1.toString() + digit2.toString());
    }
}
