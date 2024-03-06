from std import fs.*
from std import time.*
from std import collection.*
from std import math.*
from std import convert.*
from std import log.*
from std import os.posix.*
from QRCode4cj import zxing.code.aztec.common.*
from QRCode4cj import zxing.code.common.BitMatrix
from QRCode4cj import zxing.code.common.LuminanceSource
from QRCode4cj import zxing.code.common.BinaryBitmap
from QRCode4cj import zxing.code.common.BarcodeFormat
from QRCode4cj import zxing.code.common.DecodeHintType
from QRCode4cj import zxing.code.common.Result
from QRCode4cj import zxing.code.common.HybridBinarizer
from QRCode4cj import zxing.code.common.reader.MultiFormatReader
from QRCode4cj import zxing.code.common.writer.MultiFormatWriter
from image import color.*
from image import image.*
from image import drawer.*
from image import internals.model.*
from image import internals.imageutil.*
from image import png.*
from image import png.zlib.*
from image import jpeg.*

public class CvImageForZxing {
    var width: Int64 = 0
    var height: Int64 = 0
    var dataType: Int64 = 0
    var frameCount: Int64 = 0
    var cjImageData: Array<UInt8> = Array<UInt8>()

    @OverflowWrapping
    public func opencvReadImg(path0: String): Image {
        var width: Int64 = 0
        var height: Int64 = 0
        var dataType: Int64 = 0
        var channelNum: Int64 = 0
        var len: Int64 = 0
        var img: Image

        var imageData: internals.model.Image = nilImage
        try (fsI = File(path0, OpenOption.Open(true, false))) {
            if (fsI.canRead()) {
                var extensionName = fsI.info.path.extensionName
                if (extensionName == "png") {
                    // 添加PNG模块
                    png.register()
                    imageData = png.decode(fsI) // 解码图片
                } else if (extensionName == "jpg") {
                    // 添加JPEG模块
                    jpeg.register()
                    imageData = jpeg.decode(fsI)
                } else {
                    throw Exception("not support ${extensionName}")
                }
            } else {
                throw Exception("File can not read")
            }
        }

        width = imageData.bounds().max.x
        height = imageData.bounds().max.y

        len = width * height * 4

        var cjdata = Array<UInt8>(len, item: 0)
        var x: Int64 = 0
        var y: Int64 = 0
        for (i in 0..(len) : 4) {
            var (r, g, b, _) = imageData.at(y, x).rgba()
            cjdata[i] = UInt8(round(Float32(r) / 65535.0 *255.0))
            cjdata[i + 1] = UInt8(round(Float32(g) / 65535.0 *255.0))
            cjdata[i + 2] = UInt8(round(Float32(b) / 65535.0 *255.0))
            cjdata[i + 3] = 255

            if (y < width - 1) {
                y++
            } else if (y == width - 1) {
                y = 0
                x++
            }
        }

        var rectangle = Rectangle_p(0, 0, width, height)
        img = RGBA_p(cjdata, 4 * width, rectangle)

        return img
    }
}

public interface Color <: Hashable & ToString {
    func rgba(): (UInt32, UInt32, UInt32, UInt32)
}

public class RGBAC <: Color & ToString {
    public var r: UInt8 = 0
    public var g: UInt8 = 0
    public var b: UInt8 = 0
    public var a: UInt8 = 0

    public init() {}

    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        this.r = r
        this.g = g
        this.b = b
        this.a = a
    }

    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var r = UInt32(this.r)
        r |= r << 8
        var g = UInt32(this.g)
        g |= g << 8
        var b = UInt32(this.b)
        b |= b << 8
        var a = UInt32(this.a)
        a |= a << 8
        return (r, g, b, a)
    }

    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("RGBA".hashCode())
        dfh.write(r.hashCode())
        dfh.write(g.hashCode())
        dfh.write(b.hashCode())
        dfh.write(a.hashCode())
        return dfh.finish()
    }

    public func toString(): String {
        "[r=${r} g=${g} b=${b} a=${a}]"
    }
}

