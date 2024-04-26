from std import fs.*
from std import math.*
from std import os.*
from std import time.*
from std import collection.*

from QRCode4cj import aztec.decoder.*
from QRCode4cj import aztec.detector.*
from QRCode4cj import aztec.common.*
from QRCode4cj import common.*
from QRCode4cj import multi.*
from QRCode4cj import common.BitMatrix
from QRCode4cj import common.LuminanceSource
from QRCode4cj import common.BinaryBitmap
from QRCode4cj import common.BarcodeFormat
from QRCode4cj import common.EncodeHintType
from QRCode4cj import common.DecodeHintType
from QRCode4cj import common.Result
from QRCode4cj import common.ResultPoint
from QRCode4cj import common.DecoderResult
from QRCode4cj import common.HybridBinarizer
from QRCode4cj import common.reader.MultiFormatReader
from QRCode4cj import common.writer.MultiFormatWriter
from QRCode4cj import oned.MultiFormatOneDReader
public func stringToBinaryBitmap(binaryBitmap: String): BarcodeFormat {
    match (binaryBitmap) {
        case "AZTEC" => BarcodeFormat.AZTEC
        case "CODABAR" => BarcodeFormat.CODABAR
        case "CODE_128" => BarcodeFormat.CODE_128
        case "CODE_39" => BarcodeFormat.CODE_39
        case "CODE_93" => BarcodeFormat.CODE_93
        case "DATA_MATRIX" => BarcodeFormat.DATA_MATRIX
        case "EAN_13" => BarcodeFormat.EAN_13
        case "EAN_8" => BarcodeFormat.EAN_8
        case "ITF" => BarcodeFormat.ITF
        case "MAXICODE" => BarcodeFormat.MAXICODE
        case "PDF_417" => BarcodeFormat.PDF_417
        case "QR_CODE" => BarcodeFormat.QR_CODE
        case "RSS_14" => BarcodeFormat.RSS_14
        case "RSS_EXPANDED" => BarcodeFormat.RSS_EXPANDED
        case "UPC_A" => BarcodeFormat.UPC_A
        case "UPC_E" => BarcodeFormat.UPC_E
        case _ => throw Exception()
    }
}

func bitMatrixToBinaryBitmap(bitMatrix: BitMatrix, width: Int64, height: Int64): BinaryBitmap{
    var image = Gray_p(Rectangle_p(0, 0, width, height))
    for (y in 0..height) {
        for (x in 0..width) {
            var gryc: GrayC
            if (bitMatrix.get(x, y)) {
                gryc = GrayC(0)
            } else {
                gryc = GrayC(255)
            }

            var colors: GrayC = (grayModel(gryc) as GrayC).getOrThrow()
            image.setGray(x, y, colors)
        }
    }
    var imageiop = image as ImageI
    var imagei: ImageI = imageiop.getOrThrow()
    var source: LuminanceSource = BufferedImageLuminanceSource(imagei)
    var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)
    var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer)
    return bitmap
}

public func encode(barcodeFormat: BarcodeFormat, contents: String,width: Int64, height: Int64, hints:Option<HashMap<EncodeHintType, Any>>) :BitMatrix{
    var mfw = MultiFormatWriter();
    var encodeBitMatrix:BitMatrix
    if(hints.isNone()){
        encodeBitMatrix=mfw.encode(contents,barcodeFormat,  width, height)
    }else{
        encodeBitMatrix=mfw.encode(contents,barcodeFormat,  width, height,hints.getOrThrow())
    }
    return encodeBitMatrix
}

public func decode(imagePath: String,hintDe:HashMap<DecodeHintType, Any>): String {
    var image: Image
    var opencvUtils: CvImageForZxing = CvImageForZxing()
    image = opencvUtils.opencvReadImg(imagePath)

    var imageiop = image as ImageI
    var imagei: ImageI = imageiop.getOrThrow()

    var source: LuminanceSource = BufferedImageLuminanceSource(imagei);
    var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)

    var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer);
    var reader: MultiFormatReader = MultiFormatReader()
    var result=reader.decode(bitmap, hintDe).toString()

    return result
}

