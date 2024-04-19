/*
 * @Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package pdf417.decoder.ec

import common.Qrcoder4cjChecksumException

/**
 * PDF417 error correction implementation.
 */
public open class ErrorCorrection {
    private let field: ModulusGF

    public init() {
        this.field = ModulusGF.PDF417_GF
        this.field.SetZeroOne(this.field);
    }

    /**
     * @param received received codewords
     * @param numECCodewords number of those codewords used for EC
     * @param erasures location of erasures
     * @return number of errors
     * @throws Qrcoder4cjChecksumException if errors cannot be corrected, maybe because of too many errors
     */
    public func decode(
        received: Array<Int64>,
        numECCodewords: Int64,
        erasures: Array<Int64>
    ): Int64 {
        var poly: ModulusPoly = ModulusPoly(field, received)
        var S: Array<Int64> = Array<Int64>(numECCodewords, item: 0)
        var error: Bool = false
        for (i in numECCodewords..0 : -1) {
            var eval: Int64 = poly.evaluateAt(field.exp(i))
            S[numECCodewords - i] = eval
            if (eval != 0) {
                error = true
            }
        }

        if (!error) {
            return 0
        }

        var knownErrors: ModulusPoly = field.getOne()
        if (erasures.size != 0) {
            for (i in 0..erasures.size) {
                var b: Int64 = field.exp(received.size - 1 - erasures[i])

                // Add (1 - bx) term:
                var term: ModulusPoly = ModulusPoly(field, [field.subtract(0, b), 1])
                knownErrors = knownErrors.multiply(term)
            }
        }

        var syndrome: ModulusPoly = ModulusPoly(field, S)

        var sigmaOmega: Array<ModulusPoly> = runEuclideanAlgorithm(
            field.buildMonomial(numECCodewords, 1),
            syndrome,
            numECCodewords
        )
        var sigma: ModulusPoly = sigmaOmega[0]
        var omega: ModulusPoly = sigmaOmega[1]

        //sigma = sigma.multiply(knownErrors)
        var errorLocations: Array<Int64> = findErrorLocations(sigma)
        var errorMagnitudes: Array<Int64> = findErrorMagnitudes(omega, sigma, errorLocations)

        for (i in 0..errorLocations.size) {
            var position: Int64 = received.size - 1 - field.log(errorLocations[i])
            if (position < 0) {
                throw Qrcoder4cjChecksumException.getChecksumInstance()
            }
            received[position] = field.subtract(received[position], errorMagnitudes[i])
        }

        return errorLocations.size
    }

    private func runEuclideanAlgorithm(a: ModulusPoly, b: ModulusPoly, R: Int64): Array<ModulusPoly> {
        // Assume a's degree is >= b's
        if (a.getDegree() < b.getDegree()) {
            var temp: ModulusPoly = a
            a.field = b.field
            a.coefficients = b.coefficients
            b.field = temp.field
            b.coefficients = temp.coefficients
        }

        var rLast: ModulusPoly = a
        var r: ModulusPoly = b
        var tLast: ModulusPoly = field.getZero()
        var t: ModulusPoly = field.getOne()

        // Run Euclidean algorithm until r's degree is less than R/2
        while (r.getDegree() >= R / 2) {
            var rLastLast: ModulusPoly = rLast
            var tLastLast: ModulusPoly = tLast
            rLast = r
            tLast = t

            // Divide rLastLast by rLast, with quotient in q and remainder in r
            if (rLast.isZero()) {
                // Oops, Euclidean algorithm already terminated?
                throw Qrcoder4cjChecksumException.getChecksumInstance()
            }
            r = rLastLast
            var q: ModulusPoly = field.getZero()
            var denominatorLeadingTerm: Int64 = rLast.getCoefficient(rLast.getDegree())
            var dltInverse: Int64 = field.inverse(denominatorLeadingTerm)
            while (r.getDegree() >= rLast.getDegree() && !r.isZero()) {
                var degreeDiff: Int64 = r.getDegree() - rLast.getDegree()
                var scale: Int64 = field.multiply(r.getCoefficient(r.getDegree()), dltInverse)
                q = q.add(field.buildMonomial(degreeDiff, scale))
                r = r.subtract(rLast.multiplyByMonomial(degreeDiff, scale))
            }

            t = q.multiply(tLast).subtract(tLastLast).negative()
        }

        var sigmaTildeAtZero: Int64 = t.getCoefficient(0)
        if (sigmaTildeAtZero == 0) {
            throw Qrcoder4cjChecksumException.getChecksumInstance()
        }

        var inverse: Int64 = field.inverse(sigmaTildeAtZero)
        var sigma: ModulusPoly = t.multiply(inverse)
        var omega: ModulusPoly = r.multiply(inverse)
        return [sigma, omega]
    }

    private func findErrorLocations(errorLocator: ModulusPoly): Array<Int64> {
        // This is a direct application of Chien's search
        var numErrors: Int64 = errorLocator.getDegree()
        var result: Array<Int64> = Array<Int64>(numErrors, item: 0)
        var e: Int64 = 0
        var i = 1;
        while (i < field.getSize() && e < numErrors) {
            if (errorLocator.evaluateAt(i) == 0) {
                result[e] = field.inverse(i)
                e++
            }
            i++
        }
        if (e != numErrors) {
            throw Qrcoder4cjChecksumException.getChecksumInstance()
        }
        return result
    }

    private func findErrorMagnitudes(
        errorEvaluator: ModulusPoly,
        errorLocator: ModulusPoly,
        errorLocations: Array<Int64>
    ): Array<Int64> {
        var errorLocatorDegree: Int64 = errorLocator.getDegree()
        if (errorLocatorDegree < 1) {
            return Array<Int64>(0, item: 0)
        }
        var formalDerivativeCoefficients: Array<Int64> = Array<Int64>(errorLocatorDegree, item: 0)
        for (i in 1..errorLocatorDegree + 1) {
            formalDerivativeCoefficients[errorLocatorDegree - i] = field.multiply(i, errorLocator.getCoefficient(i))
        }
        var formalDerivative: ModulusPoly = ModulusPoly(field, formalDerivativeCoefficients)

        // This is directly applying Forney's Formula
        var s: Int64 = errorLocations.size
        var result: Array<Int64> = Array<Int64>(s, item: 0)
        for (i in 0..s) {
            var xiInverse: Int64 = field.inverse(errorLocations[i])
            var numerator: Int64 = field.subtract(0, errorEvaluator.evaluateAt(xiInverse))
            var denominator: Int64 = field.inverse(formalDerivative.evaluateAt(xiInverse))
            result[i] = field.multiply(numerator, denominator)
        }
        return result
    }
}