public class GrayC <: Color {
    public var y: UInt8 = 0

    public init() {}

    public init(y: UInt8) {
        this.y = y
    }

    public func rgba(): (UInt32, UInt32, UInt32, UInt32) {
        var a = UInt32(y)
        a |= a << 8
        return (a, a, a, 0xffff)
    }

    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=".hashCode())
        dfh.write("Gray".hashCode())
        dfh.write(y.hashCode())
        return dfh.finish()
    }

    public func toString(): String {
        "[y=${y}]"
    }
}

public interface Model <: ToString {
    func convert(c: Color): Color

    operator func ==(m: Model): Bool {
        toString() == m.toString()
    }
}

public class ModelFunc <: Model {
    public var modelName: String = ""

    public let f: (Color) -> Color

    public init(f: (Color) -> Color, modelName: String) {
        this.f = f
        this.modelName = modelName
    }

    public func convert(c: Color): Color {
        return f(c)
    }

    public func toString(): String {
        modelName
    }
}

public let RGBAModel: Model = ModelFunc(rgbaModel, "RGBA")

public let GrayModel: Model = ModelFunc(grayModel, "Gray")

@OverflowWrapping
public func rgbaModel(c: Color): Color {
    if (c is RGBAC) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    RGBAC(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8), UInt8(a >> 8))
}

@OverflowWrapping
public func grayModel(c: Color): Color {
    if (c is GrayC) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    let y = (19595 * r + 38470 * g + 7471 * b + (1 << 15)) >> 24
    GrayC(UInt8(y))
}

public let Black = GrayC()

@OverflowWrapping
public func rotate(src: ImageI, rotateAngle: Int64): ImageI {
    if (rotateAngle % 360 == 0) {
        return src
    }

    let bounds = src.bounds()
    let sW = bounds.dx()
    let sH = bounds.dy()

    let hW = Float64(sW) * 0.5
    let hH = Float64(sH) * 0.5

    let angle = Float64(rotateAngle) * Float64.PI / 180.0
    let sin = math.sin(angle)
    let cos = math.cos(angle)

    let (ltX, ltY) = (-hW * cos + hH * sin, hW * sin + hH * cos)
    let (rtX, rtY) = (hW * cos + hH * sin, -hW * sin + hH * cos)
    let (lbX, lbY) = (-hW * cos - hH * sin, hW * sin - hH * cos)
    let (rbX, rbY) = (hW * cos - hH * sin, -hW * sin - hH * cos)

    let maxWidth = Int64(math.max(math.abs(rbX - ltX), math.abs(rtX - lbX)))
    let maxHeight = Int64(math.max(math.abs(rbY - ltY), math.abs(rtY - lbY)))

    let dst = RGBA_p(Rectangle_p(0, 0, maxWidth, maxHeight))

    let halfWidth = Float64(maxWidth) * 0.5
    let halfHeight = Float64(maxHeight) * 0.5
    let subAngle = Float64(360 - rotateAngle % 360) * Float64.PI / 180.0
    let sinR = math.sin(subAngle)
    let cosR = math.cos(subAngle)

    for (y in 0..maxHeight) {
        for (x in 0..maxWidth) {
            let tXF = (Float64(x) - halfWidth) * cosR + (-Float64(y) + halfHeight) * sinR
            let tYF = -(Float64(x) - halfWidth) * sinR + (-Float64(y) + halfHeight) * cosR
            let tX = Int64(tXF)
            let tY = Int64(tYF)
            let colour = if (!(tXF > hW || tXF < -hW || tYF > hH || tYF < -hH)) {
                let tXN = Int64(tXF + hW)
                let tYN = Int64(math.abs(tYF - hH))
                let (r, g, b, a) = src.at(tXN, tYN).rgba()
                RGBAC(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8), UInt8(a))
            } else {
                RGBAC(255, 255, 255, 255)
            }
            dst.setRGBA(x, y, colour)
        }
    }
    dst
}

