/*
 * Copyright 2013 ZXing authors
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

// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

from QRCode4cj import common.Qrcoder4cjNotFoundException
from QRCode4cj import aztec.common.AztecDetectorResult
from QRCode4cj import aztec.decoder.Decoder
from QRCode4cj import aztec.detector.Point
from QRCode4cj import aztec.detector.Detector
from QRCode4cj import aztec.encoder.AztecCode
from QRCode4cj import aztec.encoder.Encoder
from QRCode4cj import common.BitMatrix
from QRCode4cj import common.DecoderResult
from std import unittest.*
from std import unittest.testmacro.*
from std import collection.*
from std import unicode.*
from std import random.*

main(): Int64 {
    let tester = DetectorTest()
    tester.execute()
    tester.printResult()
    tester.getTestInfo().errorCount + tester.getTestInfo().failedCount
    0
}

var random_1: Array<Int64> = [
    9,
    4,
    9,
    0,
    2,
    8,
    6,
    7,
    2,
    3,
    9,
    10,
    10,
    7,
    6,
    11,
    5,
    10,
    10,
    11,
    2,
    1,
    8,
    4,
    1,
    11,
    8,
    10,
    6,
    6,
    6,
    7,
    7,
    10,
    4,
    6,
    0,
    0,
    9,
    8,
    10,
    1,
    2,
    2,
    6,
    5,
    7,
    3,
    9,
    11,
    3,
    1,
    3,
    3,
    10,
    1,
    3,
    11,
    11,
    8,
    6,
    3,
    6,
    1,
    5,
    8,
    4,
    4,
    3,
    0,
    6,
    5,
    0,
    4,
    5,
    7,
    3,
    6,
    11,
    0,
    10,
    10,
    11,
    5,
    3,
    5,
    7,
    10,
    9,
    6,
    3,
    5,
    9,
    9,
    3,
    9,
    3,
    9,
    9,
    11,
    1,
    10,
    1,
    4,
    6,
    4,
    10,
    1,
    9,
    3,
    5,
    4,
    5,
    8,
    6,
    8,
    1,
    0,
    3,
    8,
    1,
    8,
    6,
    9,
    3,
    2,
    0,
    7,
    1,
    0,
    3,
    6,
    8,
    6,
    4,
    2,
    1,
    5
]
var random_2: Array<Int64> = [
    5,
    10,
    10,
    5,
    2,
    4,
    8,
    9,
    10,
    11,
    11,
    10,
    2,
    2,
    3,
    3,
    7,
    1,
    4,
    10,
    1,
    4,
    8,
    10,
    0,
    0,
    10,
    1,
    5,
    6,
    6,
    3,
    1,
    6,
    5,
    5,
    8,
    6,
    0,
    6,
    11,
    9,
    3,
    4,
    3,
    11,
    3,
    7,
    2,
    11,
    5,
    0,
    9,
    0,
    7,
    1,
    9,
    9,
    6,
    2,
    4,
    8,
    6,
    7,
    0,
    6,
    9,
    7,
    6,
    5,
    6,
    1,
    5,
    11,
    6,
    7,
    6,
    3,
    7,
    10,
    7,
    10,
    9,
    4,
    0,
    4,
    10,
    5,
    2,
    4,
    2,
    0,
    11,
    10,
    2,
    9,
    4,
    8,
    10,
    9,
    2,
    6,
    11,
    2,
    0,
    0,
    4,
    2,
    10,
    4,
    5,
    7,
    3,
    1,
    9,
    9,
    9,
    10,
    9,
    7,
    9,
    8,
    10,
    11,
    2,
    8,
    8,
    2,
    0,
    1,
    9,
    9,
    6,
    7,
    9,
    8,
    9,
    9,
    4,
    0
]
var random_3: Array<Int64> = [
    5,
    9,
    2,
    0,
    3,
    3,
    5,
    7,
    2,
    5,
    10,
    11,
    4,
    2,
    1,
    4,
    5,
    4,
    10,
    1,
    5,
    3,
    3,
    6,
    1,
    0,
    3,
    11,
    6,
    0,
    7,
    0,
    0,
    11,
    7,
    1,
    2,
    0,
    10,
    5,
    0,
    11,
    4,
    8,
    7,
    2,
    8,
    10,
    4,
    9,
    2,
    10,
    3,
    0,
    11,
    0,
    11,
    3,
    0,
    0,
    11,
    3,
    6,
    1,
    9,
    4,
    7,
    9,
    7,
    11,
    2,
    5,
    8,
    5,
    1,
    5,
    8,
    5,
    8,
    7,
    0,
    3,
    6,
    6,
    9,
    6,
    0,
    11,
    10,
    9,
    10,
    7,
    6,
    3,
    3,
    11,
    0,
    9,
    5,
    5,
    7,
    8,
    5,
    8,
    6,
    8,
    1,
    0,
    0,
    7,
    7,
    7,
    10,
    3,
    4,
    8,
    6,
    4,
    2,
    11,
    8,
    10,
    10,
    9,
    1,
    0,
    6,
    6,
    11,
    9,
    10,
    5,
    4,
    4,
    11,
    5
]

/**
 * Tests for the Detector
 *
 * @author Frank Yellin
 */
