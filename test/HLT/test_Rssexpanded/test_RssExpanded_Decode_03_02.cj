// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/rssexpanded-3

@Test
public class TestQRCode4cjRssexpanded{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/rssexpanded-3/"
    @TestCase
    func test_Rssexpanded_Decode_41():Unit {
        var image_src=imageBase+"41.png"
        var deRe="(10)1098_1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_42():Unit {
        var image_src=imageBase+"42.png"
        var deRe="(10)1098 1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_43():Unit {
        var image_src=imageBase+"43.png"
        var deRe="(10)123456A"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_44():Unit {
        var image_src=imageBase+"44.png"
        var deRe="(10)123456A1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_45():Unit {
        var image_src=imageBase+"45.png"
        var deRe="(10)123456A1234A"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_46():Unit {
        var image_src=imageBase+"46.png"
        var deRe="(10)123456A123456"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_47():Unit {
        var image_src=imageBase+"47.png"
        var deRe="(10)123456A12345678"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_48():Unit {
        var image_src=imageBase+"48.png"
        var deRe="(10)1ABCDEF;:/1234567"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_49():Unit {
        var image_src=imageBase+"49.png"
        var deRe="(10)1ABCDEF;:/ABCDEFG"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_50():Unit {
        var image_src=imageBase+"50.png"
        var deRe="(10)1;:/ABCDEFGHIJKLM"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_51():Unit {
        var image_src=imageBase+"51.png"
        var deRe="(10)1;:/0123456789012"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_52():Unit {
        var image_src=imageBase+"52.png"
        var deRe="(10)1;:/0123"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_53():Unit {
        var image_src=imageBase+"53.png"
        var deRe="(10)1;:/0123(15)991231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_54():Unit {
        var image_src=imageBase+"54.png"
        var deRe="(01)90012345678908(3103)012233(15)991231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_55():Unit {
        var image_src=imageBase+"55.png"
        var deRe="(01)91234567980129(3103)012233(15)991231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_56():Unit {
        var image_src=imageBase+"56.png"
        var deRe="(01)91234567980129(3102)012233(15)991231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_57():Unit {
        var image_src=imageBase+"57.png"
        var deRe="(01)91234567980129(3102)012233(15)000101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_58():Unit {
        var image_src=imageBase+"58.png"
        var deRe="(01)90012345678908(3103)001750"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_59():Unit {
        var image_src=imageBase+"59.png"
        var deRe="(01)92109876543213(3103)032767"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_60():Unit {
        var image_src=imageBase+"60.png"
        var deRe="(01)92109876543213(3103)000000"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_61():Unit {
        var image_src=imageBase+"61.png"
        var deRe="(01)90012345678908(3202)000156"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_62():Unit {
        var image_src=imageBase+"62.png"
        var deRe="(01)90012345678908(3202)009999"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_63():Unit {
        var image_src=imageBase+"63.png"
        var deRe="(01)90012345678908(3203)010000"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_64():Unit {
        var image_src=imageBase+"64.png"
        var deRe="(01)90012345678908(3203)032767"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_65():Unit {
        var image_src=imageBase+"65.png"
        var deRe="(01)90012345678908(3922)795"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_66():Unit {
        var image_src=imageBase+"66.png"
        var deRe="(01)90012345678908(3922)795888888888888888888888888888888888888888888888888888"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_67():Unit {
        var image_src=imageBase+"67.png"
        var deRe="(01)90012345678908(3932)0401234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_68():Unit {
        var image_src=imageBase+"68.png"
        var deRe="(01)90012345678908(3932)040EUR"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_69():Unit {
        var image_src=imageBase+"69.png"
        var deRe="(01)90012345678908(3932)04055GBP"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_70():Unit {
        var image_src=imageBase+"70.png"
        var deRe="(01)90012345678908(3932)04066USD778899"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_71():Unit {
        var image_src=imageBase+"71.png"
        var deRe="(01)00012345678905(10)ABC123"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_72():Unit {
        var image_src=imageBase+"72.png"
        var deRe="(01)12345678901231(10)UNIVERSITY-OF-DEUSTO"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_73():Unit {
        var image_src=imageBase+"73.png"
        var deRe="(01)12345678901231(10)PIRAMIDE-PROJECT"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_74():Unit {
        var image_src=imageBase+"74.png"
        var deRe="(01)12345678901231(10)TREELOGIC"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_75():Unit {
        var image_src=imageBase+"75.png"
        var deRe="(01)98898765432106(15)991231(3103)001750(10)12A(422)123(21)123456(423)012345678901"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_76():Unit {
        var image_src=imageBase+"76.png"
        var deRe="(15)991231(3103)001750(10)12A(422)123(21)123456(423)0123456789012"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_77():Unit {
        var image_src=imageBase+"77.png"
        var deRe="(10)5678(11)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_78():Unit {
        var image_src=imageBase+"78.png"
        var deRe="(10)5678(11)001010"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_79():Unit {
        var image_src=imageBase+"79.png"
        var deRe="(10)567890(11)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_80():Unit {
        var image_src=imageBase+"80.png"
        var deRe="(10)567(11)010101"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}