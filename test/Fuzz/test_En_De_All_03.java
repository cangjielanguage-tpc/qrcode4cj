import com.google.zxing.BarcodeFormat;
import com.google.zxing.NotFoundException;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class test_En_De_All_03 {
    public static void main(String[] args) throws IOException, NotFoundException {
        String content="";
        try {
            BufferedReader reader = new BufferedReader(new FileReader("E:\\workspace\\Project_maven\\src\\test\\java\\num12.txt"));
            String line;
            while ((line = reader.readLine()) != null) {
                content+=line;
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        String[] strs=content.split("f");
        System.out.println(strs.length);

        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.EAN_13,strs,"java_ean13","num12","f"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.UPC_A,strs,"java_upca","num12","f"));

    }
}