@Test
public class DetectorTest {
    @TestCase
    public func testErrorInParameterLocatorZeroZero(): Unit {
        // Layers=1, CodeWords=1.  So the parameter info and its Reed-Solomon info
        // will be completely zero!
        testErrorInParameterLocator("X", random_1)
    }

    @TestCase
    public func testErrorInParameterLocatorCompact(): Unit {
        testErrorInParameterLocator("This is an example Aztec symbol for Wikipedia.", random_2)
    }

    @TestCase
    public func testErrorInParameterLocatorNotCompact(): Unit {
        var alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwxyz"
        testErrorInParameterLocator(alphabet + alphabet + alphabet, random_3)
    }

    // Test that we can tolerate errors in the parameter locator bits
    private static func testErrorInParameterLocator(data: String, random: Array<Int64>) {
        var randomNum = 0;
        var aztec: AztecCode = Encoder.encode(data, 25, Encoder.DEFAULT_AZTEC_LAYERS)
        var code = aztec.getMatrix().hashCode();

        //var random: Random = Random(UInt64(code))   // pseudo-random, but deterministic
        var layers: Int64 = aztec.getLayers()
        var compact: Bool = aztec.isCompact()
        var orientationPoints: ArrayList<Point> = getOrientationPoints(aztec)
        var mirrorBoolArr: Array<Bool> = [false, true]
        for (isMirrorN in 0..2) {
            var isMirror: Bool = mirrorBoolArr[isMirrorN]
            var rotationArr: Array<BitMatrix> = getRotations(aztec.getMatrix())
            for (matrixN in 0..rotationArr.size) {
                var matrix: BitMatrix = rotationArr[matrixN]

                // Systematically try every possible 1- and 2-bit error.
                for (error1 in 0..orientationPoints.size) {
                    for (error2 in error1..orientationPoints.size) {
                        var copy: BitMatrix = clone(matrix)
                        if (isMirror) {
                            copy = transpose(matrix)
                        }
                        copy.flip(
                            orientationPoints.get(error1).getOrThrow().getX(),
                            orientationPoints.get(error1).getOrThrow().getY()
                        )
                        if (error2 > error1) {
                            // if error2 == error1, we only test a single error
                            copy.flip(
                                orientationPoints.get(error2).getOrThrow().getX(),
                                orientationPoints.get(error2).getOrThrow().getY()
                            )
                        }

                        // The detector doesn't seem to work when matrix bits are only 1x1.  So magnify.
                        var r: AztecDetectorResult = Detector(makeLarger(copy, 3)).detect(isMirror)

                        @Assert(r.getNbLayers(), layers)
                        @Assert(r.isCompact(), compact)
                        var res: DecoderResult = Decoder().decode(r)
                        @Assert(data, res.getText())
                    }
                }

                // Try a few random three-bit errors;
                for (i in 0..5) {
                    var copy: BitMatrix = clone(matrix)
                    var errors: ArrayList<Int64> = ArrayList<Int64>()
                    while (errors.size < 3) {
                        // Quick and dirty way of getting three distinct integers between 1 and n.
                        errors.append(random[randomNum])
                        randomNum++
                    }
                    for (errorN in 0..errors.size) {
                        var error: Int64 = errors[errorN]
                        copy.flip(
                            orientationPoints.get(error).getOrThrow().getX(),
                            orientationPoints.get(error).getOrThrow().getY()
                        )
                    }
                    try {
                        Detector(makeLarger(copy, 3)).detect(false)
                    } catch (expected: Qrcoder4cjNotFoundException) {
                        // continue
                    }
                }
            }
        }
    }

