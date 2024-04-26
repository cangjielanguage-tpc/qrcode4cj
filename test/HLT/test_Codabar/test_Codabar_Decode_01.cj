// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/codabar-1

@Test
public class TestQRCode4cjCodabarDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/codabar-1/"
    @TestCase
    func test_Codabar_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe="294/586"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        var deRe="123455"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe="12345"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="123456"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="3419500"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe="31117013206375"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="12345"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="31117013206375"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Codabar_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="123456789012"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}