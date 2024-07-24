// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.detector.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.math.*

main(): Int64 {
    let tester = MathUtilsTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
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
