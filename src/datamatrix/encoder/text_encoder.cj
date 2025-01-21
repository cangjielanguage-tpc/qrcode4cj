/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.datamatrix.encoder

import std.collection.*

public class TextEncoder <: C40Encoder {
    public func getEncodingMode(): Int64 {
        return HighLevelEncoder.TEXT_ENCODATION;
    }

    public func encodeChar(c: Rune, sb: ArrayList<Rune>): Int64 {
        if (c == r' ') {
            sb.add(Rune(3));
            return 1;
        }
        if (c >= r'0' && c <= r'9') {
            sb.add(Rune(c.hashCode() - 48 + 4));
            return 1;
        }
        if (c >= r'a' && c <= r'z') {
            sb.add(Rune(c.hashCode() - 97 + 14));
            return 1;
        }
        if (c < r' ') {
            sb.add(r'\u{0}');

            //Shift 1 Set
            sb.add(c);
            return 2;
        }
        if (c <= r'/') {
            sb.add(Rune(1));

            //Shift 2 Set
            sb.add(Rune(c.hashCode() - 33));
            return 2;
        }
        if (c <= r'@') {
            sb.add(Rune(1));

            //Shift 2 Set
            sb.add(Rune(c.hashCode() - 58 + 15));
            return 2;
        }
        if (c >= r'[' && c <= r'_') {
            sb.add(Rune(1));

            //Shift 2 Set
            sb.add(Rune(c.hashCode() - 91 + 22));
            return 2;
        }
        if (c == r'`') {
            sb.add(Rune(2));

            //Shift 3 Set
            sb.add(Rune(0)) // '`' - 96 == 0
            return 2;
        }
        if (c <= r'Z') {
            extracted2(c, sb)
            return 2;
        }
        if (c.hashCode() <= 127) {
            extracted(c, sb)
            return 2;
        }
        sb.add(all:"\u{2}\u{001e}".toRuneArray());

        //Shift 2, Upper Shift
        var len: Int64 = 2;
        len += encodeChar(Rune(c.hashCode() - 128), sb)
        return len
    }

    private static func extracted(c: Rune, sb: ArrayList<Rune>) {
        sb.add(Rune(2))
        sb.add(Rune(c.hashCode() - 123 + 27))
    }

    private static func extracted2(c: Rune, sb: ArrayList<Rune>) {
        sb.add(Rune(2));
        sb.add(Rune(c.hashCode() - 65 + 1));
    }
}