public func crop(src: ImageI, cropWidth: Int64, cropHeight: Int64, cropX!: Int64 = 0, cropY!: Int64 = 0): ImageI {
    let dst: Image = if (src is ImageT) {
        (src as ImageT).getOrThrow().subImage(Rectangle_p(cropX, cropY, cropX + Int64(cropWidth),
            cropY + Int64(cropHeight)))
    } else {
        src
    }
    (dst as ImageI).getOrThrow()
}

public class Config <: ToString {
    /** 颜色模型 */
    public var colorModel: ?Model = None

    /** 图片宽度 */
    public var width: Int64 = 0

    /** v图片高度 */
    public var height: Int64 = 0

    /**
     * The Function is init constructor
     *
     */
    public init() {}

    /**
     * The Function is init constructor
     *
     * @param colorModel of Model 颜色模型
     * @param width of Int64 图片宽度
     * @param height of Int64 图片高度
     */
    public init(colorModel: Model, width: Int64, height: Int64) {
        this.colorModel = colorModel
        this.width = width
        this.height = height
    }

    /**
     * The Function is toString
     *
     * @return Type of String
     */
    public func toString(): String {
        let cm = if (let Some(r) <- colorModel) {
            r
        } else {
            "None"
        }
        "color-model: ${cm} width: ${width}, height: ${height}"
    }

    /**
     * The Function is ==
     *
     * @param r of Config
     *
     * @return Type of Bool
     */
    public operator func ==(r: Config): Bool {
        this.toString() == r.toString()
    }
}

func pixelBufferLength(bytesPerPixel: Int64, r: Rectangle_p, imageTypeName: String): Int64 {
    let totalLength = bytesPerPixel * r.dx() * r.dy()
    if (totalLength <= 0) {
        throw Exception("image: New ${imageTypeName} Rectangle_p has huge or negative dimensions")
    }
    return totalLength
}

public class Gray_p <: ImageT {
    public var pix: Array<UInt8>

    public var stride: Int64 = 0

    public var rect: Rectangle_p = Rectangle_p()

    public init() {
        this.pix = []
    }

    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle_p) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    public init(r: Rectangle_p) {
        this(Array<UInt8>(pixelBufferLength(1, r, "Gray"), {n => 0}), 1 * r.dx(), r)
    }

    public func colorModel(): Model {
        return GrayModel
    }

    public func bounds(): Rectangle_p {
        rect
    }

    public func at(x: Int64, y: Int64): Color {
        grayAt(x, y)
    }

    public func grayAt(x: Int64, y: Int64): GrayC {
        if (!Point(x, y).isIn(rect)) {
            return GrayC()
        }
        let i = pixOffset(x, y)
        GrayC(pix[i])
    }

    public func getrow(y: Int64): Array<UInt8> {
        var a: Range<Int64> = Range<Int64>(y * stride, (y + 1) * stride, 1, true, true, false);
        return pix[a]
    }

    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 1
    }

    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = (GrayModel.convert(c) as GrayC).getOrThrow().y
    }

    @OverflowWrapping
    public func setGray(x: Int64, y: Int64, c: GrayC) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = c.y
    }

    public func subImage(r: Rectangle_p): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return Gray_p()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        Gray_p(pix[i..pix.size], stride, rect)
    }

    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Gray")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
        dfh.write(rect.hashCode())
        return dfh.finish()
    }

    public func eq(i: Image): Bool {
        return this.hashCode() == i.hashCode()
    }
}

public open class RGBA_p <: ImageT {
    public var pix: Array<UInt8>

    public var stride: Int64 = 0

    public var rect: Rectangle_p = Rectangle_p()

    public init() {
        this.pix = []
    }

