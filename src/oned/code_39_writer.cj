/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.oned

import std.collection.*
import QRCode4cj.tools.*
import QRCode4cj.common.*
import std.math.*
import std.convert.*

/**
 * This object renders a CODE39 code as a {@link BitMatrix}.
 */
public open class Code39Writer <: OneDimensionalCodeWriter {
    protected override func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        var returnData: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        returnData.append(BarcodeFormat.CODE_39)
        return returnData
    }

    public override func encode(contentsin: String): Array<Bool> {
        var contents: UTF32String = UTF32String(contentsin)
        var length: Int64 = contents.charSize

        if (length > 80) {
            throw IllegalArgumentException("Requested contents should be less than 80 digits long, but got ${length}")
        }

        for (i in 0..length) {
            if (let Some(indexInString) <- Code39Reader.ALPHABET_STRING.indexOf(contents.get(i).toString())) {}
            else {
                contents = tryToConvertToExtendedMode(contents)
                length = contents.charSize
                if (length > 80) {
                    throw IllegalArgumentException(
                        "Requested contents should be less than 80 digits long, but got ${length } (extended full ASCII mode)"
                    )
                }
                break
            }
        }

        var widths: Array<Int64> = Array<Int64>(9, item: 0)
        var codeWidth: Int64 = 24 + 1 + (13 * length)
        var result_: Array<Bool> = Array<Bool>(codeWidth, item: false)
        toIntArray(Code39Reader.ASTERISK_ENCODING, widths)
        var pos: Int64 = appendPattern(result_, 0, widths, true)
        var narrowWhite: Array<Int64> = Array<Int64>(1, item: 1)
        pos += appendPattern(result_, pos, narrowWhite, false)

        //append next character to byte matrix
        for (i in 0..length) {
            var indexInString: Int64 = Code39Reader.ALPHABET_STRING.indexOf(contents.get(i).toString()).getOrThrow()
            toIntArray(Code39Reader.CHARACTER_ENCODINGS[indexInString], widths)
            pos += appendPattern(result_, pos, widths, true)
            pos += appendPattern(result_, pos, narrowWhite, false)
        }

        toIntArray(Code39Reader.ASTERISK_ENCODING, widths)
        appendPattern(result_, pos, widths, true)

        return result_
    }

    private static func toIntArray(a: Int64, toReturn: Array<Int64>) {
        for (i in 0..9) {
            var temp: Int64 = a & (1 << (8 - i))
            if (temp == 0) {
                toReturn[i] = 1
            } else {
                toReturn[i] = 2
            }
        }
    }

    private static func tryToConvertToExtendedMode(contents: UTF32String): UTF32String {
        var length: Int64 = contents.charSize
        var extendedContent: ArrayList<Rune> = ArrayList<Rune>()

        for (i in 0..length) {
            var character: Rune = contents.get(i)
            match (character) {
                case r'\u{0000}' => extendedContent.appendAll("%U".toRuneArray())
                case r' ' | r'-' | r'.' => extendedContent.append(character)
                case r'@' => extendedContent.appendAll("%V".toRuneArray())

                case r'`' => extendedContent.appendAll("%W".toRuneArray())

                case _ => if (character.hashCode() <= 26) {
                    extendedContent.append(r'$')
                    extendedContent.append(Rune(r'A'.hashCode() + (character.hashCode() - 1)))
                } else if (character < r' ') {
                    extendedContent.append(r'%')
                    extendedContent.append(Rune(r'A'.hashCode() + (character.hashCode() - 27)))
                } else if (character <= r',' || character == r'/' || character == r':') {
                    extendedContent.append(r'/')
                    extendedContent.append(Rune(r'A'.hashCode() + (character.hashCode() - 33)))
                } else if (character <= r'9') {
                    extendedContent.append(Rune(r'0'.hashCode() + (character.hashCode() - 48)))
                } else if (character <= r'?') {
                    extendedContent.append(r'%')
                    extendedContent.append(Rune(r'F'.hashCode() + (character.hashCode() - 59)))
                } else if (character <= r'Z') {
                    extendedContent.append(Rune(r'A'.hashCode() + (character.hashCode() - 65)))
                } else if (character <= r'_') {
                    extendedContent.append(r'%')
                    extendedContent.append(Rune(r'K'.hashCode() + (character.hashCode() - 91)))
                } else if (character <= r'z') {
                    extendedContent.append(r'+')
                    extendedContent.append(Rune(r'A'.hashCode() + (character.hashCode() - 97)))
                } else if (character.hashCode() <= 127) {
                    extendedContent.append(r'%')
                    extendedContent.append(Rune(r'P'.hashCode() + (character.hashCode() - 123)))
                } else {
                    throw IllegalArgumentException(
                        "Requested content contains a non-encodable character: '" + contents.get(i).toString() + "'")
                }
            }
        }

        return UTF32String(extendedContent)
    }
}
