// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/datamatrix-2

@Test
public class TestQRCode4cjDataMatrixDecode02{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/datamatrix-2/"
    @TestCase
    func test_DataMatrix_Decode_42():Unit {
        var image_src=imageBase+"01.png"
        var deRe="http://google.com/m"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_43():Unit {
        var image_src=imageBase+"02.png"
        var deRe="http://google.com/m"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_44():Unit {
        var image_src=imageBase+"03.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_45():Unit {
        var image_src=imageBase+"04.png"
        var deRe="http://google.com/m"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_46():Unit {
        var image_src=imageBase+"05.png"
        var deRe="http://google.com/m"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_47():Unit {
        var image_src=imageBase+"06.png"
        var deRe="http://google.com/m"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_48():Unit {
        var image_src=imageBase+"07.png"
        var deRe="http://google.com/m"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_49():Unit {
        var image_src=imageBase+"08.png"
        var deRe="http://google.com/m"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_50():Unit {
        var image_src=imageBase+"09.png"
        var deRe="This is a test of our DataMatrix support using a longer piece of text, and therefore a more dense barcode."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_51():Unit {
        var image_src=imageBase+"10.png"
        var deRe="This is a test of our DataMatrix support using a longer piece of text, and therefore a more dense barcode."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_52():Unit {
        var image_src=imageBase+"11.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_53():Unit {
        var image_src=imageBase+"12.png"
        var deRe="This is a test of our DataMatrix support using a longer piece of text, and therefore a more dense barcode."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_54():Unit {
        var image_src=imageBase+"13.png"
        var deRe="This is a test of our DataMatrix support using a longer piece of text, and therefore a more dense barcode."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_55():Unit {
        var image_src=imageBase+"14.png"
        var deRe="This is a test of our DataMatrix support using a longer piece of text, and therefore a more dense barcode."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_56():Unit {
        var image_src=imageBase+"15.png"
        var deRe="This is a test of our DataMatrix support using a longer piece of text, and therefore a more dense barcode."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_57():Unit {
        var image_src=imageBase+"16.png"
        var deRe="01211115"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_58():Unit {
        var image_src=imageBase+"17.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_59():Unit {
        var image_src=imageBase+"18.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
}