    public init(pix: Array<UInt8>, stride: Int64, rect: Rectangle_p) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
    }

    public init(r: Rectangle_p) {
        this(Array<UInt8>(pixelBufferLength(4, r, "RGBA"), {n => 0}), 4 * r.dx(), r)
    }

    public func colorModel(): Model {
        return RGBAModel
    }

    public func bounds(): Rectangle_p {
        rect
    }

    public func at(x: Int64, y: Int64): Color {
        rgbaAt(x, y)
    }

    public func rgbaAt(x: Int64, y: Int64): Color {
        if (!Point(x, y).isIn(rect)) {
            return RGBAC()
        }
        let i = pixOffset(x, y)
        let rgba = RGBAC()
        rgba.r = pix[i]
        rgba.g = pix[i + 1]
        rgba.b = pix[i + 2]
        rgba.a = pix[i + 3]
        rgba
    }

    public func pixOffset(x: Int64, y: Int64): Int64 {
        (y - rect.min.y) * stride + (x - rect.min.x) * 4
    }

    @OverflowWrapping
    public func set(x: Int64, y: Int64, c: Color) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        let c1 = (RGBAModel.convert(c) as RGBAC).getOrThrow()
        pix[i] = c1.r
        pix[i + 1] = c1.g
        pix[i + 2] = c1.b
        pix[i + 3] = c1.a
    }

    @OverflowWrapping
    public func setRGBA(x: Int64, y: Int64, c: RGBAC) {
        if (!Point(x, y).isIn(rect)) {
            return
        }
        let i = pixOffset(x, y)
        pix[i] = c.r
        pix[i + 1] = c.g
        pix[i + 2] = c.b
        pix[i + 3] = c.a
    }

    public func subImage(r: Rectangle_p): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return RGBA_p()
        }
        let i = pixOffset(rect.min.x, rect.min.y)
        RGBA_p(pix[i..pix.size], stride, rect)
    }

    public open func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("RGBA")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
        dfh.write(rect.hashCode())
        return dfh.finish()
    }

    public func eq(i: Image): Bool {
        return this.hashCode() == i.hashCode()
    }
}

public interface Image <: Hashable {
    func colorModel(): Model

    func bounds(): Rectangle_p

    func at(x: Int64, y: Int64): Color
}

public interface PalettedImage <: Image {
    func colorIndexAt(x: Int64, y: Int64): UInt8
}

public interface ImageI <: Image {
    func set(x: Int64, y: Int64, c: Color): Unit
}

public interface ImageT <: ImageI & Opaquer {
    func subImage(r: Rectangle_p): Image
}

public interface Opaquer {}

public let nilPoint: Point = NilPoint()

public open class Point <: ToString & Hashable {
    public var x: Int64 = 0
    public var y: Int64 = 0

    public init() {}

    public init(x: Int64, y: Int64) {
        this.x = x
        this.y = y
    }

    public func toString(): String {
        "(${x}, ${y})"
    }

    public operator func +(q: Point): Point {
        Point(x + q.x, y + q.y)
    }

    public operator func -(q: Point): Point {
        Point(x - q.x, y - q.y)
    }

    public operator func *(q: Point): Point {
        Point(x * q.x, y * q.y)
    }

    public operator func /(q: Point): Point {
        Point(x / q.x, y / q.y)
    }

    public operator func %(r: Rectangle_p): Point {
        let w = r.dx()
        let h = r.dy()
        let p = this - r.min
        p.x = p.x % w
        if (p.x
            < 0) {
            p.x += w
        }
        p.y = p.y % h
        if (p.y
            < 0) {
            p.y += h
        }
        p + r.min
    }

    public operator func ==(q: Point): Bool {
        x == q.x && y == q.y
    }

    public operator func !=(q: Point): Bool {
        !(x == q.x && y == q.y)
    }

    public func isIn(r: Rectangle_p): Bool {
        r.min.x <= x && x < r.max.x && r.min.y <= y && y < r.max.y
    }

