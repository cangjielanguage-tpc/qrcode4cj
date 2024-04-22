/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package datamatrix.encoder

class Base256Encoder <: Encoder {
    public func getEncodingMode(): Int64 {
        return HighLevelEncoder.BASE256_ENCODATION;
    }

    public func encode(context: EncoderContext) {
        var buffer: ArrayList<Char> = ArrayList<Char>();
        buffer.append('\0');
        //Initialize length field
        while (context.hasMoreCharacters()) {
            var c: Char = context.getCurrentChar();
            buffer.append(c);

            context.pos++

            var newMode: Int64 = HighLevelEncoder.lookAheadTest(context.getMessage(), context.pos, getEncodingMode());
            if (newMode != getEncodingMode()) {
                // Return to ASCII encodation, which will actually handle latch to new mode
                context.signalEncoderChange(HighLevelEncoder.ASCII_ENCODATION);
                break
            }
        }
        var dataCount: Int64 = buffer.size - 1
        var lengthFieldSize: Int64 = 1;
        let currentSize = context.getCodewordCount() + dataCount + lengthFieldSize
        context.updateSymbolInfo(currentSize);
        var mustPad: Bool = (context.getSymbolInfo().getOrThrow().getDataCapacity() - currentSize) > 0
        if (context.hasMoreCharacters() || mustPad) {
            if (dataCount <= 249) {
                buffer.remove(0)
                buffer.insert(0, Char(dataCount))
            } else if (dataCount <= 1555) {
                buffer.remove(0)
                buffer.insert(0, Char((dataCount / 250 + 249)));
                buffer.insert(1, Char(dataCount % 250));
            } else {
                throw IllegalArgumentException("Message length not in valid ranges: " + dataCount.toString());
            }
        }
        for (i in 0..buffer.size) {
            context.writeCodeword(randomize255State(buffer.get(i).getOrThrow(), context.getCodewordCount() + 1));
        }
    }

    private static func randomize255State(ch: Char, codewordPosition: Int64): Char {
        let pseudoRandom = ((149 * codewordPosition) % 255) + 1
        let t: UInt32 = UInt32(ch)
        let tempVariable = UInt32(ch) + UInt32(pseudoRandom)
        if (tempVariable <= 255) {
            return Char(tempVariable)
        } else {
            return Char(tempVariable - 256)
        }
    }
}
