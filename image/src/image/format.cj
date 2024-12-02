/*
 * Copyright (c) Cangjie Library Team 2022-2022. All rights resvered.
 */

/**
 * @file
 * This file is about: Picture library factory mode packaging.
 */

package image.image

import std.io.*
import std.sync.*
import std.fs.*
import std.collection.*
import image.internals.model.*

/*
 * The class is format inherited from ToString
 * @author changeden
 */
class format {
    /** var member name type is String */
    public var name: String

    /** var member magic type is Array<UInt8> */
    public var magic: Array<UInt8>

    /** var member decode type is ?(BufferedInputStream) -> Image */
    public var decode: ?(BufferedInputStream<InputStream>) -> Image = None

    /** var member decodeConfig type is ?(BufferedInputStream) -> Config */
    public var decodeConfig: ?(BufferedInputStream<InputStream>) -> Config = None

    /**
     * The Function is init constructor
     *
     * @param name of String
     * @param magic of Array<UInt8>
     * @param decode of ?(BufferedInputStream)->Image
     * @param decodeConfig of ?(BufferedInputStream)->Config
     */
    public init(
        name: String,
        magic: Array<UInt8>,
        decode: ?(BufferedInputStream<InputStream>) -> Image,
        decodeConfig: ?(BufferedInputStream<InputStream>) -> Config
    ) {
        this.name = name
        this.magic = magic
        this.decode = decode
        this.decodeConfig = decodeConfig
    }
}

/* let member formatsMu type is ReentrantMutex */
let formatsMu: ReentrantMutex = ReentrantMutex()

/* let member formats type is collection.ArrayList<format> */
let formats: ArrayList<format> = ArrayList<format>()

/**
 * 注册图片格式模块
 *
 * @param name of String 格式名
 * @param magic of String 格式幻数
 * @param decode of (BufferedInputStream)->Image 解码器
 * @param decodeConfig of (BufferedInputStream)->Config 信息获取器
 *
 * @return Type of Unit
 */
public func registerFormat(
    name: String,
    magic: String,
    decode: (BufferedInputStream<InputStream>) -> Image,
    decodeConfig: (BufferedInputStream<InputStream>) -> Config
): Unit {
    registerFormat(name, magic.toArray(), decode, decodeConfig)
}

/**
 * 注册图片格式模块
 *
 * @param name of String 格式名
 * @param magic of Array<UInt8> 格式幻数
 * @param decode of (BufferedInputStream)->Image 解码器
 * @param decodeConfig of (BufferedInputStream)->Config 信息获取器
 *
 * @return Type of Unit
 */
public func registerFormat(
    name: String,
    magic: Array<UInt8>,
    decode: (BufferedInputStream<InputStream>) -> Image,
    decodeConfig: (BufferedInputStream<InputStream>) -> Config
): Unit {
    formatsMu.lock()
    formats.append(format(name, magic, decode, decodeConfig))
    formatsMu.unlock()
}

/*
 * The Function is matchMagic
 *
 * @param magic of Array<UInt8>
 * @param b of Array<UInt8>
 *
 * @return Type of Bool
 */
@OverflowWrapping
func matchMagic(magic: Array<UInt8>, b: Array<UInt8>): Bool {
    let a = magic
    if (a.size != b.size) {
        return false
    }
    for (i in 0..a.size) {
        if (a[i] != b[i] && a[i] != 63) {
            return false
        }
    }
    return true
}

/*
 * The Function is sniff
 *
 * @param r of BufferStreamWrapper
 *
 * @return Type of format
 */
func sniff(r: BufferStreamWrapper): format {
    for (f in formats) {
        try {
            r.reset()
            let b = Array<UInt8>(f.magic.size, item: 0)
            r.buf.read(b)
            r.reset()
            if (matchMagic(f.magic, b)) {
                return f
            }
        } catch (e: Exception) {}
    }
    format("", [], None, None)
}

/*
 * The class is BufferStreamWrapper
 * @author changeden
 */
class BufferStreamWrapper {
    /* var member src type is File */
    var src: File

    /** let member buf type is BufferedInputStream */
    public let buf: BufferedInputStream<InputStream>

    /*
     * The Function is init constructor
     *
     * @param src of File
     */
    init(src: File) {
        this.src = src
        this.buf = BufferedInputStream(src)
    }

    /*
     * The Function is reset
     *
     */
    func reset() {
        src.seek(Begin(0))
        buf.reset(src)
    }
}

/**
 * 通用解码器
 *
 * @param r of File 文件流
 *
 * @return Type of (Image, String)
 */
public func decodeFormat(r: File): (Image, String) {
    let bs = BufferStreamWrapper(r)
    try {
        let f = sniff(bs)
        match (f.decode) {
            case Some(d) => (d(bs.buf), f.name)
            case _ => throw Exception("image: unknown format")
        }
    } catch (e: Exception) {
        throw e
    } finally {
        r.close()
    }
}

/**
 * 通用信息获取器
 *
 * @param r of File 文件流
 *
 * @return Type of (Config, String)
 */
public func decodeFormatConfig(r: File): (Config, String) {
    let bs = BufferStreamWrapper(r)
    try {
        let f = sniff(bs)
        match (f.decodeConfig) {
            case Some(d) => (d(bs.buf), f.name)
            case _ => throw Exception("image: unknown format")
        }
    } catch (e: Exception) {
        throw e
    } finally {
        r.close()
    }
}
