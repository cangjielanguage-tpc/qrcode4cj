// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/upcean-extension-1

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
public class TestQRCode4cjUPCEAExtension01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/upcean-extension-1/"
    @TestCase
    func test_UPCE_Extension_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe="9780735200449"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCE_Extension_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe="9780884271789"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}