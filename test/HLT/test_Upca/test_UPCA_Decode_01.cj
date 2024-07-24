// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/upca-1

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
    let imageBase="../resources/blackbox/upca-1/"
    @TestCase
    func test_UPCA_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_UPCA_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe="036602301467"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        var deRe="070097025088"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        var deRe="070097026788"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        var deRe="070097025088"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe="071831007995"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_09():Unit {
        var image_src=imageBase+"9.png"
        var deRe="071831007995"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="027011006951"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="027011006951"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe="781735802045"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="781735802045"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="456314319671"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="434704791429"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="024543136538"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="024543136538"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_UPCA_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        var deRe="752919460009"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_27():Unit {
        var image_src=imageBase+"27.png"
        var deRe="606949762520"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_28():Unit {
        var image_src=imageBase+"28.png"
        var deRe="061869053712"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_29():Unit {
        var image_src=imageBase+"29.png"
        var deRe="619659023935"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_UPCA_Decode_35():Unit {
        var image_src=imageBase+"35.png"
        var deRe="045496442736"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}