/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.datamatrix.encoder

import std.collection.*
import std.core.*
import QRCode4cj.common.StandardCharsets
import QRCode4cj.tools.*
import QRCode4cj.common.Dimension

public class EncoderContext {
    private var msg: UTF32String
    private var shape: SymbolShapeHint
    private var minSize: ?Dimension = None
    private var maxSize: ?Dimension = None
    private let codewords: ArrayList<Rune>
    var pos: Int64 = 0;
    private var newEncoding: Int64
    private var symbolInfo: ?SymbolInfo = None
    private var skipAtEnd: Int64 = 0;

    init(msg: UTF32String) {
        //From this point on Strings are not Unicode anymore!
        var msgBinary: Array<UInt8> = StandardCharsets.ISO_8859_1.newEncoder().getBytes(msg)
        var sb: ArrayList<Rune> = ArrayList<Rune>();
        for (i in 0..msgBinary.size) {
            var ch: Rune = Rune(msgBinary[i] & 0xff)
            if (ch == r'?' && msg[i] != r'?') {
                throw IllegalArgumentException("Message contains characters outside ISO-8859-1 encoding.");
            }
            sb.append(ch);
        }
        this.msg = UTF32String(sb)

        //Not Unicode here!
        shape = SymbolShapeHint.FORCE_NONE
        this.codewords = ArrayList<Rune>()
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

    public func getCurrentChar(): Rune {
        return msg[pos];
    }

    public func getCurrent(): Rune {
        return msg[pos];
    }

    public func getCodewords(): ArrayList<Rune> {
        return codewords
    }

    public func writeCodewords(codewords: UTF32String) {
        this.codewords.appendAll(codewords.toRuneArray());
    }

    public func writeCodeword(codeword: Rune) {
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
