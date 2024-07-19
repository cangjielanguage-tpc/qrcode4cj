// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/maxicode-1

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
public class TestQRCode4cjMaxiCode{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/maxicode-1/"
    @TestCase
    func test_MaxiCode_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe=String.fromUtf8(Array<UInt8>([13]))+"ABCDEFGHIJKLMNOPQRSTUVWXYZ"+String.fromUtf8(Array<UInt8>([28,29,30]))+##" "#$%&'()*+,-./01234:56789"##
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_MaxiCode_Decode_02():Unit {
        var image_src=imageBase+"MODE2.png"
        var deRe="[)>"+String.fromUtf8(Array<UInt8>([30]))+"01"+String.fromUtf8(Array<UInt8>([29]))+"96123450000"+String.fromUtf8(Array<UInt8>([29]))+"222"+String.fromUtf8(Array<UInt8>([29]))+"111"+String.fromUtf8(Array<UInt8>([29]))+"MODE2"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_MaxiCode_Decode_03():Unit {
        var image_src=imageBase+"MODE3.png"
        var deRe="[)>"+String.fromUtf8(Array<UInt8>([30]))+"01"+String.fromUtf8(Array<UInt8>([29]))+"96123450000"+String.fromUtf8(Array<UInt8>([29]))+"222"+String.fromUtf8(Array<UInt8>([29]))+"111"+String.fromUtf8(Array<UInt8>([29]))+"MODE3"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_MaxiCode_Decode_04():Unit {
        var image_src=imageBase+"MODE4.png"
        var deRe="[)>"+String.fromUtf8(Array<UInt8>([30]))+"01"+String.fromUtf8(Array<UInt8>([29]))+"96123450000"+String.fromUtf8(Array<UInt8>([29]))+"222"+String.fromUtf8(Array<UInt8>([29]))+"111"+String.fromUtf8(Array<UInt8>([29]))+"MODE4"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_MaxiCode_Decode_05():Unit {
        var image_src=imageBase+"mode4-mixed-sets.png"
        var deRe="ABCDE12abcde1ÀÁÂÃ¢£¤¥1àáâãabcde123A123456789àáâã¢£¤¥abcdÚÛÜÝ123456789¾"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_MaxiCode_Decode_06():Unit {
        var image_src=imageBase+"MODE5.png"
        var deRe="[)>"+String.fromUtf8(Array<UInt8>([30]))+"01"+String.fromUtf8(Array<UInt8>([29]))+"96123450000"+String.fromUtf8(Array<UInt8>([29]))+"222"+String.fromUtf8(Array<UInt8>([29]))+"111"+String.fromUtf8(Array<UInt8>([29]))+"MODE5"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_MaxiCode_Decode_07():Unit {
        var image_src=imageBase+"MODE6.png"
        var deRe="[)>"+String.fromUtf8(Array<UInt8>([30]))+"01"+String.fromUtf8(Array<UInt8>([29]))+"96123450000"+String.fromUtf8(Array<UInt8>([29]))+"222"+String.fromUtf8(Array<UInt8>([29]))+"111"+String.fromUtf8(Array<UInt8>([29]))+"MODE6"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}