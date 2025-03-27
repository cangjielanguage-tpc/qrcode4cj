/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.qrcode.decoder

/**
 * See ISO 18004:2006, 6.4.1, Tables 2 and 3. This enum encapsulates the various modes in which
 * data can be encoded to bits in the QR code standard.
 */
public enum Mode <: Equatable<Mode> & ToString {
    | TERMINATOR(Array<Int64>, Int64) // Not really a mode...
    | NUMERIC(Array<Int64>, Int64)
    | ALPHANUMERIC(Array<Int64>, Int64)
    | STRUCTURED_APPEND(Array<Int64>, Int64) // Not supported
    | BYTE(Array<Int64>, Int64)
    | ECI(Array<Int64>, Int64) // character counts don't apply
    | KANJI(Array<Int64>, Int64)
    | FNC1_FIRST_POSITION(Array<Int64>, Int64)
    | FNC1_SECOND_POSITION(Array<Int64>, Int64)
    /** See GBT 18284-2000; "Hanzi" is a transliteration of this mode name. */
    | HANZI(Array<Int64>, Int64)

    /**
     * @param bits four bits encoding a QR Code data mode
     * @return Mode encoded by these bits
     * @throws IllegalArgumentException if bits do not correspond to a known mode
     */
    public static func forBits(bits: Int64): Mode {
        match (bits) {
            case 0x0 => return TERMINATOR([0, 0, 0], 0x00);
            case 0x1 => return NUMERIC([10, 12, 14], 0x01);
            case 0x2 => return ALPHANUMERIC([9, 11, 13], 0x02);
            case 0x3 => return STRUCTURED_APPEND([0, 0, 0], 0x03);
            case 0x4 => return BYTE([8, 16, 16], 0x04);
            case 0x5 => return FNC1_FIRST_POSITION([0, 0, 0], 0x05);
            case 0x7 => return ECI([0, 0, 0], 0x07);
            case 0x8 => return KANJI([8, 10, 12], 0x08);
            case 0x9 => return FNC1_SECOND_POSITION([0, 0, 0], 0x09);
            case 0xD => // 0xD is defined in GBT 18284-2000, may not be supported in foreign country
                return HANZI([8, 10, 12], 0x0D);
            case _ => throw IllegalArgumentException();
        }
    }

    /**
     * @param version version in question
     * @return number of bits used, in this QR Code symbol {@link Version}, to encode the
     * count of characters that will follow encoded in this Mode
     */
    public func getCharacterCountBits(version: Version): Int64 {
        var number: Int64 = version.getVersionNumber();
        var offset: Int64
        if (number <= 9) {
            offset = 0
        } else if (number <= 26) {
            offset = 1
        } else {
            offset = 2
        }
        match (this) {
            case TERMINATOR(x, y) => return x[offset]
            case NUMERIC(x, y) => return x[offset]
            case ALPHANUMERIC(x, y) => return x[offset]
            case STRUCTURED_APPEND(x, y) => return x[offset]
            case BYTE(x, y) => return x[offset]
            case FNC1_FIRST_POSITION(x, y) => return x[offset]
            case ECI(x, y) => return x[offset]
            case KANJI(x, y) => return x[offset]
            case FNC1_SECOND_POSITION(x, y) => return x[offset]
            case HANZI(x, y) => return x[offset]
        }
    }

    public func getBits(): Int64 {
        match (this) {
            case TERMINATOR(x, y) => return y
            case NUMERIC(x, y) => return y
            case ALPHANUMERIC(x, y) => return y
            case STRUCTURED_APPEND(x, y) => return y
            case BYTE(x, y) => return y
            case FNC1_FIRST_POSITION(x, y) => return y
            case ECI(x, y) => return y
            case KANJI(x, y) => return y
            case FNC1_SECOND_POSITION(x, y) => return y
            case HANZI(x, y) => return y
        }
    }

    public operator func ==(that: Mode): Bool {
        if (this.getBits() == that.getBits()) {
            return true;
        } else {
            return false;
        }
    }

    public operator func !=(that: Mode): Bool {
        if (this.getBits() != that.getBits()) {
            return true;
        } else {
            return false;
        }
    }

    public func toString(): String {
        match (this) {
            case TERMINATOR(x, y) => return "TERMINATOR";
            case NUMERIC(x, y) => return "NUMERIC";
            case ALPHANUMERIC(x, y) => return "ALPHANUMERIC";
            case STRUCTURED_APPEND(x, y) => return "STRUCTURED_APPEND";
            case BYTE(x, y) => return "BYTE";
            case FNC1_FIRST_POSITION(x, y) => return "FNC1_FIRST_POSITION";
            case ECI(x, y) => return "ECI";
            case KANJI(x, y) => return "KANJI";
            case FNC1_SECOND_POSITION(x, y) => return "FNC1_SECOND_POSITION";
            case HANZI(x, y) => return "HANZI";
        }
    }
}
