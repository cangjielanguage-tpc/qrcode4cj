// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/code128-2

@Test
public class TestQRCode4cjCode128Decode02{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/code128-2/"
    @TestCase
    func test_Code128_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe="005-3379497200006"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe="005-3379497200006"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe="005-3379497200006"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        var deRe="005-3379497200006"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe="15182881"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe="15182881"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe="15182881"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_08():Unit {
        var image_src=imageBase+"08.png"
        var deRe="15182881"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe="CNK8181G2C"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="CNK8181G2C"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="CNK8181G2C"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe="CNK8181G2C"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="1PEF224A4"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="1PEF224A4"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="1PEF224A4"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="1PEF224A4"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="FW727"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="FW727"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="FW727"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="FW727"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        var deRe="005-3354174500018"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        var deRe="005-3354174500018"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        var deRe="005-3354174500018"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe="005-3354174500018"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_25():Unit {
        var image_src=imageBase+"25.png"
        var deRe="31001171800000017989625355702636"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_26():Unit {
        var image_src=imageBase+"26.png"
        var deRe="31001171800000017989625355702636"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_27():Unit {
        var image_src=imageBase+"27.png"
        var deRe="31001171800000017989625355702636"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_28():Unit {
        var image_src=imageBase+"28.png"
        var deRe="31001171800000017989625355702636"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_29():Unit {
        var image_src=imageBase+"29.png"
        var deRe="42094043"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_30():Unit {
        var image_src=imageBase+"30.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_Code128_Decode_31():Unit {
        var image_src=imageBase+"31.png"
        var deRe="42094043"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_32():Unit {
        var image_src=imageBase+"32.png"
        var deRe="42094043"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_33():Unit {
        var image_src=imageBase+"33.png"
        var deRe="30885909173823"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_34():Unit {
        var image_src=imageBase+"34.png"
        var deRe="30885909173823"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_35():Unit {
        var image_src=imageBase+"35.png"
        var deRe="30885909173823"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_36():Unit {
        var image_src=imageBase+"36.png"
        var deRe="30885909173823"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_37():Unit {
        var image_src=imageBase+"37.png"
        var deRe="FGGQ6D1"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_38():Unit {
        var image_src=imageBase+"38.png"
        var deRe="FGGQ6D1"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_39():Unit {
        var image_src=imageBase+"39.png"
        var deRe="FGGQ6D1"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Code128_Decode_40():Unit {
        var image_src=imageBase+"40.png"
        var deRe="FGGQ6D1"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}