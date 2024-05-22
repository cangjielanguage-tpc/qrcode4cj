// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

@Test
public class TestQRCode4cjDataMatrixEnCode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_DataMatrix_Encode_01():Unit {
        var encode_src_legal=Array<String>([ "abcdefg",
                                             "ABCDEFG",
                                             "abcdrfd90",
                                             "abcdefghijklmnopqrstuv",
                                             "00112233445566778899",
                                             ##" !"#$%&'()*+,-./:;<=>"##,
                                             ##" !"#$%&'()*+,-."##,
                                             "AFDRETWGH123",
                                             "AFDRETWGH90",
                                             ##" !"#$%&'()*+,-./:;<="##,
                                             "abcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcdabcd",
                                             "óóóóóó"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.DATA_MATRIX,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_DataMatrix_Encode_02():Unit {
        var encode_src_illegal=Array<String>(["43",
                                              "abcde",
                                              "abcdef",
                                             ##" !"#$%&'()*+,-./:;<=>?@[]^"##,
                                             "http://google.com/m",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabc",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcd",
                                             "0123456789"])
        for (encode_src in encode_src_illegal){
            @Assert(testEncodeDecodeException(BarcodeFormat.DATA_MATRIX,encode_src,120,120,cur_en_hints,cur_de_hints,"NotFoundException"),0)
        }
    }

    @TestCase
    func test_DataMatrix_Encode_03():Unit {
        var encode_src_legal=Array<String>([
                                             "abcdefghijklm",
                                             "abcdefghijklmnopq",
                                             "abcdefghijklmnopqrstuv",
                                             "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVW",
                                             #"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(),./\"#,
                                             #"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(),./\abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(),./\abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*(),./\"#,
                                             "Testing C40",
                                             "EDIFACTEDIFACT",
                                             "10f27ce-acb7-4e4e-a7ae-a0b98da6ed4a",
                                             "X12X12X12X12",
                                             "http://code.google.com/p/zxing/",
                                             "This is a test of our DataMatrix support using a longer piece of text, and therefore a more dense barcode.",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxy",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcd",
                                             "abcdefghijklmnopqrstuvwxy",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzab",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmn",
                                             "abcdefghijklmnopqrstuvwxyzabcdefgh",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijk",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklm",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrst",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrs",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrst",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnop",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabc",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrst",
                                             "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno"])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.DATA_MATRIX,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
}