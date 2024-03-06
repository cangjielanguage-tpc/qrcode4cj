/*
 * Copyright 2006-2007 Jeremias Maerki.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package zxing.code.datamatrix.encoder

class EdifactEncoder <: Encoder {
    public func getEncodingMode(): Int64 {
        return HighLevelEncoder.EDIFACT_ENCODATION;
    }

    public func encode(context: EncoderContext): Unit {
        //step F
        var buffer: ArrayList<Char> = ArrayList<Char>();
        while (context.hasMoreCharacters()) {
            var c: Char = context.getCurrentChar();
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
        buffer.append(Char(31)) //Unlatch
        handleEOD(context, buffer);
    }

    /**
     * Handle "end of data" situations
     *
     * @param context the encoder context
     * @param buffer  the buffer with the remaining encoded characters
     */
    private static func handleEOD(context: EncoderContext, buffer: ArrayList<Char>) {
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

                // The following two lines are a hack inspired by the 'fix' from https://sourceforge.net/p/barcode4j/svn/221/
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

    private static func encodeChar(c: Char, sb: ArrayList<Char>) {
        if (c >= ' ' && c <= '?') {
            sb.append(c);
        } else if (c >= '@' && c <= '^') {
            sb.append(Char(UInt32(c) - 64));
        } else {
            HighLevelEncoder.illegalCharacter(c);
        }
    }

    @OverflowWrapping
    private static func encodeToCodewords(sb: ArrayList<Char>): UTF32String {
        var len: Int64 = sb.size;
        if (len == 0) {
            throw IllegalArgumentException("StringBuilder must not be empty");
        }
        var c1: Char = sb.get(0).getOrThrow();
        var c2: Char
        var c3: Char
        var c4: Char
        if (len >= 2) {
            c2 = sb.get(1).getOrThrow()
        } else {
            c2 = Char(0)
        }
        if (len >= 3) {
            c3 = sb.get(2).getOrThrow()
        } else {
            c3 = Char(0)
        }
        if (len >= 4) {
            c4 = sb.get(3).getOrThrow()
        } else {
            c4 = Char(0)
        }
        var v = (c1.hashCode() << 18) + (c2.hashCode() << 12) + (c3.hashCode() << 6) + c4.hashCode()
        var cw1: Char = Char((v >> 16 & 255))
        var cw2: Char = Char((v >> 8 & 255))
        var cw3: Char = Char(v & 255)
        var res: ArrayList<Char> = ArrayList<Char>();
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
