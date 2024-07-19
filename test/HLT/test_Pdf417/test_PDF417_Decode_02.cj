// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/pdf417-2

import QRCode4cj.aztec.decoder.*
import QRCode4cj.aztec.detector.*
import QRCode4cj.aztec.common.*
import QRCode4cj.multi.*
import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.common.writer.*
import QRCode4cj.oned.*
import std.collection.*

@Test
public class TestQRCode4cjPDF417{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/pdf417-2/"
    @TestCase
    func test_PDF417_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe="1234567890"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_08():Unit {
        var image_src=imageBase+"08.png"
        var deRe="A PDF 417 barcode with ASCII text"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe="A PDF 417 barcode with ASCII text"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="A PDF 417 barcode with ASCII text"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="A PDF 417 barcode with ASCII text"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe="A PDF 417 barcode with ASCII text"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="A PDF 417 barcode with ASCII text"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="A PDF 417 barcode with ASCII text"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="A PDF 417 barcode with ASCII text"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        var deRe="A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        var deRe="A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        var deRe="A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe=Array<UInt8>([120, 194, 156, 195, 133, 194, 153, 91, 194, 143, 194, 154, 64, 20, 194, 128, 195, 159, 55, 195, 177, 63, 76, 121, 195, 153, 194, 167, 21, 24, 46, 106, 194, 130, 108, 82, 117, 194, 141, 105, 194, 183, 195, 157, 84, 195, 155, 100, 195, 187, 54, 194, 129, 81, 73, 17, 195, 140, 194, 128, 194, 141, 195, 187, 195, 135, 195, 182, 15, 195, 180, 194, 143, 117, 194, 128, 65, 195, 173, 5, 194, 138, 103, 194, 176, 195, 186, 34, 195, 167, 12, 51, 195, 159, 194, 185, 195, 140, 195, 165, 194, 140, 58, 195, 183, 195, 187, 77, 194, 136, 194, 190, 83, 194, 150, 4, 113, 52, 84, 195, 180, 194, 174, 194, 166, 32, 26, 121, 194, 177, 31, 68, 194, 171, 194, 161, 195, 178, 121, 195, 177, 112, 195, 151, 87, 195, 174, 195, 157, 195, 142, 77, 195, 167, 195, 134, 121, 51, 195, 190, 56, 90, 60, 63, 77, 195, 144, 194, 152, 122, 33, 97, 36, 195, 165, 61, 195, 144, 195, 188, 121, 194, 190, 194, 152, 60, 194, 162, 195, 155, 19, 93, 195, 151, 79, 195, 189, 195, 155, 194, 162, 195, 139, 194, 137, 195, 150, 69, 194, 157, 27, 194, 132, 194, 156, 89, 194, 148, 82, 194, 182, 36, 30, 45, 100, 194, 174, 89, 194, 144, 195, 189, 36, 74, 194, 131, 195, 180, 195, 133, 194, 157, 79, 29, 195, 181, 40, 194, 157, 194, 180, 63, 81, 22, 195, 132, 194, 190, 194, 139, 53, 29, 195, 167, 111, 8, 194, 185, 124, 195, 163, 33, 8, 194, 169, 195, 176, 195, 128, 195, 165, 14, 56, 195, 170, 194, 169, 194, 162, 195, 128, 194, 170, 194, 191, 113, 194, 179, 81, 194, 183, 195, 164, 194, 133, 50, 195, 183, 72, 194, 153, 195, 185, 110, 195, 143, 195, 168, 195, 155, 194, 186, 110, 195, 167, 16, 46, 194, 138, 194, 182, 15, 100, 67, 195, 157, 41, 35, 194, 187, 194, 132, 50, 71, 195, 141, 194, 165, 3, 194, 153, 37, 105, 194, 148, 41, 30, 9, 195, 187, 194, 182, 75, 50, 116, 194, 169, 17, 194, 175, 194, 140, 73, 74, 93, 194, 171, 107, 119, 195, 181, 194, 129, 195, 157, 119, 195, 148, 92, 20, 77, 95, 194, 131, 195, 173, 40, 195, 182, 194, 169, 59, 48, 53, 195, 131, 81, 75, 73, 52, 194, 142, 194, 178, 24, 76, 195, 163, 195, 144, 39, 195, 158, 195, 154, 81, 115, 194, 169, 195, 176, 195, 164, 96, 121, 195, 161, 8, 31, 194, 144, 28, 195, 141, 194, 161, 194, 161, 195, 191, 194, 133, 194, 132, 59, 194, 138, 24, 93, 195, 178, 108, 106, 194, 154, 54, 80, 195, 144, 50, 83, 7, 194, 145, 79, 195, 183, 67, 194, 133, 194, 167, 119, 25, 194, 179, 13, 127, 195, 144, 195, 133, 195, 163, 194, 161, 65, 194, 140, 195, 130, 195, 135, 194, 153, 194, 167, 194, 140, 194, 167, 194, 191, 116, 25, 194, 149, 194, 190, 9, 194, 181, 194, 128, 194, 169, 71, 90, 29, 95, 194, 135, 195, 179, 15, 195, 153, 0, 194, 129, 194, 177, 194, 132, 195, 163, 101, 195, 152, 33, 96, 195, 131, 194, 188, 110, 195, 132, 194, 141, 30, 194, 156, 194, 159, 195, 141, 68, 36, 195, 165, 125, 195, 142, 56, 194, 151, 94, 194, 179, 70, 26, 82, 37, 194, 146, 195, 189, 195, 169, 195, 135, 195, 171, 38, 72, 194, 188, 195, 181, 195, 157, 59, 194, 146, 194, 174, 195, 163, 48, 123, 4, 194, 186, 46, 49, 195, 149, 195, 159, 83, 63, 88, 1, 194, 177, 38, 36, 195, 164, 111, 195, 163, 56, 194, 164, 36, 66, 195, 162, 59, 31, 114, 194, 168, 44, 73, 194, 152, 80, 5, 194, 169, 195, 167, 90, 0, 195, 177, 194, 188, 93, 11, 32, 19, 195, 160, 195, 175, 22, 194, 164, 108, 119, 194, 190, 1, 24, 52, 195, 175, 195, 155, 12, 1, 6, 77, 194, 191, 118, 45, 104, 47, 9, 48, 11, 76, 27, 194, 190, 2, 53, 12, 91, 126, 0, 98, 86, 194, 139, 194, 172, 195, 184, 1, 110, 105, 195, 153, 194, 167, 194, 168, 77, 86, 195, 135, 82, 194, 164, 9, 195, 151, 195, 174, 95, 194, 133, 194, 139, 13, 25, 127, 195, 141, 62, 194, 148, 10, 57, 82, 15, 195, 148, 194, 129, 194, 133, 194, 129, 92, 83, 38, 195, 138, 18, 92, 194, 169, 195, 172, 195, 130, 194, 185, 194, 134, 84, 118, 123, 22, 112, 82, 25, 194, 134, 194, 140, 194, 187, 194, 176, 195, 181, 194, 163, 105, 22, 100, 194, 175, 104, 195, 177, 195, 132, 194, 176, 195, 155, 195, 155, 194, 174, 97, 124, 195, 136, 102, 93, 70, 26, 3, 194, 131, 110, 75, 195, 148, 194, 166, 82, 101, 41, 104, 69, 195, 165, 117, 40, 195, 150, 194, 186, 58, 195, 174, 22, 87, 195, 143, 51, 11, 83, 92, 115, 195, 189, 41, 78, 194, 142, 11, 57, 194, 140, 107, 194, 174, 63, 13, 195, 128, 195, 153, 61, 28, 195, 132, 194, 172, 195, 154, 194, 166, 47, 195, 136, 195, 148, 194, 171, 18, 123, 195, 169, 0, 195, 171, 85, 23, 195, 171, 58, 112, 11, 51, 194, 170, 194, 178, 195, 140, 194, 171, 195, 163, 194, 182, 86, 100, 195, 161, 194, 154, 194, 187, 195, 150, 127, 51, 195, 128, 194, 184, 194, 182, 1, 194, 144, 121, 195, 158, 194, 170, 1, 195, 150, 53, 13, 48, 195, 181, 194, 170, 194, 163, 83, 195, 151, 195, 172, 127, 31, 29, 38, 194, 172, 74, 48, 43, 194, 171, 194, 132, 75, 82, 195, 173, 194, 186, 45, 195, 156, 54, 26, 194, 149, 195, 154, 80, 110, 101, 194, 146, 47, 195, 139, 194, 173, 194, 188, 195, 137, 94, 194, 154, 91, 194, 185, 194, 172, 27, 112, 37, 195, 178, 91, 194, 189, 194, 152, 26, 112, 194, 161, 80, 44, 19, 100, 9, 103, 101, 106, 62, 56, 21, 195, 139, 44, 194, 161, 70, 195, 156, 195, 188, 36, 37, 195, 162, 39, 195, 177, 195, 185, 110, 194, 187, 194, 141, 89, 195, 138, 194, 143, 195, 180, 113, 195, 172, 37, 101, 194, 151, 95, 194, 180, 104, 54, 22, 194, 187, 194, 165, 42, 195, 186, 195, 191, 195, 145, 194, 137, 15, 121, 195, 178, 195, 175, 69, 195, 182, 119, 195, 134, 79, 90, 21, 43, 194, 136])
        @Assert(testDecodeNormalArray(image_src,cur_de_hints,deRe),0)
    }
    @TestCase
    func test_PDF417_Decode_25():Unit {
        var image_src=imageBase+"25.png"
        var deRe="This is PDF417"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}