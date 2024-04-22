/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package common

from std import io.*
from charset import charset.*
import tools.UTF32String
from charset import charset.encoding.*
from charset import charset.exception.*

/**
 * Encapsulates a Character Set ECI, according to "Extended Channel Interpretations
 * of ISO 18004.
 */
public open class StandardCharsets {
    public var flag: Bool = false
    public static let ISO_8859_1: MyCharset = MyCharset(Charsets.WINDOWS_1252, "ISO-8859-1", "ISO-8859-1")
    public static let ASCII: MyCharset = MyCharset(Charsets.WINDOWS_1252, "ASCII")
    public static let UTF_8: MyCharset = MyCharset(Charsets.UTF8, "UTF-8")
    public static let UTF_16BE: MyCharset = MyCharset(Charsets.UTF16BE, "UTF-16BE")
    public static let UTF_16LE: MyCharset = MyCharset(Charsets.UTF16LE, "UTF-16LE")
    private var encode: CharsetEncoder
    public init(iencode: CharsetEncoder) {
        encode = iencode
        flag = true
    }
}

public open class CharsetDecoder {
    public var flag: Bool = false
    private var decodein: Decoder
    private var mycharset: MyCharset

    public init(idecode: Decoder, icharset: MyCharset) {
        this.decodein = idecode
        this.mycharset = icharset
        this.flag = true
    }
    public func charset(): MyCharset {
        return this.mycharset
    }
    public func decode(src: Array<UInt8>): String {
        // charset不支持ISO-8859-1，使用WINDOWS_1252代替，此处过滤无法编码部分数据
        var diff = HashMap<Int64, UInt8>();
        if (this.mycharset.realName == "ISO-8859-1") {
            for (i in 0..src.size) {
                if (src[i] >= 128 && src[i] <= 159) {
                    diff[i] = src[i]
                }
            }
        }

        var result = this.decodein.decode(src);

        if (!diff.isEmpty()) {
            var resutlArray = result.toRuneArray();
            for (i in diff.keys()) {
                resutlArray[i] = Char(src[i])
            }
            result = String(resutlArray)
        }

        return result
    }
}
public open class CharsetEncoder {
    public var flag: Bool = false
    private var encode: Encoder
    private var mycharset: MyCharset

    public init(iencode: Encoder, icharset: MyCharset) {
        this.encode = iencode
        this.mycharset = icharset
        this.flag = true
    }
    public func charset(): MyCharset {
        return this.mycharset
    }
    public func canEncode(c: Char): Bool {
        try {
            var result = this.encode.encode(c.toString());
            return true
        }
        catch (e:EncoderException) {
            // charset不支持ISO-8859-1，使用WINDOWS_1252代替，此处做解码判断补充
            if (this.mycharset.realName == "ISO-8859-1")
            {
                if(c.hashCode() < 255)
                {
                    return true
                }
            }
            return false
        }
    }

    @OverflowWrapping
    public func getBytes(c: UTF32String): Array<UInt8> {
        try {
            var result = this.encode.encode(c.toString());
            return result
        }
        catch (e:EncoderException) {
            var result = Array<UInt8>(c.size,item:0)
            for (i in 0..c.size) {
                result[i] = UInt8(c[i].hashCode())
            }
            return result
        }
    }
}

public open class MyCharset <: Equatable<MyCharset> & ToString {
    public var flag: Bool = false
    private var charset: Charset = Charsets.X_MAC_CYRILLIC
    private static var names: Array<String> = [
        "windows-1252",
        "windows-1252",
        "ISO-8859-2",
        "ISO-8859-3",
        "ISO-8859-4",
        "ISO-8859-5",
        "ISO-8859-6",
        "ISO-8859-7",
        "ISO-8859-8",
        "ISO-8859-10",
        "ISO-8859-13",
        "ISO-8859-14",
        "ISO-8859-15",
        "ISO-8859-16",
        "Shift_JIS",
        "windows-1250",
        "windows-1251",
        "windows-1252",
        "windows-1256",
        "UTF-8",
        "UTF-16BE",
        "UTF-16LE",
        "windows-1252",
        "BIG5",
        "GB18030",
        "EUCKR",
        "EUCJP",
        "windows-1252",
        "X_MAC_CYRILLIC"
    ]

    public var realName = String();
    private var charsetName = String();

