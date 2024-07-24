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
public class TestQRCode4cjAztecEncode02{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_Aztec_Encode_01():Unit {
        var encode_src="$%^%$^*(*(*"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_02():Unit {
        var encode_src="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        while(encode_src.size<3067){
            encode_src+=encode_src
        }
        encode_src=encode_src[0..2846]
        @Assert(testEncodeException(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,"Data too large for an Aztec code"),0)
    }
    @TestCase
    func test_Aztec_Encode_03():Unit {
        var encode_src="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        while(encode_src.size<3067){
            encode_src+=encode_src
        }
        encode_src=encode_src[0..2847]
        @Assert(testEncodeException(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,"Data too large for an Aztec code"),0)
    }
    @TestCase
    func test_Aztec_Encode_04():Unit {
        var encode_src="0123456789"
        while(encode_src.size<3832){
            encode_src+=encode_src
        }
        encode_src=encode_src[0..3748]
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_05():Unit {
        var encode_src="0123456789"
        while(encode_src.size<3832){
            encode_src+=encode_src
        }
        encode_src=encode_src[0..3749]
        @Assert(testEncodeException(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,"Data too large for an Aztec code"),0)
    }
}

