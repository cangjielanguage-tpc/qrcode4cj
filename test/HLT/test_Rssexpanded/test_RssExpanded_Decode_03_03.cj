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
    func test_Rssexpanded_Decode_81():Unit {
        var image_src=imageBase+"81.png"
        var deRe="(10)1098-1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_82():Unit {
        var image_src=imageBase+"82.png"
        var deRe="(10)1098,1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_83():Unit {
        var image_src=imageBase+"83.png"
        var deRe="(10)1098/1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_84():Unit {
        var image_src=imageBase+"84.png"
        var deRe="(10)1098.1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_85():Unit {
        var image_src=imageBase+"85.png"
        var deRe="(10)1098*1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_86():Unit {
        var image_src=imageBase+"86.png"
        var deRe="(10)1098a1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_87():Unit {
        var image_src=imageBase+"87.png"
        var deRe="(10)1098!1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_88():Unit {
        var image_src=imageBase+"88.png"
        var deRe="(10)1098\"1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_89():Unit {
        var image_src=imageBase+"89.png"
        var deRe="(10)1098%1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_90():Unit {
        var image_src=imageBase+"90.png"
        var deRe="(10)1098&1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_91():Unit {
        var image_src=imageBase+"91.png"
        var deRe="(10)1098'1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_92():Unit {
        var image_src=imageBase+"92.png"
        var deRe="(10)1098+1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_93():Unit {
        var image_src=imageBase+"93.png"
        var deRe="(10)1098:1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_94():Unit {
        var image_src=imageBase+"94.png"
        var deRe="(10)1098;1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_95():Unit {
        var image_src=imageBase+"95.png"
        var deRe="(10)1098<1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_96():Unit {
        var image_src=imageBase+"96.png"
        var deRe="(10)1098=1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_97():Unit {
        var image_src=imageBase+"97.png"
        var deRe="(10)1098>1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_98():Unit {
        var image_src=imageBase+"98.png"
        var deRe="(10)1098?1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_99():Unit {
        var image_src=imageBase+"99.png"
        var deRe="(10)1098_1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_100():Unit {
        var image_src=imageBase+"100.png"
        var deRe="(10)1098 1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_101():Unit {
        var image_src=imageBase+"101.png"
        var deRe="(10)123456A"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_102():Unit {
        var image_src=imageBase+"102.png"
        var deRe="(10)123456A1"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_103():Unit {
        var image_src=imageBase+"103.png"
        var deRe="(10)123456A123"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_104():Unit {
        var image_src=imageBase+"104.png"
        var deRe="(10)123456A1234"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_105():Unit {
        var image_src=imageBase+"105.png"
        var deRe="(10)123456A1234A"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_106():Unit {
        var image_src=imageBase+"106.png"
        var deRe="(10)123456A123456"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_107():Unit {
        var image_src=imageBase+"107.png"
        var deRe="(10)123456A12345678"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_108():Unit {
        var image_src=imageBase+"108.png"
        var deRe="(10)123456A1234A(15)991231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_109():Unit {
        var image_src=imageBase+"109.png"
        var deRe="(10)1ABCDEF;:/1234567"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_110():Unit {
        var image_src=imageBase+"110.png"
        var deRe="(10)1ABCDEF;:/ABCDEFG"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_111():Unit {
        var image_src=imageBase+"111.png"
        var deRe="(10)1;:/ABCDEFGHIJKLM"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_112():Unit {
        var image_src=imageBase+"112.png"
        var deRe="(10)1;:/0123456789012"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_113():Unit {
        var image_src=imageBase+"113.png"
        var deRe="(10)1;:/0123"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_114():Unit {
        var image_src=imageBase+"114.png"
        var deRe="(10)1;:/0123(15)991231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_115():Unit {
        var image_src=imageBase+"115.png"
        var deRe="(10)1"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_116():Unit {
        var image_src=imageBase+"116.png"
        var deRe="(10)12A"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rssexpanded_Decode_117():Unit {
        var image_src=imageBase+"117.png"
        var deRe="(10)123"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}