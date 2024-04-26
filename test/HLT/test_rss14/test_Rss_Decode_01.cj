// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/rss14-1

@Test
public class TestQRCode4cjRSS14Decode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/rss14-1/"
    @TestCase
    func test_Rss14_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe=###"04412345678909"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe=###"00821935106427"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        var deRe=###"00075678164125"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        var deRe=###"20012345678909"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        var deRe=###"00034567890125"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Rss14_Decode_06():Unit {
        var image_src=imageBase+"6.png"
        var deRe=###"00012345678905"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}