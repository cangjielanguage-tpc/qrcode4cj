// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ./image.cj
// dependence: ./LogicEnAndDe.cj
// data_file: ./fuzz

@Test
public class TestQRCode4cjDecodeAll{
    @TestCase
    func test_Decode_01():Unit {    //JAVA图片

         decodeCount("./fuzz/java_PIC_PDF_417","pdf417_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_CODABAR","codabar_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_CODE_93","code93_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_CODE_128","code128_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_DATA_MATRIX","datamatrix_java_encode","fj000")

         decodeCount("./fuzz/java_PIC_AZTEC","aztec_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_PDF_417","pdf417_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_CODABAR","codabar_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_CODE_39","code39_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_CODE_93","code93_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_CODE_128","code128_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_DATA_MATRIX","datamatrix_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_ITF","itf_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_QR_CODE","qrcode_java_encode","fj000")
         decodeCount("./fuzz/java_PIC_EAN_8_num7","ean8_num7_java_encode","f")
         decodeCount("./fuzz/java_PIC_UPC_E_num7","upce_num7_java_encode","f")
         decodeCount("./fuzz/java_PIC_UPC_E_num8","upce_num8_java_encode","f")
         decodeCount("./fuzz/java_PIC_EAN_8_num8","ean8_num8_java_encode","f")
         decodeCount("./fuzz/java_PIC_EAN_13_num12","ean13_num12_java_encode","f")
         decodeCount("./fuzz/java_PIC_UPC_A_num12","upca_num12_java_encode","f") 

    }
}