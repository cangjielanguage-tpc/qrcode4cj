// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ./image.cj
// dependence: ./LogicEnAndDe.cj
// data_file: ./num12.txt

from encoding import json.*

@Test
public class TestQRCode4cjEncodeDecodeAll01{

    @TestCase
    func test_Encode_Decode_01():Unit {
        var strSrc=File("./num12.txt",OpenOption.Open(true,true))
        var strOri=String.fromUtf8(strSrc.readToEnd())
        var strsFinal=strOri.split("f")
        println("数组长度：${strsFinal.size}")
        strsFinal=strsFinal[0..3000]

        encodeDecodeCount(BarcodeFormat.EAN_13,strsFinal,"cj_ean13","num12","f")
        encodeDecodeCount(BarcodeFormat.UPC_A,strsFinal,"cj_upca","num12","f")
    }
}