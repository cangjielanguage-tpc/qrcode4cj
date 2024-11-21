package image.resizer


import image.internals.model.*
import image.internals.imageutil.*
import image.image.*

let defaultResizeTaps = 2

public func resize(img: Image, width: Int64, height: Int64): Image {
    let bounds = img.bounds()
    let (scaleX, scaleY) = calcFactors(width, height, Float64(bounds.dx()), Float64(bounds.dy()))
    let targetWidth = if (width == 0) {
        Int64(0.7 + Float64(bounds.dx()) / scaleX)
    } else {
        width
    }
    let targetHeight = if (height == 0) {
        Int64(0.7 + Float64(bounds.dy()) / scaleY)
    } else {
        height
    }

    if (width == bounds.dx() && height == bounds.dy()) { // Trivial case: return input image
        return img
    }

    if (bounds.dx() <= 0 || bounds.dy() <= 0) { // Input image has no pixels
        return img
    }

    return resize(img, targetWidth, targetHeight, scaleX, scaleY)
}

func resize(img: Image, width: Int64, height: Int64, scaleX: Float64, scaleY: Float64): Image {
    // TODO CPU数
    let cpus = 2
    let taps = 2
    let blur = 1.0
    let wg = WaitGroup()

    let tempRect = Rectangle(0, 0, img.bounds().dy(), width)
    let resultRect = Rectangle(0, 0, width, height)
    let (coeffs0, offset0, filterLength0) = createWeightsNearest(width, taps, blur, scaleX)
    let (coeffs1, offset1, filterLength1) = createWeightsNearest(height, taps, blur, scaleY)
    if (img is RGBA) {
        let input = (img as RGBA).getOrThrow()
        let temp = RGBA(tempRect)
        let result = RGBA(resultRect)

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(temp, i, cpus) as RGBA).getOrThrow()
            spawn {
                try {
                    nearestRGBA(input, slice, scaleX, coeffs0, offset0, filterLength0)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(result, i, cpus) as RGBA).getOrThrow()
            spawn {
                try {
                    nearestRGBA(temp, slice, scaleX, coeffs1, offset1, filterLength1)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()
        result
    } else if (img is NRGBA) {
        let input = (img as NRGBA).getOrThrow()
        let temp = NRGBA(tempRect)
        let result = NRGBA(resultRect)

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(temp, i, cpus) as NRGBA).getOrThrow()
            spawn {
                try {
                    nearestNRGBA(input, slice, scaleX, coeffs0, offset0, filterLength0)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(result, i, cpus) as NRGBA).getOrThrow()
            spawn {
                try {
                    nearestNRGBA(temp, slice, scaleX, coeffs1, offset1, filterLength1)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()
        result
    } else if (img is YCbCr) {
        let input = (img as YCbCr).getOrThrow()
        let temp = YCC(tempRect, input.subsampleRatio)
        let result = YCC(resultRect, input.subsampleRatio)

        let mInput = YCC.fromYCbCr(input)
        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(temp, i, cpus) as YCC).getOrThrow()
            spawn {
                try {
                    nearestYCbCr(mInput, slice, scaleX, coeffs0, offset0, filterLength0)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(result, i, cpus) as YCC).getOrThrow()
            spawn {
                try {
                    nearestYCbCr(temp, slice, scaleX, coeffs1, offset1, filterLength1)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()
        result.toYCbCr()
    } else if (img is RGBA64) {
        let input = (img as RGBA64).getOrThrow()
        let temp = RGBA64(tempRect)
        let result = RGBA64(resultRect)

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(temp, i, cpus) as RGBA64).getOrThrow()
            spawn {
                try {
                    nearestRGBA64(input, slice, scaleX, coeffs0, offset0, filterLength0)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(result, i, cpus) as RGBA64).getOrThrow()
            spawn {
                try {
                    nearestRGBA64(temp, slice, scaleX, coeffs1, offset1, filterLength1)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()
        result
    } else if (img is NRGBA64) {
        let input = (img as NRGBA64).getOrThrow()
        let temp = NRGBA64(tempRect)
        let result = NRGBA64(resultRect)

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(temp, i, cpus) as NRGBA64).getOrThrow()
            spawn {
                try {
                    nearestNRGBA64(input, slice, scaleX, coeffs0, offset0, filterLength0)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(result, i, cpus) as NRGBA64).getOrThrow()
            spawn {
                try {
                    nearestNRGBA64(temp, slice, scaleX, coeffs1, offset1, filterLength1)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()
        result
    } else if (img is Gray) {
        let input = (img as Gray).getOrThrow()
        let temp = Gray(tempRect)
        let result = Gray(resultRect)

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(temp, i, cpus) as Gray).getOrThrow()
            spawn {
                try {
                    nearestGray(input, slice, scaleX, coeffs0, offset0, filterLength0)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(result, i, cpus) as Gray).getOrThrow()
            spawn {
                try {
                    nearestGray(temp, slice, scaleX, coeffs1, offset1, filterLength1)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()
        result
    } else if (img is Gray16) {
        let input = (img as Gray16).getOrThrow()
        let temp = Gray16(tempRect)
        let result = Gray16(resultRect)

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(temp, i, cpus) as Gray16).getOrThrow()
            spawn {
                try {
                    nearestGray16(input, slice, scaleX, coeffs0, offset0, filterLength0)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(result, i, cpus) as Gray16).getOrThrow()
            spawn {
                try {
                    nearestGray16(temp, slice, scaleX, coeffs1, offset1, filterLength1)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()
        result
    } else {
        let temp = RGBA64(tempRect)
        let result = RGBA64(resultRect)

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(temp, i, cpus) as RGBA64).getOrThrow()
            spawn {
                try {
                    nearestGeneric(img, slice, scaleX, coeffs0, offset0, filterLength0)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()

        wg.add(UInt32(cpus))
        for (i in 0..cpus) {
            let slice = (makeArray(result, i, cpus) as RGBA64).getOrThrow()
            spawn {
                try {
                    nearestRGBA64(temp, slice, scaleX, coeffs1, offset1, filterLength1)
                } finally {
                    wg.done()
                }
            }
        }
        wg.wait()
        result
    }
}

func calcFactors(width: Int64, height: Int64, oldWidth: Float64, oldHeight: Float64): (Float64, Float64) {
    if (width == 0) {
        if (height == 0) {
            (1.0, 1.0)
        } else {
            let scaleY = oldHeight / Float64(height)
            (scaleY, scaleY)
        }
    } else {
        let scaleX = oldWidth / Float64(width)
        (scaleX, if (height == 0) {
                scaleX
            } else {
                oldHeight / Float64(height)
            })
    }
}

func makeArray(img: ImageT, i: Int64, n: Int64): Image {
    let bounds = img.bounds()
    return img.subImage(
        Rectangle(bounds.min.x, bounds.min.y + i * bounds.dy() / n, bounds.max.x, bounds.min.y + (i + 1) * bounds.dy() /
            n)
    )
}
