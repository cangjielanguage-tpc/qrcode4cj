// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/pdf417-3

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
    let imageBase="../resources/blackbox/pdf417-3/"
    @TestCase
    func test_PDF417_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe="A larger PDF417 barcode with text and error correction level 4."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_08():Unit {
        var image_src=imageBase+"08.png"
        var deRe="A larger PDF417 barcode with text and error correction level 4."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe="A larger PDF417 barcode with text and error correction level 4."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="A larger PDF417 barcode with text and error correction level 4."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="A larger PDF417 barcode with text and error correction level 4."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe=###"[)>010210011840539080122327430201FDE238351251289 1/13.0LBY76 NINTH AVENUENEW YORK CITYNYSUSAN ZOLEZZI0610ZED00411ZGOOGLE12Z212565418630Z3100119200000114Z4TH FLOOR15Z39795720Z0.000.0028Z9080122327430201K533 PROGRAMS26Z584a"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="A larger PDF417 barcode with text and error correction level 8."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_PDF417_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}