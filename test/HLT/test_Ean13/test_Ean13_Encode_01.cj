// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj


@Test
public class TestQRCode4cjEan13Encode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_Ean13_Encode_01():Unit {
        var encode_src_legal=Array<String>([ "8413000065504","8480010092271","8480000823274","5449000039231","8410054010412",
                                             "8480010045062","9788430532674","8480017507990","3166298099809","8480010001136",
                                             "5201815331227","8413600298517","3560070169443","4045787034318",
                                             "3086126100326","4820024790635","4000539017100",
                                             "7622200008018","5603667020517","7622400791949","5709262942503","9780140013993",
                                             "4901780188352","9771699057002","4007817327098","5025121072311",
                                             "9780393058673","9780393058673","9781558604971","5030159003930",
                                             "5000213101025","5000213002834","9780201752847" ])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.EAN_13,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_Ean13_Encode_02():Unit {
        var encode_src_legal=Array<String>([ "9780804816632","9780345348036","9784872348880","1920081045006","9780764544200","9780596008574","9781585730575","9780735619937",
                                             "9780441014989","9780679601050","9780345460950","9780446579803"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.EAN_13,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
}