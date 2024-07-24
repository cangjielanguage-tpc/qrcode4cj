/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package QRCode4cj.common.reedsolomon

import std.collection.*
import std.core.*


public class GenericGFPoly <: Equatable<GenericGFPoly> & ToString {
    private var field: ?GenericGF = None
    private var coefficients = Array<Int64>()
    public var flag: Bool = false

    public init(field: GenericGF, coefficients: Array<Int64>) {
        if (coefficients.size == 0) {
            throw IllegalArgumentException()
        }
        this.field = field
        let coefficientsLength = coefficients.size
        if (coefficientsLength > 1 && coefficients[0] == 0) {
            // Leading term must be non-zero for anything except the constant polynomial "0"
            var firstNonZero = 1
            while (firstNonZero < coefficientsLength && coefficients[firstNonZero] == 0) {
                firstNonZero++
            }
            if (firstNonZero == coefficientsLength) {
                this.coefficients = [0]
            } else {
                this.coefficients = Array<Int64>(coefficientsLength - firstNonZero, item: 0)

                coefficients.copyTo(this.coefficients, firstNonZero, 0, this.coefficients.size)
            }
        } else {
            this.coefficients = coefficients
        }
        this.flag = true
    }

    public func getCoefficients(): Array<Int64> {
        return coefficients
    }

    /**
     * @return degree of this polynomial
     */
    public func getDegree(): Int64 {
        return coefficients.size - 1
    }

    /**
     * @return true iff this polynomial is the monomial "0"
     */
    public func isZero(): Bool {
        return coefficients[0] == 0
    }

    /**
     * @return coefficient of x^degree term in this polynomial
     */
    public func getCoefficient(degree: Int64): Int64 {
        return coefficients[coefficients.size - 1 - degree]
    }

    /**
     * @return evaluation of this polynomial at a given point
     */
    public func evaluateAt(a: Int64): Int64 {
        if (a == 0) {
            // Just return the x^0 coefficient
            return getCoefficient(0)
        }
        if (a == 1) {
            // Just the sum of the coefficients
            var result = 0
            for (i in 0..coefficients.size) {
                result = GenericGF.addOrSubtract(result, coefficients[i])
            }
            return result
        }
        var result = coefficients[0]
        let size = coefficients.size;
        for (i in 1..size) {
            result = GenericGF.addOrSubtract(field.getOrThrow().multiply(a, result), coefficients[i])
        }
        return result
    }

    public func addOrSubtract(other: GenericGFPoly): GenericGFPoly {
        if (!refEq(field.getOrThrow(), other.field.getOrThrow())) {
        }
        if (isZero()) {
            return other
        }
        if (other.isZero()) {
            return this
        }

        var smallerCoefficients: Array<Int64> = this.coefficients
        var largerCoefficients: Array<Int64> = other.coefficients
        if (smallerCoefficients.size > largerCoefficients.size) {
            let temp: Array<Int64> = smallerCoefficients
            smallerCoefficients = largerCoefficients
            largerCoefficients = temp
        }
        var sumDiff = Array<Int64>(largerCoefficients.size, item: 0)
        let lengthDiff = largerCoefficients.size - smallerCoefficients.size

        // Copy high-order terms only found in higher-degree polynomial's coefficients
        largerCoefficients.copyTo(sumDiff, 0, 0, lengthDiff)

        for (i in lengthDiff..largerCoefficients.size) {
            sumDiff[i] = GenericGF.addOrSubtract(smallerCoefficients[i - lengthDiff], largerCoefficients[i])
        }

        return GenericGFPoly(field.getOrThrow(), sumDiff)
    }

    public func multiply(other: GenericGFPoly): GenericGFPoly {
        if (!refEq(field.getOrThrow(), other.field.getOrThrow())) {
        }
        if (isZero() || other.isZero()) {
            return field.getOrThrow().getZero()
        }
        let aCoefficients: Array<Int64> = this.coefficients
        let aLength = aCoefficients.size
        let bCoefficients: Array<Int64> = other.coefficients
        let bLength = bCoefficients.size
        let product: Array<Int64> = Array<Int64>(aLength + bLength - 1, item: 0)
        for (i in 0..aLength) {
            let aCoeff = aCoefficients[i]
            for (j in 0..bLength) {
                product[i + j] = GenericGF.addOrSubtract(
                    product[i + j],
                    field.getOrThrow().multiply(aCoeff, bCoefficients[j])
                )
            }
        }
        return GenericGFPoly(field.getOrThrow(), product)
    }

