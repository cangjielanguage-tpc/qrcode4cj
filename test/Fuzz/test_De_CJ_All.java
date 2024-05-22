import com.google.zxing.*;

import java.io.IOException;

public class test_De_CJ_All {
  public static void main(String[] args) throws IOException, NotFoundException {
      
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_AZTEC","cj_encode_aztec","fj000");
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_PDF_417","cj_encode_pdf417","fj000");
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_CODABAR","cj_encode_codabar","fj000") ;
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_CODE_39","cj_encode_code39","fj000") ;
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_CODE_93","cj_encode_code93","fj000") ;
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_CODE_128","cj_encode_code128","fj000") ;
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_DATA_MATRIX","cj_encode_datamatrix","fj000");
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_ITF","cj_encode_itf","fj000");
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_QR_CODE","cj_encode_qrcode","fj000");
      
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_EAN_8_num7","cj_encode_ean8_num7","f");
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_UPC_E_num7","cj_encode_upce_num7","f");

      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_EAN_8_num8","cj_encode_ean8_num8","f");
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_UPC_E_num8","cj_encode_upce_num8","f");

      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_EAN_13_num12","cj_encode_ean13_num12","f");
      EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_UPC_A_num12","cj_encode_upca_num12","f");

  }
}
