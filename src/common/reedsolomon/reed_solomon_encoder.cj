/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package QRCode4cj.common.reedsolomon

import std.random.*

import std.collection.*

public class ReedSolomonEncoder {
    private var field: ?GenericGF = None
    private var cachedGenerators: ArrayList<GenericGFPoly> = ArrayList<GenericGFPoly>()

    public init(field: GenericGF) {
        this.field = field
        this.cachedGenerators.add(GenericGFPoly(field, [1]))
    }

    private func buildGenerator(degree: Int64): GenericGFPoly {
        if (degree >= cachedGenerators.size) {
            var lastGenerator: GenericGFPoly = cachedGenerators[cachedGenerators.size - 1]
            for (d in cachedGenerators.size..=degree) {
                var nextGenerator: GenericGFPoly = lastGenerator.multiply(
                    GenericGFPoly(
                        field.getOrThrow(),
                        [1, field.getOrThrow().exp(d - 1 + field.getOrThrow().getGeneratorBase())]
                    )
                );
                cachedGenerators.add(nextGenerator)
                lastGenerator = nextGenerator
            }
        }
        return cachedGenerators[degree]
    }

    public func encode(toEncode: Array<Int64>, ecBytes: Int64) {
        if (ecBytes == 0) {
            throw IllegalArgumentException("No error correction bytes")
        }
        let dataBytes = toEncode.size - ecBytes
        if (dataBytes <= 0) {
            throw IllegalArgumentException("No data bytes provided")
        }
        let generator: GenericGFPoly = buildGenerator(ecBytes)
        let infoCoefficients: Array<Int64> = Array<Int64>(dataBytes, repeat: 0)
        toEncode.copyTo(infoCoefficients, 0, 0, dataBytes)
        var info: GenericGFPoly = GenericGFPoly(field.getOrThrow(), infoCoefficients)
        info = info.multiplyByMonomial(ecBytes, 1)
        let remainder: GenericGFPoly = info.divide(generator)[1]
        let coefficients: Array<Int64> = remainder.getCoefficients()

        let numZeroCoefficients = ecBytes - coefficients.size
        for (i in 0..numZeroCoefficients) {
            toEncode[dataBytes + i] = 0
        }

        coefficients.copyTo(toEncode, 0, dataBytes + numZeroCoefficients, coefficients.size)
    }
}
