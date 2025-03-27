/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common

import std.collection.*
import QRCode4cj.tools.*

public class ECIStringBuilder <: ToString {
    private var currentBytes: ArrayList<Rune>
    private var result: ArrayList<Rune>
    private var currentCharset: MyCharset = StandardCharsets.ISO_8859_1

    public init() {
        currentBytes = ArrayList<Rune>()
        result = ArrayList<Rune>()
    }
    public init(_: Int64) {
        currentBytes = ArrayList<Rune>()
        result = ArrayList<Rune>()
    }

    /**
     * Appends {@code value} as a byte value
     *
     * @param value character whose lowest byte is to be appended
     */
    public func add(value: Rune) {
        currentBytes.add(Rune(UInt32(value) & 0xff))
    }

    /**
     * Appends {@code value} as a byte value
     *
     * @param value byte to add
     */
    public func add(value: Byte) {
        currentBytes.add(Rune(UInt32(value) & 0xff))
    }

    /**
     * Appends the characters in {@code value} as bytes values
     *
     * @param value string to add
     */
    public func add(value: String) {
        currentBytes.add(all:value.toRuneArray());
    }

    /**
     * Append the string repesentation of {@code value} (short for {@code add(String.valueOf(value))})
     *
     * @param value int to add as a string
     */
    public func add(value: Int64) {
        add(value.toString());
    }

    /**
     * Appends ECI value to output.
     *
     * @param value ECI value to add, as an int
     * @throws Qrcoder4cjFormatException on invalid ECI value
     */
    public func appendECI(value: Int64) {
        encodeCurrentBytesIfAny();
        var characterSetECI: CharacterSetECI = CharacterSetECI.getCharacterSetECIByValue(value);
        if (!characterSetECI.flag) {
            throw Qrcoder4cjFormatException.getFormatInstance();
        }
        currentCharset = characterSetECI.getCharset()
    }

    private func encodeCurrentBytesIfAny() {
        if (currentCharset.equals(StandardCharsets.ISO_8859_1)) {
            if (currentBytes.size > 0) {
                if (result.size == 0) {
                    result = currentBytes
                    currentBytes = ArrayList<Rune>()
                } else {
                    result.add(all:currentBytes);
                    currentBytes = ArrayList<Rune>()
                }
            }
        } else if (currentBytes.size > 0) {
            var bytes: Array<Byte> = StandardCharsets.ISO_8859_1.newEncoder().getBytes(UTF32String(currentBytes));
            currentBytes = ArrayList<Rune>()
            if (result.size == 0) {
                var resultdata: String = currentCharset.newDecoder().decode(bytes);
                result = ArrayList<Rune>(resultdata.toRuneArray())
            } else {
                var resultdata: String = currentCharset.newDecoder().decode(bytes);
                result.add(all:resultdata.toRuneArray());
            }
        }
    }

    /**
     * Appends the characters from {@code value} (unlike all other add methods of this class who add bytes)
     *
     * @param value characters to add
     */
    public func appendCharacters(value: ArrayList<Rune>) {
        encodeCurrentBytesIfAny();
        result.add(all:value);
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
