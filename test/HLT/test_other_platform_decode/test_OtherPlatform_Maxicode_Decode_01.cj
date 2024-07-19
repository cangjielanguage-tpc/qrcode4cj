// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ./MaxiCode

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
public class TestQRCode4cjMaxiCodeDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="./MaxiCode/"
    @TestCase
    func test_MaxiCode_Decode_01():Unit {
        var image_src=imageBase+"maxicode.png"
        var deRe="82802"+String.fromUtf8(Array<UInt8>([29]))+"840"+String.fromUtf8(Array<UInt8>([29]))+"291"+
                                            String.fromUtf8(Array<UInt8>([29]))+"UPSN"+String.fromUtf8(Array<UInt8>([29]))+"06X610"+
                                            String.fromUtf8(Array<UInt8>([29]))+"159"+String.fromUtf8(Array<UInt8>([29]))+"1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}
