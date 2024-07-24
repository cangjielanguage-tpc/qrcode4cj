// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

import QRCode4cj.aztec.decoder.*
import QRCode4cj.aztec.detector.*
import QRCode4cj.aztec.common.*
import QRCode4cj.multi.*
import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.common.writer.*
import QRCode4cj.oned.*
import std.collection.*
import std.fs.*
import std.time.*

@Test
public class TestQRCode4cjCode128Encode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_Code128_Encode_01():Unit {
        //合法
        var encode_src_legal=Array<(String,String)>([("168901","168901"),("Code 128","Code 128"),("102030405060708090","102030405060708090"),
                                                     ("123456","123456"),("8101054321120021123456","8101054321120021123456"),("óóóó1234óóabózz","1234abzz"),
                                                     ("005-3379497200006","005-3379497200006"),("15182881","15182881"),("CNK8181G2C","CNK8181G2C"),
                                                     ("1PEF224A4","1PEF224A4"),("FW727","FW727"),("005-3354174500018","005-3354174500018"),
                                                     ("31001171800000017989625355702636","31001171800000017989625355702636"),("42094043","42094043"),
                                                     ("30885909173823","30885909173823"),("FGGQ6D1","FGGQ6D1"),("10064908","10064908"),("10\n064908","10\n064908"),
                                                     ("1","1"),("11","11"),("A","A"),("a","a"),(":",":"),("\n","\n"),("óóóóóóóóóóóóó","")])
        for(encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.CODE_128,encode_src[0],120,120,cur_en_hints,cur_de_hints,encode_src[1]),0)
        }
    }
    @TestCase
    func test_Code128_Encode_02():Unit {
        //非法
        var encode_src_illegal=Array<(String,String)>([("","Found empty contents"),("China中China","Bad character in input: ASCII value=20013")])
        for(encode_src in encode_src_illegal){
            @Assert(testEncodeException(BarcodeFormat.CODE_128,encode_src[0],120,120,cur_en_hints,encode_src[1]),0)
        }
    }
}