    public open func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Point")
        dfh.write(x.hashCode())
        dfh.write(y.hashCode())
        return dfh.finish()
    }

    public func clone(): Point {
        Point(x, y)
    }
}

public class NilPoint <: Point {
    public override func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("NilPoint")
        dfh.write(x.hashCode())
        dfh.write(y.hashCode())
        return dfh.finish()
    }
}

public class Rectangle_p <: ToString & Hashable {
    public var min: Point = Point()

    public var max: Point = Point()

    public init() {}

    public init(min: Point, max: Point) {
        this.min = min
        this.max = max
    }

    public init(x0: Int64, y0: Int64, x1: Int64, y1: Int64) {
        var x2 = x0
        var x3 = x1
        if (x0 > x1) {
            x2 = x1
            x3 = x0
        }
        var y2 = y0
        var y3 = y1
        if (y0 > y1) {
            y2 = y1
            y3 = y0
        }
        min = Point(x2, y2)
        max = Point(x3, y3)
    }

    public func toString(): String {
        min.toString() + " - " + max.toString()
    }

    public func dx(): Int64 {
        max.x - min.x
    }

    public func dy(): Int64 {
        max.y - min.y
    }

    public func size(): Point {
        Point(max.x - min.x, max.y - min.y)
    }

    public operator func +(p: Point): Rectangle_p {
        Rectangle_p(Point(min.x + p.x, min.y + p.y), Point(max.x + p.x, max.y + p.y))
    }

    public operator func -(p: Point): Rectangle_p {
        Rectangle_p(Point(min.x - p.x, min.y - p.y), Point(max.x - p.x, max.y - p.y))
    }

    public operator func ==(s: Rectangle_p): Bool {
        (min == s.min && max == s.max) || empty() && s.empty()
    }

    public func inset(n: Int64): Rectangle_p {
        if (dx() < (2 * n)) {
            min.x = (min.x + max.x) / 2
            max.x = min.x
        } else {
            min.x += n
            max.x -= n
        }
        if (dy() < (2 * n)) {
            min.y = (min.y + max.y) / 2
            max.y = min.y
        } else {
            min.y += n
            max.y -= n
        }
        this
    }

    public func intersect(s: Rectangle_p): Rectangle_p {
        if (min.x
            < s.min.x) {
            min.x = s.min.x
        }
        if (min.y
            < s.min.y) {
            min.y = s.min.y
        }
        if (max.x > s.max.x) {
            max.x = s.max.x
        }
        if (max.y > s.max.y) {
            max.y = s.max.y
        }
        if (empty()) {
            return Rectangle_p()
        }
        this
    }

    public func empty(): Bool {
        min.x >= max.x || min.y >= max.y
    }

    public func overlaps(s: Rectangle_p): Bool {
        !empty() && !s.empty() && min.x
            < s.max.x && s.min.x
            < max.x && min.y
            < s.max.y && s.min.y
            < max.y
    }

    public func isIn(s: Rectangle_p): Bool {
        if (empty()) {
            return true
        }
        s.min.x <= min.x && max.x <= s.max.x && s.min.y <= min.y && max.y <= s.max.y
    }

    public func canon(): Rectangle_p {
        if (max.x
            < min.x) {
            let t = min.x
            min.x = max.x
            max.x = t
        }
        if (max.y
            < min.y) {
            let t = min.y
            min.y = max.y
            max.y = t
        }
        this
    }

    public func at(x: Int64, y: Int64): Color {
        if (Point(x, y).isIn(this)) {
            return Black
        }
        return Black
    }

    public func bounds(): Rectangle_p {
        this
    }

    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("Rectangle_p")
        dfh.write(min.hashCode())
        dfh.write(max.hashCode())
        return dfh.finish()
    }

    public func clone(): Rectangle_p {
        Rectangle_p(min.x, min.y, max.x, max.y)
    }
}

