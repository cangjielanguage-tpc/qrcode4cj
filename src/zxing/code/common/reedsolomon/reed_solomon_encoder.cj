/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package zxing.code.common.reedsolomon

from std import random.*
from std import format.*

/**
 * <p>Implements Reed-Solomon encoding, as the name implies.</p>
 *
 * @author Sean Owen
 * @author William Rucklidge
 */
public class ReedSolomonEncoder {
    private var field: ?GenericGF = None
    private var cachedGenerators: ArrayList<GenericGFPoly> = ArrayList<GenericGFPoly>()

    public init(field: GenericGF) {
        this.field = field
        this.cachedGenerators.append(GenericGFPoly(field, [1]))
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
                cachedGenerators.append(nextGenerator)
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
        let infoCoefficients: Array<Int64> = Array<Int64>(dataBytes, item: 0)
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
