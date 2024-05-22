import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

public class FileDiff {
    /*
    * 用来对比四组数据：注意这里对比要将生成的内容文件放到代码中相应的位置，否则程序报错z
    * 1. cj生成图片
    *    a. cj编解码前后,原字符串和解码后相同(aztec//cj_cj//)
    *    b. cj编码后,java解码和cj解码相同 (aztec//cj_cj//和aztec//cj_java//)
    * 2. java生成图片
     *    a. java编解码前后,原字符串和解码后相同(aztec//java_java//)
     *    b. java编码后,java解码和cj解码相同 (aztec//java_cj//和aztec//java_java//)
    * */
    public static void main(String[] args) {
        String logRootPath="E:\\Fuzz_Log\\log_compare\\";

        fileDiffCase(logRootPath,"aztec");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"pdf417");    //可能空行
        System.out.println();

        fileDiffCase(logRootPath,"codabar");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"code39");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"code93");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"code128");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"datamatrix");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"itf");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"qrcode");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"ean8_num7");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"upce_num7");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"ean8_num8");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"upce_num8");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"ean13_num12");    //可能空行
        System.out.println();
        fileDiffCase(logRootPath,"upca_num12"); 
    }
    public static void fileDiffCase(String logRootPath,String barType){
        String cjcjPathDe=logRootPath+barType+"\\cj_cj\\cj_"+barType+"_decode_pass.txt";
        String cjcjPathEn="";
        String cjjavaPathDe=logRootPath+barType+"\\cj_java\\cj_encode_"+barType+"_java_decode_pass.txt";
        String javacjPathDe=logRootPath+barType+"\\java_cj\\java_encode_"+barType+"_cj_decode_pass.txt";
        String javajavaPathDe=logRootPath+barType+"\\java_java\\java_"+barType+"_decode_pass.txt";
        String javajavaPathEn="";
        if(barType.contains("num7")||barType.contains("num12")){
            javajavaPathEn=logRootPath+barType+"\\java_java\\java_"+barType+"_notequalFail.txt";
            cjcjPathEn=logRootPath+barType+"\\cj_cj\\cj_"+barType+"_notequalFail.txt";
        }else{
            javajavaPathEn=logRootPath+barType+"\\java_java\\java_"+barType+"_encode_pass.txt";
            cjcjPathEn=logRootPath+barType+"\\cj_cj\\cj_"+barType+"_encode_pass.txt";
        }
        if( diffLogic(cjcjPathDe,cjcjPathEn)==0){
            System.out.println("fileDiffCase_"+barType.toUpperCase()+": cj生成图片 cj解码后与原文本相同,校验通过");
        }else{
            //System.out.println("cjcjPathDe="+cjcjPathDe);
            //System.out.println("cjcjPathEn="+cjcjPathEn);
            System.out.println("fileDiffCase_"+barType.toUpperCase()+": cj生成图片 cj解码后与原文本不同,校验失败");
        }
        if(diffLogic(cjcjPathDe,cjjavaPathDe)==0){
            System.out.println("fileDiffCase_"+barType.toUpperCase()+": cj生成图片 java解码后与cj解码后文本相同,校验通过");
        }else{
            //System.out.println("cjjavaPathDe="+cjjavaPathDe);
            //System.out.println("cjcjPathDe="+cjcjPathDe);
            System.out.println("fileDiffCase_"+barType.toUpperCase()+": cj生成图片 java解码后与cj解码后文本不同,校验失败");
        }
        if( diffLogic(javajavaPathEn,javajavaPathDe)==0){
            System.out.println("fileDiffCase_"+barType.toUpperCase()+": java生成图片 java解码后与原文本相同,校验通过");
        }else{
            //System.out.println("javajavaPathEn="+javajavaPathEn);
            //System.out.println("javajavaPathDe="+javajavaPathDe);
            System.out.println("fileDiffCase_"+barType.toUpperCase()+": java生成图片 java解码后与原文本不同,校验失败");
        }
        if(diffLogic(javacjPathDe,javajavaPathDe)==0){
            System.out.println("fileDiffCase_"+barType.toUpperCase()+": java生成图片 java解码后与cj解码后文本相同,校验通过");
        }else{
            //System.out.println("javacjPathDe="+javacjPathDe);
            //System.out.println("javajavaPathDe="+javajavaPathDe);
            System.out.println("fileDiffCase_"+barType.toUpperCase()+": java生成图片 java解码后与cj解码后文本不同,校验失败");
        }
    }
    public static int diffLogic(String cjPath,String javaPath){
        Path pathcj = Paths.get(cjPath);
        Path pathjava = Paths.get(javaPath);
        try {
            List<String> linescj = Files.readAllLines(pathcj, StandardCharsets.UTF_8);
            List<String> linesjava = Files.readAllLines(pathjava, StandardCharsets.UTF_8);
            int count=0;
            if(linescj.size()>=linesjava.size()){
                count=linesjava.size();
            }else{
                count=linescj.size();
            }
            for (int index=0;index<count;index++) {
                if(linescj.get(index) != linesjava.get(index)){
                    if(linescj.size()==linesjava.size()){
                        byte[] bytescj=linescj.get(index).getBytes();
                        byte[] bytesjava=linesjava.get(index).getBytes();
                        int countDiff=0;
                        if(bytescj.length>=bytesjava.length){
                            countDiff=bytesjava.length;
                        }else{
                            countDiff=bytescj.length;
                        }
                        for(int indexByte=0;indexByte<countDiff;indexByte++) {
                            if(bytescj[indexByte]!=bytesjava[indexByte]){
                                return 1;
                            }
                        }
                    }
                }

            }
            return 0;
        } catch (IOException e) {
            e.printStackTrace();
            return 1;
        }
    }

}
