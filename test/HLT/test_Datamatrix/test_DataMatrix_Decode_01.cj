// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/datamatrix-1

@Test
public class TestQRCode4cjDataMatrixDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/datamatrix-1/"
    @TestCase
    func test_DataMatrix_Decode_01():Unit {
        var image_src=imageBase+"0123456789.png"
        var deRe="0123456789"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_02():Unit {
        var image_src=imageBase+"abcd-18x8.png"
        var deRe="abcde"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_03():Unit {
        var image_src=imageBase+"abcd-26x12.png"
        var deRe="abcdefghijklm"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_04():Unit {
        var image_src=imageBase+"abcd-32x8.png"
        var deRe="abcdef"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_05():Unit {
        var image_src=imageBase+"abcd-36x12.png"
        var deRe="abcdefghijklmnopq"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_06():Unit {
        var image_src=imageBase+"abcd-36x16.png"
        var deRe="abcdefghijklmnopqrstuvwxyz"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_07():Unit {
        var image_src=imageBase+"abcd-48x16.png"
        var deRe="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_08():Unit {
        var image_src=imageBase+"abcd-52x52.png"
        var deRe="abcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcd"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_09():Unit {
        var image_src=imageBase+"abcd-52x52-IDAutomation.png"
        var deRe="abcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcd"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_10():Unit {
        var image_src=imageBase+"abcdefg.png"
        var deRe=###"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(),./\"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_11():Unit {
        var image_src=imageBase+"abcdefg-64x64.png"
        var deRe=###"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(),./\abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(),./\abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(),./\"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_13():Unit {
        var image_src=imageBase+"C40.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_14():Unit {
        var image_src=imageBase+"EDIFACT.jpg"
        var deRe="EDIFACTEDIFACT"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_15():Unit {
        var image_src=imageBase+"GUID.png"
        var deRe="10f27ce-acb7-4e4e-a7ae-a0b98da6ed4a"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_16():Unit {
        var image_src=imageBase+"HelloWorld_Text_L_Kaywa.png"
        var deRe="Hello World"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_17():Unit {
        var image_src=imageBase+"HelloWorld_Text_L_Kaywa_1_error_byte.png"
        var deRe="Hello World"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_18():Unit {
        var image_src=imageBase+"HelloWorld_Text_L_Kaywa_2_error_byte.png"
        var deRe="Hello World"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_19():Unit {
        var image_src=imageBase+"HelloWorld_Text_L_Kaywa_3_error_byte.png"
        var deRe="Hello World"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_20():Unit {
        var image_src=imageBase+"HelloWorld_Text_L_Kaywa_4_error_byte.png"
        var deRe="Hello World"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_22():Unit {
        var image_src=imageBase+"X12.jpg"//对标库可解
        var deRe="X12X12X12X12"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_23():Unit {
        var image_src=imageBase+"zxing_URL_L_Kayway.png"
        var deRe="http://code.google.com/p/zxing/"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}