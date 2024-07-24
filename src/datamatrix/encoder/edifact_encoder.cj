/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.datamatrix.encoder

import QRCode4cj.tools.*
import std.collection.*

class EdifactEncoder <: Encoder {
    public func getEncodingMode(): Int64 {
        return HighLevelEncoder.EDIFACT_ENCODATION;
    }

    public func encode(context: EncoderContext): Unit {
        //step F
        var buffer: ArrayList<Rune> = ArrayList<Rune>();
        while (context.hasMoreCharacters()) {
            var c: Rune = context.getCurrentChar();
            encodeChar(c, buffer);
            context.pos++

            var count: Int64 = buffer.size;
            if (count >= 4) {
                context.writeCodewords(encodeToCodewords(buffer));
                buffer.remove(Range(0, 4, 1, true, false, true))
                var newMode: Int64 = HighLevelEncoder.lookAheadTest(context.getMessage(), context.pos, getEncodingMode()
                );
                if (newMode != getEncodingMode()) {
                    // Return to ASCII encodation, which will actually handle latch to new mode
                    context.signalEncoderChange(HighLevelEncoder.ASCII_ENCODATION);
                    break
                }
            }
        }
        buffer.append(Rune(31)) //Unlatch
        handleEOD(context, buffer);
    }

    /**
     * Handle "end of data" situations
     *
     * @param context the encoder context
     * @param buffer  the buffer with the remaining encoded characters
     */
    private static func handleEOD(context: EncoderContext, buffer: ArrayList<Rune>) {
        try {
            var count: Int64 = buffer.size;
            if (count == 0) {
                return; //Already finished
            }
            if (count == 1) {
                //Only an unlatch at the end
                context.updateSymbolInfo();
                var available: Int64 = context.getSymbolInfo().getOrThrow().getDataCapacity() -
                    context.getCodewordCount()
                var remaining: Int64 = context.getRemainingCharacters();

                // The following two lines are a hack inspired by the 'fix'
                if (remaining > available) {
                    context.updateSymbolInfo(context.getCodewordCount() + 1);
                    available = context.getSymbolInfo().getOrThrow().getDataCapacity() - context.getCodewordCount()
                }
                if (remaining <= available && available <= 2) {
                    return; //No unlatch
                }
            }

            if (count > 4) {
                throw IllegalArgumentException("Count must not exceed 4");
            }
            var restChars: Int64 = count - 1
            var encoded: UTF32String = encodeToCodewords(buffer);
            let endOfSymbolReached = !context.hasMoreCharacters()

            var restInAscii: String = (endOfSymbolReached && (restChars <= 2)).toString();

            if (restChars <= 2) {
                context.updateSymbolInfo(context.getCodewordCount() + restChars);
                let available: Int64 = context.getSymbolInfo().getOrThrow().getDataCapacity() -
                    context.getCodewordCount()

                if (available >= 3) {
                    context.updateSymbolInfo(context.getCodewordCount() + encoded.charSize);
                    restInAscii = "false"
                } else {}
            }

            if (restInAscii == "true") {
                context.resetSymbolInfo();
                context.pos -= restChars
            } else {
                context.writeCodewords(encoded);
            }
        } finally {
            context.signalEncoderChange(HighLevelEncoder.ASCII_ENCODATION);
        }
    }

    private static func encodeChar(c: Rune, sb: ArrayList<Rune>) {
        if (c >= r' ' && c <= r'?') {
            sb.append(c);
        } else if (c >= r'@' && c <= r'^') {
            sb.append(Rune(UInt32(c) - 64));
        } else {
            HighLevelEncoder.illegalCharacter(c);
        }
    }

    @OverflowWrapping
    private static func encodeToCodewords(sb: ArrayList<Rune>): UTF32String {
        var len: Int64 = sb.size;
        if (len == 0) {
            throw IllegalArgumentException("StringBuilder must not be empty");
        }
        var c1: Rune = sb.get(0).getOrThrow();
        var c2: Rune
        var c3: Rune
        var c4: Rune
        if (len >= 2) {
            c2 = sb.get(1).getOrThrow()
        } else {
            c2 = Rune(0)
        }
        if (len >= 3) {
            c3 = sb.get(2).getOrThrow()
        } else {
            c3 = Rune(0)
        }
        if (len >= 4) {
            c4 = sb.get(3).getOrThrow()
        } else {
            c4 = Rune(0)
        }
        var v = (c1.hashCode() << 18) + (c2.hashCode() << 12) + (c3.hashCode() << 6) + c4.hashCode()
        var cw1: Rune = Rune((v >> 16 & 255))
        var cw2: Rune = Rune((v >> 8 & 255))
        var cw3: Rune = Rune(v & 255)
        var res: ArrayList<Rune> = ArrayList<Rune>();
        res.append(cw1);
        if (len >= 2) {
            res.append(cw2);
        }
        if (len >= 3) {
            res.append(cw3);
        }
        return UTF32String(res);
    }
}
