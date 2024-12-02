package image.resizer

import image.image as image
import image.color as color
import image.internals.model.*

class YCC <: ImageT {
    public var pix: Array<UInt8>
    public var stride: Int64 = 0
    public var rect: Rectangle = Rectangle()
    public var subsampleRatio: image.YCbCrSubsampleRatio = YCbCrSubsampleRatio444

    // init() {
    //     this.pix = []
    // }

    // init(subsampleRatio: YCbCrSubsampleRatio) {
    //     this.pix = []
    //     this.subsampleRatio = subsampleRatio
    // }

    init(r: Rectangle, subsampleRatio: image.YCbCrSubsampleRatio) {
        let (w, h) = (r.dx(), r.dy())
        this.pix = Array<UInt8>(3 * w * h, item: 0)
        this.stride = 3 * w
        this.rect = r
        this.subsampleRatio = subsampleRatio
    }

    init(pix: Array<UInt8>, stride: Int64, rect: Rectangle, subsampleRatio: image.YCbCrSubsampleRatio) {
        this.pix = pix
        this.stride = stride
        this.rect = rect
        this.subsampleRatio = subsampleRatio
    }

    public func pixOffset(x: Int64, y: Int64): Int64 {
        return (y - this.rect.min.y) * this.stride + (x - this.rect.min.x) * 3
    }

    public func bounds(): Rectangle {
        rect
    }

    public func colorModel(): color.Model {
        return color.YCbCrModel
    }

    public func at(x: Int64, y: Int64): color.Color {
        if (!Point(x, y).isIn(this.rect)) {
            return color.YCbCr()
        }
        let i = this.pixOffset(x, y)
        color.YCbCr(this.pix[i], this.pix[i + 1], this.pix[i + 2])
    }

    public func opaque(): Bool {
        true
    }

    public func subImage(r: Rectangle): Image {
        var rect = r.intersect(rect)
        if (rect.empty()) {
            return YCC(Rectangle(), this.subsampleRatio)
        }
        let i = this.pixOffset(rect.min.x, rect.min.y)
        YCC(this.pix[i..this.pix.size], this.stride, rect, this.subsampleRatio)
    }

    @OverflowWrapping
    public func set(_: Int64, _: Int64, _: color.Color) {}

    public func hashCode(): Int64 {
        var dfh: DefaultHasher = DefaultHasher()
        dfh.write("name=")
        dfh.write("YCC")
        dfh.write(pix.size.hashCode())
        dfh.write(stride.hashCode())
        dfh.write(rect.hashCode())
        dfh.write(subsampleRatio.hashCode())
        return dfh.finish()
    }

    public func eq(i: Image): Bool {
        return this.hashCode() == i.hashCode()
    }

    public func toYCbCr(): image.YCbCr {
        let ycbcr = image.YCbCr(this.rect, this.subsampleRatio)
        match (this.subsampleRatio) {
            case YCbCrSubsampleRatio444 => this.ycbcr444(ycbcr)
            case YCbCrSubsampleRatio422 => this.ycbcr422(ycbcr)
            case YCbCrSubsampleRatio420 => this.ycbcr420(ycbcr)
            case YCbCrSubsampleRatio440 => this.ycbcr440(ycbcr)
            case YCbCrSubsampleRatio411 => this.ycbcr411(ycbcr)
            case YCbCrSubsampleRatio410 => this.ycbcr410(ycbcr)
        }
    }

    public static func fromYCbCr(ycbcr: image.YCbCr): YCC {
        let (w, h) = (ycbcr.rect.dx(), ycbcr.rect.dy())
        let ycc = YCC(Array<UInt8>(3 * w * h, item: 0), 3 * w, Rectangle(0, 0, w, h), ycbcr.subsampleRatio)
        match (ycc.subsampleRatio) {
            case YCbCrSubsampleRatio444 => convertToYCC444(ycbcr, ycc)
            case YCbCrSubsampleRatio422 => convertToYCC422(ycbcr, ycc)
            case YCbCrSubsampleRatio420 => convertToYCC420(ycbcr, ycc)
            case YCbCrSubsampleRatio440 => convertToYCC440(ycbcr, ycc)
            case YCbCrSubsampleRatio411 => convertToYCC411(ycbcr, ycc)
            case YCbCrSubsampleRatio410 => convertToYCC410(ycbcr, ycc)
        }
    }

