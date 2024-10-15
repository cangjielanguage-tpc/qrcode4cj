/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common

import QRCode4cj.tools.*
import std.collection.*

public class ECIEncoderSet {
    // List of encoders that potentially encode characters not in ISO-8859-1 in one byte.
    private static let ENCODERS: ArrayList<CharsetEncoder> = ArrayList<CharsetEncoder>();
    private var encoders: Array<CharsetEncoder> = Array<CharsetEncoder>()
    private var priorityEncoderIndex: Int64 = 0

    /**
     * Constructs an encoder set
     *
     * @param stringToEncode the string that needs to be encoded
     * @param priorityCharset The preferred {@link Charset} or null.
     * @param fnc1 fnc1 denotes the character in the input that represents the FNC1 character or -1 for a non-GS1 bar
     * code. When specified, it is considered an error to pass it as argument to the methods canEncode() or encode().
     */
    public init(stringToEncodeIn: UTF32String, priorityCharset: MyCharset, fnc1: Int64) {
        let names = ["IBM437", "ISO-8859-2", "ISO-8859-3", "ISO-8859-4", "ISO-8859-5", "ISO-8859-7", "ISO-8859-9",
        "ISO-8859-13", "ISO-8859-16", "windows-1250", "windows-1251", "windows-1252", "windows-1256", "Shift_JIS"]
        for (i in 0..names.size) {
            if (CharacterSetECI.getCharacterSetECIByName(names[i]).flag) {
                try {
                    ENCODERS.append(MyCharset.forName(names[i]).newEncoder());
                } catch (e: Exception) {
                    // continue
                }
            }
        }

        var neededEncoders: ArrayList<CharsetEncoder> = ArrayList<CharsetEncoder>();

        //we always need the ISO-8859-1 encoder. It is the default encoding
        neededEncoders.append(StandardCharsets.ISO_8859_1.newEncoder());
        var needUnicodeEncoder: String = String();
        if (priorityCharset.flag && priorityCharset.name().startsWith("UTF")) {
            needUnicodeEncoder = true.toString()
        } else {
            needUnicodeEncoder = false.toString()
        }

        //Walk over the input string and see if all characters can be encoded with the list of encoders 
        needUnicodeEncoder = exinit(stringToEncodeIn, neededEncoders, needUnicodeEncoder, fnc1)

        if (neededEncoders.size == 1 && needUnicodeEncoder == false.toString()) {
            //the entire input can be encoded by the ISO-8859-1 encoder
            encoders = [neededEncoders[0]]
        } else {
            // we need more than one single byte encoder or we need a Unicode encoder.
            // In this case we append a UTF-8 and UTF-16 encoder to the list
            let data = CharacterSetECI(CharacterSetECI.NO).getCharset().newEncoder()
            encoders = Array<CharsetEncoder>(neededEncoders.size + 2, repeat: data)
            var index: Int64 = 0;
            for (i in 0..neededEncoders.size) {
                encoders[index] = neededEncoders[i]
                index++
            }

            encoders[index] = StandardCharsets.UTF_8.newEncoder()
            encoders[index + 1] = StandardCharsets.UTF_16BE.newEncoder()
        }

        //Compute priorityEncoderIndex by looking up priorityCharset in encoders
        var priorityEncoderIndexValue: Int64 = -1;
        if (priorityCharset.flag) {
            for (i in 0..encoders.size) {
                if (encoders[i].flag && priorityCharset.name() == (encoders[i].charset().name())) {
                    priorityEncoderIndexValue = i
                    break
                }
            }
        }
        priorityEncoderIndex = priorityEncoderIndexValue

        //invariants
        if (!encoders[0].charset().equals(StandardCharsets.ISO_8859_1)) {
            throw Exception()
        }
    }

    private static func exinit(stringToEncodeIn: UTF32String, neededEncoders: ArrayList<CharsetEncoder>,
        needUnicodeEncoder: String, fnc1: Int64) {
        var needUnicodeEncoder_p = needUnicodeEncoder
        for (i in 0..stringToEncodeIn.charSize) {
            var canEncode: Bool = false;
            for (j in 0..neededEncoders.size) {
                var c: Rune = stringToEncodeIn[i];
                if (c.hashCode() == fnc1 || neededEncoders[j].canEncode(c)) {
                    canEncode = true
                    break
                }
            }

            if (!canEncode) {
                //for the character at position i we don't yet have an encoder in the list
                for (j in 0..ENCODERS.size) {
                    if (ENCODERS[j].canEncode(stringToEncodeIn[i])) {
                        //Good, we found an encoder that can encode the character. We add him to the list and continue scanning
                        //the input
                        neededEncoders.append(ENCODERS[j]);
                        canEncode = true
                        break
                    }
                }
            }

            if (!canEncode) {
                //The character is not encodeable by any of the single byte encoders so we remember that we will need a
                //Unicode encoder.
                needUnicodeEncoder_p = true.toString()
            }
        }
        return needUnicodeEncoder_p
    }

    public func length(): Int64 {
        return encoders.size;
    }

    public func getCharsetName(index: Int64): String {
        if (!(index < length())) {
            throw Exception()
        }
        return encoders[index].charset().name();
    }

    public func getCharset(index: Int64): MyCharset {
        if (!(index < length())) {
            throw Exception()
        }
        return encoders[index].charset();
    }

    public func getECIValue(encoderIndex: Int64): Int64 {
        return CharacterSetECI.getCharacterSetECI(encoders[encoderIndex].charset());
    }

    /*
     * returns -1 if no priority charset was defined
     */
    public func getPriorityEncoderIndex(): Int64 {
        return priorityEncoderIndex
    }

    public func canEncode(c: Rune, encoderIndex: Int64): Bool {
        if (!(encoderIndex < length())) {
            throw Exception()
        }
        var encoder: CharsetEncoder = encoders[encoderIndex]
        return encoder.canEncode(c);
    }

    public func encode(c: Rune, encoderIndex: Int64): Array<UInt8> {
        if (!(encoderIndex < length())) {
            throw Exception()
        }
        var encoder: CharsetEncoder = encoders[encoderIndex]

        if (!(encoder.canEncode(c))) {
            throw Exception()
        }
        return encoder.getBytes(UTF32String(c.toString()))
    }

    public func encode(s: UTF32String, encoderIndex: Int64): Array<UInt8> {
        if (!(encoderIndex < length())) {
            throw Exception()
        }
        var encoder: CharsetEncoder = encoders[encoderIndex]
        return encoder.getBytes(s)
    }
}
