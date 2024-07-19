// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/qrcode-2

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
public class TestQRCode4cjQrcodeDecode02{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/qrcode-2/"
    @TestCase
    func test_Qrcode_Decode_01():Unit {
        var image_src=imageBase+"1.png"
        var deRe=###"When we at WRT talk about \"text,\" we are generally talking about a particular kind of readable information encoding - and readable is a complex proposition. Text may be stylized in a way we are unfamiliar with, as in blackletter - it may be interspersed with some markup we don\'t understand, such as HTML - it may be be a substitution system we aren\'t familiar with, such as braille or morse code - or it may be a system that, while technically human-readable, isn\'t particularly optimized for reading by humans, as with barcodes (although barcodes can be read)."###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_02():Unit {
        var image_src=imageBase+"2.png"
        var deRe=###"LANDBYASCARC   PERCEPTIBLEC EEK,OOZI GITSWAYTHROU  AWILDERNESSOFBESUPPOSED,I  CANT,ORATL ASTDWARFISH.NO REESOFANYM  NITUDEARETOBESOMEMISERA  EFRAMEBUIL I GS,TENANTED, U INGSUMMER   THEFUGITIVE;BUTTHEWHO  ISLAND,WI H   EXCEPTIONOFT   W STERNPOI  ,ANDALINEOFLLIAMLEGR   .HEWASOF N    ENTHUGUENOTF    Y ANDHADON  BEENWEALTHTIONCONSE  ENTUPONH SD   STERS,HELEFTNE   LE NS,THEC   OFHISFOREOUTHCARO   A.THISISLA    AVERYSINGULARO    TCONSISTSO  ITTLEELSEDSAQUART   FAMILE. TI   PARATEDFROMTHEMA   AN BYASCAR   YPERCEPTERESORT     MARSH EN   EVEGETATION,ASMIGH   SU POSED,   CANT,ORATREMITY,      ORT OULTRIESTANDS,ANDWHEREARESOM MIS      FRAMEBUIFEVER,MAYBE      INDEED,                TO;BUTT      EISLAND,WITNYYEARSAGO,IC    ACTED                    LLIAM    AND.HEWASOFANNESHADREDUCEDHIM OWA                       IONC NSEQUENTUPONHISDSIDENCEATSULLIVA \'S                          HC ROLINA.THISISLANOUTTHR    LESLON .        THATN  OINTE        U RTEROF    E.ITISTHROU       ERNE       DSANDSLI  ,AFAVOR        TOFT       HEN.T"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_04():Unit {
        var image_src=imageBase+"4.png"
        var deRe=###"http://wwws.keihin.ktr.mlit.go.jp/keitai/"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_05():Unit {
        var image_src=imageBase+"5.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_06():Unit {
        var image_src=imageBase+"6.png"
        var deRe=###"http://d.kaywa.com/20207100"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_07():Unit {
        var image_src=imageBase+"7.png"
        var deRe=###"BIZCARD:N:Todd;X:Ogasawara;T:Tech Geek;C:MobileViews.com;A:MobileTown USA;E:editor@mobileviews.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_08():Unit {
        var image_src=imageBase+"8.png"
        var deRe=###"http://staticrooster.com"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_09():Unit {
        var image_src=imageBase+"9.png"
        var deRe="Morden"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe="""
Google モバイル\r
http://google.jp"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe="""
BEGIN:VCARD\r
N:Kennedy;Steve\r
TEL:+44 (0)7775 755503\r
ADR;HOME:;;Flat 2, 43 Howitt Road, Belsize Park;London;;NW34LU;UK\r
ORG:NetTek Ltd;\r
TITLE:Consultant\r
EMAIL:steve@nettek.co.uk\r
URL:www.nettek.co.uk\r
EMAIL;IM:MSN:steve@gbnet.net\r
NOTE:Testing 1 2 3\r
BDAY:19611105\r
END:VCARD"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        @Assert(testDecodeException(image_src,cur_de_hints,"Single","NotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe=###"http://bbc.co.uk/programmes"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe=###"In 25 words or less in the comments, below, tell us how QR codes will make the world less ordinary."###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="""
[外側QRコード]\r
 \r
*ﾀﾞﾌﾞﾙQR*\r
http://d-qr.net/ex/"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="""
ﾃﾞｻﾞｲﾝQR\r
http://d-qr.net/ex/"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="""
*ﾃﾞｻﾞｲﾝQR*     \r
http://d-qr.net/ex/       """
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="""
*ﾃﾞｻﾞｲﾝQR*    \r
http://d-qr.net/ex/         """
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_20():Unit {
        var image_src=imageBase+"20.png"
        var deRe="""
*ﾃﾞｻﾞｲﾝQR*\r
http://d-qr.net/ex/    """
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_21():Unit {
        var image_src=imageBase+"21.png"
        var deRe="""
*ﾃﾞｻﾞｲﾝQR*  \r
http://d-qr.net/ex/        """
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_22():Unit {
        var image_src=imageBase+"22.png"
        var deRe=###"http://www.hotpepper.jp/mobile/cgi-bin/MBLC80100.cgi?SA=00&Z=AG&vos=hpp064&uid=NULLGWDOCOMO"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_23():Unit {
        var image_src=imageBase+"23.png"
        var deRe=###"http://aniful.jp/pr/  "###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_24():Unit {
        var image_src=imageBase+"24.png"
        var deRe="""
*ﾃﾞｻﾞｲﾝQR* \r
http://d-qr.net/ex/      """
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_25():Unit {
        var image_src=imageBase+"25.png"
        var deRe=###"MEBKM:TITLE:;URL:http://d.kaywa.com/2020400102;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_26():Unit {
        var image_src=imageBase+"26.png"
        var deRe="""
<ﾃﾞｻﾞｲﾝQR> \r
ｲﾗｽﾄ入りｶﾗｰQRｺｰﾄﾞ\r
http://d-qr.net/ex/ """
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_27():Unit {
        var image_src=imageBase+"27.png"
        var deRe="""
*ﾃﾞｻﾞｲﾝQR*   \r
http://d-qr.net/ex/ """
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_28():Unit {
        var image_src=imageBase+"28.png"
        var deRe=###"http://www.webtech.co.jp/k/"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_29():Unit {
        var image_src=imageBase+"29.png"
        var deRe="""
http://live.fdgm.jp/u/event/hype/hype_top.html \r
\r
MEBKM:TITLE:hypeモバイル;URL:http\\://live.fdgm.jp/u/event/hype/hype_top.html;;"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_30():Unit {
        var image_src=imageBase+"30.png"
        var deRe=###"MECARD:N:測試;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_31():Unit {
        var image_src=imageBase+"31.png"
        var deRe=###"今度のバージョンでは文章の暗号化ができます。"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_32():Unit {
        var image_src=imageBase+"32.png"
        var deRe="""
BEGIN:VCARD\r
N:Kennedy;Steve\r
TEL:+44 (0)7775 755503\r
ADR;HOME:;;Flat 2, 43 Howitt Road, Belsize Park;London;;NW34LU;UK\r
ORG:NetTek Ltd;\r
TITLE:Consultant\r
EMAIL:steve@nettek.co.uk\r
URL:www.nettek.co.uk\r
EMAIL;IM:MSN:steve@gbnet.net\r
NOTE:Testing 1 2 3\r
BDAY:19611105\r
END:VCARD"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_33():Unit {
        var image_src=imageBase+"33.png"
        var deRe=###"AD:SUB:阿;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_34():Unit {
        var image_src=imageBase+"34.png"
        var deRe=###"http://www.google.com/"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_35():Unit {
        var image_src=imageBase+"35.png"
        var deRe=###"http://www.google.com/"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}