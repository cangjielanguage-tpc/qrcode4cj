/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package datamatrix.encoder

class X12Encoder <: C40Encoder {
    public func getEncodingMode(): Int64 {
        return HighLevelEncoder.X12_ENCODATION;
    }

    public func encode(context: EncoderContext) {
        //step C
        var buffer: ArrayList<Char> = ArrayList<Char>();
        while (context.hasMoreCharacters()) {
            var c: Char = context.getCurrentChar();
            context.pos++

            encodeChar(c, buffer);

            var count: Int64 = buffer.size;
            if ((count % 3) == 0) {
                writeNextTriplet(context, buffer);

                var newMode: Int64 = HighLevelEncoder.lookAheadTest(context.getMessage(), context.pos, getEncodingMode()
                );
                if (newMode != getEncodingMode()) {
                    // Return to ASCII encodation, which will actually handle latch to new mode
                    context.signalEncoderChange(HighLevelEncoder.ASCII_ENCODATION);
                    break
                }
            }
        }
        handleEOD(context, buffer);
    }

    public func encodeChar(c: Char, sb: ArrayList<Char>): Int64 {
        match (c) {
            case '\r' => sb.append('\0');
            case '*' => sb.append(Char(1));
            case '>' => sb.append(Char(2));
            case ' ' => sb.append(Char(3));
            case _ => if (c >= '0' && c <= '9') {
                sb.append(Char(c.hashCode() - 48 + 4));
            } else if (c >= 'A' && c <= 'Z') {
                sb.append(Char(c.hashCode() - 65 + 14));
            } else {
                HighLevelEncoder.illegalCharacter(c);
            }
        }
        return 1;
    }

    public func handleEOD(context: EncoderContext, buffer: ArrayList<Char>) {
        context.updateSymbolInfo();
        var available: Int64 = context.getSymbolInfo().getOrThrow().getDataCapacity() - context.getCodewordCount()
        var count: Int64 = buffer.size;
        context.pos -= count
        if (context.getRemainingCharacters() > 1 || available > 1 || context.getRemainingCharacters() != available) {
            context.writeCodeword(HighLevelEncoder.X12_UNLATCH);
        }
        if (context.getNewEncoding() < 0) {
            context.signalEncoderChange(HighLevelEncoder.ASCII_ENCODATION);
        }
    }
}
