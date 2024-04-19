/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package pdf417.decoder.ec

import pdf417.common.PDF417Common

/**
 * <p>A field based on powers of a generatoreger:Int64 modulo some modulus.</p>
     , *
 * @author Sean Owen
 * @see com.google.zxing.common.reedsolomon.GenericGF
 */
public open class ModulusGF {
    public static let PDF417_GF: ModulusGF = ModulusGF(PDF417Common.NUMBER_OF_CODEWORDS, 3);

    private let expTable: Array<Int64>
    private let logTable: Array<Int64>
    private var zero: ?ModulusPoly = None
    private var one: ?ModulusPoly = None
    private let modulus: Int64

    init(modulus: Int64, generator: Int64) {
        this.modulus = modulus
        expTable = Array<Int64>(modulus, item: 0)
        logTable = Array<Int64>(modulus, item: 0)
        var x: Int64 = 1
        for (i in 0..modulus) {
            expTable[i] = x
            x = (x * generator) % modulus
        }
        for (i in 0..modulus - 1) {
            logTable[expTable[i]] = i
        }
    }

    public func SetZeroOne(_: ModulusGF) {
        zero = ModulusPoly(this, [0])
        one = ModulusPoly(this, [1])
    }

    func getZero(): ModulusPoly {
        return zero.getOrThrow();
    }

    func getOne(): ModulusPoly {
        return one.getOrThrow();
    }

    func buildMonomial(degree: Int64, coefficient: Int64): ModulusPoly {
        if (degree < 0) {
            throw IllegalArgumentException();
        }
        if (coefficient == 0) {
            return zero.getOrThrow()
        }
        var coefficients: Array<Int64> = Array<Int64>(degree + 1, item: 0);
        coefficients[0] = coefficient
        return ModulusPoly(this, coefficients);
    }

    func add(a: Int64, b: Int64): Int64 {
        return (a + b) % modulus
    }

    func subtract(a: Int64, b: Int64): Int64 {
        return (modulus + a - b) % modulus
    }

    func exp(a: Int64): Int64 {
        return expTable[a]
    }

    func log(a: Int64): Int64 {
        if (a == 0) {
            throw IllegalArgumentException();
        }
        return logTable[a]
    }

    func inverse(a: Int64): Int64 {
        if (a == 0) {
            throw ArithmeticException();
        }
        return expTable[modulus - logTable[a] - 1]
    }

    func multiply(a: Int64, b: Int64): Int64 {
        if (a == 0 || b == 0) {
            return 0
        }
        return expTable[(logTable[a] + logTable[b]) % (modulus - 1)]
    }

    func getSize(): Int64 {
        return modulus
    }
}
