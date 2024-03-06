/*
 * Copyright 2007 ZXing authors
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

package zxing.code.common

/**
 * <p>Encapsulates the result of decoding a matrix of bits. This typically
 * applies to 2D barcode formats. For now it contains the raw bytes obtained,
 * as well as a String interpretation of those bytes, if applicable.</p>
 *
 * @author Sean Owen
 */
public class DecoderResult {
    public let rawBytes: Array<UInt8>
    public var numBits: Int64
    public let text: String
    public let byteSegments: ArrayList<Array<UInt8>>
    public let ecLevel: String
    public var errorsCorrected: Int64 = 0
    public var erasures: Int64 = 0
    public var other: Any = "";
    public let structuredAppendParity: Int64
    public let structuredAppendSequenceNumber: Int64
    public let symbologyModifier: Int64
    public var flag: Bool = false
    init() {
        this.rawBytes = Array<UInt8>()
        this.numBits = 0
        this.text = ""
        this.byteSegments = ArrayList<Array<UInt8>>()
        this.ecLevel = ""
        this.structuredAppendParity = 0
        this.structuredAppendSequenceNumber = 0
        this.symbologyModifier = 0
    }
    public init(rawBytes: Array<UInt8>, text: String, byteSegments: ArrayList<Array<UInt8>>, ecLevel: String) {
        this.rawBytes = rawBytes
        this.numBits = rawBytes.size
        this.text = text
        this.byteSegments = byteSegments
        this.ecLevel = ecLevel
        this.structuredAppendParity = -1
        this.structuredAppendSequenceNumber = -1
        this.symbologyModifier = 0
        this.flag = true
    }

    public init(
        rawBytes: Array<UInt8>,
        text: String,
        byteSegments: ArrayList<Array<UInt8>>,
        ecLevel: String,
        symbologyModifier: Int64
    ) {
        this.rawBytes = rawBytes
        this.numBits = rawBytes.size
        this.text = text
        this.byteSegments = byteSegments
        this.ecLevel = ecLevel
        this.structuredAppendParity = -1
        this.structuredAppendSequenceNumber = -1
        this.symbologyModifier = symbologyModifier
        this.flag = true
    }

    public init(
        rawBytes: Array<UInt8>,
        text: String,
        byteSegments: ArrayList<Array<UInt8>>,
        ecLevel: String,
        saSequence: Int64,
        saParity: Int64
    ) {
        this.rawBytes = rawBytes
        this.numBits = rawBytes.size

        this.text = text
        this.byteSegments = byteSegments
        this.ecLevel = ecLevel
        this.structuredAppendParity = saParity
        this.structuredAppendSequenceNumber = saSequence
        this.symbologyModifier = 0
        this.flag = true
    }

    public init(
        rawBytes: Array<UInt8>,
        text: String,
        byteSegments: ArrayList<Array<UInt8>>,
        ecLevel: String,
        saSequence: Int64,
        saParity: Int64,
        symbologyModifier: Int64
    ) {
        this.rawBytes = rawBytes
        this.numBits = rawBytes.size
        this.text = text
        this.byteSegments = byteSegments
        this.ecLevel = ecLevel
        this.structuredAppendParity = saParity
        this.structuredAppendSequenceNumber = saSequence
        this.symbologyModifier = symbologyModifier
        this.flag = true
    }

    /**
     * @return raw bytes representing the result, or {@code null} if not applicable
     */
    public func getRawBytes(): Array<UInt8> {
        return this.rawBytes
    }

    /**
     * @return how many bits of {@link #getRawBytes()} are valid; typically 8 times its length
     * @since 3.3.0
     */
    public func getNumBits(): Int64 {
        return this.numBits
    }

    /**
     * @param numBits overrides the number of bits that are valid in {@link #getRawBytes()}
     * @since 3.3.0
     */
    public func setNumBits(numBits: Int64): Unit {
        this.numBits = numBits
    }

    /**
     * @return text representation of the result
     */
    public func getText(): String {
        return this.text
    }

    /**
     * @return list of byte segments in the result, or {@code null} if not applicable
     */
    public func getByteSegments(): ArrayList<Array<UInt8>> {
        return this.byteSegments
    }

    /**
     * @return name of error correction level used, or {@code null} if not applicable
     */
    public func getECLevel(): String {
        return this.ecLevel
    }

    /**
     * @return number of errors corrected, or {@code null} if not applicable
     */
    public func getErrorsCorrected(): Int64 {
        return this.errorsCorrected
    }

    public func setErrorsCorrected(errorsCorrected: Int64): Unit {
        this.errorsCorrected = errorsCorrected
    }

    /**
     * @return number of erasures corrected, or {@code null} if not applicable
     */
    public func getErasures(): Int64 {
        return this.erasures
    }

    public func setErasures(erasures: Int64): Unit {
        this.erasures = erasures
    }

    /**
     * @return arbitrary additional metadata
     */
    public func getOther(): Any {
        return this.other
    }

    public func setOther(other: Any): Unit {
        this.other = other
    }

    public func hasStructuredAppend(): Bool {
        return this.structuredAppendParity >= 0 && this.structuredAppendSequenceNumber >= 0
    }

    public func getStructuredAppendParity(): Int64 {
        return this.structuredAppendParity
    }

    public func getStructuredAppendSequenceNumber(): Int64 {
        return this.structuredAppendSequenceNumber
    }

    public func getSymbologyModifier(): Int64 {
        return this.symbologyModifier
    }
}
