// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

import QRCode4cj.common.*
import std.unittest.* //testfame
import std.unittest.testmacro.* //macro_Defintion
import std.math.*
import std.format.*
import std.collection.*
import QRCode4cj.tools.UTF32String

main(): Int64 {
    let tester = PerspectiveTransformTestCase()
    let test = tester.asTestSuite().runTests()
    test.failedCount + test.errorCount
}

@Test
public class PerspectiveTransformTestCase {
    private static let EPSILON: Float64 = 1.0E-4f64;

    @TestCase
    public func testSquareToQuadrilateral(): Unit {
        let pt: PerspectiveTransform = PerspectiveTransform.squareToQuadrilateral(
            2.0,
            3.0,
            10.0,
            4.0,
            16.0,
            15.0,
            4.0,
            9.0
        );
        assertPointEquals(2.0, 3.0, 0.0, 0.0, pt);
        assertPointEquals(10.0, 4.0, 1.0, 0.0, pt);
        assertPointEquals(4.0, 9.0, 0.0, 1.0, pt);
        assertPointEquals(16.0, 15.0, 1.0, 1.0, pt);
        assertPointEquals(6.535211, 6.8873234, 0.5, 0.5, pt);
        assertPointEquals(48.0, 42.42857, 1.5, 1.5, pt);
    }

    @TestCase
    public func testQuadrilateralToQuadrilateral(): Unit {
        let pt: PerspectiveTransform = PerspectiveTransform.quadrilateralToQuadrilateral(
            2.0,
            3.0,
            10.0,
            4.0,
            16.0,
            15.0,
            4.0,
            9.0,
            103.0,
            110.0,
            300.0,
            120.0,
            290.0,
            270.0,
            150.0,
            280.0
        );
        assertPointEquals(103.0, 110.0, 2.0, 3.0, pt);
        assertPointEquals(300.0, 120.0, 10.0, 4.0, pt);
        assertPointEquals(290.0, 270.0, 16.0, 15.0, pt);
        assertPointEquals(150.0, 280.0, 4.0, 9.0, pt);
        assertPointEquals(7.1516876, -64.60185, 0.5, 0.5, pt);
        assertPointEquals(328.09116, 334.16385, 50.0, 50.0, pt);
    }

    private static func assertPointEquals(
        expectedX: Float64,
        expectedY: Float64,
        sourceX: Float64,
        sourceY: Float64,
        pt: PerspectiveTransform
    ) {
        let points: Array<Float64> = [sourceX, sourceY]
        pt.transformPoints(points);

        let delta: Float64 = 0.0001
        let isEqualX: Bool = abs(expectedX - points[0]) < delta
        let isEqualY: Bool = abs(expectedY - points[1]) < delta
        @Assert( isEqualX && isEqualY)
    }
}
