// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/rss14-2

@Test
public class TestQRCode4cjRSS14Decode02{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/rss14-2/"
    @TestCase
    func test_Rss14_Decode_01():Unit {
        var image_src=imageBase+"err/1.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_06():Unit {
        var image_src=imageBase+"6.png"
        var deRe=###"02001234567893"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_07():Unit {
        var image_src=imageBase+"7.png"
        var deRe=###"02001234567893"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe=###"02001234567893"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_09():Unit {
        var image_src=imageBase+"9.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_11():Unit {
        var image_src=imageBase+"err/11.png"
        var deRe="02244358"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe=###"02001234567893"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe=###"02001234567893"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe=###"00012345678905"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Rss14_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        var deRe=###"00012345678905"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe=###"00012345678905"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}