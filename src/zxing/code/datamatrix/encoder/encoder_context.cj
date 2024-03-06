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

from std import collection.*
from std import core.*
import zxing.code.common.StandardCharsets

public class EncoderContext {
    private var msg: UTF32String
    private var shape: SymbolShapeHint
    private var minSize: ?Dimension = None
    private var maxSize: ?Dimension = None
    private let codewords: ArrayList<Char>
    var pos: Int64 = 0;
    private var newEncoding: Int64
    private var symbolInfo: ?SymbolInfo = None
    private var skipAtEnd: Int64 = 0;

    init(msg: UTF32String) {
        //From this point on Strings are not Unicode anymore!
        var msgBinary: Array<UInt8> = StandardCharsets.ISO_8859_1.newEncoder().getBytes(msg)
        var sb: ArrayList<Char> = ArrayList<Char>();
        for (i in 0..msgBinary.size) {
            var ch: Char = Char(msgBinary[i] & 0xff)
            if (ch == '?' && msg[i] != '?') {
                throw IllegalArgumentException("Message contains characters outside ISO-8859-1 encoding.");
            }
            sb.append(ch);
        }
        this.msg = UTF32String(sb)

        //Not Unicode here!
        shape = SymbolShapeHint.FORCE_NONE
        this.codewords = ArrayList<Char>()
        this.newEncoding = -1
    }

    public func setSymbolShape(shape: SymbolShapeHint) {
        this.shape = shape
    }

    public func setSizeConstraints(minSize: ?Dimension, maxSize: ?Dimension) {
        this.minSize = minSize
        this.maxSize = maxSize
    }

    public func getMessage(): UTF32String {
        return this.msg;
    }

    public func setSkipAtEnd(count: Int64) {
        this.skipAtEnd = count
    }

    public func getCurrentChar(): Char {
        return msg[pos];
    }

    public func getCurrent(): Char {
        return msg[pos];
    }

    public func getCodewords(): ArrayList<Char> {
        return codewords
    }

    public func writeCodewords(codewords: UTF32String) {
        this.codewords.appendAll(codewords.toRuneArray());
    }

    public func writeCodeword(codeword: Char) {
        this.codewords.append(codeword);
    }

    public func getCodewordCount(): Int64 {
        return this.codewords.size;
    }

    public func getNewEncoding(): Int64 {
        return newEncoding
    }

    public func signalEncoderChange(encoding: Int64) {
        this.newEncoding = encoding
    }

    public func resetEncoderSignal() {
        this.newEncoding = -1
    }

    public func hasMoreCharacters(): Bool {
        return pos < getTotalMessageCharCount()
    }

    public func getTotalMessageCharCount(): Int64 {
        return msg.charSize - skipAtEnd
    }

    public func getRemainingCharacters(): Int64 {
        return getTotalMessageCharCount() - pos
    }

    public func getSymbolInfo(): ?SymbolInfo {
        return symbolInfo
    }

    public func updateSymbolInfo() {
        updateSymbolInfo(getCodewordCount());
    }

    public func updateSymbolInfo(len: Int64) {
        if (let Some(s) <- this.symbolInfo) {
            if (len > s.getDataCapacity()) {
                this.symbolInfo = SymbolInfo.lookup(len, shape, minSize, maxSize, true)
            }
        } else {
            this.symbolInfo = SymbolInfo.lookup(len, shape, minSize, maxSize, true)
        }
    }

    public func resetSymbolInfo() {
        this.symbolInfo = None
    }
}
