// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ./code128

@Test
public class TestQRCode4cjCode128Decode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="./code128/"
    @TestCase
    func test_Code128_Decode_01():Unit {
        var image_src=imageBase+"code128-A.png"
        var deRe="QWERTYUIOPLKJHGFDSAZXCVBNM"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_02():Unit {
        var image_src=imageBase+"code128-A-02.png"
        var deRe="QWERTYUIOPLKJHGFDSAZXCVBNM1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_03():Unit {
        var image_src=imageBase+"code128-B.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Code128_Decode_04():Unit {
        var image_src=imageBase+"code128-C.png"
        var deRe="12"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_05():Unit {
        var image_src=imageBase+"code128-C-02.png"
        var deRe="12657575675676765756757676767676234424235621432432536344"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}
