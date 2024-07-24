// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/ean13-3

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
public class TestQRCode4cjEan13Decode03{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/ean13-3/"
    @TestCase
    func test_Ean13_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_08():Unit {
        var image_src=imageBase+"08.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe="9780764544200"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_11():Unit {
        var image_src=imageBase+"10.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        var deRe="9780596008574"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_25():Unit {
        var image_src=imageBase+"25.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_26():Unit {
        var image_src=imageBase+"26.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_27():Unit {
        var image_src=imageBase+"27.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_28():Unit {
        var image_src=imageBase+"28.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_29():Unit {
        var image_src=imageBase+"29.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_30():Unit {
        var image_src=imageBase+"30.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_31():Unit {
        var image_src=imageBase+"31.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_32():Unit {
        var image_src=imageBase+"32.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_33():Unit {
        var image_src=imageBase+"33.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_34():Unit {
        var image_src=imageBase+"34.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_35():Unit {
        var image_src=imageBase+"35.png"
        var deRe="9780201310054"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_36():Unit {
        var image_src=imageBase+"36.png"
        var deRe="9781585730575"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_37():Unit {
        var image_src=imageBase+"37.png"
        var deRe="9781585730575"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_38():Unit {
        var image_src=imageBase+"38.png"
        var deRe="9781585730575"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_39():Unit {
        var image_src=imageBase+"39.png"
        var deRe="9781585730575"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_40():Unit {
        var image_src=imageBase+"40.png"
        var deRe="9781585730575"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_41():Unit {
        var image_src=imageBase+"41.png"
        var deRe="9781585730575"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_42():Unit {
        var image_src=imageBase+"42.png"
        var deRe="9781585730575"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_43():Unit {
        var image_src=imageBase+"43.png"
        var deRe="9781585730575"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_44():Unit {
        var image_src=imageBase+"44.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_45():Unit {
        var image_src=imageBase+"45.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_46():Unit {
        var image_src=imageBase+"46.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_47():Unit {
        var image_src=imageBase+"47.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_48():Unit {
        var image_src=imageBase+"48.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_49():Unit {
        var image_src=imageBase+"49.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_50():Unit {
        var image_src=imageBase+"50.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_51():Unit {
        var image_src=imageBase+"51.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_52():Unit {
        var image_src=imageBase+"52.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_53():Unit {
        var image_src=imageBase+"53.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_54():Unit {
        var image_src=imageBase+"54.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_55():Unit {
        var image_src=imageBase+"55.png"
        var deRe="9780735619937"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}