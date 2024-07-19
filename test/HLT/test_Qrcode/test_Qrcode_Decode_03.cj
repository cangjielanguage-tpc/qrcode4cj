// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/qrcode-3

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
public class TestQRCode4cjQrcodeDecode03{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/qrcode-3/"
    @TestCase
    func test_Qrcode_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe=###"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe=###"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe=###"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe=###"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe=###"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe=###"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_08():Unit {
        var image_src=imageBase+"08.png"
        var deRe=###"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe=###"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe=###"MECARD:N:Google 411,;TEL:18665881077;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe=###"MECARD:N:Google 411,;TEL:18665881077;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe=###"MECARD:N:Google 411,;TEL:18665881077;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe=###"MECARD:N:Google 411,;TEL:18665881077;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe=###"MECARD:N:Google 411,;TEL:18665881077;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe=###"MECARD:N:Google 411,;TEL:18665881077;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe=###"MECARD:N:Google 411,;TEL:18665881077;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe=###"MECARD:N:Google 411,;TEL:18665881077;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="""
UI office hours signup\r
http://www.corp.google.com/sparrow/ui_office_hours/ \r
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="""
UI office hours signup\r
http://www.corp.google.com/sparrow/ui_office_hours/ \r
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="""
UI office hours signup\r
http://www.corp.google.com/sparrow/ui_office_hours/ \r
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe="""
UI office hours signup\r
http://www.corp.google.com/sparrow/ui_office_hours/ \r
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_25():Unit {
        var image_src=imageBase+"25.png"
        var deRe="""
UI office hours signup\r
http://www.corp.google.com/sparrow/ui_office_hours/ \r
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_26():Unit {
        var image_src=imageBase+"26.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_27():Unit {
        var image_src=imageBase+"27.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_28():Unit {
        var image_src=imageBase+"28.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_29():Unit {
        var image_src=imageBase+"29.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_30():Unit {
        var image_src=imageBase+"30.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_31():Unit {
        var image_src=imageBase+"31.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_32():Unit {
        var image_src=imageBase+"32.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_33():Unit {
        var image_src=imageBase+"33.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_34():Unit {
        var image_src=imageBase+"34.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_35():Unit {
        var image_src=imageBase+"35.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_36():Unit {
        var image_src=imageBase+"36.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_37():Unit {
        var image_src=imageBase+"33.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_38():Unit {
        var image_src=imageBase+"34.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_39():Unit {
        var image_src=imageBase+"35.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_40():Unit {
        var image_src=imageBase+"36.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_41():Unit {
        var image_src=imageBase+"41.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_42():Unit {
        var image_src=imageBase+"42.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}