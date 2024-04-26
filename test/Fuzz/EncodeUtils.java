import com.google.zxing.*;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.HybridBinarizer;

import javax.imageio.IIOException;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.EnumMap;
import java.util.Map;

public class EncodeUtils {
    public static BitMatrix encode(BarcodeFormat barcodeFormat, String contents, int width, int height, Map<EncodeHintType, Object> hints) throws WriterException {
        MultiFormatWriter mfw = new MultiFormatWriter();
        BitMatrix encodeBitMatrix;
        if(hints==null){
            encodeBitMatrix=mfw.encode(contents,barcodeFormat,  width, height);
        }else{
            encodeBitMatrix=mfw.encode(contents,barcodeFormat,  width, height,hints);
        }
        return encodeBitMatrix;
    }
    public static int encodePDF417(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\pdf417_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int PDF417count=0;
        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.PDF_417,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                PDF417count+=1;
            }
        }
        fw.close();
        System.out.println("PDF417count="+PDF417count);
        return PDF417count;
    }
    public static int encodeAztec(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\aztec_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int AZTECcount=0;
        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.AZTEC,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                AZTECcount+=1;
            }
        }
        fw.close();
        System.out.println("AZTECcount="+AZTECcount);
        return AZTECcount;
    }
    public static int encodeCODABAR(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\codabar_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int CODABARcount=0;
        for(int index=0;index<strs.length;index++){
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            Map<EncodeHintType, Object> hints=null;
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.CODABAR,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                CODABARcount+=1;
            }
        }
        fw.close();
        System.out.println("CODABARcount="+CODABARcount);
        return CODABARcount;
    }
    public static int encodeCODE39(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\code39_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int CODE39count=0;
        for(int index=0;index<strs.length;index++){
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            Map<EncodeHintType, Object> hints=null;
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.CODE_39,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                CODE39count+=1;
            }
        }
        fw.close();
        System.out.println("CODE39count="+CODE39count);
        return CODE39count;
    }
    public static int encodeCODE93(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\code93_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int CODE93count=0;
        for(int index=0;index<strs.length;index++){
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            Map<EncodeHintType, Object> hints=null;
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.CODE_93,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                CODE93count+=1;
            }
        }
        fw.close();
        System.out.println("CODE93count="+CODE93count);
        return CODE93count;
    }
    public static int encodeCODE128(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\code128_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int CODE128count=0;

        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.CODE_128,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                CODE128count+=1;
            }
        }
        fw.close();
        System.out.println("CODE128count="+CODE128count);
        return CODE128count;
    }
    public static int encodeDATAMATRIX(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\datamatrix_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int DATAMATRIXcount=0;
        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.DATA_MATRIX,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                DATAMATRIXcount+=1;
            }
        }
        fw.close();
        System.out.println("DATAMATRIXcount="+DATAMATRIXcount);
        return DATAMATRIXcount;
    }
    public static int encodeEAN8(String[] strs,String dic,String type) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\ean8_encode_pass_"+type+".txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int EAN8Ccount=0;
        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.EAN_8,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                EAN8Ccount+=1;
            }
        }
        fw.close();
        System.out.println("EAN8Ccount="+EAN8Ccount);
        return EAN8Ccount;
    }
    public static int encodeEAN13(String[] strs,String dic,String type) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\ean13_encode_pass"+type+".txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int EAN13count=0;
        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.EAN_13,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                EAN13count+=1;
            }
        }
        fw.close();
        System.out.println("EAN13count="+EAN13count);
        return EAN13count;
    }
    public static int encodeITF(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\itf_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int ITFcount=0;
        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.ITF,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                ITFcount+=1;
            }
        }
        fw.close();
        System.out.println("ITFcount="+ITFcount);
        return ITFcount;
    }
    public static int encodeQRCODE(String[] strs,String dic) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\qrcode_encode_pass.txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int QRCODECcount=0;
        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.QR_CODE,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                QRCODECcount+=1;
            }
        }
        fw.close();
        System.out.println("QRCODECcount="+QRCODECcount);
        return QRCODECcount;
    }
    public static int encodeUPCA(String[] strs,String dic,String type) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\upca_encode_pass_"+type+".txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int UPCACcount=0;
        for(int index=0;index<strs.length;index++){
            Map<EncodeHintType, Object> hints=null;
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            try{
                BitMatrix bitMatrixAfterEncode=encode(BarcodeFormat.UPC_A,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                UPCACcount+=1;
            }
        }
        fw.close();
        System.out.println("UPCACcount="+UPCACcount);
        return UPCACcount;
    }
    public static int encodeUPCE(String[] strs,String dic,String type) throws IOException {
        File dir = new File(dic);
        String pathTarget=dic+"\\..\\encodePass\\upce_encode_pass_"+type+".txt";
        FileWriter fw = new FileWriter(pathTarget);
        dir.mkdir();
        int UPCECount=0;
        for(int index=0;index<strs.length;index++){
            File file = new File(dic+"\\"+index+".png"); // 图片文件
            Map<EncodeHintType, Object> hints=null;
            BitMatrix bitMatrixAfterEncode=null;
            try{
                bitMatrixAfterEncode=encode(BarcodeFormat.UPC_E,strs[index],480,360,hints);
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                fw.write(strs[index]);
                fw.flush();
            } catch(Exception e){
                file.delete();
                UPCECount+=1;
            }
        }
        fw.close();
        System.out.println("UPCECount="+UPCECount);
        return UPCECount;
    }
    public static String decodefuzz(String dicpath,Map<DecodeHintType, Object> curhints) throws IOException, NotFoundException {
        File file=new File(dicpath);
        BufferedImage image= ImageIO.read(file);   //这里均是png ,不需要遍历子目录
        int width=image.getWidth();
        int height=image.getHeight();
        int[] pixels=new int[width * height];
        image.getRGB(0,0,width,height,pixels,0,width);
        LuminanceSource source = new BufferedImageLuminanceSource(image);
        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
        MultiFormatReader mfr= new MultiFormatReader();
        Result re=mfr.decode(bitmap,curhints);
        return re.getText();
    }
    public static int encodeDecodeCount(BarcodeFormat barcodeFormat,String[] strs,String fileflag,String typeLen,String appensStr) throws IOException {
        //System.out.println(EncodeUtils.encodeDecodeCount(BarcodeFormat.EAN_8,strs,"java_ean8","num7","f"));
        System.out.println("编码的字符串个数="+strs.length);
        String fileStart="";
        if(typeLen==""){
            fileStart=fileflag;
        }else{
            fileStart=fileflag+"_"+typeLen;
        }
        FileWriter encodePassStr = new FileWriter(fileStart+"_encode_pass.txt");
        FileWriter encodeFailStr = new FileWriter(fileStart+"_encode_fail.txt");
        FileWriter decodePassStr = new FileWriter(fileStart+"_decode_pass.txt");
        FileWriter decodeFailStr = new FileWriter(fileStart+"_decode_fail.txt");
        FileWriter notequals = new FileWriter(fileStart+"_notequalFail.txt");
        FileWriter equalstrs = new FileWriter(fileStart+"_equalstrPass.txt");

        int EncodeExceptioncount=0;
        int DecodeExceptioncount=0;
        int NotEqualFail=0;
        int EqualsPass=0;

        BitMatrix bitMatrixAfterEncode=null;
        File dir =null;
        if(typeLen==""){
            dir = new File("java_PIC_"+barcodeFormat);
        }else{
            dir = new File("java_PIC_"+barcodeFormat+"_"+typeLen);
        }
        dir.mkdir();

        Map<DecodeHintType, Object> hints = new EnumMap<>(DecodeHintType.class);
        hints.put(DecodeHintType.TRY_HARDER,true);

        for(int index=0;index<strs.length;index++) {
            String PathImage= dir.getPath()+"\\"+index+".png";
            System.out.println("strs["+index+"]="+strs[index]);
            String finalStr=strs[index]+appensStr;
            System.out.println("finalStr01="+finalStr);
            File file = new File(PathImage);
            try{
                bitMatrixAfterEncode=encode(barcodeFormat,strs[index],480,360,null);
                encodePassStr.write(finalStr); //将编码成功的字符串加上分割字符串一起写入:java_codabar_encode_pass_.txt
                System.out.println("finalStr02="+finalStr);
                encodePassStr.flush();
                MatrixToImageWriter.writeToFile(bitMatrixAfterEncode, "PNG",file);
                try{
                    var re=decodefuzz("./"+PathImage,hints);
                    re+=appensStr;
                    //将解码成功的字符串加上分割字符串一起写入:java_codabar_decode_pass_.txt
                    decodePassStr.write(re);
                    decodePassStr.flush();
                    //将解码字符串加分割字符串与编码字符串与分割字符串进行对比
                    if(re!=finalStr) {
                        //System.out.println("re      ="+re);
                        //System.out.println("finalStr="+finalStr);
                        //对比不一致，将解码结果和分割字符串一起写入java_codabar_notequal_.txt
                        notequals.write(re);
                        notequals.flush();
                        NotEqualFail+=1;
                    }else{
                        //对比一致，将解码结果和分割字符串一起写入java_codabar_equalstr_.txt
                        equalstrs.write(re);
                        equalstrs.flush();
                        EqualsPass+=1;
                    }
                }catch(NotFoundException e){
                    //解码异常，将解码异常的图片路径写入java_codabar_decode_fail_.txt
                    decodeFailStr.write(PathImage+"解码失败\n");
                    decodeFailStr.flush();
                    DecodeExceptioncount+=1;
                }catch(IIOException e){
                    decodeFailStr.write(PathImage+"图片不存在\n");
                    decodeFailStr.flush();
                }
            }catch(Exception e){
                //编码异常，将编码异常的字符串索引写入java_codabar_encode_fail_.txt
                file.delete();
                encodeFailStr.write(index+", ");
                encodeFailStr.flush();
                EncodeExceptioncount+=1;
            }
        }
        notequals.close();
        equalstrs.close();
        encodeFailStr.close();
        encodePassStr.close();
        decodeFailStr.close();
        decodePassStr.close();

        System.out.println(barcodeFormat+"_"+typeLen+"_enFail_count="+EncodeExceptioncount);
        System.out.println(barcodeFormat+"_"+typeLen+"_deFail_count="+DecodeExceptioncount);
        System.out.println(barcodeFormat+"_"+typeLen+"_dePass_NotEqualFail="+NotEqualFail);
        System.out.println(barcodeFormat+"_"+typeLen+"_dePass_EqualsPass="+EqualsPass);
        return NotEqualFail;
    }
    public static int decodeCount(String dicpath,String typeStr,String appensStr) throws IOException, NotFoundException {
        //EncodeUtils.decodeCount("E:\\workspace\\Project_maven\\src\\test\\java\\cj_PIC_AZTEC","ci_encode_aztec","fj000");
        Map<DecodeHintType, Object> hints = new EnumMap<>(DecodeHintType.class);
        hints.put(DecodeHintType.TRY_HARDER,true);

        File decodePassStr=new File(typeStr+"_java_decode_pass.txt");
        File decodeFailStr=new File(typeStr+"_java_decode_fail.txt");
        int decodeOnlycountFail=0;
        int decodeOnlycountPass=0;

        FileWriter fwDecodePass = new FileWriter(decodePassStr);
        FileWriter fwDecodeFail = new FileWriter(decodeFailStr);

        for(int index=0;index<3000;index++) {
            String oripic=dicpath+"\\"+index+".png";
            try{
                String re=EncodeUtils.decodefuzz(oripic,hints);
                //将解码出来的字符串，加入分割字符串写入:cj_encode_aztec_java_decode_pass.txt
                fwDecodePass.write(re+appensStr);
                fwDecodePass.flush();
                decodeOnlycountPass+=1;
            }catch(NotFoundException e){
                //将解码异常的图片路径加上换行符写入:cj_encode_aztec_java_decode_fail.txt
                fwDecodeFail.write(oripic+"解码失败\n");
                fwDecodeFail.flush();
                decodeOnlycountFail+=1;
            }catch(IIOException e){
                fwDecodeFail.write(oripic+"图片不存在"+"\n");
                fwDecodeFail.flush();
            }
        }
        fwDecodeFail.close();
        fwDecodePass.close();
        System.out.println(dicpath+":decodeOnlycountFail="+decodeOnlycountFail);
        System.out.println(dicpath+":decodeOnlycountPass="+decodeOnlycountPass);
        return decodeOnlycountFail;
    }

}
