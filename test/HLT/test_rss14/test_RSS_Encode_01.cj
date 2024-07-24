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
public class TestQRCode4cjRSS01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    @TestCase
    func test_RSS_Encode_01():Unit {
        var encode_src="9780735200449"
        var flag=1
        try{
            testNormal(BarcodeFormat.RSS_14,encode_src,141,162,cur_en_hints,cur_de_hints,encode_src)
        }catch(e:IllegalArgumentException){
            if(e.toString().contains("No encoder available for format RSS_14")) {
                flag=0
            }
        }
        @Assert(flag,0)
    }
}