// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/rssexpanded-1

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
    let imageBase="../resources/blackbox/rssexpanded-1/"
    @TestCase
    func test_Rssexpanded_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe="(11)100224(17)110224(3102)000100"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe="(01)90012345678908(3103)001750"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        var deRe="(10)12A"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        var deRe="(01)98898765432106(3202)012345(15)991231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        var deRe="(01)90614141000015(3202)000150"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_06():Unit {
        var image_src=imageBase+"6.png"
        var deRe="(10)567(01)90012345678908(11)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_07():Unit {
        var image_src=imageBase+"7.png"
        var deRe="(10)567(11)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe="(10)567(11)010101(13)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_09():Unit {
        var image_src=imageBase+"9.png"
        var deRe="(10)567(3102)123456"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)012345678901"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe="(01)98898765432106(3103)001750"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="(01)90012345678908(3922)795"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="(01)90012345678908(3932)0401234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="(01)90012345678908(3102)001750(11)100312"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="(01)90012345678908(3202)001750(11)100312"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="(01)90012345678908(3102)001750(13)100312"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="(01)90012345678908(3202)001750(13)100312"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="(01)90012345678908(3102)001750(15)100312"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="(01)90012345678908(3202)001750(15)100312"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        var deRe="(01)90012345678908(3102)001750(17)100312"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        var deRe="(01)90012345678908(3202)001750(17)100312"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        var deRe="(10)56789(11)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe="(10)567890(11)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_25():Unit {
        var image_src=imageBase+"25.png"
        var deRe="(10)123"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_26():Unit {
        var image_src=imageBase+"26.png"
        var deRe="(10)5678(11)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_27():Unit {
        var image_src=imageBase+"27.png"
        var deRe="(10)1098-1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_28():Unit {
        var image_src=imageBase+"28.png"
        var deRe="(10)1098/1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_29():Unit {
        var image_src=imageBase+"29.png"
        var deRe="(10)1098.1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_30():Unit {
        var image_src=imageBase+"30.png"
        var deRe="(10)1098*1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_31():Unit {
        var image_src=imageBase+"31.png"
        var deRe="(10)1098,1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_32():Unit {
        var image_src=imageBase+"32.png"
        var deRe="(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}