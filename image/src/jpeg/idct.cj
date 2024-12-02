/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * JPEG格式模块
 */
package image.jpeg

/* let member blockSize */
let blockSize = 64

/**
 * The class is Block inherited from ToString
 * @author changeden
 */
public class Block <: ToString {
    /** let member b type is Array<Int32> */
    public let b: Array<Int32> = Array<Int32>(blockSize, item: 0)

    /**
     * The Function is []
     *
     * @param index of Int64
     *
     * @return Type of Int32
     */
    public operator func [](index: Int64): Int32 {
        b[index]
    }

    /**
     * The Function is []
     *
     * @param index of Int64
     * @param value of Int32
     *
     * @return Type of Unit
     */
    public operator func [](index: Int64, value!: Int32): Unit {
        b[index] = value
    }

    /**
     * The Function is []
     *
     * @param range of Range<Int64>
     *
     * @return Type of Array<Int32>
     */
    public operator func [](range: Range<Int64>): Array<Int32> {
        b[range]
    }

    /**
     * The Function is size
     *
     */
    public func size() {
        b.size
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        b.toString()
    }
}

/* let member w1 type is Int32 */
let w1: Int32 = 2841 // 2048*sqrt(2)*cos(1*pi/16)
/* let member w2 type is Int32 */
let w2: Int32 = 2676 // 2048*sqrt(2)*cos(2*pi/16)
/* let member w3 type is Int32 */
let w3: Int32 = 2408 // 2048*sqrt(2)*cos(3*pi/16)
/* let member w5 type is Int32 */
let w5: Int32 = 1609 // 2048*sqrt(2)*cos(5*pi/16)
/* let member w6 type is Int32 */
let w6: Int32 = 1108 // 2048*sqrt(2)*cos(6*pi/16)
/* let member w7 type is Int32 */
let w7: Int32 = 565 // 2048*sqrt(2)*cos(7*pi/16)

/* let member w1pw7 */
let w1pw7 = w1 + w7
/* let member w1mw7 */
let w1mw7 = w1 - w7
/* let member w2pw6 */
let w2pw6 = w2 + w6
/* let member w2mw6 */
let w2mw6 = w2 - w6
/* let member w3pw5 */
let w3pw5 = w3 + w5
/* let member w3mw5 */
let w3mw5 = w3 - w5

/* let member r2 type is Int32 */
let r2: Int32 = 181 // 256/sqrt(2)

/*
 * The Function is idct
 *
 * @param src of Block
 *
 * @return Type of Unit
 */
func idct(src: Block): Unit {
    // Horizontal 1-D IDCT.
    for (y in 0..8) {
        let y8 = y * 8
        if (src[y8 + 1] == 0 && src[y8 + 2] == 0 && src[y8 + 3] == 0 && src[y8 + 4] == 0 && src[y8 + 5] == 0 &&
            src[y8 + 6] == 0 && src[y8 + 7] == 0) {
            let dc = src[y8 + 0] << 3
            src[y8 + 0] = dc
            src[y8 + 1] = dc
            src[y8 + 2] = dc
            src[y8 + 3] = dc
            src[y8 + 4] = dc
            src[y8 + 5] = dc
            src[y8 + 6] = dc
            src[y8 + 7] = dc
            continue
        }

        // Prescale.
        var x0 = (src[y8 + 0] << 11) + 128
        var x1 = src[y8 + 4] << 11
        var x2 = src[y8 + 6]
        var x3 = src[y8 + 2]
        var x4 = src[y8 + 1]
        var x5 = src[y8 + 7]
        var x6 = src[y8 + 5]
        var x7 = src[y8 + 3]

        // Stage 1.
        var x8 = w7 * (x4 + x5)
        x4 = x8 + w1mw7 * x4
        x5 = x8 - w1pw7 * x5
        x8 = w3 * (x6 + x7)
        x6 = x8 - w3mw5 * x6
        x7 = x8 - w3pw5 * x7

        // Stage 2.
        x8 = x0 + x1
        x0 -= x1
        x1 = w6 * (x3 + x2)
        x2 = x1 - w2pw6 * x2
        x3 = x1 + w2mw6 * x3
        x1 = x4 + x6
        x4 -= x6
        x6 = x5 + x7
        x5 -= x7

        // Stage 3.
        x7 = x8 + x3
        x8 -= x3
        x3 = x0 + x2
        x0 -= x2
        x2 = (r2 * (x4 + x5) + 128) >> 8
        x4 = (r2 * (x4 - x5) + 128) >> 8

        // Stage 4.
        src[y8 + 0] = (x7 + x1) >> 8
        src[y8 + 1] = (x3 + x2) >> 8
        src[y8 + 2] = (x0 + x4) >> 8
        src[y8 + 3] = (x8 + x6) >> 8
        src[y8 + 4] = (x8 - x6) >> 8
        src[y8 + 5] = (x0 - x4) >> 8
        src[y8 + 6] = (x3 - x2) >> 8
        src[y8 + 7] = (x7 - x1) >> 8
    }

    // Vertical 1-D IDCT.
    for (x in 0..8) {
        // Prescale.
        var y0 = (src[x + 8 * 0] << 8) + 8192
        var y1 = src[x + 8 * 4] << 8
        var y2 = src[x + 8 * 6]
        var y3 = src[x + 8 * 2]
        var y4 = src[x + 8 * 1]
        var y5 = src[x + 8 * 7]
        var y6 = src[x + 8 * 5]
        var y7 = src[x + 8 * 3]

        // Stage 1.
        var y8 = w7 * (y4 + y5) + 4
        y4 = (y8 + w1mw7 * y4) >> 3
        y5 = (y8 - w1pw7 * y5) >> 3
        y8 = w3 * (y6 + y7) + 4
        y6 = (y8 - w3mw5 * y6) >> 3
        y7 = (y8 - w3pw5 * y7) >> 3

        // Stage 2.
        y8 = y0 + y1
        y0 -= y1
        y1 = w6 * (y3 + y2) + 4
        y2 = (y1 - w2pw6 * y2) >> 3
        y3 = (y1 + w2mw6 * y3) >> 3
        y1 = y4 + y6
        y4 -= y6
        y6 = y5 + y7
        y5 -= y7

        // Stage 3.
        y7 = y8 + y3
        y8 -= y3
        y3 = y0 + y2
        y0 -= y2
        y2 = (r2 * (y4 + y5) + 128) >> 8
        y4 = (r2 * (y4 - y5) + 128) >> 8

        // Stage 4.
        src[x + 8 * 0] = (y7 + y1) >> 14
        src[x + 8 * 1] = (y3 + y2) >> 14
        src[x + 8 * 2] = (y0 + y4) >> 14
        src[x + 8 * 3] = (y8 + y6) >> 14
        src[x + 8 * 4] = (y8 - y6) >> 14
        src[x + 8 * 5] = (y0 - y4) >> 14
        src[x + 8 * 6] = (y3 - y2) >> 14
        src[x + 8 * 7] = (y7 - y1) >> 14
    }
}
