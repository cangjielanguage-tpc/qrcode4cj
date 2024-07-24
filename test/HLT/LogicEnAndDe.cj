import std.fs.*
import std.math.*
import std.os.*
import std.time.*
import std.collection.*

import QRCode4cj.aztec.decoder.*
import QRCode4cj.aztec.detector.*
import QRCode4cj.aztec.common.*
import QRCode4cj.common.*
import QRCode4cj.multi.*
import QRCode4cj.common.BitMatrix
import QRCode4cj.common.LuminanceSource
import QRCode4cj.common.BinaryBitmap
import QRCode4cj.common.BarcodeFormat
import QRCode4cj.common.EncodeHintType
import QRCode4cj.common.DecodeHintType
import QRCode4cj.common.Result
import QRCode4cj.common.ResultPoint
import QRCode4cj.common.DecoderResult
import QRCode4cj.common.HybridBinarizer
import QRCode4cj.common.reader.MultiFormatReader
import QRCode4cj.common.writer.MultiFormatWriter
import QRCode4cj.oned.MultiFormatOneDReader
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
public func decodeMulti(imagePath: String,hintDe:HashMap<DecodeHintType, Any>): Array<Result> {
    var image: Image
    var opencvUtils: CvImageForZxing = CvImageForZxing()
    image = opencvUtils.opencvReadImg(imagePath)

    var imageiop = image as ImageI
    var imagei: ImageI = imageiop.getOrThrow()

    var source: LuminanceSource = BufferedImageLuminanceSource(imagei);
    var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)

    var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer);
    // 创建解码参数
    var reader: MultiFormatReader = MultiFormatReader()
    var multiReader:MultipleBarcodeReader=GenericMultipleBarcodeReader(reader)
    var result=multiReader.decodeMultiple(bitmap, hintDe)
    return result
}

public func testNormal(format:BarcodeFormat,content:String,width:Int64,height:Int64,en_hints:Option<HashMap<EncodeHintType, Any>>,de_hints:Option<HashMap<DecodeHintType, Any>>,expDe:String):Int64{
    var bitMatrixAfterEncode:BitMatrix=encode(format,content,width,height,en_hints)
    var binaryBitMap=bitMatrixToBinaryBitmap(bitMatrixAfterEncode,bitMatrixAfterEncode.getWidth(),bitMatrixAfterEncode.getHeight())
    var mfr=MultiFormatReader()
    var deRe=""
    if(de_hints.isNone()){
        deRe=mfr.decode(binaryBitMap).getText()
    }else{
        deRe=mfr.decode(binaryBitMap,de_hints.getOrThrow()).getText()
    }
    if(deRe!=expDe){
         println("deRe=${deRe}")
         return 1
    }
    return 0
}
public func testEncodeException(format:BarcodeFormat,content:String,width:Int64,height:Int64,en_hints:Option<HashMap<EncodeHintType, Any>>,errMsg:String):Int64{
    try{
        encode(format,content,width,height,en_hints)
    }catch(e:IllegalArgumentException){
        if(e.toString().contains(errMsg)){
            return 0
        }else{
            println(e.toString())
            return 1
        }
    }
    return 2
}
public func testEncodeDecodeException(format:BarcodeFormat,content:String,width:Int64,height:Int64,en_hints:Option<HashMap<EncodeHintType, Any>>,de_hints:Option<HashMap<DecodeHintType, Any>>,errMsg:String):Int64{
    var bitMatrixAfterEncode:BitMatrix=encode(format,content,width,height,en_hints)
    var binaryBitMap=bitMatrixToBinaryBitmap(bitMatrixAfterEncode,bitMatrixAfterEncode.getWidth(),bitMatrixAfterEncode.getHeight())
    var mfr=MultiFormatReader()
    try{
        mfr.decode(binaryBitMap,de_hints.getOrThrow()).getText()
    }catch(e:Qrcoder4cjNotFoundException){
         if(e.toString().contains(errMsg)){
             return 0
         }else{
             println(e.toString())
             return 3
         }
    }
    println("content=${content}")
    return 4
}
public func testDecodeNormal(imagePath: String,de_hints:Option<HashMap<DecodeHintType, Any>>,expSingleRe:String,expMutilRe:Array<String>,deType:String):Int64{
    if(deType=="Single"){
        var deSingRe=decode(imagePath,de_hints.getOrThrow())
        if(deSingRe==expSingleRe){
            return 0
        }else{
            println("deSingRe=${deSingRe}")
            println("deSingRe   =${deSingRe.toArray()}")
            println("expSingleRe=${expSingleRe.toArray()}")
            return 1
        }
    }else if(deType=="Multi") {
        var deMutilRe=decodeMulti(imagePath,de_hints.getOrThrow())
        if(expMutilRe.size!=deMutilRe.size){
            return 2
        }
        var deMultis=ArrayList<String>()
        for(deMutil in deMutilRe){
             deMultis.append(deMutil.getText())
        }
        if(expMutilRe!=Array<String>(deMultis)) {
            return 3
        }
        return 0
    }else{
        println("请输入要解析的图片类型：单张:Single,多张：Multi")
        return 4
    }
}
public func testDecodeException(imagePath: String,de_hints:Option<HashMap<DecodeHintType, Any>>,deType:String,errMsg:String):Int64{
    if(deType=="Single"){
        try{
            decode(imagePath,de_hints.getOrThrow())
        }catch(e:Qrcoder4cjNotFoundException){
            if(e.toString().contains(errMsg)){
                return 0
            }
            return 1
        }
        return 2
    }else if(deType=="Multi") {
        try{
            decodeMulti(imagePath,de_hints.getOrThrow())
        }catch(e:Qrcoder4cjNotFoundException){
            if(e.toString().contains(errMsg)){
                return 0
            }
            return 3
        }
        return 4
    }else{
        println("请输入要解析的图片类型：单张:Single,多张：Multi")
        return 5
    }
}
public func testDecodeNormalArray(imagePath: String,de_hints:Option<HashMap<DecodeHintType, Any>>,deExp:Array<UInt8>):Int64{
    var deSingRe=decode(imagePath,de_hints.getOrThrow()).toArray()
    if(deSingRe==deExp){
        return 0
    }else{
        println("deSingRe=${deSingRe}")
        println("deExp   =${deExp}")
        return 1
    }
}