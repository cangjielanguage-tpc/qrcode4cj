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
public class TestQRCode4cjEan13Encode02{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_Ean13_Encode_01():Unit {
        var encode_src_legal=Array<String>(["8888888888888","6666666666666","4444444444444","2222222222222","1234567890142"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.EAN_13,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
        @Assert(testNormal(BarcodeFormat.EAN_13,"0000000000000",120,120,cur_en_hints,cur_de_hints,"000000000000"),0)
    }
    @TestCase
    func test_Ean13_Encode_02():Unit {
        @Assert(testNormal(BarcodeFormat.EAN_13,"232554543456",120,120,cur_en_hints,cur_de_hints,"2325545434560"),0)
        @Assert(testNormal(BarcodeFormat.EAN_13,"999999999999",120,120,cur_en_hints,cur_de_hints,"9999999999994"),0)
    }
    @TestCase
    func test_Ean13_Encode_03():Unit {
        var encode_src_illegal=Array<String>(["43",
                                              "12345678901234",
                                              "12345678901"])
        for (encode_src in encode_src_illegal){
            @Assert(testEncodeException(BarcodeFormat.EAN_13,encode_src,120,120,cur_en_hints,"Requested contents should be 12 or 13 digits long, but got"),0)
        }
    }
    @TestCase
    func test_Ean13_Encode_04():Unit {
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"",120,120,cur_en_hints,"Found empty contents"),0)
    }
    @TestCase
    func test_Ean13_Encode_05():Unit {
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"abcdefghabcde",120,120,cur_en_hints,"Illegal contents"),0)
    }
    @TestCase
    func test_Ean13_Encode_06():Unit {
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"ABCDEFGHIJKLM",120,120,cur_en_hints,"Illegal contents"),0)
    }
    @TestCase
    func test_Ean13_Encode_07():Unit {
        let encode_src=##"#$%&' !"#$%&'"##
        @Assert(testEncodeException(BarcodeFormat.EAN_13,encode_src,120,120,cur_en_hints,"Illegal contents"),0)
    }
    @TestCase
    func test_Ean13_Encode_08():Unit {
        let encode_src="中中中中中中中中中中中中中"
        @Assert(testEncodeException(BarcodeFormat.EAN_13,encode_src,120,120,cur_en_hints,"Illegal contents"),0)
    }
    @TestCase
    func test_Ean13_Encode_09():Unit {
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"9999999999999",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"7777777777777",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"3333333333333",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"1111111111111",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"3243543345542",120,120,cur_en_hints,"Contents do not pass checksum"),0)
        @Assert(testEncodeException(BarcodeFormat.EAN_13,"5555555555555",120,120,cur_en_hints,"Contents do not pass checksum"),0)
    }

}