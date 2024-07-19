import QRCode4cj.common.*
import QRCode4cj.common.reader.*
import QRCode4cj.common.writer.*
import QRCode4cj.tools.UTF32String
import QRCode4cj.aztec.common.*
import std.math.*

public func bitMatrixToBinaryBitmap(bitMatrix: BitMatrix, width: Int64, height: Int64): BinaryBitmap {
    var image = Gray_p(Rectangle_p(0, 0, width, height))
    for (y in 0..height) {
        for (x in 0..width) {
            var gryc: GrayC
            if (bitMatrix.get(x, y)) {
                gryc = GrayC(0)
            } else {
                gryc = GrayC(255)
            }

            var colors: GrayC = (grayModel(gryc) as GrayC).getOrThrow()
            image.setGray(x, y, colors)
        }
    }
    var imageiop = image as ImageI
    var imagei: ImageI = imageiop.getOrThrow()
    var source: LuminanceSource = BufferedImageLuminanceSource(imagei)
    var hybridBinarizer: HybridBinarizer = HybridBinarizer(source)
    var bitmap: BinaryBitmap = BinaryBitmap(hybridBinarizer)
    return bitmap
}

public interface Color <: Hashable & ToString {
    func rgba(): (UInt32, UInt32, UInt32, UInt32)
}

public interface ImageI <: Image {
    func set(x: Int64, y: Int64, c: Color): Unit
}

public interface ImageT <: ImageI & Opaquer {
    func subImage(r: Rectangle_p): Image
}

public interface Image <: Hashable {
    func colorModel(): Model

    func bounds(): Rectangle_p

    func at(x: Int64, y: Int64): Color
}

public interface Opaquer {}

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

public let Black = GrayC()

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

public let GrayModel: Model = ModelFunc(grayModel, "Gray")

@OverflowWrapping
public func grayModel(c: Color): Color {
    if (c is GrayC) {
        return c
    }
    var (r, g, b, a) = c.rgba()
    let y = (19595 * r + 38470 * g + 7471 * b + (1 << 15)) >> 24
    GrayC(UInt8(y))
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

public open class BufferedImageLuminanceSource <: LuminanceSource {
    //private static let MINUS_45_IN_RADIANS: Float64 = -0.7853981633974483

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

                    let (_, _, _, a4) = colorin.rgba();

                    if (a4 == 0) {
                        gray.setGray(x, y - top, GrayC(255))
                    } else {
                        gray.set(x, y - top, colorin)
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
        let _ = crop(image, width, height, cropX: left, cropY: top)

        for (x in 0..width) {
            for (y in 0..height) {
                var colors: GrayC = (grayModel(image.at(x + left, top + y)) as GrayC).getOrThrow()
                matrix[x + y * width] = colors.y
            }
        }

        return matrix
    }
}
