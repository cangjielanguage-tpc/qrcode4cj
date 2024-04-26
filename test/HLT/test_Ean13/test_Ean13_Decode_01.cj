// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/ean13-1

@Test
public class TestQRCode4cjEan13Decode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/ean13-1/"
    @TestCase
    func test_Ean13_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe="8413000065504"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe="8480010092271"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_03():Unit {
        var image_src=imageBase+"3.png"
        var deRe="8480000823274"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        var deRe="5449000039231"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        var deRe="8410054010412"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_06():Unit {
        var image_src=imageBase+"6.png"
        var deRe="8480010045062"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_07():Unit {
        var image_src=imageBase+"7.png"
        var deRe="9788430532674"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe="8480017507990"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_09():Unit {
        var image_src=imageBase+"9.png"
        var deRe="3166298099809"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="8480010001136"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe="5201815331227"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe="8413600298517"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe="3560070169443"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe="4045787034318"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="3086126100326"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="4820024790635"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="4000539017100"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        var deRe="7622200008018"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        var deRe="5603667020517"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        var deRe="7622400791949"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe="5709262942503"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_25():Unit {
        var image_src=imageBase+"25.png"
        var deRe="9780140013993"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_26():Unit {
        var image_src=imageBase+"26.png"
        var deRe="4901780188352"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_28():Unit {
        var image_src=imageBase+"28.png"
        var deRe="9771699057002"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_29():Unit {
        var image_src=imageBase+"29.png"
        var deRe="4007817327098"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_30():Unit {
        var image_src=imageBase+"30.png"
        var deRe="5025121072311"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_31():Unit {
        var image_src=imageBase+"31.png"
        var deRe="9780393058673"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_32():Unit {
        var image_src=imageBase+"32.png"
        var deRe="9780393058673"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_33():Unit {
        var image_src=imageBase+"33.png"
        var deRe="9781558604971"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_34():Unit {
        var image_src=imageBase+"34.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_35():Unit {
        var image_src=imageBase+"35.png"
        var deRe="5030159003930"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_36():Unit {
        var image_src=imageBase+"36.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Ean13_Decode_37():Unit {
        var image_src=imageBase+"37.png"
        var deRe="5000213002834"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Ean13_Decode_38():Unit {
        var image_src=imageBase+"38.png"
        var deRe="9780201752847"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}