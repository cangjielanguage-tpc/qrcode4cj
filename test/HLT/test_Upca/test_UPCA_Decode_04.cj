// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/upca-4

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
public class TestQRCode4cjUPCA01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/upca-4/"

    @TestCase
    func test_UPCA_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_UPCA_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_UPCA_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_UPCA_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_UPCA_Decode_07():Unit {
        var image_src=imageBase+"7.png"
        var deRe="023942431015"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe="060410049235"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_09():Unit {
        var image_src=imageBase+"9.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_UPCA_Decode_10():Unit {
        var image_src=imageBase+"10.jpg"
        var deRe="9000771010995"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="059290522143"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_12():Unit {
        var image_src=imageBase+"12.jpg"
        var deRe="057961000228"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="059290522143"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="066721017185"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="059290571110"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="067932000263"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="069000061015"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="071691155775"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="807648011401"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}
