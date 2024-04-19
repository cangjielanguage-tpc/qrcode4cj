/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package oned

/**
 * This object renders a CODE93 code as a BitMatrix
 */
public class Code93Writer <: OneDimensionalCodeWriter {
    protected override func getSupportedWriteFormats(): ArrayList<BarcodeFormat> {
        var returnData: ArrayList<BarcodeFormat> = ArrayList<BarcodeFormat>()
        returnData.append(BarcodeFormat.CODE_93)
        return returnData
    }

    /**
     * @param contents barcode contents to encode. It should not be encoded for extended characters.
     *
     * @return a boolean[] of horizontal pixels (false = white, true = black)
     */
    public override func encode(contentsin: String): Array<Bool> {
        var contentsinuty32 = UTF32String(contentsin)
        var contents: UTF32String = convertToExtended(contentsinuty32)
        var length: Int64 = contents.charSize;
        if (length > 80) {
            throw IllegalArgumentException(
                "Requested contents should be less than 80 digits long after " +
                    "converting to extended encoding, but got ${length}"
            );
        }

        //length of code + 2 start/stop characters + 2 checksums, each of 9 bits, plus a termination bar
        var codeWidth: Int64 = (contents.charSize + 2 + 2) * 9 + 1

        var result: Array<Bool> = Array<Bool>(codeWidth, item: false)

        //start character (*)
        var pos: Int64 = appendPattern(result, 0, Code93Reader.ASTERISK_ENCODING);

        for (i in 0..length) {
            var indexInString: Int64 = Code93Reader.ALPHABET_STRING.indexOf(contents.get(i).toString()).getOrThrow()
            pos += appendPattern(result, pos, Code93Reader.CHARACTER_ENCODINGS[indexInString])
        }

        //add two checksums
        var check1: Int64 = computeChecksumIndex(contents, 20);
        pos += appendPattern(result, pos, Code93Reader.CHARACTER_ENCODINGS[check1])

        //append the contents to reflect the first checksum added
        contents += UTF32String(Code93Reader.ALPHABET_STRING.get(check1))
        var check2: Int64 = computeChecksumIndex(contents, 15);
        pos += appendPattern(result, pos, Code93Reader.CHARACTER_ENCODINGS[check2])

        //end character (*)
        pos += appendPattern(result, pos, Code93Reader.ASTERISK_ENCODING)

        //termination bar (single black bar)
        result[pos] = true

        return result
    }

    /**
     * @param target output to append to
     * @param pos start position
     * @param pattern pattern to append
     * @param startColor unused
     *
     * @return 9
     * @deprecated without replacement; intended as an internal-only method
     */
    protected static func appendPattern(targetin: Array<Bool>, posin: Int64, pattern: Array<Int64>, _: Bool): Int64 {
        var target: Array<Bool> = targetin
        var pos: Int64 = posin
        for (i in 0..pattern.size) {
            target[pos] = pattern[i] != 0
            pos++
        }
        return 9;
    }

    private static func appendPattern(target: Array<Bool>, pos: Int64, a: Int64): Int64 {
        for (i in 0..9) {
            var temp: Int64 = a & (1 << (8 - i))
            target[pos + i] = temp != 0
        }
        return 9;
    }

    private static func computeChecksumIndex(contents: UTF32String, maxWeight: Int64): Int64 {
        var weight: Int64 = 1;
        var total: Int64 = 0;
        var i: Int64 = contents.charSize - 1
        while (i > -1) {
            var indexInString: Int64 = Code93Reader.ALPHABET_STRING.indexOf(contents.get(i).toString()).getOrThrow()
            total += indexInString * weight
            weight++
            if (weight > maxWeight) {
                weight = 1
            }
            i--
        }
        return total % 47
    }

    static func convertToExtended(contents: UTF32String): UTF32String {
        var length: Int64 = contents.charSize;
        var extendedContent: ArrayList<Char> = ArrayList<Char>();

        for (i in 0..length) {
            var character: Char = contents.get(i);

            /* ($)=a, (%)=b, (/)=c, (+)=d. see Code93Reader.ALPHABET_STRING */
            if (character.hashCode() == 0) {
                /* NUL: (%)U */
                extendedContent.appendAll("bU".toRuneArray());
            } else if (character.hashCode() <= 26) {
                /* SOH - SUB: ($)A - ($)Z */
                extendedContent.append('a');
                extendedContent.append(Char('A'.hashCode() + character.hashCode() - 1));
            } else if (character.hashCode() <= 31) {
                /* ESC - US: (%)A - (%)E */
                extendedContent.append('b');
                extendedContent.append(Char('A'.hashCode() + character.hashCode() - 27));
            } else if (character == ' ' || character == '$' || character == '%' || character == '+') {
                /* space $ % + */
                extendedContent.append(character);
            } else if (character <= ',') {
                /* ! " # & ' ( ) * ,: (/)A - (/)L */
                extendedContent.append('c');
                extendedContent.append(Char('A'.hashCode() + character.hashCode() - '!'.hashCode()));
            } else if (character <= '9') {
                extendedContent.append(character);
            } else if (character == ':') {
                // :: (/)Z
                extendedContent.appendAll("cZ".toRuneArray());
            } else if (character <= '?') {
                // ; - ?: (%)F - (%)J
                extendedContent.append('b');
                extendedContent.append(Char('F'.hashCode() + character.hashCode() - ';'.hashCode()));
            } else if (character == '@') {
                /* @: (%)V */
                extendedContent.appendAll("bV".toRuneArray());
            } else if (character <= 'Z') {
                /* A - Z */
                extendedContent.append(character);
            } else if (character <= '_') {
                /* [ - _: (%)K - (%)O */
                extendedContent.append('b');
                extendedContent.append(Char('K'.hashCode() + character.hashCode() - '['.hashCode()));
            } else if (character == '`') {
                /* `: (%)W */
                extendedContent.appendAll("bW".toRuneArray());
            } else if (character <= 'z') {
                /* a - z: (*)A - (*)Z */
                extendedContent.append('d');
                extendedContent.append(Char('A'.hashCode() + character.hashCode() - 'a'.hashCode()));
            } else if (character.hashCode() <= 127) {
                /* { - DEL: (%)P - (%)T */
                extendedContent.append('b');
                extendedContent.append(Char('P'.hashCode() + character.hashCode() - '{'.hashCode()));
            } else {
                throw IllegalArgumentException("Requested content contains a non-encodable character: '${character}'");
            }
        }
        return UTF32String(extendedContent);
    }
}
