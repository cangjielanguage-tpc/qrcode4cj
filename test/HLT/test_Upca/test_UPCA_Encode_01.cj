// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

@Test
public class TestQRCode4cjUPCAEncode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_UPCA_Encode_01():Unit{
        var encode_src_illegal=Array<String>([ "111111111111",
                                             "222222222222",
                                             "333333333333",
                                             "444444444444",
                                             "666666666666",
                                             "777777777777",
                                             "888888888888",
                                             "999999999999",
                                             "012345678901"])
        for (encode_src in encode_src_illegal){
            @Assert(testEncodeException(BarcodeFormat.UPC_A,encode_src,120,120,cur_en_hints,"Contents do not pass checksum"),0)
        }
    }
    @TestCase
    func test_UPCA_Encode_02():Unit{
        var encode_src_legal=Array<String>(["555555555555","000000000000","036602301467","070097025088","071831007995","027011006951","781735802045","456314319671",
                                            "434704791429","024543136538","752919460009","606949762520","061869053712","619659023935","045496442736"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.UPC_A,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_UPCA_Encode_03():Unit{
        var encode_src_legal=Array<String>(["890444000335","181497000879","051000000675","752050200137","899684001003","012546619592","075720003259"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.UPC_A,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_UPCA_Encode_04():Unit{
        var encode_src_legal=Array<String>(["049000042566","854818000116"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.UPC_A,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_UPCA_Encode_05():Unit{
        var encode_src_legal=Array<String>(["023942431015","060410049235","066721010995","059290522143","057961000228","066721017185","059290571110",
                                            "067932000263","069000061015","071691155775","807648011401"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.UPC_A,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_UPCA_Encode_06():Unit{
        var encode_src_legal=Array<String>(["312547701310","625034201058","066721010995","059290522143","057961000228","066721017185","059290571110",
                                            "067932000263","069000061015","071691155775","807648011401"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.UPC_A,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_UPCA_Encode_07():Unit{
        var encode_src_legal=Array<String>(["071831007995","605482330012","073333531084"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.UPC_A,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_UPCA_Encode_08():Unit{
        @Assert(testNormal(BarcodeFormat.UPC_A,"12345670123",120,120,cur_en_hints,cur_de_hints,"123456701236"),0)
    }
    @TestCase
    func test_UPCA_Encode_09():Unit{
        var encode_src_illegal=Array<String>(["","0","12","345","6789","12345","123456","1234567","12345678","123456789","12345670","123456701","1234567012"])
        for (encode_src in encode_src_illegal){
            @Assert(testEncodeException(BarcodeFormat.UPC_A,encode_src,120,120,cur_en_hints,"Requested contents should be 12 or 13 digits long, but got ${encode_src.toRuneArray().size+1}"),0)
        }
    }
    @TestCase
    func test_UPCA_Encode_10():Unit{
        @Assert(testEncodeException(BarcodeFormat.UPC_A,"1234567890g",120,120,cur_en_hints,"Qrcoder4cjFormatException"),0)
        @Assert(testEncodeException(BarcodeFormat.UPC_A,"1234567890g1",120,120,cur_en_hints,"Illegal contents"),0)
        @Assert(testEncodeException(BarcodeFormat.UPC_A,"G1234567890",120,120,cur_en_hints,"Qrcoder4cjFormatException"),0)
        @Assert(testEncodeException(BarcodeFormat.UPC_A,"1G1234567890",120,120,cur_en_hints,"Illegal contents"),0)
    }
}