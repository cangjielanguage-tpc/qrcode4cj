/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package datamatrix.encoder

public open class C40Encoder <: Encoder {
    public open func getEncodingMode(): Int64 {
        return HighLevelEncoder.C40_ENCODATION;
    }

    func encodeMaximal(context: EncoderContext) {
        var buffer: ArrayList<Char> = ArrayList<Char>();
        var lastCharSize: Int64 = 0;
        var backtrackStartPosition: Int64 = context.pos;
        var backtrackBufferLength: Int64 = 0;
        while (context.hasMoreCharacters()) {
            var c: Char = context.getCurrentChar();
            context.pos++
            lastCharSize = encodeChar(c, buffer)
            if (buffer.size % 3 == 0) {
                backtrackStartPosition = context.pos
                backtrackBufferLength = buffer.size
            }
        }
        if (backtrackBufferLength != buffer.size) {
            let unwritten: Int64 = (buffer.size / 3) * 2

            let curCodewordCount: Int64 = context.getCodewordCount() + unwritten + 1
            // +1 for the latch to C40
            context.updateSymbolInfo(curCodewordCount);
            var available: Int64 = context.getSymbolInfo().getOrThrow().getDataCapacity() - curCodewordCount
            var rest: Int64 = buffer.size % 3
            if ((rest == 2 && available != 2) || (rest == 1 && (lastCharSize > 3 || available != 1))) {
                buffer = ArrayList<Char>()

                context.pos = backtrackStartPosition
            }
        }
        if (buffer.size > 0) {
            context.writeCodeword(HighLevelEncoder.LATCH_TO_C40);
        }

        handleEOD(context, buffer);
    }

    public open func encode(context: EncoderContext): Unit {
        //step C
        var buffer: ArrayList<Char> = ArrayList<Char>();
        while (context.hasMoreCharacters()) {
            var c: Char = context.getCurrentChar();
            context.pos++

            var lastCharSize: Int64 = encodeChar(c, buffer);

            let unwritten = (buffer.size / 3) * 2

            let curCodewordCount = context.getCodewordCount() + unwritten
            context.updateSymbolInfo(curCodewordCount);
            var available: Int64 = context.getSymbolInfo().getOrThrow().getDataCapacity() - curCodewordCount

            if (!context.hasMoreCharacters()) {
                //Avoid having a single C40 value in the last triplet
                var removed: ArrayList<Char> = ArrayList<Char>();
                if ((buffer.size % 3) == 2 && available != 2) {
                    lastCharSize = backtrackOneCharacter(context, buffer, removed, lastCharSize)
                }
                while ((buffer.size % 3) == 1 && (lastCharSize > 3 || available != 1)) {
                    lastCharSize = backtrackOneCharacter(context, buffer, removed, lastCharSize)
                }
                break
            }

            var count: Int64 = buffer.size;
            if ((count % 3) == 0) {
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

    private func backtrackOneCharacter(
        context: EncoderContext,
        buffer: ArrayList<Char>,
        removed: ArrayList<Char>,
        lastCharSize: Int64
    ): Int64 {
        var lastCharSize_ = lastCharSize
        var count: Int64 = buffer.size;
        let trange = count - lastCharSize_..count
        buffer.remove(trange);
        context.pos--
        var c: Char = context.getCurrentChar();
        lastCharSize_ = encodeChar(c, removed)
        context.resetSymbolInfo();
        //Deal with possible reduction in symbol size
        return lastCharSize_
    }

    static func writeNextTriplet(context: EncoderContext, buffer: ArrayList<Char>) {
        context.writeCodewords(encodeToCodewords(buffer));
        let trange = 0..3
        buffer.remove(trange);
    }

    /**
     * Handle "end of data" situations
     *
     * @param context the encoder context
     * @param buffer  the buffer with the remaining encoded characters
     */
    public open func handleEOD(context: EncoderContext, buffer: ArrayList<Char>) {
        let unwritten = (buffer.size / 3) * 2
        var rest: Int64 = buffer.size % 3

        let curCodewordCount = context.getCodewordCount() + unwritten
        context.updateSymbolInfo(curCodewordCount);
        var available: Int64 = context.getSymbolInfo().getOrThrow().getDataCapacity() - curCodewordCount

        if (rest == 2) {
            buffer.append('\0');
            //Shift 1
            while (buffer.size >= 3) {
                writeNextTriplet(context, buffer);
            }
            if (context.hasMoreCharacters()) {
                context.writeCodeword(HighLevelEncoder.C40_UNLATCH);
            }
        } else if (available == 1 && rest == 1) {
            while (buffer.size >= 3) {
                writeNextTriplet(context, buffer);
            }
            if (context.hasMoreCharacters()) {
                context.writeCodeword(HighLevelEncoder.C40_UNLATCH);
            }

            // else no unlatch
            context.pos--
        } else if (rest == 0) {
            while (buffer.size >= 3) {
                writeNextTriplet(context, buffer);
            }
            if (available > 0 || context.hasMoreCharacters()) {
                context.writeCodeword(HighLevelEncoder.C40_UNLATCH);
            }
        } else {
            throw IllegalArgumentException("Unexpected case. Please report!");
        }
        context.signalEncoderChange(HighLevelEncoder.ASCII_ENCODATION);
    }

    public open func encodeChar(c: Char, sb: ArrayList<Char>): Int64 {
        if (c == ' ') {
            sb.append('\u{3}');
            return 1;
        }
        if (c >= '0' && c <= '9') {
            sb.append(Char(c.hashCode() - 48 + 4));
            return 1;
        }
        if (c >= 'A' && c <= 'Z') {
            sb.append(Char(c.hashCode() - 65 + 14));
            return 1;
        }
        if (c < ' ') {
            sb.append('\u{0}');
            //Shift 1 Set
            sb.append(c);
            return 2;
        }
        if (c <= '/') {
            sb.append('\u{1}');
            //Shift 2 Set
            sb.append(Char(c.hashCode() - 33));
            return 2;
        }
        if (c <= '@') {
            sb.append('\u{1}');
            //Shift 2 Set
            sb.append(Char(c.hashCode() - 58 + 15));
            return 2;
        }
        if (c <= '_') {
            sb.append('\u{1}');
            //Shift 2 Set
            sb.append(Char(c.hashCode() - 91 + 22));
            return 2;
        }
        if (c.hashCode() <= 127) {
            sb.append('\u{2}');
            //Shift 3 Set
            sb.append(Char(c.hashCode() - 96));
            return 2;
        }
        sb.appendAll("\u{1}\u{001e}".toRuneArray());
        //Shift 2, Upper Shift
        var len: Int64 = 2;
        len += encodeChar(Char(c.hashCode() - 128), sb)
        return len
    }

    private static func encodeToCodewords(sb: ArrayList<Char>): UTF32String {
        var v: Int64 = (1600 * sb[0].hashCode()) + (40 * sb[1].hashCode()) + sb[2].hashCode() + 1
        var cw1: Char = Char(v / 256)
        var cw2: Char = Char(v % 256)
        return UTF32String([cw1, cw2]);
    }
}
