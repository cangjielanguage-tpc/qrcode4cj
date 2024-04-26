// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ./Qrcode

@Test
public class TestQRCode4cjQrcodeDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="./Qrcode/"
    @TestCase
    func test_Qrcode_Decode_01():Unit {
        var image_src=imageBase+"01.jpg"
        var deRe="https://zh.qr-code.net/#link"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_02():Unit {
        var image_src=imageBase+"02.jpg"
        var deRe="mailto:1244810097@qq.com?subject=加班&body=%E5%8A%A0%E7%8F%AD%E7%94%B3%E8%AF%B7"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_03():Unit {
        var image_src=imageBase+"03.jpg"
        var deRe="geo:45,55?q=45,55"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_04():Unit {
        var image_src=imageBase+"04.jpg"
        var deRe="SMSTO:+784018245628521:你好，这里是中国移动"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_05():Unit {
        var image_src=imageBase+"05.jpg"
        var deRe="tel:18391821016"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_06():Unit {
        var image_src=imageBase+"06.jpg"
        var deRe="https://wa.me/24478545621/?text=%E4%BD%A0%E5%A5%BD%EF%BC%8C244"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_07():Unit {
        var image_src=imageBase+"07.jpg"
        var deRe="skype:%E6%B3%9B%E6%B3%9B%E4%B9%8B%E4%BA%A4?chat"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_08():Unit {
        var image_src=imageBase+"08.jpg"
        var deRe="skype:%E6%B3%9B%E6%B3%9B%E4%B9%8B%E4%BA%A4?call"  // skype
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_09():Unit {
        var image_src=imageBase+"09.jpg"
        var deRe="https://zoom.us/j/201452236?pwd=1213456"    //会议
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_10():Unit {
        var image_src=imageBase+"10.jpg"
        var deRe="WIFI:S:fj;T:WEP;P:12345;;"  //wifi
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_11():Unit {
        var image_src=imageBase+"11.jpg"
        var deRe="WIFI:S:fj;T:WPA;P:12345;;"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_12():Unit {
        var image_src=imageBase+"12.jpg"
        var deRe="WIFI:S:fj;P:12345;;"      //wifi
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_13():Unit {
        var image_src=imageBase+"13.jpg"
        var deRe="""
BEGIN:VCARD
VERSION:3.0
N;CHARSET=UTF-8:fang;kitty;;建行;
FN;CHARSET=UTF-8:建行 kitty fang
TEL;TYPE=CELL:18264523698
TEL;TYPE=HOME,VOICE:32032028
TEL;TYPE=WORK,VOICE:18396854562
TEL;TYPE=FAX,WORK:18625452363
END:VCARD"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)    //联系人信息，信用卡
    }
    @TestCase
    func test_Qrcode_Decode_14():Unit {
        var image_src=imageBase+"14.jpg"
        var deRe="""
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//QRcdr//QRcdr 4.0//EN
BEGIN:VEVENT
LOCATION:绅嘉苑
DTSTART:20240417T032100Z
DTEND:20240503T032100Z
SUMMARY:ty
DESCRIPTION:gsgdsdgsdgsd
URL:http://gasfgagasgkk
CLASS:PUBLIC
BEGIN:VALARM
TRIGGER:-PT6H
ACTION:DISPLAY
DESCRIPTION:Reminder
END:VALARM
END:VEVENT
END:VCALENDAR"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)   //活动，记事录
    }
    @TestCase
    func test_Qrcode_Decode_15():Unit {
        var image_src=imageBase+"15.jpg"    //paypal
        var deRe="https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=1244810097%40qq.com&item_name=%E6%B4%97%E8%A1%A3%E6%B6%B2&amount=&currency_code=USD&button_subtype=services&bn=PP-BuyNowBF%3Abtn_buynow_LG.gif%3ANonHostedGuest&lc=US&no_note=0"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_16():Unit {
        var image_src=imageBase+"16.jpg"
        var deRe="bitcoin:65895456233555?amount=25462123636"   //比特币
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_17():Unit {
        var image_src=imageBase+"17.jpg"
        var deRe="https://zh.qr-code.net/#link"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_18():Unit {
        var image_src=imageBase+"18.jpg"
        var deRe="https://zh.qr-code.net/#link"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_19():Unit {
        var image_src=imageBase+"19.jpg"
        var deRe="https://zh.qr-code.net/#link"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_20():Unit {
        var image_src=imageBase+"20.jpg"
        var deRe="https://zh.qr-code.net/#link"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}
