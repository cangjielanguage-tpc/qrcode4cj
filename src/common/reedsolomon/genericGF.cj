/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.common.reedsolomon

import encoding.hex.*
import QRCode4cj.tools.*

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

        expTable = Array<Int64>(size, repeat: 0)
        logTable = Array<Int64>(size, repeat: 0)
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
        var coefficients = Array<Int64>(degree + 1, repeat: 0)
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
