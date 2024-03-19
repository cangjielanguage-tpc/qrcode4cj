/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.oned

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
        var result: Array<Bool> = Array<Bool>(codeWidth, item: false)
        toIntArray(Code39Reader.ASTERISK_ENCODING, widths)
        var pos: Int64 = appendPattern(result, 0, widths, true)
        var narrowWhite: Array<Int64> = Array<Int64>(1, item: 1)
        pos += appendPattern(result, pos, narrowWhite, false)

        //append next character to byte matrix
        for (i in 0..length) {
            var indexInString: Int64 = Code39Reader.ALPHABET_STRING.indexOf(contents.get(i).toString()).getOrThrow()
            toIntArray(Code39Reader.CHARACTER_ENCODINGS[indexInString], widths)
            pos += appendPattern(result, pos, widths, true)
            pos += appendPattern(result, pos, narrowWhite, false)
        }

        toIntArray(Code39Reader.ASTERISK_ENCODING, widths)
        appendPattern(result, pos, widths, true)

        return result
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
        var extendedContent: ArrayList<Char> = ArrayList<Char>()

        for (i in 0..length) {
            var character: Char = contents.get(i)
            match (character) {
                case '\u{0000}' => extendedContent.appendAll("%U".toRuneArray())
                case ' ' | '-' | '.' => extendedContent.append(character)
                case '@' => extendedContent.appendAll("%V".toRuneArray())

                case '`' => extendedContent.appendAll("%W".toRuneArray())

                case _ => if (character.hashCode() <= 26) {
                    extendedContent.append('$')
                    extendedContent.append(Char('A'.hashCode() + (character.hashCode() - 1)))
                } else if (character < ' ') {
                    extendedContent.append('%')
                    extendedContent.append(Char('A'.hashCode() + (character.hashCode() - 27)))
                } else if (character <= ',' || character == '/' || character == ':') {
                    extendedContent.append('/')
                    extendedContent.append(Char('A'.hashCode() + (character.hashCode() - 33)))
                } else if (character <= '9') {
                    extendedContent.append(Char('0'.hashCode() + (character.hashCode() - 48)))
                } else if (character <= '?') {
                    extendedContent.append('%')
                    extendedContent.append(Char('F'.hashCode() + (character.hashCode() - 59)))
                } else if (character <= 'Z') {
                    extendedContent.append(Char('A'.hashCode() + (character.hashCode() - 65)))
                } else if (character <= '_') {
                    extendedContent.append('%')
                    extendedContent.append(Char('K'.hashCode() + (character.hashCode() - 91)))
                } else if (character <= 'z') {
                    extendedContent.append('+')
                    extendedContent.append(Char('A'.hashCode() + (character.hashCode() - 97)))
                } else if (character.hashCode() <= 127) {
                    extendedContent.append('%')
                    extendedContent.append(Char('P'.hashCode() + (character.hashCode() - 123)))
                } else {
                    throw IllegalArgumentException(
                        "Requested content contains a non-encodable character: '" + contents.get(i).toString() + "'")
                }
            }
        }

        return UTF32String(extendedContent)
    }
}
