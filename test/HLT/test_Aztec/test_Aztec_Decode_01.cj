// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/aztec-1

@Test
public class TestQRCode4cjAztecDecode01{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/aztec-1/"
    @TestCase
    func test_Aztec_Decode_01():Unit {
        var image_src=imageBase+"abc-19x19C.png"
        var deRe="abcdefghijklmnopqrstuvwxyz"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_02():Unit {
        var image_src=imageBase+"abc-37x37.png"
        var deRe="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_03():Unit {
        var image_src=imageBase+"dlusbs.png"
        var deRe="3333h3i3jITIT"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_04():Unit {
        var image_src=imageBase+"hello.png"
        var deRe="hello"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_05():Unit {
        var image_src=imageBase+"hello-with-errors.png"
        var deRe="hello"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_06():Unit {
        var image_src=imageBase+"Historico.png"
        var deRe="Histórico"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_07():Unit {
        var image_src=imageBase+"HistoricoLong.png"
        var deRe="Históóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóóórico"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_08():Unit {
        var image_src=imageBase+"lorem-075x075.png"
        var deRe="In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_09():Unit {
        var image_src=imageBase+"lorem-105x105.jpg"
        var deRe="In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_10():Unit {
        var image_src=imageBase+"lorem-131x131.jpg"
        var deRe="In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p. In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tris. In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo e."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_11():Unit {
        var image_src=imageBase+"lorem-151x151.jpg"
        var deRe="In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p. In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tristique ac, p.In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem. Nulla ultrices, elit pellentesque aliquet laoreet, justo erat pulvinar nisi, id elementum sapien dolor et diam. Donec ac nunc sodales elit placerat eleifend. Sed ornare luctus ornare. Vestibulum vehicula, massa at pharetra fringilla, risus justo faucibus erat, nec porttitor nibh tellus sed est. Ut justo diam, lobortis eu tris. In ut magna vel mauris malesuada dictum. Nulla ullamcorper metus quis diam cursus facilisis. Sed mollis quam id justo rutrum sagittis. Donec laoreet rutrum est, nec convallis mauris condimentum sit amet. Phasellus gravida, justo et congue auctor, nisi ipsum viverra erat, eget hendrerit felis turpis nec lorem."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_12():Unit {
        var image_src=imageBase+"tableShifts.png"
        var deRe="AhUUDgdy672;..:8KjHH776JHHn3g. 8lm/%22Nn873R2897ks4JKDJ9JJaza2323!::;09UJRrhDQSKJDKdSJSdskjdslkEdjseze:ze"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_13():Unit {
        var image_src=imageBase+"tag.png"
        var deRe="Ceci est un tag."
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_14():Unit {
        var image_src=imageBase+"texte.png"
        var deRe="Ceci est un texte!"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Aztec_Decode_15():Unit {
        var image_src=imageBase+"7.png"
        var deRe="Code 2D!"
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}