    // Zooms a bit matrix so that each bit is factor x factor
    private static func makeLarger(input: BitMatrix, factor: Int64): BitMatrix {
        var width: Int64 = input.getWidth()
        var output: BitMatrix = BitMatrix(width * factor)
        for (inputY in 0..width) {
            for (inputX in 0..width) {
                if (input.get(inputX, inputY)) {
                    output.setRegion(inputX * factor, inputY * factor, factor, factor)
                }
            }
        }
        return output
    }

    // Returns a list of the four rotations of the BitMatrix.
    private static func getRotations(matrix0: BitMatrix): Array<BitMatrix> {
        var matrix90: BitMatrix = rotateRight(matrix0)
        var matrix180: BitMatrix = rotateRight(matrix90)
        var matrix270: BitMatrix = rotateRight(matrix180)
        var matrixArr: Array<BitMatrix> = [matrix0, matrix90, matrix180, matrix270]
        return matrixArr
    }

    // Rotates a square BitMatrix to the right by 90 degrees
    private static func rotateRight(input: BitMatrix): BitMatrix {
        var width: Int64 = input.getWidth()
        var result: BitMatrix = BitMatrix(width)
        for (x in 0..width) {
            for (y in 0..width) {
                if (input.get(x, y)) {
                    result.set(y, width - x - 1)
                }
            }
        }
        return result
    }

    // Returns the transpose of a bit matrix, which is equivalent to rotating the
    // matrix to the right, and then flipping it left-to-right
    private static func transpose(input: BitMatrix): BitMatrix {
        var width: Int64 = input.getWidth()
        var result: BitMatrix = BitMatrix(width)
        for (x in 0..width) {
            for (y in 0..width) {
                if (input.get(x, y)) {
                    result.set(y, x)
                }
            }
        }
        return result
    }

    private static func clone(input: BitMatrix): BitMatrix {
        var width: Int64 = input.getWidth()
        var result: BitMatrix = BitMatrix(width)
        for (x in 0..width) {
            for (y in 0..width) {
                if (input.get(x, y)) {
                    result.set(x, y)
                }
            }
        }
        return result
    }

    private static func getOrientationPoints(code: AztecCode): ArrayList<Point> {
        var center: Int64 = code.getMatrix().getWidth() / 2
        var offset: Int64 = if (code.isCompact()) {
            5
        } else {
            7
        }
        var result: ArrayList<Point> = ArrayList<Point>()
        for (xSign in -1..=1 : 2) {
            for (ySign in -1..=1 : 2) {
                result.append(Point(center + xSign * offset, center + ySign * offset))
                result.append(Point(center + xSign * (offset - 1), center + ySign * offset))
                result.append(Point(center + xSign * offset, center + ySign * (offset - 1)))
            }
        }
        return result
    }
}
