// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ./EAN8

@Test
public class TestQRCode4cjEAN8Decode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="./EAN8/"
    @TestCase
    func test_EAN8_Decode_01():Unit {
        var image_src=imageBase+"Ean8.png"
        var deRe="89232323"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_EAN8_Decode_02():Unit {
        var image_src=imageBase+"Ean8-02.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException"),0)
    }
    @TestCase
    func test_EAN8_Decode_03():Unit {
        var image_src=imageBase+"Ean8-03.png"
        var deRe="12345670"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}