    func ycbcr422(ycbcr: image.YCbCr): image.YCbCr {
        var off = 0
        let pix = this.pix
        let Y = ycbcr.y
        let Cb = ycbcr.cb
        let Cr = ycbcr.cr
        for (y in 0..ycbcr.rect.dy()) {
            let yy = y * ycbcr.yStride
            let cy = y * ycbcr.cStride
            for (x in 0..ycbcr.rect.dx()) {
                let ci = cy + x / 2
                Y[yy + x] = pix[off + 0]
                Cb[ci] = pix[off + 1]
                Cr[ci] = pix[off + 2]
                off += 3
            }
        }
        return ycbcr
    }

    func ycbcr420(ycbcr: image.YCbCr): image.YCbCr {
        var off = 0
        let pix = this.pix
        let Y = ycbcr.y
        let Cb = ycbcr.cb
        let Cr = ycbcr.cr
        for (y in 0..ycbcr.rect.dy()) {
            let yy = y * ycbcr.yStride
            let cy = (y / 2) * ycbcr.cStride
            for (x in 0..ycbcr.rect.dx()) {
                let ci = cy + x / 2
                Y[yy + x] = pix[off + 0]
                Cb[ci] = pix[off + 1]
                Cr[ci] = pix[off + 2]
                off += 3
            }
        }
        return ycbcr
    }

    func ycbcr440(ycbcr: image.YCbCr): image.YCbCr {
        var off = 0
        let pix = this.pix
        let Y = ycbcr.y
        let Cb = ycbcr.cb
        let Cr = ycbcr.cr
        for (y in 0..ycbcr.rect.dy()) {
            let yy = y * ycbcr.yStride
            let cy = (y / 2) * ycbcr.cStride
            for (x in 0..ycbcr.rect.dx()) {
                let ci = cy + x
                Y[yy + x] = pix[off + 0]
                Cb[ci] = pix[off + 1]
                Cr[ci] = pix[off + 2]
                off += 3
            }
        }
        return ycbcr
    }

    func ycbcr444(ycbcr: image.YCbCr): image.YCbCr {
        var off = 0
        let pix = this.pix
        let Y = ycbcr.y
        let Cb = ycbcr.cb
        let Cr = ycbcr.cr
        for (y in 0..ycbcr.rect.dy()) {
            let yy = y * ycbcr.yStride
            let cy = y * ycbcr.cStride
            for (x in 0..ycbcr.rect.dx()) {
                let ci = cy + x
                Y[yy + x] = pix[off + 0]
                Cb[ci] = pix[off + 1]
                Cr[ci] = pix[off + 2]
                off += 3
            }
        }
        return ycbcr
    }

    func ycbcr411(ycbcr: image.YCbCr): image.YCbCr {
        var off = 0
        let pix = this.pix
        let Y = ycbcr.y
        let Cb = ycbcr.cb
        let Cr = ycbcr.cr
        for (y in 0..ycbcr.rect.dy()) {
            let yy = y * ycbcr.yStride
            let cy = y * ycbcr.cStride
            for (x in 0..ycbcr.rect.dx()) {
                let ci = cy + x / 4
                Y[yy + x] = pix[off + 0]
                Cb[ci] = pix[off + 1]
                Cr[ci] = pix[off + 2]
                off += 3
            }
        }
        return ycbcr
    }

    func ycbcr410(ycbcr: image.YCbCr): image.YCbCr {
        var off = 0
        let pix = this.pix
        let Y = ycbcr.y
        let Cb = ycbcr.cb
        let Cr = ycbcr.cr
        for (y in 0..ycbcr.rect.dy()) {
            let yy = y * ycbcr.yStride
            let cy = (y / 2) * ycbcr.cStride
            for (x in 0..ycbcr.rect.dx()) {
                let ci = cy + x / 4
                Y[yy + x] = pix[off + 0]
                Cb[ci] = pix[off + 1]
                Cr[ci] = pix[off + 2]
                off += 3
            }
        }
        return ycbcr
    }
}

