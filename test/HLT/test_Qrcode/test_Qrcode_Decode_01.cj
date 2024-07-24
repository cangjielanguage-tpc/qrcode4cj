// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/qrcode-1

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
public class TestQRCode4cjQrcodeDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/qrcode-1/"
    @TestCase
    func test_Qrcode_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_06():Unit {
        var image_src=imageBase+"6.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_07():Unit {
        var image_src=imageBase+"7.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_09():Unit {
        var image_src=imageBase+"9.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe=###"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe=###"http://google.com/gwt/n?u=bluenile.com"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="""
Sean Owen\r
srowen@google.com\r
917-364-2918\r
http://awesome-thoughts.com"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="""
Sean Owen\r
srowen@google.com\r
917-364-2918\r
http://awesome-thoughts.com"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="""
Sean Owen\r
srowen@google.com\r
917-364-2918\r
http://awesome-thoughts.com"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="""
Sean Owen\r
srowen@google.com\r
917-364-2918\r
http://awesome-thoughts.com"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}