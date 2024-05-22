// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

@Test
public class TestQRCode4cjRSSEXPANDED01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    @TestCase
    func test_RSSEXPANDED_Encode_01():Unit {
        var encode_src="9780735200449"
        var flag=1
        try{
            testNormal(BarcodeFormat.RSS_EXPANDED,encode_src,141,162,cur_en_hints,cur_de_hints,encode_src)
        }catch(e:IllegalArgumentException){
            if(e.toString().contains("No encoder available for format RSS_EXPANDED")) {
                flag=0
            }
        }
        @Assert(flag,0)
    }
}