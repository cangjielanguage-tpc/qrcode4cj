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

@Test
public class TestQRCode4cjEan8Encode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_Ean8_Encode_01():Unit {
        var encode_src_legal=Array<String>([ "00000000","32435542","55555555"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.EAN_8,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_Ean8_Encode_02():Unit {
        var encode_src_legal=Array<String>([
                                             "48512343",
                                             "12345670",
                                             "67678983",
                                             "80674313",
                                             "59001270",
                                             "50487066",
                                             "55123457"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.EAN_8,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_Ean8_Encode_03():Unit {
        var encode_src_illegal=Array<String>(["43",
                                              "123456789",
                                              "123456"])
        for (encode_src in encode_src_illegal){
            @Assert(testEncodeException(BarcodeFormat.EAN_8,encode_src,120,120,cur_en_hints,"Requested contents should be 7 or 8 digits long, but got"),0)
        }
    }
    @TestCase
    func test_Ean8_Encode_04():Unit {
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"",120,120,cur_en_hints,"Found empty contents"),0)
    }
    @TestCase
    func test_Ean8_Encode_05():Unit {
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"abcdefgh",120,120,cur_en_hints,"Illegal contents"),0)
    }
    @TestCase
    func test_Ean8_Encode_06():Unit {
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"ABCDEFGH",120,120,cur_en_hints,"Illegal contents"),0)
    }
    @TestCase
    func test_Ean8_Encode_07():Unit {
        let encode_src=##" !"#$%&'"##
        @Assert(testEncodeException(BarcodeFormat.EAN_8,encode_src,120,120,cur_en_hints,"Illegal contents"),0)
    }
    @TestCase
    func test_Ean8_Encode_08():Unit {
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"99999999",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"88888888",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"77777777",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"66666666",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"44444444",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"33333333",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"22222222",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_8,"11111111",120,120,cur_en_hints,"Contents do not pass checksum"),0)
    }
    @TestCase
    func test_Ean8_Encode_09():Unit {
        @Assert(testNormal(BarcodeFormat.EAN_8,"2325545",120,120,cur_en_hints,cur_de_hints,"23255456"),0)
        @Assert(testNormal(BarcodeFormat.EAN_8,"9999999",120,120,cur_en_hints,cur_de_hints,"99999995"),0)
    }
}