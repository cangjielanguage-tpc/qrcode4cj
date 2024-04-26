// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ./DataMatrix

@Test
public class TestQRCode4cjDataMatrixDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="./DataMatrix/"
    @TestCase
    func test_DataMatrix_Decode_01():Unit {
        var image_src=imageBase+"DataMatrix.png"
        var deRe=Array<UInt8>([71, 83, 68, 70, 71, 83, 68, 72, 71, 72, 68, 70, 74, 72, 70, 71, 75, 72, 76, 73, 80, 59, 80, 79, 102, 100, 103, 100, 102, 104, 103, 102, 106, 104, 117, 121, 107, 117, 105, 111, 59, 105, 111, 195, 164, 194, 184, 194, 173, 195, 166, 194, 160, 194, 135, 195, 164, 194, 186, 194, 186, 51, 50, 52, 50, 51, 53, 50, 51, 53, 50, 51, 52, 53])
        @Assert(testDecodeNormalArray(image_src,cur_de_hints,deRe),0)
    }
}
