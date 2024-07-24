// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

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
public class TestQRCode4cjUPCEEncode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_UPCE_Encode_01():Unit{
        var encode_src_legal=Array<String>(["01234565",
                                            "00123457",
                                            "01234531",
                                            "05096893",
                                            "04963406",
                                            "04124498",
                                            "04965802"
                                            ])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.UPC_E,encode_src,141,162,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_UPCE_Encode_02():Unit{
        var encode_src_illegal=Array<String>(["0","12","345","6789","12345","123456","123456789"])
        for (encode_src in encode_src_illegal){
            @Assert(testEncodeException(BarcodeFormat.UPC_E,encode_src,120,120,cur_en_hints,"Requested contents should be 7 or 8 digits long, but got ${encode_src.toRuneArray().size}"),0)
        }
    }
    @TestCase
    func test_UPCE_Encode_03():Unit{
        @Assert(testEncodeException(BarcodeFormat.UPC_E,"",120,120,cur_en_hints,"Found empty contents"),0)
        @Assert(testEncodeException(BarcodeFormat.UPC_E,"012T4565",120,120,cur_en_hints,"Illegal contents"),0)
        @Assert(testEncodeException(BarcodeFormat.UPC_E,"t0124565",120,120,cur_en_hints,"Illegal contents"),0)
        @Assert(testEncodeException(BarcodeFormat.UPC_E,"0124565t",120,120,cur_en_hints,"Contents do not pass checksum"),0)
    }
}