let namesuffix: Array<String> = [".jpg", ".jpeg", ".gif", ".png", ".JPG", ".JPEG", ".GIF", ".PNG"]

let testcount = [ /*1,10 ,100,1000,*/ 10000]

let encodeInfo: HashMap<String, Array<String>> = HashMap<String, Array<String>>(
    [
        ("AZTEC", [
                "Code 2D!",
                "abcdefghijklmnopqrstuvwxyz",
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            ]),
        ("CODABAR", ["1234567890", "12345678901", "294/586"]),
        ("CODE_128", ["168901", "Code 128", "102030405060708000"]),
        ("CODE_39", ["TEST-SHEET", " WWW.CITRONSOFT.COM ", "MOROVIA"]),
        ("CODE_93", ["1234567890", "CODE 93", "DATA"]),
        ("DATA_MATRIX", ["123456789", "abcde", "abcdefghijklm"]),
        ("EAN_13", ["9780764544200", "5201815331227", "9781558604971"]),
        ("EAN_8", ["48512343", "12345670", "96385074"]),
        ("ITF", ["30712345000010", "00123456789012", "00123456789011"]),
        ("PDF_417", [
                "This is PDF417\r\nABCDEFGHIJKLMNOPQRSTUVWXYZ \"#$%&'()*+,-./01234:56789",
                "12345678",
                "ActiveBarcode"
            ]),
        ("QR_CODE", [
                "MECARD:N:Sean Owen;TEL:+12125658770;EMAIL:srowen@google.com;;",
                "http://www.webtech.co.jp/k/",
                "MEBKM:URL:http\\://en.wikipedia.org/wiki/Main_Page;;"
            ]),
        ("UPC_A", ["36602301467", "70097025088", "606949762520"]),
        ("UPC_E", ["1234565", "1234572", "1234531"])
    ]
);

public func getImageFiles(testBase: String): ArrayList<Path> {
    let src = "Please download and install test images, and run from the 'core' directory"
    if (!Directory.exists(testBase)) {
    }
    var paths = ArrayList<Path>();

    let dir: Directory = Directory(testBase)
    let data: ArrayList<FileInfo> = dir.entryList()
    for (one in data) {
        for (suffix in namesuffix) {
            if (one.path.toString().count(suffix) > 0) {
                paths.append(one.path);
            }
        }
    }

    return paths
}

public func stringToBinaryBitmap(binaryBitmap: String): BarcodeFormat {
    match (binaryBitmap) {
        case "AZTEC" => BarcodeFormat.AZTEC
        case "CODABAR" => BarcodeFormat.CODABAR
        case "CODE_128" => BarcodeFormat.CODE_128
        case "CODE_39" => BarcodeFormat.CODE_39
        case "CODE_93" => BarcodeFormat.CODE_93
        case "DATA_MATRIX" => BarcodeFormat.DATA_MATRIX
        case "EAN_13" => BarcodeFormat.EAN_13
        case "EAN_8" => BarcodeFormat.EAN_8
        case "ITF" => BarcodeFormat.ITF
        case "MAXICODE" => BarcodeFormat.MAXICODE
        case "PDF_417" => BarcodeFormat.PDF_417
        case "QR_CODE" => BarcodeFormat.QR_CODE
        case "RSS_14" => BarcodeFormat.RSS_14
        case "RSS_EXPANDED" => BarcodeFormat.RSS_EXPANDED
        case "UPC_A" => BarcodeFormat.UPC_A
        case "UPC_E" => BarcodeFormat.UPC_E
        case _ => throw Exception()
    }
}

// public func SaveImage(bitMatrix: BitMatrix, width: Int64, height: Int64, imageFilePath: String) {
//     var image = Gray_p(Rectangle_p(0, 0, width, height))
//     for (y in 0..height) {
//         for (x in 0..width) {
//             var gryc: GrayC
//             if (bitMatrix.get(width - x - 1, height - y - 1)) {
//                 gryc = GrayC(255)
//             } else {
//                 gryc = GrayC(0)
//             }