    public init() {}
    public init(mychartset: Charset, name: String) {
        charset = mychartset
        charsetName = name
        this.flag = true
    }
    public init(mychartset: Charset, name: String, realName: String) {
        charset = mychartset
        charsetName = name
        this.flag = true
        this.realName = realName
    }
    public static func forName(name: String): MyCharset {
        match (name) {
            // case Cp437 => return Charsets.Cp437()
            case "ISO-8859-1" => return MyCharset(Charsets.WINDOWS_1252, "ISO-8859-1", "ISO-8859-1")
            case "windows-1252" => return MyCharset(Charsets.WINDOWS_1252, "windows-1252")
            case "ISO-8859-2" => return MyCharset(Charsets.ISO_8859_2, "ISO-8859-2")
            case "ISO-8859-3" => return MyCharset(Charsets.ISO_8859_3, "ISO-8859-3")
            case "ISO-8859-4" => return MyCharset(Charsets.ISO_8859_4, "ISO-8859-4")
            case "ISO-8859-5" => return MyCharset(Charsets.ISO_8859_5, "ISO-8859-5")
            case "ISO-8859-6" => return MyCharset(Charsets.ISO_8859_6, "ISO-8859-6")
            case "ISO-8859-7" => return MyCharset(Charsets.ISO_8859_7, "ISO-8859-7")
            case "ISO-8859-8" => return MyCharset(Charsets.ISO_8859_8, "ISO-8859-8")

            // case ISO8859_9 => return Charsets.ISO_8859_9()
            case "ISO-8859-10" => return MyCharset(Charsets.ISO_8859_10, "ISO-8859-10")

            // case ISO8859_11 => return Charsets.ISO_8859_11()
            case "ISO-8859-13" => return MyCharset(Charsets.ISO_8859_13, "ISO-8859-13")
            case "ISO-8859-14" => return MyCharset(Charsets.ISO_8859_14, "ISO-8859-14")
            case "ISO-8859-15" => return MyCharset(Charsets.ISO_8859_15, "ISO-8859-15")
            case "ISO-8859-16" => return MyCharset(Charsets.ISO_8859_16, "ISO-8859-16")
            case "Shift_JIS" => return MyCharset(Charsets.SHIFT_JIS, "Shift_JIS")
            case "windows-1250" => return MyCharset(Charsets.WINDOWS_1250, "windows-1250")
            case "windows-1251" => return MyCharset(Charsets.WINDOWS_1251, "windows-1251")
            case "windows-1256" => return MyCharset(Charsets.WINDOWS_1256, "windows-1256")

            // case UnicodeBigUnmarked => return 25
            case "UTF-8" => return MyCharset(Charsets.UTF8, "UTF-8")
            case "UTF-16BE" => return MyCharset(Charsets.UTF16BE, "UTF-16BE")
            case "ASCII" => return MyCharset(Charsets.WINDOWS_1252, "ASCII")
            case "Big5" => return MyCharset(Charsets.BIG5, "Big5")
            case "GB18030" => return MyCharset(Charsets.GB18030, "GB18030")
            case "EUC_KR" => return MyCharset(Charsets.EUCKR, "EUC_KR")
            case "EUC_JP" => return MyCharset(Charsets.EUCJP, "EUC_JP")
            case _ => return MyCharset(Charsets.X_MAC_CYRILLIC, "X_MAC_CYRILLIC")
        }
    }

    public func newEncoder(): CharsetEncoder {
        return CharsetEncoder(this.charset.newEncoder(), this)
    }

    public func newDecoder(): CharsetDecoder {
        return CharsetDecoder(this.charset.newDecoder(), this)
    }

    public func equals(scharset: MyCharset): Bool {
        if (scharset.name() == this.name() && this.flag == scharset.flag) {
            true;
        } else {
            false;
        }
    }

    public func name(): String {
        this.charsetName
    }

    public operator func !=(that: MyCharset): Bool {
        if (this.name() != that.name() || this.flag != that.flag) {
            return true;
        } else {
            return false;
        }
    }

    public operator func ==(that: MyCharset): Bool {
        if (this.name() == that.name() && this.flag == that.flag) {
            return true;
        } else {
            return false;
        }
    }

    public func toString(): String {
        this.name();
    }
}

public open class CharacterSetECI {
    public var flag = false

    // case Cp437 => return 0
    public static let ISO8859_1: Int64 = 1
    public static let ISO8859_2: Int64 = 4
    public static let ISO8859_3: Int64 = 5
    public static let ISO8859_4: Int64 = 6
    public static let ISO8859_5: Int64 = 7
    public static let ISO8859_6: Int64 = 8
    public static let ISO8859_7: Int64 = 9
    public static let ISO8859_8: Int64 = 10

    // public let  ISO8859_9:Int64 = 11
    public static let ISO8859_10: Int64 = 12

