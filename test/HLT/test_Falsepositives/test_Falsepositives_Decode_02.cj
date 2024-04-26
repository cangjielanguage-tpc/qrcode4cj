// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/falsepositives-2

@Test
public class TestQRCode4cjFalsepositivesDecode02{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/falsepositives-2/"
    @TestCase
    func test_Falsepositives_Decode_01():Unit {
        var imageSrcs=Array<String>(["01.png","02.png","03.png","04.jpg","05.png","06.png",
                                     "07.png","08.png","09.png","11.png","12.png","14.png",
                                     "15.png","16.png","18.png","19.png","21.png",
                                     "22.png","23.png","24.png","25.png"])
        var imageCur=""
        for (tmp in imageSrcs){
            imageCur=imageBase+tmp
            @Assert(testDecodeException(imageCur,cur_de_hints,"Single","NotFoundException"),0)
        }
    }
    @TestCase
    func test_Falsepositives_Decode_02():Unit {
        var image_src=imageBase+"10.png"
        var deRe="12251117"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Falsepositives_Decode_03():Unit {
        var image_src=imageBase+"13.png"
        var deRe="02371672"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Falsepositives_Decode_04():Unit {
        var image_src=imageBase+"20.png"
        var deRe="06182218"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Falsepositives_Decode_05():Unit {
        var image_src=imageBase+"17.png"
        var deRe="06117825"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}

