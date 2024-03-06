/*
 * Copyright 2007 ZXing authors
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

from encoding import hex.*
import zxing.code.tools.*

/**
 * <p>This class contains utility methods for performing mathematical operations over
 * the Galois Fields. Operations use a given primitive polynomial in calculations.</p>
 *
 * <p>Throughout this package, elements of the GF are represented as an {@code int}
 * for convenience and speed (but at the cost of memory).
 * </p>
 *
 * @author Sean Owen
 * @author David Olivier
 */
public class GenericGF {
    public static let AZTEC_DATA_12: GenericGF = GenericGF(0x1069, 4096, 1) // x^12 + x^6 + x^5 + x^3 + 1
    public static let AZTEC_DATA_10 = GenericGF(0x409, 1024, 1) // x^10 + x^3 + 1
    public static let AZTEC_DATA_6 = GenericGF(0x43, 64, 1) // x^6 + x + 1
    public static let AZTEC_PARAM = GenericGF(0x13, 16, 1) // x^4 + x + 1
    public static let QR_CODE_FIELD_256 = GenericGF(0x011D, 256, 0) // x^8 + x^4 + x^3 + x^2 + 1
    public static let DATA_MATRIX_FIELD_256 = GenericGF(0x012D, 256, 1) // x^8 + x^5 + x^3 + x^2 + 1
    public static let AZTEC_DATA_8 = DATA_MATRIX_FIELD_256
    public static let MAXICODE_FIELD_64 = AZTEC_DATA_6

    private var expTable: Array<Int64> = Array<Int64>()
    private var logTable: Array<Int64> = Array<Int64>()
    private var zero: ?GenericGFPoly = None
    private var one: ?GenericGFPoly = None
    private var size: Int64 = 0
    private var primitive: Int64 = 0
    private var generatorBase: Int64 = 0
    public var flag: Bool = false

    /**
     * Create a representation of GF(size) using the given primitive polynomial.
     *
     * @param primitive irreducible polynomial whose coefficients are represented by
     * the bits of an int, where the least-significant bit represents the constant
     * coefficient
     * @param size the size of the field
     * @param b the factor b in the generator polynomial can be 0- or 1-based
     * (g(x) = (x+a^b)(x+a^(b+1))...(x+a^(b+2t-1))).
     * In most cases it should be 1, but for QR code it is 0.
     */
    public init(primitive: Int64, size: Int64, b: Int64) {
        this.primitive = primitive
        this.size = size
        this.generatorBase = b

        expTable = Array<Int64>(size, item: 0)
        logTable = Array<Int64>(size, item: 0)
        var x = 1
        for (i in 0..size) {
            expTable[i] = x
            x *= 2

            // we're assuming the generator alpha is 2
            if (x >= size) {
                x ^= primitive
                x &= size - 1
            }
        }
        for (i in 0..size - 1) {
            logTable[expTable[i]] = i
        }

        // logTable[0] == 0 but this should never be used
        zero = GenericGFPoly(this, [0])
        one = GenericGFPoly(this, [1])
        this.flag = true
    }

    public func getZero(): GenericGFPoly {
        return zero.getOrThrow()
    }

    public func getOne(): GenericGFPoly {
        return one.getOrThrow()
    }

    /**
     * @return the monomial representing coefficient * x^degree
     */
    public func buildMonomial(degree: Int64, coefficient: Int64): GenericGFPoly {
        if (degree < 0) {
            throw IllegalArgumentException()
        }
        if (coefficient == 0) {
            return zero.getOrThrow()
        }
        var coefficients = Array<Int64>(degree + 1, item: 0)
        coefficients[0] = coefficient
        return GenericGFPoly(this, coefficients)
    }

    /**
     * Implements both addition and subtraction -- they are the same in GF(size).
     *
     * @return sum/difference of a and b
     */
    public static func addOrSubtract(a: Int64, b: Int64): Int64 {
        return a ^ b
    }

    /**
     * @return 2 to the power of a in GF(size)
     */
    public func exp(a: Int64): Int64 {
        return expTable[a]
    }

    /**
     * @return base 2 log of a in GF(size)
     */
    public func log(a: Int64): Int64 {
        if (a == 0) {
            throw IllegalArgumentException()
        }
        return logTable[a]
    }

    /**
     * @return multiplicative inverse of a
     */
    public func inverse(a: Int64): Int64 {
        if (a == 0) {
            throw ArithmeticException()
        }
        return expTable[size - logTable[a] - 1]
    }

    /**
     * @return product of a and b in GF(size)
     */
    public func multiply(a: Int64, b: Int64): Int64 {
        if (a == 0 || b == 0) {
            return 0
        }
        return expTable[(logTable[a] + logTable[b]) % (size - 1)]
    }

    public func getSize(): Int64 {
        return size
    }

    public func getGeneratorBase(): Int64 {
        return generatorBase
    }

    public func toString(): String {
        var str = intToHexString(primitive)
        return "GF(0x${str},${size})"
    }
}
