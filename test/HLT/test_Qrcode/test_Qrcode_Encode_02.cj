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
    func test_Qrcode_Encode_05():Unit {
        var encode_src_legal=Array<String>([##"http://arnaud.sahuguet.com/graffiti/test.php?ll=-74.00309961503218,40.74102573163046,0"##,
                                            ##"MECARD:N:Google 411,;TEL:18665881077;;"##,
                                            """
UI office hours signup
http://www.corp.google.com/sparrow/ui_office_hours/""",
                                            ##"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"##
                                            ])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
    @TestCase
    func test_Qrcode_Encode_06():Unit {
        var encode_src_legal=Array<String>([##"Google Print Ads - T.G.I.A.F. - January 31, 2008"##,
                                            ##"http://code.google.com"##,
                                            """
UI office hours signup
http://www.corp.google.com/sparrow/ui_office_hours/""",
                                            ##"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"##,
                                            ##"http://code.google.com/p/zxing/"##
                                            ])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)

        }
    }
    @TestCase
    func test_Qrcode_Encode_07():Unit {
        var encode_src="""
THROUGH THE LOOKING-GLASS

By Lewis Carroll


CHAPTER I. Looking-Glass house

One thing was certain, that the WHITE kitten had had nothing to do with
it:--it was the black kitten's fault entirely. For the white kitten had
been having its face washed by the old cat for the last quarter of
an hour (and bearing it pretty well, considering); so you see that it
COULDN'T have had any hand in the mischief.

The way Dinah washed her children's faces was this: first she held the
poor thing down by its ear with one paw, and then with the other paw she
rubbed its face all over, the wrong way, beginning at the nose: and
just now, as I said, she was hard at work on the white kitten, which was
lying quite still and trying to purr--no doubt feeling that it was all
meant for its good.

But the black kitten had been finished with earlier in the afternoon,
and so, while Alice was sitting curled up in a corner of the great
arm-chair, half talking to herself and half asleep, the kitten had been
having a grand game of romps with the ball of worsted Alice had been
trying to wind up, and had been rolling it up and down till it had all
come undone again; and there it was, spread over the hearth-rug, all
knots and tangles, with the kitten running after its own tail in the
middle.

'Oh, you wicked little thing!' cried Alice, catching up the kitten, and
giving it a little kiss to make it understand that it was in disgrace.
'Really, Dinah ought to have taught you better manners! You OUGHT,
Dinah, you know you ought!' she added, looking reproachfully at the old
cat, and speaking in as cross a voice as she could manage--and then she
scrambled back into the arm-chair, taking the kitten and the worsted
with her, and began winding up the ball again. But she didn't get on
very fast, as she was talking all the time, sometimes to the kitten, and
sometimes to herself. Kitty sat very demurely on her knee, pretending to
watch the progress of the winding, and now and then putting out one
paw and gently touching the ball, as if it would be glad to help, if it
might.

'Do you know what to-morrow is, Kitty?' Alice began. 'You'd have guessed
if you'd been up in the window with me--only Dinah was making you tidy,
so you couldn't. I was watching the boys getting in sticks for the
bonfire--and it wants plenty of sticks, Kitty! Only it got so cold, and
it snowed so, they had to leave off. Never mind, Kitty, we'll go and
see the bonfire to-morrow.' Here Alice wound two or three turns of the
worsted round the kitten's neck, just to see how it would look: this led
to a scramble, in which the ball rolled down upon the floor, and yards
and yards of it got unwound again.

'Do you know, I was so angry, Kitty,' Alice went on as soon as they were
comfortably settled again, 'when I saw all the mischief you had been
doing, I was very nearly opening the window, and putting you out into
the snow! And you'd have deserved it, you little mischievous darling!
Wha"""
        @Assert(testEncodeDecodeException(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,"Qrcoder4cjNotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Encode_08():Unit {
        var encode_src= """
THROUGH THE LOOKING-GLASS1

By Lewis Carroll


CHAPTER I. Looking-Glass house

One thing was certain, that the WHITE kitten had had nothing to do with
it:--it was the black kitten's fault entirely. For the white kitten had
been having its face washed by the old cat for the last quarter of
an hour (and bearing it pretty well, considering); so you see that it
COULDN'T have had any hand in the mischief.

The way Dinah washed her children's faces was this: first she held the
poor thing down by its ear with one paw, and then with the other paw she
rubbed its face all over, the wrong way, beginning at the nose: and
just now, as I said, she was hard at work on the white kitten, which was
lying quite still and trying to purr--no doubt feeling that it was all
meant for its good.

But the black kitten had been finished with earlier in the afternoon,
and so, while Alice was sitting curled up in a corner of the great
arm-chair, half talking to herself and half asleep, the kitten had been
having a grand game of romps with the ball of worsted Alice had been
trying to wind up, and had been rolling it up and down till it had all
come undone again; and there it was, spread over the hearth-rug, all
knots and tangles, with the kitten running after its own tail in the
middle.

'Oh, you wicked little thing!' cried Alice, catching up the kitten, and
giving it a little kiss to make it understand that it was in disgrace.
'Really, Dinah ought to have taught you better manners! You OUGHT,
Dinah, you know you ought!' she added, looking reproachfully at the old
cat, and speaking in as cross a voice as she could manage--and then she
scrambled back into the arm-chair, taking the kitten and the worsted
with her, and began winding up the ball again. But she didn't get on
very fast, as she was talking all the time, sometimes to the kitten, and
sometimes to herself. Kitty sat very demurely on her knee, pretending to
watch the progress of the winding, and now and then putting out one
paw and gently touching the ball, as if it would be glad to help, if it
might.

'Do you know what to-morrow is, Kitty?' Alice began. 'You'd have guessed
if you'd been up in the window with me--only Dinah was making you tidy,
so you couldn't. I was watching the boys getting in sticks for the
bonfire--and it wants plenty of sticks, Kitty! Only it """
        @Assert(testEncodeDecodeException(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,"Qrcoder4cjNotFoundException"),0)
    }

    @TestCase
    func test_Qrcode_Encode_09():Unit {
        var encode_src="""
THROUGH THE LOOKING-GLASS2

By Lewis Carroll


CHAPTER I. Looking-Glass house

One thing was certain, that the WHITE kitten had had nothing to do with
it:--it was the black kitten's fault entirely. For the white kitten had
been having its face washed by the old cat for the last quarter of
an hour (and bearing it pretty well, considering); so you see that it
COULDN'T have had any hand in the mischief.

The way Dinah washed her children's faces was this: first she held the
poor thing down by its ear with one paw, and then with the other paw she
rubbed its face all over, the wrong way, beginning at the nose: and
just now, as I said, she was hard at work on the white kitten, which was
lying quite still and trying to purr--no doubt feeling that it was all
meant for its good.

But the black kitten had been finished with earlier in the afternoon,
and so, while Alice was sitting curled up in a corner of the great
arm-chair, half talking to herself and half asleep, the kitten had been
having a grand game of romps with the ball of worsted Alice had been
trying to wind up, and had been rolling it up and down till it had all
come undone again; and there it was, spread over the hearth-rug, all
knots and tangles, with the kitten running after its own tail in the
middle.

'Oh, you wicked little thing!' cried Alice, catching up the kitten, and
giving it a little kiss to make it understand that it was in disgrace.
'Really, Dinah ought to have taught you better manners! You OUGHT,
Dinah, you know you ought!' she added, looking reproachfully at the old
cat, and speaking in as cross a voice as she could manage--and then she
scrambled back into the arm-ch"""
        @Assert(testEncodeDecodeException(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,"Qrcoder4cjNotFoundException"),0)
    }

    @TestCase
    func test_Qrcode_Encode_10():Unit {
        var encode_src="""
THROUGH THE LOOKING-GLASS3

By Lewis Carroll


CHAPTER I. Looking-Glass house

One thing was certain, that the WHITE kitten had had nothing to do with
it:--it was the black kitten's fault entirely. For the white kitten had
been having its face washed by the old cat for the last quarter of
an hour (and bearing it pretty well, considering); so you see that it
COULDN'T have had any hand in the mischief.

The way Dinah washed her children's faces was this: first she held the
poor thing down by its ear with one paw, and then with the other paw she
rubbed its face all over, the wrong way, beginning at the nose: and
just now, as I said, she was hard at work on the white kitten, which was
lying quite still and trying to purr--no doubt feeling that it was all
meant for its good.

But the black kitten had been finished with earlier in the afternoon,
and so, while Alice was sitting curled up in a corner of the great
arm-chair, half talking to herself and half asleep, the kitten had been
having a grand game of romps with the ball of worsted Alice had been
trying to wind up, and had been rolling it up and down till it had all
come undone again; and there it was, spread over the hearth-rug, all
knots and tangles, with the kitten running after its own tail in the
midd
"""
        @Assert(testEncodeDecodeException(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,"Qrcoder4cjNotFoundException"),0)
    }
    @TestCase
    func test_Qrcode_Encode_11():Unit {
        var encode_src_legal=Array<String>([##"1234567890"##,
                                            ##"TEST"##])
        for (encode_src in encode_src_legal){
            @Assert(testNormal(BarcodeFormat.QR_CODE,encode_src,120,120,cur_en_hints,cur_de_hints,encode_src),0)
        }
    }
}