//             var colors: GrayC = (grayModel(gryc) as GrayC).getOrThrow()
//             image.setGray(x, y, colors)
//         }
//     }
//     let cvImageForZxing = CvImageForZxing()
//     cvImageForZxing.opencvWriteImg(imageFilePath, image)
// }

public func encode(width: Int64, height: Int64, formatstr: String, num: Int64, count: Int64) {

    // 创建二维码写入器
    var timestart: DateTime = DateTime.now()
    var timeend: DateTime = DateTime.now()

    let format = stringToBinaryBitmap(formatstr)

    var timeSum: Int64 = 0;
    var a: BitMatrix = BitMatrix();
    for (_ in 0..count) {
        timestart = DateTime.now()

        a = MultiFormatWriter().encode(encodeInfo[formatstr][num], format, width, height)

        timeend = DateTime.now()

        timeSum += (timeend - timestart).toNanoseconds()
    }
    println(formatstr + "_" + num.toString() + "    :" + (timeSum / count).toString());
}

public func decode(imagePath: String, count: Int64): String {
    var timestart: DateTime = DateTime.now()
    var timeend: DateTime = DateTime.now()
    var result = ""
    try {
        var image: Image
        var opencvUtils: CvImageForZxing = CvImageForZxing()
        image = opencvUtils.opencvReadImg(imagePath)

        var imageiop = image as ImageI
        var imagei: ImageI = imageiop.getOrThrow()

        var source: LuminanceSource = BufferedImageLuminanceSource(imagei);

        var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)

        var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer);

        // 创建解码参数
        var hintType: DecodeHintType = DecodeHintType.TRY_HARDER;
        var hints: HashMap<DecodeHintType, Any> = HashMap<DecodeHintType, Any>();
        hints.put(hintType, true);

        var reader: MultiFormatReader = MultiFormatReader();

        var a: Result = Result();
        var timeSum: Int64 = 0;
        for (_ in 0..count) {
            timestart = DateTime.now()

            a = reader.decode(bitmap, hints)
            println("decode result = ${a.getText()}")
            result = a.getText()

            timeend = DateTime.now()

            timeSum += (timeend - timestart).toNanoseconds()
        }
        println(imagePath.toString() + "    :" + count.toString() + "    :" + (timeSum / count).toString());
    } catch (e: Exception) {
        e.printStackTrace()
        println("解码失败：" + e.toString());
    }

    return result;
}

public open class BufferedImageLuminanceSource <: LuminanceSource {
    private static let MINUS_45_IN_RADIANS: Float64 = -0.7853981633974483

    private var image: ImageI = Gray_p()
    private let left: Int64
    private let top: Int64

    public init(image: ImageI) {
        this(image, 0, 0, image.bounds().size().x, image.bounds().size().y);
    }

    @OverflowWrapping
    public init(imagein: ImageI, left: Int64, top: Int64, width: Int64, height: Int64) {
        super(width, height);
        if (imagein.colorModel() == GrayModel) {
            this.image = imagein
        } else {
            var sourceWidth: Int64 = imagein.bounds().size().x
            var sourceHeight: Int64 = imagein.bounds().size().y
            if (left + width > sourceWidth || top + height > sourceHeight) {
                throw IllegalArgumentException("Crop rectangle does not fit within image data.");
            }
            let rectangle: Rectangle_p = Rectangle_p(left, top, width, height)
            var gray: Gray_p = Gray_p(rectangle)

            for (y in top..top + height) {
                for (x in 0..width) {
                    let colorin: Color = imagein.at(x, y)

                    let (a1, a2, a3, a4) = colorin.rgba();

                    if (a4 == 0) {
                        gray.setGray(x, y - top, GrayC(255))
                    } else {
                        if (imagein is RGBA) {
                            let colorRGB: Color = (imagein as RGBA_p).getOrThrow().rgbaAt(x, y)
                            let coloritem = (colorRGB as RGBAC).getOrThrow();
                            gray.set(
                                x,
                                y - top,
                                GrayC(
                                    UInt8((Int64(coloritem.r) * 306 + Int64(coloritem.g) * 601 + Int64(coloritem.b) * 117 +
                                            0x200) >> 10)
                                )
                            )
                        } else {
                            gray.set(x, y - top, colorin)
                        }
                    }
                }
            }
            this.image = gray
        }
        this.left = left
        this.top = top
    }

