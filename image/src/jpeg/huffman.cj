/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * JPEG格式模块
 */
package image.jpeg

// maxCodeLength is the maximum (inclusive) number of bits in a Huffman code.
/* let member maxCodeLength */
let maxCodeLength = 16

// maxNCodes is the maximum (inclusive) number of codes in a Huffman tree.
/* let member maxNCodes */
let maxNCodes = 256

// lutSize is the log-2 size of the Huffman decoder's look-up table.
/* let member lutSize */
let lutSize = 8

/**
 * The class is Huffman
 * @author changeden
 */
public class Huffman {
    /** var member nCodes type is Int32 */
    public var nCodes: Int32 = 0
    /** let member lut type is Array<UInt16> */
    public let lut: Array<UInt16> = Array<UInt16>(1 << lutSize, repeat: 0)
    /** let member vals type is Array<UInt8> */
    public let vals: Array<UInt8> = Array<UInt8>(maxNCodes, repeat: 0)
    /** let member minCodes type is Array<Int32> */
    public let minCodes: Array<Int32> = Array<Int32>(maxCodeLength, repeat: 0)
    /** let member maxCodes type is Array<Int32> */
    public let maxCodes: Array<Int32> = Array<Int32>(maxCodeLength, repeat: 0)
    /** let member valsIndices type is Array<Int32> */
    public let valsIndices: Array<Int32> = Array<Int32>(maxCodeLength, repeat: 0)
}

/* let member errShortHuffmanData */
let errShortHuffmanData = FormatError("short Huffman data")
