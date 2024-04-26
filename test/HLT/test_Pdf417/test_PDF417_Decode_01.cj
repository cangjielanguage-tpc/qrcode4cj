// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/pdf417-1

@Test
public class TestQRCode4cjPDF417{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/pdf417-1/"
    @TestCase
    func test_PDF417_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe="This is PDF417"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe="12345678"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe="ActiveBarcode"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        var deRe="-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe="-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe="-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe="-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe=Array<UInt8>([33, 194, 130, 194, 159, 9, 33, 26, 69, 195, 180, 9, 53, 47, 68, 63, 9, 63, 194, 154, 70, 90, 9, 99, 39, 194, 130, 195, 191, 9, 109, 21, 65, 195, 137, 9, 194, 160, 35, 70])
        @Assert(testDecodeNormalArray(image_src,cur_de_hints,deRe),0)
    }
    @TestCase
    func test_PDF417_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="PDF-417"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="This is just a test."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}