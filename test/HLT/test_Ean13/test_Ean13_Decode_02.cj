// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/ean13-2

@Test
public class TestQRCode4cjEan13Decode02{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/ean13-2/"
    @TestCase
    func test_Ean13_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe="9780804816632"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe="9780804816632"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe="9780804816632"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe="9780804816632"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_08():Unit {
        var image_src=imageBase+"08.png"
        var deRe="9780345348036"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe="9780345348036"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        var deRe="1920081045006"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe="1920081045006"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_25():Unit {
        var image_src=imageBase+"25.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_26():Unit {
        var image_src=imageBase+"26.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_27():Unit {
        var image_src=imageBase+"27.png"
        var deRe="9784872348880"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_28():Unit {
        var image_src=imageBase+"28.png"
        var deRe="1920081045006"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}