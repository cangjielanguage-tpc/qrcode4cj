// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/rssexpandedstacked-2

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
public class TestQRCode4cjRssexpanded{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/rssexpandedstacked-2/"
    @TestCase
    func test_RssexpandedStacked_Decode_65():Unit {
        var image_src=imageBase+"1.png"
        var deRe="(8110)10014141012345290110100"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_RssexpandedStacked_Decode_66():Unit {
        var image_src=imageBase+"13.png"
        var deRe="(01)90012345678908(3922)795888888888888888888888888888888888888888888888888888"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_RssexpandedStacked_Decode_67():Unit {
        var image_src=imageBase+"19.png"
        var deRe="(01)12345678901231(10)UNIVERSITY-OF-DEUSTO"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_RssexpandedStacked_Decode_68():Unit {
        var image_src=imageBase+"20.png"
        var deRe="(01)12345678901231(10)PIRAMIDE-PROJECT"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_RssexpandedStacked_Decode_69():Unit {
        var image_src=imageBase+"22.png"
        var deRe="(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)012345678901"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_RssexpandedStacked_Decode_70():Unit {
        var image_src=imageBase+"23.png"
        var deRe="(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_RssexpandedStacked_Decode_71():Unit {
        var image_src=imageBase+"1000.png"
        var deRe="(01)98898765432106(3202)012345(15)991231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}