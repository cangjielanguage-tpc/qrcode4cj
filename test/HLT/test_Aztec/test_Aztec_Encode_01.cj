// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj

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
public class TestQRCode4cjAztecEncode01 {
    var cur_en_hints = Option<HashMap<EncodeHintType, Any>>.None
    var cur_de_hints = Option<HashMap<DecodeHintType, Any>>.Some(
        HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER, true)]))
    @TestCase
    func test_Aztec_Encode_01(): Unit {
        var encode_src = "abcdefghijklmnopqrstuvwxyz"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_02(): Unit {
        var encode_src = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_03(): Unit {
        var encode_src = "3333h3i3jITIT"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_04(): Unit {
        var encode_src = "hello"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_05(): Unit {
        var encode_src = "Histórico"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_06(): Unit {
        var encode_src = "Históóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóórico"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_07(): Unit {
        var encode_src = "In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_08(): Unit {
        var encode_src = "In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
    @TestCase
    func test_Aztec_Encode_09(): Unit {
        var encode_src = "In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p. In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tris. In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo e."
        @Assert(testEncodeException(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,"Data too large for an Aztec code"),0)

    }
    @TestCase
    func test_Aztec_Encode_10(): Unit {
        var encode_src = "In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p. In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tris. In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem."
        @Assert(testEncodeException(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,"Data too large for an Aztec code"),0)
    }
    @TestCase
    func test_Aztec_Encode_11(): Unit {
        var encode_src = "AhUUDgdy672;..:8KjHH776JHHn3g. 8lm/%22Nn873R2897ks4JKDJ9JJaza2323!::;09UJRrhDQSKJDKdSJSdskjdslkEdjseze:ze"
        @Assert(testNormal(BarcodeFormat.AZTEC,encode_src,480,360,cur_en_hints,cur_de_hints,encode_src),0)
    }
}
