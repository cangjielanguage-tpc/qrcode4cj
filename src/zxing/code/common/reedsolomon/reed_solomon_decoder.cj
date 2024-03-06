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

/**
 * <p>Implements Reed-Solomon decoding, as the name implies.</p>
 *
 * <p>The algorithm will not be explained here, but the following references were helpful
 * in creating this implementation:</p>
 *
 * <ul>
 * <li>Bruce Maggs.
 * <a href="http://www.cs.cmu.edu/afs/cs.cmu.edu/project/pscico-guyb/realworld/www/rs_decode.ps">
 * "Decoding Reed-Solomon Codes"</a> (see discussion of Forney's Formula)</li>
 * <li>J.I. Hall. <a href="www.mth.msu.edu/~jhall/classes/codenotes/GRS.pdf">
 * "Chapter 5. Generalized Reed-Solomon Codes"</a>
 * (see discussion of Euclidean algorithm)</li>
 * </ul>
 *
 * <p>Much credit is due to William Rucklidge since portions of this code are an indirect
 * port of his C++ Reed-Solomon implementation.</p>
 *
 * @author Sean Owen
 * @author William Rucklidge
 * @author sanfordsquires
 */
public class ReedSolomonDecoder {
    private let field: GenericGF

    public init(field: GenericGF) {
        this.field = field
    }

    /**
     * <p>Decodes given set of received codewords, which include both data and error-correction
     * codewords. Really, this means it uses Reed-Solomon to detect and correct errors, in-place,
     * in the input.</p>
     *
     * @param received data and error-correction codewords
     * @param twoS number of error-correction codewords available
     * @throws ReedSolomonException if decoding fails for any reason
     */
    public func decode(received: Array<Int64>, twoS: Int64) {
        let poly: GenericGFPoly = GenericGFPoly(field, received)
        let syndromeCoefficients: Array<Int64> = Array<Int64>(twoS, item: 0)
        var noError: Bool = true
        for (i in 0..twoS) {
            let eval = poly.evaluateAt(field.exp(i + field.getGeneratorBase()));
            syndromeCoefficients[syndromeCoefficients.size - 1 - i] = eval
            if (eval != 0) {
                noError = false
            }
        }
        if (noError) {
            return;
        }
        let syndrome: GenericGFPoly = GenericGFPoly(field, syndromeCoefficients);
        let sigmaOmega: Array<GenericGFPoly> = runEuclideanAlgorithm(field.buildMonomial(twoS, 1), syndrome, twoS);
        let sigma: GenericGFPoly = sigmaOmega[0]
        let omega: GenericGFPoly = sigmaOmega[1]
        let errorLocations: Array<Int64> = findErrorLocations(sigma)
        let errorMagnitudes: Array<Int64> = findErrorMagnitudes(omega, errorLocations);
        for (i in 0..errorLocations.size) {
            var position: Int64 = received.size - 1 - field.log(errorLocations[i])
            if (position < 0) {
                throw ReedSolomonException("Bad error location")
            }
            received[position] = GenericGF.addOrSubtract(received[position], errorMagnitudes[i])
        }
    }

    private func runEuclideanAlgorithm(a: GenericGFPoly, b: GenericGFPoly, R: Int64): Array<GenericGFPoly> {
        // Assume a's degree is >= b's
        let temp0 = a
        let temp1 = b
        if (a.getDegree() < b.getDegree()) {
            let temp0 = b
            let temp1 = a
        }

        var rLast: GenericGFPoly = temp0
        var r: GenericGFPoly = temp1
        var tLast: GenericGFPoly = field.getZero()
        var t: GenericGFPoly = field.getOne()

        // Run Euclidean algorithm until r's degree is less than R/2
        while (2 * r.getDegree() >= R) {
            let rLastLast = rLast
            let tLastLast = tLast
            rLast = r
            tLast = t

            // Divide rLastLast by rLast, with quotient in q and remainder in r
            if (rLast.isZero()) {
                // Oops, Euclidean algorithm already terminated?
                throw ReedSolomonException("r_{i-1} was zero")
            }
            r = rLastLast
            var q: GenericGFPoly = field.getZero()
            let denominatorLeadingTerm = rLast.getCoefficient(rLast.getDegree())
            let dltInverse = field.inverse(denominatorLeadingTerm)
            while (r.getDegree() >= rLast.getDegree() && !r.isZero()) {
                let degreeDiff = r.getDegree() - rLast.getDegree()
                let scale = field.multiply(r.getCoefficient(r.getDegree()), dltInverse)
                q = q.addOrSubtract(field.buildMonomial(degreeDiff, scale))
                r = r.addOrSubtract(rLast.multiplyByMonomial(degreeDiff, scale))
            }

            t = q.multiply(tLast).addOrSubtract(tLastLast)

            if (r.getDegree() >= rLast.getDegree()) {
                throw ReedSolomonException(
                    "Division algorithm failed to reduce polynomial? r: ${ r.toString() }, rLast: ${ rLast.toString() }"
                )
            }
        }

        let sigmaTildeAtZero: Int64 = t.getCoefficient(0)
        if (sigmaTildeAtZero == 0) {
            throw ReedSolomonException("sigmaTilde(0) was zero")
        }

        let inverse = field.inverse(sigmaTildeAtZero)
        let sigma: GenericGFPoly = t.multiply(inverse)
        let omega: GenericGFPoly = r.multiply(inverse)
        let tmp = [sigma, omega]
        return tmp
    }

    private func findErrorLocations(errorLocator: GenericGFPoly): Array<Int64> {
        // This is a direct application of Chien's search
        let numErrors = errorLocator.getDegree()
        if (numErrors == 1) { // shortcut
            return [errorLocator.getCoefficient(1)]
        }
        var result: Array<Int64> = Array<Int64>(numErrors, item: 0)
        var e = 0
        var i = 1;
        while (i < field.getSize() && e < numErrors) {
            if (errorLocator.evaluateAt(i) == 0) {
                result[e] = field.inverse(i)
                e++
            }
            i++;
        }
        if (e != numErrors) {
            throw ReedSolomonException("Error locator degree does not match number of roots")
        }
        return result
    }

    private func findErrorMagnitudes(errorEvaluator: GenericGFPoly, errorLocations: Array<Int64>): Array<Int64> {
        // This is directly applying Forney's Formula
        let s = errorLocations.size
        let result = Array<Int64>(s, item: 0)
        for (i in 0..s) {
            let xiInverse = field.inverse(errorLocations[i])
            var denominator = 1
            for (j in 0..s) {
                if (i != j) {
                    //denominator = field.multiply(denominator,
                    //    GenericGF.addOrSubtract(1, field.multiply(errorLocations[j], xiInverse)));
                    // Above should work but fails on some Apple and Linux JDKs due to a Hotspot bug.
                    // Below is a funny-looking workaround from Steven Parkes
                    var term = field.multiply(errorLocations[j], xiInverse)
                    var termPlus1: Int64
                    if ((term & 0x1) == 0) {
                        termPlus1 = term | 1
                    } else {
                        termPlus1 = term & -2 // ~1 
                    }

                    denominator = field.multiply(denominator, termPlus1)
                }
            }
            result[i] = field.multiply(
                errorEvaluator.evaluateAt(xiInverse),
                field.inverse(denominator)
            )
            if (field.getGeneratorBase() != 0) {
                result[i] = field.multiply(result[i], xiInverse)
            }
        }
        return result
    }
}