func convertToYCC422(ycbcr: image.YCbCr, p: YCC): YCC {
    var off = 0
    let pix = p.pix
    let Y = ycbcr.y
    let Cb = ycbcr.cb
    let Cr = ycbcr.cr
    for (y in 0..ycbcr.rect.dy()) {
        let yy = y * ycbcr.yStride
        let cy = y * ycbcr.cStride
        for (x in 0..ycbcr.rect.dx()) {
            let ci = cy + x / 2
            pix[off + 0] = Y[yy + x]
            pix[off + 1] = Cb[ci]
            pix[off + 2] = Cr[ci]
            off += 3
        }
    }
    return p
}

func convertToYCC420(ycbcr: image.YCbCr, p: YCC): YCC {
    var off = 0
    let pix = p.pix
    let Y = ycbcr.y
    let Cb = ycbcr.cb
    let Cr = ycbcr.cr
    for (y in 0..ycbcr.rect.dy()) {
        let yy = y * ycbcr.yStride
        let cy = (y / 2) * ycbcr.cStride
        for (x in 0..ycbcr.rect.dx()) {
            let ci = cy + x / 2
            pix[off + 0] = Y[yy + x]
            pix[off + 1] = Cb[ci]
            pix[off + 2] = Cr[ci]
            off += 3
        }
    }
    return p
}

func convertToYCC440(ycbcr: image.YCbCr, p: YCC): YCC {
    var off = 0
    let pix = p.pix
    let Y = ycbcr.y
    let Cb = ycbcr.cb
    let Cr = ycbcr.cr
    for (y in 0..ycbcr.rect.dy()) {
        let yy = y * ycbcr.yStride
        let cy = (y / 2) * ycbcr.cStride
        for (x in 0..ycbcr.rect.dx()) {
            let ci = cy + x
            pix[off + 0] = Y[yy + x]
            pix[off + 1] = Cb[ci]
            pix[off + 2] = Cr[ci]
            off += 3
        }
    }
    return p
}

func convertToYCC444(ycbcr: image.YCbCr, p: YCC): YCC {
    var off = 0
    let pix = p.pix
    let Y = ycbcr.y
    let Cb = ycbcr.cb
    let Cr = ycbcr.cr
    for (y in 0..ycbcr.rect.dy()) {
        let yy = y * ycbcr.yStride
        let cy = y * ycbcr.cStride
        for (x in 0..ycbcr.rect.dx()) {
            let ci = cy + x
            pix[off + 0] = Y[yy + x]
            pix[off + 1] = Cb[ci]
            pix[off + 2] = Cr[ci]
            off += 3
        }
    }
    return p
}

func convertToYCC411(ycbcr: image.YCbCr, p: YCC): YCC {
    var off = 0
    let pix = p.pix
    let Y = ycbcr.y
    let Cb = ycbcr.cb
    let Cr = ycbcr.cr
    for (y in 0..ycbcr.rect.dy()) {
        let yy = y * ycbcr.yStride
        let cy = y * ycbcr.cStride
        for (x in 0..ycbcr.rect.dx()) {
            let ci = cy + x / 4
            pix[off + 0] = Y[yy + x]
            pix[off + 1] = Cb[ci]
            pix[off + 2] = Cr[ci]
            off += 3
        }
    }
    return p
}

func convertToYCC410(ycbcr: image.YCbCr, p: YCC): YCC {
    var off = 0
    let pix = p.pix
    let Y = ycbcr.y
    let Cb = ycbcr.cb
    let Cr = ycbcr.cr
    for (y in 0..ycbcr.rect.dy()) {
        let yy = y * ycbcr.yStride
        let cy = (y / 2) * ycbcr.cStride
        for (x in 0..ycbcr.rect.dx()) {
            let ci = cy + x / 4
            pix[off + 0] = Y[yy + x]
            pix[off + 1] = Cb[ci]
            pix[off + 2] = Cr[ci]
            off += 3
        }
    }
    return p
}
