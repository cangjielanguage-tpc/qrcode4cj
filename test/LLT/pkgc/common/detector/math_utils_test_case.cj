/*
 * Copyright 2014 ZXing authors
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

from QRCode4cj import zxing.code.common.detector.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion
from std import math.*

main(): Int64 {
    let tester = MathUtilsTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link MathUtils}.
 */
@Test
public class MathUtilsTestCase {
    private static let EPSILON: Float32 = 1.0E-8f32;

    @TestCase
    public func testRound(): Unit {
        @Assert(-1, MathUtils.round(-1.0))
        @Assert(0, MathUtils.round(0.0))
        @Assert(1, MathUtils.round(1.0))

        @Assert(2, MathUtils.round(1.9))
        @Assert(2, MathUtils.round(2.1))

        @Assert(3, MathUtils.round(2.5))

        @Assert(-2, MathUtils.round(-1.9))
        @Assert(-2, MathUtils.round(-2.1))

        @Assert(-3, MathUtils.round(-2.5))

        // This differs from Math.round()
        @Assert(Int64.Max, MathUtils.round(Float32(Int64.Max)))
        @Assert(Int64.Min, MathUtils.round(Float32(Int64.Min)))

        @Assert(Int64.Max, MathUtils.round(Float32.Max))
        @Assert(Int64.Min, MathUtils.round(Float32.Min))

        @Assert(0, MathUtils.round(Float32.NaN))
    }

    @TestCase
    public func testDistance(): Unit {
        MathUtilsTestCase.assertEqual(sqrt(8.0), MathUtils.distance(1.0, 2.0, 3.0, 4.0), EPSILON)
        MathUtilsTestCase.assertEqual(0.0, MathUtils.distance(1.0, 2.0, 1.0, 2.0), EPSILON);

        MathUtilsTestCase.assertEqual(sqrt(8.0), MathUtils.distance(1, 2, 3, 4), EPSILON)
        MathUtilsTestCase.assertEqual(0.0, MathUtils.distance(1, 2, 1, 2), EPSILON);
    }

    public static func assertEqual(left: Float32, right: Float32, epsilon: Float32): Unit {
        if (abs(left - right) < abs(epsilon)) {
            @Assert(0, 0)
        } else {
            assertEqual("left:" + left.toString(), "right:" + right.toString(), 1, 0);
        }
    }

    @TestCase
    public func testSum(): Unit {
        @Assert(0, MathUtils.sum( Array<Int64>()))
        @Assert(1, MathUtils.sum( Array<Int64>([1])))
        @Assert(4, MathUtils.sum( Array<Int64>([1,3])))
        @Assert(0, MathUtils.sum( Array<Int64>([-1,1])))
    }
}
