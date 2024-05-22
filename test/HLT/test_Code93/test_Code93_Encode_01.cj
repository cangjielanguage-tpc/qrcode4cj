// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

from std import fs.*
from std import time.*
from QRCode4cj import oned.*
from QRCode4cj import common.*
@Test
public class TestQRCode4cjCode93Encode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_Code93_Encode_01():Unit {
        //合法--单个,混合
        var encode_src_legal=Array<String>(["01234567890",
                                            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                                            "~!@#^&*()=[]{};:\"\'|\\<>?^-. $/+%",
                                            "7",
                                            "-",
                                            "abcdefghijklmnopqrstuvwxyz",
                                            "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%",
                                            "A342342F-rwer-%"])

        for(encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.CODE_93,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_Code93_Encode_02():Unit {
        //合法--非法
        var encode_src_illegal=Array<String>(["中",
                                            "！",
                                            "￥",
                                            "…",
                                            "（",
                                            "）",
                                            "—",
                                            "”",
                                            "：",
                                            "《",
                                            "》",
                                            "，",
                                            "。",
                                            "、",
                                            "？",
                                            "【",
                                            "】"])

        for(encode_src in encode_src_illegal){
            @Assert(testEncodeException(BarcodeFormat.CODE_93,encode_src,120,120,cur_en_hints,"Requested content contains a non-encodable character: '"+encode_src+"'"),0)
        }
    }
    @TestCase
    func test_Code93_Encode_03():Unit {
        //合法，但是字符超长
        var encode_src="1234567890"
        while(encode_src.size<10000){
            encode_src+=encode_src
        }
        @Assert(testEncodeException(BarcodeFormat.CODE_93,encode_src,120,120,cur_en_hints,"Requested contents should be less than 80 digits long after converting to extended encoding, but got 10240"),0)
    }
    @TestCase
    func test_Code93_Encode_04():Unit {
        //合法，长度边界值
        var encode_src="1234567890"
        while(encode_src.size<71){
            encode_src+=encode_src
        }
        encode_src=encode_src[0..80 : 1]
        @Assert(testNormal(BarcodeFormat.CODE_93,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Code93_Encode_05():Unit {
        //合法，长度边界值
        var encode_src="1234567890"
        while(encode_src.size<=80){
            encode_src+=encode_src
        }
        encode_src=encode_src[0..81 : 1]
        @Assert(testEncodeException(BarcodeFormat.CODE_93,encode_src,120,120,cur_en_hints,"Requested contents should be less than 80 digits long after converting to extended encoding, but got 81"),0)
    }
}