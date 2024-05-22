// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/falsepositives

@Test
public class TestQRCode4cjFalsepositivesDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/falsepositives/"
    @TestCase
    func test_Falsepositives_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe="1858176738383"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Falsepositives_Decode_02():Unit {
        var image_src=imageBase+"13.png"
        var deRe="03017932"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Falsepositives_Decode_03():Unit {
        var imageSrcs=Array<String>(["02.png","03.png","04.png","05.png","06.png","07.png",
                                     "08.png","09.png","10.png","11.png","12.png","14.png",
                                     "15.png","16.png","17.png","18.png","19.png","20.png",
                                     "21.png","22.png"])
        var imageCur=""
        for (tmp in imageSrcs){
            imageCur=imageBase+tmp
            @Assert(testDecodeException(imageCur,cur_de_hints,"Single","NotFoundException"),0)
        }
    }
}