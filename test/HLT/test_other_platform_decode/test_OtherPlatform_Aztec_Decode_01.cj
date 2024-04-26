// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ./Aztec

@Test
public class TestQRCode4cjAztecDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="./Aztec/"
    @TestCase
    func test_Aztec_Decode_01():Unit {
        var image_src=imageBase+"AZTEC.png"
        var deRe=Array<UInt8>([102, 115, 100, 102, 115, 97, 102, 115, 100, 102, 97, 115, 100, 97, 115, 102, 100, 102, 102, 100, 102, 115, 97, 100, 102, 115, 97, 100, 102, 97, 115, 102, 97, 115, 100, 102, 115, 97, 100, 102, 115, 100, 103, 100, 115, 102, 103, 100, 50, 49, 51, 51, 50, 49, 52, 50, 52, 53, 51, 52, 54, 53, 52, 51, 54, 55, 52, 53, 195, 164, 194, 184, 194, 173, 195, 165, 194, 143, 194, 145, 195, 166, 194, 146, 194, 146, 104, 105, 195, 166, 194, 152, 194, 175, 195, 164, 194, 189, 194, 155, 195, 164, 194, 187, 194, 165, 195, 165, 194, 144, 194, 142, 83, 65, 70, 83, 68, 71, 83, 68, 71, 83, 71, 83, 68, 71, 68, 70, 71, 83, 68])
        @Assert(testDecodeNormalArray(image_src,cur_de_hints,deRe),0)
    }
}