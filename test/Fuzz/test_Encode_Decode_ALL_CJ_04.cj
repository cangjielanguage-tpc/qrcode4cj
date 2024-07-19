// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ./image.cj
// dependence: ./LogicEnAndDe.cj
// data_file: ./string1024.txt

import encoding.json.*

@Test
public class TestQRCode4cjEncodeDecodeAll01{

    @TestCase
    func test_Encode_Decode_01():Unit {
        var strSrc=File("./string1024.txt",OpenOption.Open(true,true))
        var strOri=String.fromUtf8(strSrc.readToEnd())
        var strsFinal=strOri.split("fj000")
        println("数组长度：${strsFinal.size}")
        strsFinal=strsFinal[0..3000]
        encodeDecodeCount(BarcodeFormat.AZTEC,strsFinal,"cj_aztec","","fj000")
        encodeDecodeCount(BarcodeFormat.PDF_417,strsFinal,"cj_pdf417","","fj000")
        encodeDecodeCount(BarcodeFormat.CODABAR,strsFinal,"cj_codabar","","fj000")
        encodeDecodeCount(BarcodeFormat.CODE_39,strsFinal,"cj_code39","","fj000")
        encodeDecodeCount(BarcodeFormat.CODE_93,strsFinal,"cj_code93","","fj000")
        encodeDecodeCount(BarcodeFormat.CODE_128,strsFinal,"cj_code128","","fj000")
        encodeDecodeCount(BarcodeFormat.DATA_MATRIX,strsFinal,"cj_datamatrix","","fj000")
        encodeDecodeCount(BarcodeFormat.ITF,strsFinal,"cj_itf","","fj000")
        encodeDecodeCount(BarcodeFormat.QR_CODE,strsFinal,"cj_qrcode","","fj000")

    }
}