public func testDecodefuzz(imagePath: String,de_hints:Option<HashMap<DecodeHintType, Any>>):String{
    return decode(imagePath,de_hints.getOrThrow())
}
public func SaveImage(bitMatrix: BitMatrix, imageFilePath: String):Int64 {
    var height = bitMatrix.height
    var width = bitMatrix.width
    var rectangle = Rectangle(internals.model.Point(0, 0), internals.model.Point(width, height))
    var pngImg = Gray(rectangle)
    for (y in 0..height) {
        for (x in 0..width) {
            var gryc: GrayC
            if (bitMatrix.get(width - x - 1, height - y - 1)) {
                pngImg.set(width - x - 1, height - y - 1, color.GrayC(0))
            } else {
                pngImg.set(width - x - 1, height - y - 1, color.GrayC(255))
            }
        }
    }
    png.register() // 添加PNG模块

    let fsO = File(imageFilePath, OpenOption.CreateOrTruncate(true)) // 覆盖或创建输出文件
    if (fsO.canWrite()) {
        png.encode(fsO, pngImg) // 编码图片并保存至对应文件流
    }
    fsO.close()
    return 0
}
public func encodeDecodeCount(barcodeFormat: BarcodeFormat,strs:Array<String>,fileflag:String,typeLen:String,appendStr:String):Int64{
     var encodePassStr=File("${fileflag}_encode_pass_${typeLen}.txt",OpenOption.CreateOrTruncate(true))
     var encodeFailStr=File("${fileflag}_encode_fail_${typeLen}.txt",OpenOption.CreateOrTruncate(true))
     var decodePassStr=File("${fileflag}_decode_pass_${typeLen}.txt",OpenOption.CreateOrTruncate(true))
     var decodeFailStr=File("${fileflag}_decode_fail_${typeLen}.txt",OpenOption.CreateOrTruncate(true))
     var notequals=File("${fileflag}_notequal_${typeLen}.txt",OpenOption.CreateOrTruncate(true))
     var equalstrs=File("${fileflag}_equalstr_${typeLen}.txt",OpenOption.CreateOrTruncate(true))

     var EncodeExceptioncount=0
     var DecodeExceptioncount=0
     var NotEqualFail=0
     var EqualsPass=0

     var bitMatrixAfterEncode:BitMatrix
     var picPath=""
     if(typeLen==""){
          picPath="cj_PIC_${barcodeFormat}"
     }else{
          picPath="cj_PIC_${barcodeFormat}_${typeLen}"
     }
     Directory.create(picPath,recursive:true)
     var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
     for(index in 0..strs.size) {
         var PathImage="./${picPath}/${index}.png"
         var finalStr=strs[index]+appendStr
         try{
             bitMatrixAfterEncode=encode(barcodeFormat,strs[index],480,360,Option<HashMap<EncodeHintType, Any>>.None)
             encodePassStr.write(finalStr.toArray())
             encodePassStr.flush()
             SaveImage(bitMatrixAfterEncode,PathImage)

             try{
                var re=testDecodefuzz("./"+PathImage,cur_de_hints)+""
                 re+=appendStr
                 //解码成功，将解码得到的字符串，加上生成字符串的是分割符一起写到:cj_itf_decode_pass_.txt
                 decodePassStr.write(re.toArray())
                 decodePassStr.flush()
                 //判断解码出来的结果（包含解码结果和分割字符串）和原始字符串（包括分割字符串）对比
                 if(re!=finalStr) {
                    //不等，将图片路径写到cj_itf_notequal_.txt
                    notequals.write("./${PathImage}\n".toArray())
                    notequals.flush()
                    NotEqualFail+=1
                 }else{
                     //相等，将将该字符串写到 cj_itf_equalstr_.txt
                     equalstrs.write("re.toArray()".toArray())
                     equalstrs.flush()
                     EqualsPass+=1
                 }
             }catch(e:Exception){
                 decodeFailStr.write("./${PathImage}\n".toArray())   //解码失败，将解码失败的图片路径写入  :cj_itf_decode_fail_.txt
                 decodeFailStr.flush()
                 DecodeExceptioncount+=1
             }
         }catch(e:Exception){ //编码失败,删除已创建的图片路径,将编码失败的字符串索引写入编码失败对应的文件:   cj_aztec_encode_fail_.txt
             if(File.exists(PathImage)) {
                File.delete(PathImage)
             }
             encodeFailStr.write("${index},".toArray())
             encodeFailStr.flush()
             EncodeExceptioncount+=1
         }
     }
     notequals.close()
     equalstrs.close()
     encodeFailStr.close()
     encodePassStr.close()
     decodeFailStr.close()
     decodePassStr.close()
     println("${barcodeFormat}_${typeLen}_enFail_count=${EncodeExceptioncount}")
     println("${barcodeFormat}_${typeLen}_deFail_count=${DecodeExceptioncount}")
     println("${barcodeFormat}_${typeLen}_dePass_NotEqualFail=${NotEqualFail}")
     println("${barcodeFormat}_${typeLen}_dePass_EqualsPass=${EqualsPass}")
     return NotEqualFail
}
public func decodeCount(dic:String,typeStr:String,appendStr:String){
     //decodeCount("./fuzz/java_PIC_QR_CODE","qrcode_java_encode"),用于解码对标库生成的图片，不需要解码和编码字符串对比
     var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
     var decodePassStr=File(typeStr+"_cj_decode_pass.txt",OpenOption.CreateOrTruncate(true))
     var decodeFailStr=File(typeStr+"_cj_decode_fail.txt",OpenOption.CreateOrTruncate(true))
     var decodeOnlycountFail=0
     var decodeOnlycountPass=0
     for(index in 0..3000) {
         var oripic="./${dic}/${index}.png"
         try{
            var re=testDecodefuzz(oripic,cur_de_hints)
            re+=appendStr
            //将解码出来的字符串，加入分割字符串写入:aztec_java_encode_cj_decode_pass.txt
            decodePassStr.write(re.toArray())
            decodePassStr.flush()
            decodeOnlycountPass+=1
         }catch(e:Exception){
             decodeOnlycountFail+=1
             //将解码异常的图片路径加上换行符写入:aztec_java_encode_cj_decode_fail.txt
             decodeFailStr.write(oripic.toArray())
             decodeFailStr.write("\n".toArray())
             decodeFailStr.flush()
         }
     }
     decodePassStr.close()
     decodeFailStr.close()
     println(dic+"decodeOnlycountPass=${decodeOnlycountPass}")
     println(dic+"decodeOnlycountFail=${decodeOnlycountFail}")
}
