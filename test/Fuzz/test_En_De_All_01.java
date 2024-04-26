import com.google.zxing.*;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.EnumMap;
import java.util.Map;

public class test_En_De_All_01 {
    public static void main(String[] args) throws IOException, NotFoundException {
        String content="";
        try {
            BufferedReader reader = new BufferedReader(new FileReader("E:\\workspace\\Project_maven\\src\\test\\java\\num7.txt"));
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

        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.EAN_8,strs,"java_ean8","num7","f"));
        System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.UPC_E,strs,"java_upce","num7","f"));

    }
}
