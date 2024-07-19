// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/datamatrix-3

import QRCode4cj.aztec.decoder.*
import QRCode4cj.aztec.detector.*
import QRCode4cj.aztec.common.*
import QRCode4cj.multi.*
import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.common.writer.*
import QRCode4cj.oned.*
import std.collection.*

@Test
public class TestQRCode4cjDataMatrixDecode03{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/datamatrix-3/"
    @TestCase
    func test_DataMatrix_Decode_24():Unit {
        var image_src=imageBase+"abcd-36x20.png"
        var deRe="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_25():Unit {
        var image_src=imageBase+"abcd-40x26.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_26():Unit {
        var image_src=imageBase+"abcd-44x20.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_27():Unit {
        var image_src=imageBase+"abcd-48x8.png"
        var deRe="abcdefghijklmnopqrstuvwxy"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_28():Unit {
        var image_src=imageBase+"abcd-48x22.png"
        var deRe="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzab"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_29():Unit {
        var image_src=imageBase+"abcd-48x24.png"
        var deRe="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmn"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_30():Unit {
        var image_src=imageBase+"abcd-48x26.png"
        var deRe="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabc"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_31():Unit {
        var image_src=imageBase+"abcd-64x8.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_32():Unit {
        var image_src=imageBase+"abcd-64x12.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_33():Unit {
        var image_src=imageBase+"abcd-64x16.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_34():Unit {
        var image_src=imageBase+"abcd-64x20.png"
        var deRe="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrst"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_DataMatrix_Decode_35():Unit {
        var image_src=imageBase+"abcd-64x24.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_36():Unit {
        var image_src=imageBase+"abcd-64x26.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_37():Unit {
        var image_src=imageBase+"abcd-80x8.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_38():Unit {
        var image_src=imageBase+"abcd-88x12.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_39():Unit {
        var image_src=imageBase+"abcd-96x8.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_40():Unit {
        var image_src=imageBase+"abcd-120x8.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
    @TestCase
    func test_DataMatrix_Decode_41():Unit {
        var image_src=imageBase+"abcd-144x8.png"//com.google.zxing.NotFoundException
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","Qrcoder4cjNotFoundException") ,0)
    }
}
/*
public func testDecodeException(imagePath:String,hints:DecodeHintType,deMsg:String):Int64{
    try{
        decode(imagePath,hints)
    }catch(e:Exception){
        if(e.toString().contains(deMsg)){
            return 0
        }
        return 1
    }
    return 2
} */