// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

@Test
public class TestQRCode4cjCode39Encode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_Code39_Encode_01():Unit {
        var encode_src="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%"
        @Assert(testNormal(BarcodeFormat.CODE_39,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Code39_Encode_02():Unit {
        var encode_src="0123456789ABCDEFGHIJK……………………LMNOPQRSTUVWXYZ-. $/+%"
        @Assert(testEncodeException(BarcodeFormat.CODE_39,encode_src,120,120,cur_en_hints,"IllegalArgumentException: Requested content contains a non-encodable character: \'…\'"),0)
    }
    @TestCase
    func test_Code39_Encode_03():Unit {
        var encode_src=#"0123456789~=|;ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%"#
        @Assert(testNormal(BarcodeFormat.CODE_39,encode_src,120,120,cur_en_hints,cur_de_hints,"0123456789%S%H%Q%FABCDEFGHIJKLMNOPQRSTUVWXYZ-. /D/O/K/E"),0)
    }
    @TestCase
    func test_Code39_Encode_04():Unit {
        var encode_src="abcdefghijklmnopqrstuvwxyz"
        @Assert(testNormal(BarcodeFormat.CODE_39,encode_src,120,120,cur_en_hints,cur_de_hints,"+A+B+C+D+E+F+G+H+I+J+K+L+M+N+O+P+Q+R+S+T+U+V+W+X+Y+Z"),0)
    }
    @TestCase
    func test_Code39_Encode_05():Unit {
        var encode_src="美丽中国"
        @Assert(testEncodeException(BarcodeFormat.CODE_39,encode_src,120,120,cur_en_hints,"IllegalArgumentException: Requested content contains a non-encodable character: \'美\'"),0)
    }
    @TestCase
    func test_Code39_Encode_06():Unit {
        var encode_src=""
        @Assert(testEncodeException(BarcodeFormat.CODE_39,encode_src,120,120,cur_en_hints,"IllegalArgumentException: Found empty contents"),0)
    }
}