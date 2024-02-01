/*
 * Copyright 2022 ZXing authors
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
 * Class that converts a sequence of ECIs and bytes into a string
 *
 * @author Alex Geller
 */
public class ECIStringBuilder <: ToString {
    private var currentBytes: ArrayList<Char>
    private var result: ArrayList<Char>
    private var currentCharset: MyCharset = StandardCharsets.ISO_8859_1

    public init() {
        currentBytes = ArrayList<Char>()
        result = ArrayList<Char>()
    }
    public init(initialCapacity: Int64) {
        currentBytes = ArrayList<Char>()
        result = ArrayList<Char>()
    }

    /**
     * Appends {@code value} as a byte value
     *
     * @param value character whose lowest byte is to be appended
     */
    public func append(value: Char) {
        currentBytes.append(Char(UInt32(value) & 0xff))
    }

    /**
     * Appends {@code value} as a byte value
     *
     * @param value byte to append
     */
    public func append(value: Byte) {
        currentBytes.append(Char(UInt32(value) & 0xff))
    }

    /**
     * Appends the characters in {@code value} as bytes values
     *
     * @param value string to append
     */
    public func append(value: String) {
        currentBytes.appendAll(value.toRuneArray());
    }

    /**
     * Append the string repesentation of {@code value} (short for {@code append(String.valueOf(value))})
     *
     * @param value int to append as a string
     */
    public func append(value: Int64) {
        append(value.toString());
    }

    /**
     * Appends ECI value to output.
     *
     * @param value ECI value to append, as an int
     * @throws FormatException on invalid ECI value
     */
    public func appendECI(value: Int64) {
        encodeCurrentBytesIfAny();
        var characterSetECI: CharacterSetECI = CharacterSetECI.getCharacterSetECIByValue(value);
        if (!characterSetECI.flag) {
            throw FormatException.getFormatInstance();
        }
        currentCharset = characterSetECI.getCharset()
    }

    private func encodeCurrentBytesIfAny() {
        if (currentCharset.equals(StandardCharsets.ISO_8859_1)) {
            if (currentBytes.size > 0) {
                if (result.size == 0) {
                    result = currentBytes
                    currentBytes = ArrayList<Char>()
                } else {
                    result.appendAll(currentBytes);
                    currentBytes = ArrayList<Char>()
                }
            }
        } else if (currentBytes.size > 0) {
            var bytes: Array<Byte> = StandardCharsets.ISO_8859_1.newEncoder().getBytes(UTF32String(currentBytes));
            currentBytes = ArrayList<Char>()
            if (result.size == 0) {
                var resultdata: String = currentCharset.newDecoder().decode(bytes);
                result = ArrayList<Char>(resultdata.toRuneArray())
            } else {
                var resultdata: String = currentCharset.newDecoder().decode(bytes);
                result.appendAll(resultdata.toRuneArray());
            }
        }
    }

    /**
     * Appends the characters from {@code value} (unlike all other append methods of this class who append bytes)
     *
     * @param value characters to append
     */
    public func appendCharacters(value: ArrayList<Char>) {
        encodeCurrentBytesIfAny();
        result.appendAll(value);
    }

    /**
     * Short for {@code toString().size} (if possible, use {@link #isEmpty()} instead)
     *
     * @return length of string representation in characters
     */
    public func length(): Int64 {
        return UTF32String(toString()).charSize;
    }

    /**
     * @return true iff nothing has been appended
     */
    public func isEmpty(): Bool {
        return currentBytes.size == 0 && (result.size == 0)
    }

    public func toString(): String {
        encodeCurrentBytesIfAny();
        if (result.size == 0) {
            return ""
        } else {
            return String(result)
        }
    }
}
