/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package datamatrix.encoder

public class TextEncoder <: C40Encoder {
    public func getEncodingMode(): Int64 {
        return HighLevelEncoder.TEXT_ENCODATION;
    }

    public func encodeChar(c: Char, sb: ArrayList<Char>): Int64 {
        if (c == ' ') {
            sb.append(Char(3));
            return 1;
        }
        if (c >= '0' && c <= '9') {
            sb.append(Char(c.hashCode() - 48 + 4));
            return 1;
        }
        if (c >= 'a' && c <= 'z') {
            sb.append(Char(c.hashCode() - 97 + 14));
            return 1;
        }
        if (c < ' ') {
            sb.append('\u{0}');

            //Shift 1 Set
            sb.append(c);
            return 2;
        }
        if (c <= '/') {
            sb.append(Char(1));

            //Shift 2 Set
            sb.append(Char(c.hashCode() - 33));
            return 2;
        }
        if (c <= '@') {
            sb.append(Char(1));

            //Shift 2 Set
            sb.append(Char(c.hashCode() - 58 + 15));
            return 2;
        }
        if (c >= '[' && c <= '_') {
            sb.append(Char(1));

            //Shift 2 Set
            sb.append(Char(c.hashCode() - 91 + 22));
            return 2;
        }
        if (c == '`') {
            sb.append(Char(2));

            //Shift 3 Set
            sb.append(Char(0)) // '`' - 96 == 0
            return 2;
        }
        if (c <= 'Z') {
            extracted2(c, sb)
            return 2;
        }
        if (c.hashCode() <= 127) {
            extracted(c, sb)
            return 2;
        }
        sb.appendAll("\u{2}\u{001e}".toRuneArray());

        //Shift 2, Upper Shift
        var len: Int64 = 2;
        len += encodeChar(Char(c.hashCode() - 128), sb)
        return len
    }

    private static func extracted(c: Char, sb: ArrayList<Char>) {
        sb.append(Char(2))
        sb.append(Char(c.hashCode() - 123 + 27))
    }

    private static func extracted2(c: Char, sb: ArrayList<Char>) {
        sb.append(Char(2));
        sb.append(Char(c.hashCode() - 65 + 1));
    }
}
