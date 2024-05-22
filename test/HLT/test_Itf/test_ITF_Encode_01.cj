// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj


@Test
public class TestQRCode4cjITFEncode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_ITF_Encode_01():Unit {
        var encode_src_legal=Array<String>([ "555555","77777777","9999999999","0000000000000000","0123456789"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.ITF,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_ITF_Encode_02():Unit {
        var encode_src_legal=Array<String>([ "0","222","44444","6666666","888888888"])
        for (encode_src in encode_src_legal){
            @Assert(testEncodeException(BarcodeFormat.ITF,encode_src,120,120,cur_en_hints,"The length of the input should be even number"),0)
        }
    }
    @TestCase
    func test_ITF_Encode_03():Unit {
        var encode_src_legal=Array<String>([ "00","2222","9999"])
        for (encode_src in encode_src_legal){
            @Assert(testEncodeDecodeException(BarcodeFormat.ITF,encode_src,120,120,cur_en_hints,cur_de_hints,"NotFoundException"),0)
        }
    }
    @TestCase
    func test_ITF_Encode_04():Unit {
        @Assert(testEncodeException(BarcodeFormat.ITF,"",120,120,cur_en_hints,"Found empty contents"),0)
    }
    @TestCase
    func test_ITF_Encode_05():Unit {
        var encode_src_legal=Array<String>([ "abbbbb","ABBBBB","中国中国中国","^@^&*%%$"])
        for (encode_src in encode_src_legal){
            @Assert(testEncodeException(BarcodeFormat.ITF,encode_src,120,120,cur_en_hints,"Input should only contain digits 0-9"),0)
        }
    }
}