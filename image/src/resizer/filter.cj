package image.resizer

import std.math.*

func createWeightsNearest(dy: Int64, filterLength: Int64, blur: Float64, scale: Float64): (Array<Bool>, Array<Int64>, 
    Int64) {
    let length = filterLength * Int64(max(ceil(blur * scale), 1.0))
    let filterFactor = min(1.0 / (blur * scale), 1.0)

    let coeffs = Array<Bool>(dy * length, item: false)
    let start = Array<Int64>(dy, item: 0)
    for (y in 0..dy) {
        var interpX = scale * (Float64(y) + 0.5) - 0.5
        start[y] = Int64(interpX) - length / 2 + 1
        interpX -= Float64(start[y])
        for (i in 0..length) {
            let j = (interpX - Float64(i)) * filterFactor
            coeffs[y * length + i] = j >= -0.5 && j < 0.5
        }
    }

    return (coeffs, start, length)
}
