// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/multi-1
// data_file: ../resources/blackbox/multi-qrcode-1

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
public class TestQRCode4cjMultiCode{
    var cur_de_hints=HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)])
    @TestCase
    func test_MultiCode_Decode_01():Unit {
        var image_src="../resources/blackbox/multi-1/1.png"
        var re=decodeMulti(image_src,cur_de_hints)
        @Assert(re[1].toString(),"031415926531")
        @Assert(re[1].getBarcodeFormat(),BarcodeFormat.UPC_A)
        @Assert(re[0].toString(),"www.airtable.com/jobs")
        @Assert(re[0].getBarcodeFormat(),BarcodeFormat.QR_CODE)
    }
    @TestCase
    func test_MultiCode_Decode_02():Unit {
        var image_src="../resources/blackbox/multi-qrcode-1/1.png"
        var re=decodeMulti(image_src,cur_de_hints)
        @Assert(re[0].getBarcodeFormat(),BarcodeFormat.QR_CODE)
        @Assert(re[1].getBarcodeFormat(),BarcodeFormat.QR_CODE)
        @Assert(re[2].getBarcodeFormat(),BarcodeFormat.QR_CODE)
        @Assert(re[3].getBarcodeFormat(),BarcodeFormat.QR_CODE)
        @Assert(re[0].toString(),"You get to SIT AT MRS. SIGMON'S DESK FOR A DAY!!  Awesome!!  Way to go!! Guess I better clean up! :)")
        @Assert(re[1].toString(),"You earned the class 5 EXTRA MINUTES OF RECESS!!  Fabulous!!  Way to go!!")
        @Assert(re[2].toString(),"You earned the class a 5 MINUTE DANCE PARTY!!  Awesome!  Way to go!  Let's boogie!")
        @Assert(re[3].toString(),"You get to CREATE OUR JOURNAL PROMPT FOR THE DAY!  Yay!  Way to go!  ")

    }
}