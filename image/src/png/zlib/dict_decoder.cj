/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * zlib压缩算法
 */

package image.png.zlib
import image.internals.model.*
import image.internals.imageutil.*

/**
 * The class is DictDecoder
 * @author changeden
 */
public class DictDecoder {
    /* var member hist type is Array<UInt8> */
    var hist: Array<UInt8> = []

    /* var member wrPos type is Int64 */
    var wrPos: Int64 = 0

    /* var member rdPos type is Int64 */
    var rdPos: Int64 = 0

    /* var member full type is Bool */
    var full: Bool = false

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /*
     * The Function is initiator
     *
     * @param size of Int64
     * @param dict of ?Array<UInt8>
     */
    func initiator(size: Int64, dict: ?Array<UInt8>) {
        reset()

        this.hist = if (this.hist.size < size) {
            Array<UInt8>(size, repeat: 0)
        } else {
            this.hist[0..size]
        }

        var mdict = if (let Some(d) <- dict) {
            if (d.size > this.hist.size) {
                d[(d.size - this.hist.size)..d.size]
            } else {
                d
            }
        } else {
            Array<UInt8>()
        }

        this.wrPos = copy(this.hist, mdict)

        if (this.wrPos == this.hist.size) {
            this.wrPos = 0
            this.full = true
        }
        this.rdPos = this.wrPos
    }

    /*
     * The Function is reset
     *
     */
    func reset() {
        wrPos = 0
        rdPos = 0
        full = false
    }

    /*
     * The Function is histSize
     *
     * @return Type of Int64
     */
    func histSize(): Int64 {
        if (full) {
            hist.size
        } else {
            wrPos
        }
    }

    /*
     * The Function is availRead
     *
     * @return Type of Int64
     */
    func availRead(): Int64 {
        wrPos - rdPos
    }

    /*
     * The Function is availWrite
     *
     * @return Type of Int64
     */
    func availWrite(): Int64 {
        hist.size - wrPos
    }

    /*
     * The Function is writeSlice
     *
     * @return Type of Array<UInt8>
     */
    func writeSlice(): Array<UInt8> {
        hist[wrPos..hist.size]
    }

    /*
     * The Function is writeSlice
     *
     * @param b of Array<UInt8>
     */
    func writeSlice(b: Array<UInt8>) {
        copy(hist, b, dstStart: wrPos)
    }

    /*
     * The Function is writeMark
     *
     * @param cnt of Int64
     */
    func writeMark(cnt: Int64) {
        wrPos += cnt
    }

    /*
     * The Function is writeByte
     *
     * @param c of UInt8
     */
    func writeByte(c: UInt8) {
        hist[wrPos] = c
        wrPos++
    }

    /*
     * The Function is writeCopy
     *
     * @param dist of Int64
     * @param length of Int64
     *
     * @return Type of Int64
     */
    func writeCopy(dist: Int64, length: Int64): Int64 {
        let dstBase = this.wrPos
        var dstPos = dstBase
        var srcPos = dstPos - dist
        var endPos = dstPos + length
        if (endPos > hist.size) {
            endPos = hist.size
        }

        if (srcPos < 0) {
            srcPos += hist.size
            dstPos += copy(this.hist, this.hist, dstStart: dstPos, dstEnd: endPos, srcStart: srcPos)
            srcPos = 0
        }

        while (dstPos < endPos) {
            dstPos += copy(this.hist, this.hist, dstStart: dstPos, dstEnd: endPos, srcStart: srcPos, srcEnd: dstPos)
        }

        this.wrPos = dstPos
        dstPos - dstBase
    }

    /*
     * The Function is tryWriteCopy
     *
     * @param dist of Int64
     * @param length of Int64
     *
     * @return Type of Int64
     */
    func tryWriteCopy(dist: Int64, length: Int64): Int64 {
        var dstPos = this.wrPos
        let endPos = dstPos + length
        if (dstPos < dist || endPos > this.hist.size) {
            return 0
        }
        let dstBase = dstPos
        let srcPos = dstPos - dist

        // Copy possibly overlapping section before destination position.
        while (dstPos < endPos) {
            dstPos += copy(this.hist, this.hist, dstStart: dstPos, dstEnd: endPos, srcStart: srcPos, srcEnd: dstPos)
        }

        this.wrPos = dstPos
        dstPos - dstBase
    }

    /*
     * The Function is readFlush
     *
     * @return Type of Array<UInt8>
     */
    func readFlush(): Array<UInt8> {
        let toRead = hist[rdPos..wrPos]
        rdPos = wrPos
        if (wrPos == hist.size) {
            wrPos = 0
            rdPos = 0
            full = true
        }
        toRead
    }
}
