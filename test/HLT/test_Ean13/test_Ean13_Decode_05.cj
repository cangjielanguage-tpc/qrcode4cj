// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/ean13-5

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
public class TestQRCode4cjEan13Decode05{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let image_src_base="../resources/blackbox/ean13-5/"
    @TestCase
    func test_Ean13_Decode_01():Unit {
        let images=Array<String>(["01.png","02.png","03.png","04.png","05.png","06.png","07.png","08.png",
                                  "09.png","10.png","11.png","12.png","13.png","14.png","15.png","16.png",
                                  "17.png","18.png"])
        var imageCur=""
        for (tmp in images){
            imageCur=""
            imageCur=image_src_base+tmp
            @Assert(testDecodeException(imageCur,cur_de_hints,"Single","NotFoundException"),0)
        }
    }
}