    public override func getRow(y: Int64, rowin: Array<UInt8>): Array<UInt8> {
        var row: Array<UInt8> = rowin
        if (y < 0 || y >= getHeight()) {
            throw IllegalArgumentException("Requested row is outside the image: ${y}");
        }
        var width: Int64 = getWidth();
        if (row.size == 0 || row.size < width) {
            row = Array<UInt8>(width, item: 0)
        }

        let dstImg = crop(image, width, 1, cropX: left, cropY: top + y)

        for (x in 0..width) {
            var colors: GrayC = (grayModel(dstImg.at(x, top + y)) as GrayC).getOrThrow()
            row[x] = colors.y
        }
        return row
    }

    public override func getMatrix(): Array<UInt8> {
        var width: Int64 = getWidth();
        var height: Int64 = getHeight();
        var area: Int64 = width * height
        var matrix: Array<UInt8> = Array<UInt8>(area, item: 0)

        // The underlying raster of image consists of area bytes with the luminance values
        let dstImg = crop(image, width, height, cropX: left, cropY: top)

        for (x in 0..width) {
            for (y in 0..height) {
                var colors: GrayC = (grayModel(image.at(x + left, top + y)) as GrayC).getOrThrow()
                matrix[x + y * width] = colors.y
            }
        }

        return matrix
    }

    public override func isCropSupported(): Bool {
        return true;
    }

    public override func crop(left: Int64, top: Int64, width: Int64, height: Int64): LuminanceSource {
        return BufferedImageLuminanceSource(image, this.left + left, this.top + top, width, height);
    }

    /**
     * This is always true, since the image is a gray-scale image.
     *
     * @return true
     */
    public override func isRotateSupported(): Bool {
        return true;
    }

    public override func rotateCounterClockwise(): LuminanceSource {
        var sourceWidth: Int64 = image.bounds().size().x
        var sourceHeight: Int64 = image.bounds().size().y
        var imageI: ImageI = this.image
        let rotatedImage = AbstractBlackBoxTestCase.selfrotate(imageI, 270)

        // Maintain the cropped region, but rotate it too.
        var width: Int64 = getWidth();
        return BufferedImageLuminanceSource(rotatedImage, top, sourceWidth - (left + width), getHeight(), width);
    }

    public override func rotateCounterClockwise45(): LuminanceSource {
        var width: Int64 = getWidth();
        var height: Int64 = getHeight();

        var oldCenterX: Int64 = left + width / 2
        var oldCenterY: Int64 = top + height / 2

        let rotatedImage = rotate(this.image, 45)
        var sourceDimension: Int64 = math.max(this.image.bounds().size().x, this.image.bounds().size().y);
        var halfDimension: Int64 = math.max(width, height) / 2
        var newLeft: Int64 = math.max(0, oldCenterX - halfDimension);
        var newTop: Int64 = math.max(0, oldCenterY - halfDimension);
        var newRight: Int64 = math.min(sourceDimension - 1, oldCenterX + halfDimension);
        var newBottom: Int64 = math.min(sourceDimension - 1, oldCenterY + halfDimension);

        return BufferedImageLuminanceSource(rotatedImage, newLeft, newTop, newRight - newLeft, newBottom - newTop);
    }
}