    // public let  ISO8859_11:Int64 = 13
    public static let ISO8859_13: Int64 = 15
    public static let ISO8859_14: Int64 = 16
    public static let ISO8859_15: Int64 = 17
    public static let ISO8859_16: Int64 = 18
    public static let Shift_JIS: Int64 = 20
    public static let windows_1250: Int64 = 21
    public static let windows_1251: Int64 = 22
    public static let windows_1252: Int64 = 23
    public static let windows_1256: Int64 = 24

    public static let UnicodeBigUnmarked: Int64 = 25
    public static let UTF8: Int64 = 26
    public static let ASCII: Int64 = 27
    public static let Big5: Int64 = 28
    public static let GB18030: Int64 = 29
    public static let EUC_KR: Int64 = 30
    public static let EUC_JP: Int64 = 31
    public static let WINDOWS_1252: Int64 = 32
    public static let NO: Int64 = 899
    private var value: Int64 = NO
    private var charset: MyCharset = MyCharset(Charsets.X_MAC_CYRILLIC, "X_MAC_CYRILLIC")
    private static let VALUE_TO_NAME: HashMap<Int64, String> = HashMap<Int64, String>(
        [
            (ISO8859_1, "ISO-8859-1"),
            (ISO8859_2, "ISO-8859-2"),
            (ISO8859_3, "ISO-8859-3"),
            (ISO8859_4, "ISO-8859-4"),
            (ISO8859_5, "ISO-8859-5"),
            (ISO8859_6, "ISO-8859-6"),
            (ISO8859_7, "ISO-8859-7"),
            (ISO8859_8, "ISO-8859-8"),
            (ISO8859_10, "ISO-8859-10"),
            (ISO8859_13, "ISO-8859-13"),
            (ISO8859_14, "ISO-8859-14"),
            (ISO8859_15, "ISO-8859-15"),
            (ISO8859_16, "ISO-8859-16"),
            (Shift_JIS, "Shift_JIS"),
            (windows_1250, "windows-1250"),
            (windows_1251, "windows-1251"),
            (windows_1252, "windows-1252"),
            (windows_1256, "windows-1256"),
            (UTF8, "UTF-8"),
            (UnicodeBigUnmarked, "UTF-16BE"),
            (ASCII, "ASCII"),
            (Big5, "Big5"),
            (GB18030, "GB18030"),
            (EUC_KR, "EUC_KR"),
            (EUC_JP, "EUC_JP"),
            (WINDOWS_1252, "windows-1252"),
            (NO, "NO")
        ]
    )
    private static let NAME_TO_VALUE: HashMap<String, Int64> = HashMap<String, Int64>(
        [
            ("ISO-8859-1", ISO8859_1),
            ("ISO-8859-2", ISO8859_2),
            ("ISO-8859-3", ISO8859_3),
            ("ISO-8859-4", ISO8859_4),
            ("ISO-8859-5", ISO8859_5),
            ("ISO-8859-6", ISO8859_6),
            ("ISO-8859-7", ISO8859_7),
            ("ISO-8859-8", ISO8859_8),
            ("ISO-8859-10", ISO8859_10),
            ("ISO-8859-13", ISO8859_13),
            ("ISO-8859-14", ISO8859_14),
            ("ISO-8859-15", ISO8859_15),
            ("ISO-8859-16", ISO8859_16),
            ("Shift_JIS", Shift_JIS),
            ("windows-1250", windows_1250),
            ("windows-1251", windows_1251),
            ("windows-1252", windows_1252),
            ("windows-1256", windows_1256),
            ("UTF-8", UTF8),
            ("UTF-16BE", UnicodeBigUnmarked),
            ("ASCII", ASCII),
            ("Big5", Big5),
            ("GB18030", GB18030),
            ("EUC_KR", EUC_KR),
            ("EUC_JP", EUC_JP),
            ("windows-1252", WINDOWS_1252),
            ("NO", NO)
        ]
    )
    init() {}
    init(val: Int64) {
        if (VALUE_TO_NAME.contains(val)) {
            this.value = val
            this.flag = true
        } else {
            this.flag = false
            this.value = val
        }
    }
    init(val: String) {
        if (NAME_TO_VALUE.contains(val)) {
            this.value = NAME_TO_VALUE[val]
            this.flag = true
        } else {
            this.flag = false
        }
    }
    init(val: MyCharset) {
        if (NAME_TO_VALUE.contains(val.name())) {
            this.value = NAME_TO_VALUE[val.name()]
            this.flag = true
        } else {
            this.flag = false
        }
    }
    public func name(): String {
        this.flag = true
        return VALUE_TO_NAME[this.value]
    }
    public func GetCharacterSetECIByValue(result: CharacterSetECI): MyCharset {
        this.flag = true
        if (value < 0 || value >= 900) {
            throw Qrcoder4cjFormatException.getFormatInstance();
        }

        match (result.value) {
            // case Cp437 => return Charsets.Cp437()
            case 1 => return MyCharset(Charsets.WINDOWS_1252, "ISO-8859-1", "ISO-8859-1")
            case 3 => return MyCharset(Charsets.WINDOWS_1252, "windows-1252")
            case 4 => return MyCharset(Charsets.ISO_8859_2, "ISO-8859-2")
            case 5 => return MyCharset(Charsets.ISO_8859_3, "ISO-8859-3")
            case 6 => return MyCharset(Charsets.ISO_8859_4, "ISO-8859-4")
            case 7 => return MyCharset(Charsets.ISO_8859_5, "ISO-8859-5")
            case 8 => return MyCharset(Charsets.ISO_8859_6, "ISO-8859-6")
            case 9 => return MyCharset(Charsets.ISO_8859_7, "ISO-8859-7")
            case 10 => return MyCharset(Charsets.ISO_8859_8, "ISO-8859-8")

            // case ISO8859_9 => return Charsets.ISO_8859_9()
            case 12 => return MyCharset(Charsets.ISO_8859_10, "ISO-8859-10")

            // case ISO8859_11 => return Charsets.ISO_8859_11()
            case 15 => return MyCharset(Charsets.ISO_8859_13, "ISO-8859-13")
            case 16 => return MyCharset(Charsets.ISO_8859_14, "ISO-8859-14")
            case 17 => return MyCharset(Charsets.ISO_8859_15, "ISO-8859-15")
            case 18 => return MyCharset(Charsets.ISO_8859_16, "ISO-8859-16")
            case 20 => return MyCharset(Charsets.SHIFT_JIS, "Shift_JIS")
            case 21 => return MyCharset(Charsets.WINDOWS_1250, "windows-1250")
            case 22 => return MyCharset(Charsets.WINDOWS_1251, "windows-1251")
            case 23 => return MyCharset(Charsets.WINDOWS_1252, "windows-1252")
            case 24 => return MyCharset(Charsets.WINDOWS_1256, "windows-1256")

            case 25 => return MyCharset(Charsets.UTF16BE, "UTF-16BE")
            case 26 => return MyCharset(Charsets.UTF8, "UTF-8")
            case 27 => return MyCharset(Charsets.WINDOWS_1252, "ASCII")
            case 28 => return MyCharset(Charsets.BIG5, "Big5")
            case 29 => return MyCharset(Charsets.GB18030, "GB18030")
            case 30 => return MyCharset(Charsets.EUCKR, "EUC_KR")
            case 31 => return MyCharset(Charsets.EUCJP, "EUC_JP")
            case 32 => return MyCharset(Charsets.WINDOWS_1252, "WINDOWS_1252")
            case 170 => return MyCharset(Charsets.WINDOWS_1252, "WINDOWS_1252")
            case _ => return MyCharset(Charsets.X_MAC_CYRILLIC, "X_MAC_CYRILLIC")
        }
    }
    public operator func !=(right: CharacterSetECI): Bool {
        if (right.value != this.value) {
            true;
        } else {
            false;
        }
    }

