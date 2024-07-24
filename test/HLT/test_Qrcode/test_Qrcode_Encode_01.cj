// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/qrcode-1

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
public class TestQRCode4cjQrcodeEncode01{
    var cur_en_hints=Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    @TestCase
    func test_Qrcode_Encode_01():Unit {
        var encode_src=##"MEBKM:URL:http\://en.wikipedia.org/wiki/Main_Page;;"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_02():Unit {
        var encode_src=##"http://google.com/gwt/n?u=bluenile.com"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_03():Unit {
        var encode_src="""
Sean Owen
srowen@google.com
917-364-2918
http://awesome-thoughts.com"""
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)

    }
    @TestCase
    func test_Qrcode_Encode_04():Unit {
        var encode_src="""
Google モバイル
http://google.jp"""
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_05():Unit {
        var encode_src="""
[外側QRコード]

*ﾀﾞﾌﾞﾙQR*
http://d-qr.net/ex/"""
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_06():Unit {
        var encode_src="""
ﾃﾞｻﾞｲﾝQR
http://d-qr.net/ex/"""
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_07():Unit {
        var encode_src="""
<ﾃﾞｻﾞｲﾝQR>
ｲﾗｽﾄ入りｶﾗｰQRｺｰﾄﾞ
http://d-qr.net/ex/"""
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_08():Unit {
        var encode_src="""
http://live.fdgm.jp/u/event/hype/hype_top.html

MEBKM:TITLE:hypeモバイル;URL:http://live.fdgm.jp/u/event/hype/hype_top.html;;"""
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_09():Unit {
        var encode_src=##"MECARD:N:測試;;"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_10():Unit {
        var encode_src=##"今度のバージョンでは文章の暗号化ができます。"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_11():Unit {
        var encode_src=##"AD:SUB:阿;;"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_12():Unit {
        var encode_src=##"http://www.google.com/"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_13():Unit {
        var encode_src=##"When we at WRT talk about "text," we are generally talking about a particular kind of readable information encoding - and readable is a complex proposition. Text may be stylized in a way we are unfamiliar with, as in blackletter - it may be interspersed with some markup we don't understand, such as HTML - it may be be a substitution system we aren't familiar with, such as braille or morse code - or it may be a system that, while technically human-readable, isn't particularly optimized for reading by humans, as with barcodes (although barcodes can be read)."##
        @Assert(testEncodeDecodeException(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,"Qrcoder4cjNotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Encode_14():Unit {
        var encode_src=##"LANDBYASCARC   PERCEPTIBLEC EEK,OOZI GITSWAYTHROU  AWILDERNESSOFBESUPPOSED,I  CANT,ORATL ASTDWARFISH.NO REESOFANYM  NITUDEARETOBESOMEMISERA  EFRAMEBUIL I GS,TENANTED, U INGSUMMER   THEFUGITIVE;BUTTHEWHO  ISLAND,WI H   EXCEPTIONOFT   W STERNPOI  ,ANDALINEOFLLIAMLEGR   .HEWASOF N    ENTHUGUENOTF    Y ANDHADON  BEENWEALTHTIONCONSE  ENTUPONH SD   STERS,HELEFTNE   LE NS,THEC   OFHISFOREOUTHCARO   A.THISISLA    AVERYSINGULARO    TCONSISTSO  ITTLEELSEDSAQUART   FAMILE. TI   PARATEDFROMTHEMA   AN BYASCAR   YPERCEPTERESORT     MARSH EN   EVEGETATION,ASMIGH   SU POSED,   CANT,ORATREMITY,      ORT OULTRIESTANDS,ANDWHEREARESOM MIS      FRAMEBUIFEVER,MAYBE      INDEED,                TO;BUTT      EISLAND,WITNYYEARSAGO,IC    ACTED                    LLIAM    AND.HEWASOFANNESHADREDUCEDHIM OWA                       IONC NSEQUENTUPONHISDSIDENCEATSULLIVA \'S                          HC ROLINA.THISISLANOUTTHR    LESLON .        THATN  OINTE        U RTEROF    E.ITISTHROU       ERNE       DSANDSLI  ,AFAVOR        TOFT       HEN.T"##
        @Assert(testEncodeDecodeException(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,"Qrcoder4cjNotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Encode_15():Unit {
        var encode_src=##"2021200000"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_16():Unit {
        var encode_src=##"http://d.kaywa.com/20207100"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_17():Unit {
        var encode_src=##"http://staticrooster.com"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_18():Unit {
        var encode_src=##"The 2005 USGS aerial photography of the Washington Monument is censored."##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_19():Unit {
        var encode_src=##"http://bbc.co.uk/programmes"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_20():Unit {
        var encode_src=##"In 25 words or less in the comments, below, tell us how QR codes will make the world less ordinary."##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_21():Unit {
        var encode_src=##"http://www.hotpepper.jp/mobile/cgi-bin/MBLC80100.cgi?SA=00&Z=AG&vos=hpp064&uid=NULLGWDOCOMO"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_22():Unit {
        var encode_src=##"http://aniful.jp/pr/ "##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_23():Unit {
        var encode_src=##"MEBKM:TITLE:;URL:http://d.kaywa.com/2020400102;;"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_24():Unit {
        var encode_src=##"http://www.webtech.co.jp/k/"##
        @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Qrcode_Encode_25():Unit {
        var encode_src="""
BEGIN:VCARD
N:Kennedy;Steve
TEL:+44 (0)7775 755503
ADR;HOME:;;Flat 2, 43 Howitt Road, Belsize Park;London;;NW34LU;UK
ORG:NetTek Ltd;
TITLE:Consultant
EMAIL:steve@nettek.co.uk
URL:www.nettek.co.uk
EMAIL;IM:MSN:steve@gbnet.net
NOTE:Testing 1 2 3
BDAY:19611105
END:VCARD"""
        @Assert(testEncodeDecodeException(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,"NotFoundException"),0)
    }
}