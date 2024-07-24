// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.reedsolomon.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion

main(): Int64 {
    let tester = GenericGFPolyTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
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
