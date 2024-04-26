// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/itf-2

@Test
public class TestQRCode4cjITFDecode02{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/itf-2/"
    @TestCase
    func test_ITF_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_08():Unit {
        var image_src=imageBase+"08.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="070429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}