    public operator func ==(right: CharacterSetECI): Bool {
        if (right.value == this.value) {
            true;
        } else {
            false;
        }
    }

    public func hashCode(): Int64 {
        return this.value;
    }

    public func getValue(): Int64 {
        return this.value;
    }

    public func getCharset(): MyCharset {
        return GetCharacterSetECIByValue(this)
    }

    /**
     * @param charset Java character set object
     * @return CharacterSetECI representing ECI for character encoding, or null if it is legal
     * but unsupported
     */
    public static func getCharacterSetECI(charset: MyCharset): Int64 {
        if (charset.realName != "" && NAME_TO_VALUE.contains(charset.realName)) {
            return NAME_TO_VALUE[charset.realName]
        } else if (NAME_TO_VALUE.contains(charset.name())) {
            return NAME_TO_VALUE[charset.name()]
        } else {
            return NO
        }
    }

    /**
     * @param value character set ECI value
     * @return {@code CharacterSetECI} representing ECI of given value, or null if it is legal but
     * unsupported
     * @throws Qrcoder4cjFormatException if ECI value is invalid
     */
    public static func getCharacterSetECIByValue(result: Int64): CharacterSetECI {
        return CharacterSetECI(result)
    }

    /**
     * @param name character set ECI encoding name
     * @return CharacterSetECI representing ECI for character encoding, or null if it is legal
     * but unsupported
     */
    public static func getCharacterSetECIByName(result: String): CharacterSetECI {
        return CharacterSetECI(result)
    }
}
