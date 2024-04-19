/*
 * Copyright 2018 ZXing authors
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

from QRCode4cj import common.reedsolomon.*
from std import unittest.* //testfame
from std import unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = GenericGFPolyTestCase()
    tester.execute()
    tester.printResult()
    0
}

/**
 * Tests {@link GenericGFPoly}.
 */
@Test
public class GenericGFPolyTestCase {
    private static let FIELD: GenericGF = GenericGF.QR_CODE_FIELD_256;

    @TestCase
    public func testPolynomialString(): Unit {
        @Assert("0", FIELD.getZero().toString())
        @Assert("-1", FIELD.buildMonomial(0, -1).toString())
        var p: GenericGFPoly = GenericGFPoly(FIELD, [3, 0, -2, 1, 1]);
        @Assert("a^25x^4 - ax^2 + x + 1", p.toString())
        p = GenericGFPoly(FIELD, Array<Int64>([3]))
        @Assert("a^25", p.toString())
    }

    @TestCase
    public func testZero(): Unit {
        @Assert(FIELD.getZero(),FIELD.buildMonomial(1, 0))
        @Assert(FIELD.getZero(), FIELD.buildMonomial(1, 2).multiply(0))
    }

    @TestCase
    public func testEvaluate(): Unit {
        @Assert(3, FIELD.buildMonomial(0, 3).evaluateAt(0))
    }

    public static func add() {}
}
