// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

@Test
public class TestQRCode4cjCodabarEncode02{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    //组合
    @TestCase
    func test_Codabar_Encode_01():Unit {
        //开头结尾不符合规则的
        var encode_srcs_illeagal=Array<String>(["A1234567890","B1234567894","C1234567894","D1234567894",
                                         "a1234567890","b1234567894","b1234567894","b1234567894",
                                         "1234567890A","1234567894B","1234567894C","1234567894D",
                                         "1234567890a","1234567894b","1234567894c","1234567894d",
                                         "M1234567890N","E1234567890F","SD1234567894T","D12345H67G894",
                                         "EFGHIJKLMNOPQRSTUVWXYZ","efghijklmnopqrstuvwxyz"])
        for(encode_src in encode_srcs_illeagal){
            @Assert(testEncodeException(BarcodeFormat.CODABAR,encode_src,480,360,cur_en_hints,"Invalid start/end guards: ${encode_src}"),0)
        }
    }

    @TestCase
    func test_Codabar_Encode_02():Unit {
        //不符合规则的
        var encode_srcs_illeagal=Array<String>(["123A4567B890","123C456D7894","123F4567F894","A12345D67890D",
                                                "G1234567894H","I1234567894J","KD1234567894L","O1234567894P",
                                                "Q1234567894R","U1234567890V","W1234567894X","Y1234567894Z",
                                                "A","ABCD","a","abcd"])
        var decode_errMsg_start=Array<String>([
                                         "A","C","F","D",
                                         "G","I","K","O",
                                         "Q","U","W","Y",
                                         "A","B","a","b"])
        for(index in 0..encode_srcs_illeagal.size){
            @Assert(testEncodeException(BarcodeFormat.CODABAR,encode_srcs_illeagal[index],480,360,cur_en_hints,"Cannot encode : '"+decode_errMsg_start[index]+'\''.toString()),0)
        }
    }
    @TestCase
    func test_Codabar_Encode_03():Unit {
        //合法-解码成功-开头结尾不删减
        var encode_srcs_leagal=Array<String>(["1234567890","-$:/.+","123/456","456$56","2345","234","23",
                                              "23:45","45.56","45+56","1234567890123456789012345678901234567890",
                                              #"-1234567890."#,#"/1234567890."#,#"-1234567890"#,#"+1234567890"#,
                                              #"1234567890."#,#"1234567890/"#,#"1234567890$"#,"$1234567890+"])
        for(encode_src in encode_srcs_leagal){
            @Assert(testNormal(BarcodeFormat.CODABAR,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_Codabar_Encode_04():Unit {
        //合法-解码成功-开头结尾删减
        var encode_srcs_leagal=Array<(String,String)>([("A1234567890D","1234567890"),("B1234567890C","1234567890"),
                                                       ("C1234567890B","1234567890"),("D1234567890A","1234567890"),
                                                       ("A12345+67890D","12345+67890"),("B123456$7890C","123456$7890"),
                                                       ("C12345:67890B","12345:67890"),("D1234/567890A","1234/567890"),
                                                       ("a12345.67890D","12345.67890"),("b12345.67890D","12345.67890"),
                                                       ("c12345.67890D","12345.67890"),("d1234/567890A","1234/567890"),
                                                       ("a12345.67890d","12345.67890"),("b12345.67890c","12345.67890"),
                                                       ("c12345.67890b","12345.67890"),("d1234/567890a","1234/567890")])
        for(index in 0..encode_srcs_leagal.size){
            @Assert(testNormal(BarcodeFormat.CODABAR,encode_srcs_leagal[index][0],480,360,cur_en_hints,cur_de_hints,encode_srcs_leagal[index][1]),0)
        }
    }
    @TestCase
    func test_Codabar_Encode_05():Unit {
        //合法，但是解码失败
        var encode_srcs_leagal=Array<String>(["-","$",":",#"/"#,#"."#,"+","2"])
        for(encode_src in encode_srcs_leagal){
            @Assert(testEncodeDecodeException(BarcodeFormat.CODABAR,encode_src,100,80,cur_en_hints,cur_de_hints,"Qrcoder4cjNotFoundException"),0)
        }
    }
    @TestCase
    func test_Codabar_Encode_06():Unit {
        //合法，但是字符超长
        var encode_src="1234567890"
        while(encode_src.size<10000){
            encode_src+=encode_src
        }
        @Assert(testNormal(BarcodeFormat.CODABAR,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
}