    public func multiply(scalar: Int64): GenericGFPoly {
        if (scalar == 0) {
            return field.getOrThrow().getZero();
        }
        if (scalar == 1) {
            return this
        }
        let size = coefficients.size
        let product = Array<Int64>(size, item: 0)
        for (i in 0..size) {
            product[i] = field.getOrThrow().multiply(coefficients[i], scalar)
        }
        return GenericGFPoly(field.getOrThrow(), product)
    }

    public func multiplyByMonomial(degree: Int64, coefficient: Int64): GenericGFPoly {
        if (degree < 0) {
            throw IllegalArgumentException();
        }
        if (coefficient == 0) {
            return field.getOrThrow().getZero()
        }
        let size = coefficients.size
        let product: Array<Int64> = Array<Int64>(size + degree, item: 0)
        for (i in 0..size) {
            product[i] = field.getOrThrow().multiply(coefficients[i], coefficient)
        }
        return GenericGFPoly(field.getOrThrow(), product)
    }

    func divide(other: GenericGFPoly): Array<GenericGFPoly> {
        if (!refEq(field.getOrThrow(), other.field.getOrThrow())) {
        }
        if (other.isZero()) {
            throw IllegalArgumentException("Divide by 0")
        }

        var quotient: GenericGFPoly = field.getOrThrow().getZero()
        var remainder: GenericGFPoly = this

        let denominatorLeadingTerm = other.getCoefficient(other.getDegree())
        let inverseDenominatorLeadingTerm = field.getOrThrow().inverse(denominatorLeadingTerm)

        while (remainder.getDegree() >= other.getDegree() && !remainder.isZero()) {
            let degreeDifference = remainder.getDegree() - other.getDegree()
            let scale = field.getOrThrow().multiply(
                remainder.getCoefficient(remainder.getDegree()),
                inverseDenominatorLeadingTerm
            );
            let term: GenericGFPoly = other.multiplyByMonomial(degreeDifference, scale)
            let iterationQuotient: GenericGFPoly = field.getOrThrow().buildMonomial(degreeDifference, scale)
            quotient = quotient.addOrSubtract(iterationQuotient)
            remainder = remainder.addOrSubtract(term)
        }
        let tmp = [quotient, remainder]
        return tmp
    }

    public func toString(): String {
        if (isZero()) {
            return "0"
        }
        var result: ArrayList<Rune> = ArrayList<Rune>();
        for (degree in getDegree()..=0 : -1) {
            var coefficient = getCoefficient(degree)
            if (coefficient != 0) {
                if (coefficient < 0) {
                    if (degree == getDegree()) {
                        result.append(r'-')
                    } else {
                        result.appendAll(" - ".toRuneArray())
                    }
                    coefficient = -coefficient
                } else {
                    if (result.size > 0) {
                        result.appendAll(" + ".toRuneArray())
                    }
                }
                if (degree == 0 || coefficient != 1) {
                    let alphaPower = field.getOrThrow().log(coefficient);
                    if (alphaPower == 0) {
                        result.append(r'1')
                    } else if (alphaPower == 1) {
                        result.append(r'a')
                    } else {
                        result.appendAll("a^".toRuneArray())
                        result.appendAll(alphaPower.toString().toRuneArray())
                    }
                }
                if (degree != 0) {
                    if (degree == 1) {
                        result.append(r'x')
                    } else {
                        result.appendAll("x^".toRuneArray())
                        result.appendAll(degree.toString().toRuneArray())
                    }
                }
            }
        }
        return String(result)
    }

    public operator func ==(that: GenericGFPoly): Bool {
        return refEq(that, this);
    }

    public operator func !=(that: GenericGFPoly): Bool {
        return !refEq(that, this)
    }
}
