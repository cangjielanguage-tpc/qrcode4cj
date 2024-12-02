package image.resizer

import image.image.*
import image.internals.model.*

func floatToUInt8(x: Float32): UInt8 {
    if (x >= 255.0) {
        0xff
    } else {
        UInt8(x)
    }
}

func floatToUInt16(x: Float32): UInt16 {
    if (x >= 65535.0) {
        0xffff
    } else {
        UInt16(x)
    }
}

@OverflowWrapping
func nearestGeneric(
    src: Image,
    out: RGBA64,
    _: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    let newBounds = out.bounds()
    let maxX = src.bounds().dx() - 1

    for (x in newBounds.min.x..newBounds.max.x) {
        for (y in newBounds.min.y..newBounds.max.y) {
            var rgba = Array<Float32>(4, item: 0.0)
            var sum: Float32 = 0.0
            let start = offset[y]
            let ci = y * filterLength
            for (i in 0..filterLength) {
                if (coeffs[ci + i]) {
                    var xi = start + i
                    xi = if (xi < 0) {
                        0
                    } else if (xi >= maxX) {
                        maxX
                    } else {
                        xi
                    }
                    let (r, g, b, a) = src.at(xi + src.bounds().min.x, x + src.bounds().min.y).rgba()
                    rgba[0] += Float32(r)
                    rgba[1] += Float32(g)
                    rgba[2] += Float32(b)
                    rgba[3] += Float32(a)
                    sum += 1.0
                }
            }

            let mOffset = (y - newBounds.min.y) * out.stride + (x - newBounds.min.x) * 8
            var value = floatToUInt16(rgba[0] / sum)
            out.pix[mOffset + 0] = UInt8(value >> 8)
            out.pix[mOffset + 1] = UInt8(value)
            value = floatToUInt16(rgba[1] / sum)
            out.pix[mOffset + 2] = UInt8(value >> 8)
            out.pix[mOffset + 3] = UInt8(value)
            value = floatToUInt16(rgba[2] / sum)
            out.pix[mOffset + 4] = UInt8(value >> 8)
            out.pix[mOffset + 5] = UInt8(value)
            value = floatToUInt16(rgba[3] / sum)
            out.pix[mOffset + 6] = UInt8(value >> 8)
            out.pix[mOffset + 7] = UInt8(value)
        }
    }
}

func nearestRGBA(
    src: RGBA,
    out: RGBA,
    scale: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    nearestRGBA(
        src.pix,
        src.bounds(),
        src.stride,
        out.pix,
        out.bounds(),
        out.stride,
        scale,
        coeffs,
        offset,
        filterLength
    )
}

func nearestNRGBA(
    src: NRGBA,
    out: NRGBA,
    scale: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    nearestRGBA(
        src.pix,
        src.bounds(),
        src.stride,
        out.pix,
        out.bounds(),
        out.stride,
        scale,
        coeffs,
        offset,
        filterLength
    )
}

func nearestRGBA(
    inpix: Array<UInt8>,
    inbounds: Rectangle,
    instride: Int64,
    outpix: Array<UInt8>,
    outbounds: Rectangle,
    outstride: Int64,
    _: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    let maxX = inbounds.dx() - 1
    for (x in outbounds.min.x..outbounds.max.x) {
        let row = if (x * instride >= inpix.size) {
            Array<UInt8>()
        } else {
            inpix[(x * instride)..inpix.size]
        }
        for (y in outbounds.min.y..outbounds.max.y) {
            var rgba = Array<Float32>(4, item: 0.0)
            var sum: Float32 = 0.0
            let start = offset[y]
            let ci = y * filterLength
            for (i in 0..filterLength) {
                if (coeffs[ci + i]) {
                    var xi = start + i
                    xi = if (UInt32(xi) < UInt32(maxX)) {
                        xi * 4
                    } else if (xi >= maxX) {
                        4 * maxX
                    } else {
                        0
                    }
                    rgba[0] += Float32(row[xi + 0])
                    rgba[1] += Float32(row[xi + 1])
                    rgba[2] += Float32(row[xi + 2])
                    rgba[3] += Float32(row[xi + 3])
                    sum += 1.0
                }
            }

            let xo = (y - outbounds.min.y) * outstride + (x - outbounds.min.x) * 4
            outpix[xo + 0] = floatToUInt8(rgba[0] / sum)
            outpix[xo + 1] = floatToUInt8(rgba[1] / sum)
            outpix[xo + 2] = floatToUInt8(rgba[2] / sum)
            outpix[xo + 3] = floatToUInt8(rgba[3] / sum)
        }
    }
}

func nearestRGBA64(
    src: RGBA64,
    out: RGBA64,
    scale: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    nearestRGBA64(
        src.pix,
        src.bounds(),
        src.stride,
        out.pix,
        out.bounds(),
        out.stride,
        scale,
        coeffs,
        offset,
        filterLength
    )
}

func nearestNRGBA64(
    src: NRGBA64,
    out: NRGBA64,
    scale: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    nearestRGBA64(
        src.pix,
        src.bounds(),
        src.stride,
        out.pix,
        out.bounds(),
        out.stride,
        scale,
        coeffs,
        offset,
        filterLength
    )
}

