// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/itf-1

@Test
public class TestQRCode4cjITFDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/itf-1/"
    @TestCase
    func test_ITF_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe="30712345000010"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe="00012345678905"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        var deRe="0053611912"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        var deRe="0829220875"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_06():Unit {
        var image_src=imageBase+"6.png"
        var deRe="0829220874"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_07():Unit {
        var image_src=imageBase+"7.png"
        var deRe="0817605453"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe="0829220874"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_09():Unit {
        var image_src=imageBase+"9.png"
        var deRe="0053611912"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="0053611912"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="0829220875"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="0829220875"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="0829220875"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="0829220874"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_ITF_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="3018108390"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}