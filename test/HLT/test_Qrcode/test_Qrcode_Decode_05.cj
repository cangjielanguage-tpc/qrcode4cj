// 3rd_party_lib:qrcode4cj/build/QRCode4cj:qrcode4cj/build/charset:qrcode4cj/build/image
// 3rd_party_lib_ohos:qrcode4cj/build/aarch64-linux-ohos/QRCode4cj:qrcode4cj/build/aarch64-linux-ohos/charset:qrcode4cj/build/aarch64-linux-ohos/image
// dependence: ../image.cj
// dependence: ../LogicEnAndDe.cj
// data_file: ../resources/blackbox/qrcode-5

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
public class TestQRCode4cjQrcodeDecode05{
    var cur_de_hints=Option<HashMap<DecodeHintType, Any>>.Some(HashMap<DecodeHintType, Any>([(DecodeHintType.TRY_HARDER,true)]))
    let imageBase="../resources/blackbox/qrcode-5/"
    @TestCase
    func test_Qrcode_Decode_01():Unit {
        var image_src=imageBase+"01.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_02():Unit {
        var image_src=imageBase+"02.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_03():Unit {
        var image_src=imageBase+"03.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_04():Unit {
        var image_src=imageBase+"04.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_05():Unit {
        var image_src=imageBase+"05.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_06():Unit {
        var image_src=imageBase+"06.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_07():Unit {
        var image_src=imageBase+"07.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_08():Unit {
        var image_src=imageBase+"08.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_09():Unit {
        var image_src=imageBase+"09.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_10():Unit {
        var image_src=imageBase+"10.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_11():Unit {
        var image_src=imageBase+"11.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_12():Unit {
        var image_src=imageBase+"12.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_13():Unit {
        var image_src=imageBase+"13.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_14():Unit {
        var image_src=imageBase+"14.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_15():Unit {
        var image_src=imageBase+"15.png"
        var deRe=###"MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;"###
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_16():Unit {
        var image_src=imageBase+"16.png"
        var deRe="""
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
Wha
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_17():Unit {
        var image_src=imageBase+"17.png"
        var deRe="""
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
bonfire--and it wants plenty of sticks, Kitty! Only it 
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_18():Unit {
        var image_src=imageBase+"18.png"
        var deRe="""
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
scrambled back into the arm-ch\n
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
    @TestCase
    func test_Qrcode_Decode_19():Unit {
        var image_src=imageBase+"19.png"
        var deRe="""
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
midd
"""
        @Assert(testDecodeNormal(image_src,cur_de_hints,deRe,Array<String>(),"Single"),0)
    }
}