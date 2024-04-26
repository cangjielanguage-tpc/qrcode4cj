import com.google.zxing.BarcodeFormat;
import com.google.zxing.NotFoundException;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class test_En_De_All_04 {
    public static void main(String[] args) throws IOException, NotFoundException {
        String content="";
        try {
            BufferedReader reader = new BufferedReader(new FileReader("E:\\workspace\\Project_maven\\src\\test\\java\\string1024.txt"));
            String line;
            while ((line = reader.readLine()) != null) {
                content+=line;
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        String[] strs=content.split("fj000");
        System.out.println(strs.length);
        System.out.println(strs[0]);

        /*
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.AZTEC,strs,"java_aztec","","fj000"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.PDF_417,strs,"java_pdf417","","fj000"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.CODABAR,strs,"java_codabar","","fj000"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.CODE_39,strs,"java_code39","","fj000"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.CODE_93,strs,"java_code93","","fj000"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.CODE_128,strs,"java_code128","","fj000"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.DATA_MATRIX,strs,"java_datamatrix","","fj000"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.ITF,strs,"java_itf","","fj000"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.QR_CODE,strs,"java_qrcode","","fj000"));*/

    }
}
