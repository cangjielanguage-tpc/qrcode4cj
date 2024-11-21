/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * JPEG格式模块
 */
package image.jpeg

/* let member fix_0_298631336 type is Int32 */
let fix_0_298631336: Int32 = 2446

/* let member fix_0_390180644 type is Int32 */
let fix_0_390180644: Int32 = 3196

/* let member fix_0_541196100 type is Int32 */
let fix_0_541196100: Int32 = 4433

/* let member fix_0_765366865 type is Int32 */
let fix_0_765366865: Int32 = 6270

/* let member fix_0_899976223 type is Int32 */
let fix_0_899976223: Int32 = 7373

/* let member fix_1_175875602 type is Int32 */
let fix_1_175875602: Int32 = 9633

/* let member fix_1_501321110 type is Int32 */
let fix_1_501321110: Int32 = 12299

/* let member fix_1_847759065 type is Int32 */
let fix_1_847759065: Int32 = 15137

/* let member fix_1_961570560 type is Int32 */
let fix_1_961570560: Int32 = 16069

/* let member fix_2_053119869 type is Int32 */
let fix_2_053119869: Int32 = 16819

/* let member fix_2_562915447 type is Int32 */
let fix_2_562915447: Int32 = 20995

/* let member fix_3_072711026 type is Int32 */
let fix_3_072711026: Int32 = 25172

/* let member constBits type is Int32 */
let constBits: Int32 = 13

/* let member pass1Bits type is Int32 */
let pass1Bits: Int32 = 2

/* let member centerJSample type is Int32 */
let centerJSample: Int32 = 128

/*
 * The Function is fdct
 *
 * @param src of Block
 *
 * @return Type of Unit
 */
func fdct(src: Block): Unit {
    // Pass 1: process rows.
    for (y in 0..8) {
        var y8 = y * 8
        var x0 = src[y8 + 0]
        var x1 = src[y8 + 1]
        var x2 = src[y8 + 2]
        var x3 = src[y8 + 3]
        var x4 = src[y8 + 4]
        var x5 = src[y8 + 5]
        var x6 = src[y8 + 6]
        var x7 = src[y8 + 7]

        var tmp0 = x0 + x7
        var tmp1 = x1 + x6
        var tmp2 = x2 + x5
        var tmp3 = x3 + x4

        var tmp10 = tmp0 + tmp3
        var tmp12 = tmp0 - tmp3
        var tmp11 = tmp1 + tmp2
        var tmp13 = tmp1 - tmp2

        tmp0 = x0 - x7
        tmp1 = x1 - x6
        tmp2 = x2 - x5
        tmp3 = x3 - x4

        src[y8 + 0] = (tmp10 + tmp11 - 8 * centerJSample) << pass1Bits
        src[y8 + 4] = (tmp10 - tmp11) << pass1Bits
        var z1 = (tmp12 + tmp13) * fix_0_541196100
        z1 += 1 << (constBits - pass1Bits - 1)
        src[y8 + 2] = (z1 + tmp12 * fix_0_765366865) >> (constBits - pass1Bits)
        src[y8 + 6] = (z1 - tmp13 * fix_1_847759065) >> (constBits - pass1Bits)

        tmp10 = tmp0 + tmp3
        tmp11 = tmp1 + tmp2
        tmp12 = tmp0 + tmp2
        tmp13 = tmp1 + tmp3
        z1 = (tmp12 + tmp13) * fix_1_175875602
        z1 += 1 << (constBits - pass1Bits - 1)
        tmp0 *= fix_1_501321110
        tmp1 *= fix_3_072711026
        tmp2 *= fix_2_053119869
        tmp3 *= fix_0_298631336
        tmp10 *= -fix_0_899976223
        tmp11 *= -fix_2_562915447
        tmp12 *= -fix_0_390180644
        tmp13 *= -fix_1_961570560

        tmp12 += z1
        tmp13 += z1
        src[y8 + 1] = (tmp0 + tmp10 + tmp12) >> (constBits - pass1Bits)
        src[y8 + 3] = (tmp1 + tmp11 + tmp13) >> (constBits - pass1Bits)
        src[y8 + 5] = (tmp2 + tmp11 + tmp12) >> (constBits - pass1Bits)
        src[y8 + 7] = (tmp3 + tmp10 + tmp13) >> (constBits - pass1Bits)
    }

    // Pass 2: process columns.
    // We remove pass1Bits scaling, but leave results scaled up by an overall factor of 8.
    for (x in 0..8) {
        var tmp0 = src[0 * 8 + x] + src[7 * 8 + x]
        var tmp1 = src[1 * 8 + x] + src[6 * 8 + x]
        var tmp2 = src[2 * 8 + x] + src[5 * 8 + x]
        var tmp3 = src[3 * 8 + x] + src[4 * 8 + x]

        var tmp10 = tmp0 + tmp3 + (1 << (pass1Bits - 1))
        var tmp12 = tmp0 - tmp3
        var tmp11 = tmp1 + tmp2
        var tmp13 = tmp1 - tmp2

        tmp0 = src[0 * 8 + x] - src[7 * 8 + x]
        tmp1 = src[1 * 8 + x] - src[6 * 8 + x]
        tmp2 = src[2 * 8 + x] - src[5 * 8 + x]
        tmp3 = src[3 * 8 + x] - src[4 * 8 + x]

        src[0 * 8 + x] = (tmp10 + tmp11) >> pass1Bits
        src[4 * 8 + x] = (tmp10 - tmp11) >> pass1Bits

        var z1 = (tmp12 + tmp13) * fix_0_541196100
        z1 += 1 << (constBits + pass1Bits - 1)
        src[2 * 8 + x] = (z1 + tmp12 * fix_0_765366865) >> (constBits + pass1Bits)
        src[6 * 8 + x] = (z1 - tmp13 * fix_1_847759065) >> (constBits + pass1Bits)

        tmp10 = tmp0 + tmp3
        tmp11 = tmp1 + tmp2
        tmp12 = tmp0 + tmp2
        tmp13 = tmp1 + tmp3
        z1 = (tmp12 + tmp13) * fix_1_175875602
        z1 += 1 << (constBits + pass1Bits - 1)
        tmp0 *= fix_1_501321110
        tmp1 *= fix_3_072711026
        tmp2 *= fix_2_053119869
        tmp3 *= fix_0_298631336
        tmp10 *= -fix_0_899976223
        tmp11 *= -fix_2_562915447
        tmp12 *= -fix_0_390180644
        tmp13 *= -fix_1_961570560

        tmp12 += z1
        tmp13 += z1
        src[1 * 8 + x] = (tmp0 + tmp10 + tmp12) >> (constBits + pass1Bits)
        src[3 * 8 + x] = (tmp1 + tmp11 + tmp13) >> (constBits + pass1Bits)
        src[5 * 8 + x] = (tmp2 + tmp11 + tmp12) >> (constBits + pass1Bits)
        src[7 * 8 + x] = (tmp3 + tmp10 + tmp13) >> (constBits + pass1Bits)
    }
}