@OverflowWrapping
func nearestRGBA64(
    inpix: Array<UInt8>,
    inbounds: Rectangle,
    instride: Int64,
    outpix: Array<UInt8>,
    outbounds: Rectangle,
    outstride: Int64,
    _: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    let maxX = inbounds.dx() - 1

    for (x in outbounds.min.x..outbounds.max.x) {
        let row = inpix[(x * instride)..inpix.size]
        for (y in outbounds.min.y..outbounds.max.y) {
            var rgba = Array<Float32>(4, item: 0.0)
            var sum: Float32 = 0.0
            let start = offset[y]
            let ci = y * filterLength
            for (i in 0..filterLength) {
                if (coeffs[ci + i]) {
                    var xi = start + i
                    xi = if (UInt32(xi) < UInt32(maxX)) {
                        xi * 8
                    } else if (xi >= maxX) {
                        8 * maxX
                    } else {
                        0
                    }
                    rgba[0] += Float32((UInt16(row[xi + 0]) << 8) | UInt16(row[xi + 1]))
                    rgba[1] += Float32((UInt16(row[xi + 2]) << 8) | UInt16(row[xi + 3]))
                    rgba[2] += Float32((UInt16(row[xi + 4]) << 8) | UInt16(row[xi + 5]))
                    rgba[3] += Float32((UInt16(row[xi + 6]) << 8) | UInt16(row[xi + 7]))
                    sum += 1.0
                }
            }

            let xo = (y - outbounds.min.y) * outstride + (x - outbounds.min.x) * 8
            var value = floatToUInt16(rgba[0] / sum)
            outpix[xo + 0] = UInt8(value >> 8)
            outpix[xo + 1] = UInt8(value)
            value = floatToUInt16(rgba[1] / sum)
            outpix[xo + 2] = UInt8(value >> 8)
            outpix[xo + 3] = UInt8(value)
            value = floatToUInt16(rgba[2] / sum)
            outpix[xo + 4] = UInt8(value >> 8)
            outpix[xo + 5] = UInt8(value)
            value = floatToUInt16(rgba[3] / sum)
            outpix[xo + 6] = UInt8(value >> 8)
            outpix[xo + 7] = UInt8(value)
        }
    }
}

func nearestGray(
    src: Gray,
    out: Gray,
    _: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    let newBounds = out.bounds()
    let maxX = src.bounds().dx() - 1

    for (x in newBounds.min.x..newBounds.max.x) {
        let row = src.pix[(x * src.stride)..src.pix.size]
        for (y in newBounds.min.y..newBounds.max.y) {
            var gray: Float32 = 0.0
            var sum: Float32 = 0.0
            let start = offset[y]
            let ci = y * filterLength
            for (i in 0..filterLength) {
                if (coeffs[ci + i]) {
                    var xi = start + i
                    xi = if (xi < 0) {
                        0
                    } else if (xi >= maxX) {
                        maxX
                    } else {
                        xi
                    }
                    gray += Float32(row[xi])
                    sum += 1.0
                }
            }

            let mOffset = (y - newBounds.min.y) * out.stride + (x - newBounds.min.x)
            out.pix[mOffset] = floatToUInt8(gray / sum)
        }
    }
}

func nearestGray16(
    src: Gray16,
    out: Gray16,
    _: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    let newBounds = out.bounds()
    let maxX = src.bounds().dx() - 1

    for (x in newBounds.min.x..newBounds.max.x) {
        let row = src.pix[(x * src.stride)..src.pix.size]
        for (y in newBounds.min.y..newBounds.max.y) {
            var gray: Float32 = 0.0
            var sum: Float32 = 0.0
            let start = offset[y]
            let ci = y * filterLength
            for (i in 0..filterLength) {
                if (coeffs[ci + i]) {
                    var xi = start + i
                    xi = if (UInt32(xi) < UInt32(maxX)) {
                        xi * 2
                    } else if (xi >= maxX) {
                        2 * maxX
                    } else {
                        0
                    }
                    gray += Float32((UInt16(row[xi + 0]) << 8) | UInt16(row[xi + 1]))
                    sum += 1.0
                }
            }

            let mOffset = (y - newBounds.min.y) * out.stride + (x - newBounds.min.x) * 2
            let value = floatToUInt16(gray / sum)
            out.pix[mOffset + 0] = UInt8(value >> 8)
            out.pix[mOffset + 1] = UInt8(value)
        }
    }
}

func nearestYCbCr(
    src: YCC,
    out: YCC,
    _: Float64,
    coeffs: Array<Bool>,
    offset: Array<Int64>,
    filterLength: Int64
) {
    let newBounds = out.bounds()
    let maxX = src.bounds().dx() - 1

    for (x in newBounds.min.x..newBounds.max.x) {
        let row = src.pix[(x * src.stride)..src.pix.size]
        for (y in newBounds.min.y..newBounds.max.y) {
            var p = Array<Float32>(3, item: 0.0)
            var sum: Float32 = 0.0
            let start = offset[y]
            let ci = y * filterLength
            for (i in 0..filterLength) {
                if (coeffs[ci + i]) {
                    var xi = start + i
                    xi = if (UInt32(xi) < UInt32(maxX)) {
                        xi * 3
                    } else if (xi >= maxX) {
                        3 * maxX
                    } else {
                        0
                    }
                    p[0] += Float32(row[xi + 0])
                    p[1] += Float32(row[xi + 1])
                    p[2] += Float32(row[xi + 2])
                    sum += 1.0
                }
            }

            let xo = (y - newBounds.min.y) * out.stride + (x - newBounds.min.x) * 3
            out.pix[xo + 0] = floatToUInt8(p[0] / sum)
            out.pix[xo + 1] = floatToUInt8(p[1] / sum)
            out.pix[xo + 2] = floatToUInt8(p[2] / sum)
        }
    }
}
