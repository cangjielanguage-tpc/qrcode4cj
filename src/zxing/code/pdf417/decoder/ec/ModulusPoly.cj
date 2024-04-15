/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package zxing.code.pdf417.decoder.ec

import zxing.code.tools.System
import zxing.code.tools.UTF32String
from std import collection.*

/**
 * @author Sean Owen
 */
open class ModulusPoly <: ToString {
    public var field: ModulusGF
    public var coefficients: Array<Int64>

    init(field: ModulusGF, coefficients: Array<Int64>) {
        if (coefficients.size == 0) {
            throw IllegalArgumentException();
        }
        this.field = field
        var coefficientsLength: Int64 = coefficients.size;
        if (coefficientsLength > 1 && coefficients[0] == 0) {
            // Leading term must be non-zero for anything except the constant polynomial "0"
            var firstNonZero: Int64 = 1
            while (firstNonZero < coefficientsLength && coefficients[firstNonZero] == 0) {
                firstNonZero++
            }
            if (firstNonZero == coefficientsLength) {
                this.coefficients = Array<Int64>(1, item: 0)
            } else {
                this.coefficients = Array<Int64>(coefficientsLength - firstNonZero, item: 0)
                System.arraycopy(
                    coefficients,
                    firstNonZero,
                    this.coefficients,
                    0,
                    this.coefficients.size
                );
            }
        } else {
            this.coefficients = coefficients
        }
    }

    func getCoefficients(): Array<Int64> {
        return coefficients
    }

    /**
     * @return degree of this polynomial
     */
    func getDegree(): Int64 {
        return coefficients.size - 1
    }

    /**
     * @return true iff this polynomial is the monomial "0"
     */
    func isZero(): Bool {
        return coefficients[0] == 0
    }

    /**
     * @return coefficient of x^degree term in this polynomial
     */
    func getCoefficient(degree: Int64): Int64 {
        return coefficients[coefficients.size - 1 - degree]
    }

    /**
     * @return evaluation of this polynomial at a given point
     */
    func evaluateAt(a: Int64): Int64 {
        if (a == 0) {
            // Just return the x^0 coefficient
            return getCoefficient(0);
        }
        if (a == 1) {
            // Just the sum of the coefficients
            var result: Int64 = 0
            for (i in 0..coefficients.size) {
                result = field.add(result, coefficients[i])
            }
            return result
        }
        var result: Int64 = coefficients[0]
        var size: Int64 = coefficients.size;
        for (i in 1..size) {
            result = field.add(field.multiply(a, result), coefficients[i])
        }
        return result
    }

    func add(other: ModulusPoly): ModulusPoly {
        if (!refEq(field, other.field)) {
        }
        if (isZero()) {
            return other
        }
        if (other.isZero()) {
            return this
        }

        var smallerCoefficients: Array<Int64> = this.coefficients;
        var largerCoefficients: Array<Int64> = other.coefficients;
        if (smallerCoefficients.size > largerCoefficients.size) {
            var temp: Array<Int64> = smallerCoefficients
            smallerCoefficients = largerCoefficients
            largerCoefficients = temp
        }
        var sumDiff: Array<Int64> = Array<Int64>(largerCoefficients.size, item: 0);
        var lengthDiff: Int64 = largerCoefficients.size - smallerCoefficients.size

        // Copy high-order terms only found in higher-degree polynomial's coefficients
        System.arraycopy(largerCoefficients, 0, sumDiff, 0, lengthDiff);
        for (i in lengthDiff..largerCoefficients.size) {
            sumDiff[i] = field.add(smallerCoefficients[i - lengthDiff], largerCoefficients[i])
        }

        return ModulusPoly(field, sumDiff);
    }

    func subtract(other: ModulusPoly): ModulusPoly {
        if (!refEq(field, other.field)) {
        }
        if (other.isZero()) {
            return this
        }
        return add(other.negative());
    }

    func multiply(other: ModulusPoly): ModulusPoly {
        if (!refEq(field, other.field)) {
        }
        if (isZero() || other.isZero()) {
            return field.getZero();
        }
        var aCoefficients: Array<Int64> = this.coefficients;
        var aLength: Int64 = aCoefficients.size;
        var bCoefficients: Array<Int64> = other.coefficients;
        var bLength: Int64 = bCoefficients.size;
        var product: Array<Int64> = Array<Int64>(aLength + bLength - 1, item: 0);
        for (i in 0..aLength) {
            var aCoeff: Int64 = aCoefficients[i]
            for (j in 0..bLength) {
                product[i + j] = field.add(product[i + j], field.multiply(aCoeff, bCoefficients[j]))
            }
        }
        return ModulusPoly(field, product);
    }

    func negative(): ModulusPoly {
        var size: Int64 = coefficients.size;
        var negativeCoefficients: Array<Int64> = Array<Int64>(size, item: 0);
        for (i in 0..size) {
            negativeCoefficients[i] = field.subtract(0, coefficients[i])
        }
        return ModulusPoly(field, negativeCoefficients);
    }

    func multiply(scalar: Int64): ModulusPoly {
        if (scalar == 0) {
            return field.getZero();
        }
        if (scalar == 1) {
            return this
        }
        var size: Int64 = coefficients.size;
        var product: Array<Int64> = Array<Int64>(size, item: 0);
        for (i in 0..size) {
            product[i] = field.multiply(coefficients[i], scalar)
        }
        return ModulusPoly(field, product);
    }

    func multiplyByMonomial(degree: Int64, coefficient: Int64): ModulusPoly {
        if (degree < 0) {
            throw IllegalArgumentException();
        }
        if (coefficient == 0) {
            return field.getZero();
        }
        var size: Int64 = coefficients.size;
        var product: Array<Int64> = Array<Int64>(size + degree, item: 0);
        for (i in 0..size) {
            product[i] = field.multiply(coefficients[i], coefficient)
        }
        return ModulusPoly(field, product);
    }

    public override func toString(): String {
        var result: ArrayList<Char> = ArrayList<Char>()
        for (degree in getDegree()..-1) {
            var coefficient: Int64 = getCoefficient(degree);
            if (coefficient != 0) {
                if (coefficient < 0) {
                    result.appendAll(" - ".toRuneArray());
                    coefficient = -coefficient
                } else {
                    if (result.size > 0) {
                        result.appendAll(" + ".toRuneArray());
                    }
                }
                if (degree == 0 || coefficient != 1) {
                    result.appendAll(coefficient.toString().toRuneArray());
                }
                if (degree != 0) {
                    if (degree == 1) {
                        result.append('x');
                    } else {
                        result.appendAll("x^".toRuneArray());
                        result.appendAll(degree.toString().toRuneArray());
                    }
                }
            }
        }
        return String(result);
    }
}
