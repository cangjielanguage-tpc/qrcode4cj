// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/ean8-1

@Test
public class TestQRCode4cjEan8{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/ean8-1/"
    @TestCase
    func test_Ean8_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe="48512343"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean8_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe="12345670"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean8_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        var deRe="12345670"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean8_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        var deRe="67678983"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean8_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        var deRe="80674313"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean8_Decode_06():Unit {
        var image_src=imageBase+"6.png"
        var deRe="59001270"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean8_Decode_07():Unit {
        var image_src=imageBase+"7.png"
        var deRe="50487066"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean8_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe="55123457"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}